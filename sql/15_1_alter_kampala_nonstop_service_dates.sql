-- Kampala Nonstop / Africa Nonstop - date-only service occurrences and expiry
-- Run once after schemas 10, 11, 12 and 13, before the revised Magma insert 16.
-- Also run pricing schema 14 and pricing enhancements 15 before insert 16.
-- This is an additional 15_ migration, not a replacement for pricing enhancements.
-- No business dates/prices are invented or inserted by this schema migration.
-- Existing Event end dates remain INCLUSIVE; no existing occurrence is rewritten.
-- New accommodation occurrences may use EXCLUSIVE checkout dates.
-- Exact timestamps, existing foreign keys and option/occurrence rules are retained.
-- Sales windows and price validity are not added/required for fixed Magma prices.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';

DO $preflight$
DECLARE r record; actual text;
BEGIN
 FOR r IN SELECT * FROM (VALUES
  ('listing_occurrences','schedule_precision','varchar'),
  ('listing_occurrences','starts_on','date'),
  ('listing_occurrences','ends_on','date'),
  ('listing_occurrences','starts_at','timestamptz'),
  ('listing_occurrences','ends_at','timestamptz'),
  ('listings','listing_type_id','uuid'),
  ('listing_types','code','varchar'),
  ('events','listing_id','uuid'),
  ('event_occurrence_details','occurrence_id','uuid')
 ) AS d(tbl,col,typ) LOOP
  SELECT udt_name INTO actual FROM information_schema.columns
   WHERE table_schema='public' AND table_name=r.tbl AND column_name=r.col;
  IF actual IS DISTINCT FROM r.typ THEN
   RAISE EXCEPTION 'Expected public.%.% type %, found %',r.tbl,r.col,r.typ,coalesce(actual,'missing');
  END IF;
 END LOOP;
 IF to_regprocedure('public.kns_event_check_occurrence()') IS NULL THEN
  RAISE EXCEPTION 'Expected Event occurrence validation function from schema 12';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='listing_occurrences'::regclass
   AND tgname='trg_event_check_occurrence' AND NOT tgisinternal
   AND tgfoid='kns_event_check_occurrence()'::regprocedure) THEN
  RAISE EXCEPTION 'Expected schema 12 occurrence validation trigger';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND ((table_name='listing_occurrences' AND column_name IN ('end_date_basis','time_zone'))
     OR (table_name='listings' AND column_name='expires_at'))) THEN
  RAISE EXCEPTION 'Service date/expiry columns already exist; inspect applied migrations rather than rerunning';
 END IF;
END
$preflight$;

ALTER TABLE listing_occurrences
 ADD COLUMN end_date_basis varchar(20) NOT NULL DEFAULT 'INCLUSIVE',
 ADD COLUMN time_zone text,
 ADD CONSTRAINT ck_occurrence_end_date_basis CHECK(end_date_basis IN ('INCLUSIVE','EXCLUSIVE')),
 ADD CONSTRAINT ck_occurrence_exclusive_date_end CHECK(
  end_date_basis <> 'EXCLUSIVE'
  OR (schedule_precision='DATE_ONLY' AND ends_on > starts_on)),
 ADD CONSTRAINT ck_occurrence_date_service_zone CHECK(
  time_zone IS NULL OR btrim(time_zone) <> '');

COMMENT ON COLUMN listing_occurrences.starts_on IS
 'Inclusive local start/service/check-in date for DATE_ONLY. Does not invent a check-in clock time.';
COMMENT ON COLUMN listing_occurrences.ends_on IS
 'Local end date interpreted with end_date_basis: INCLUSIVE last service day, EXCLUSIVE checkout/end boundary.';
COMMENT ON COLUMN listing_occurrences.end_date_basis IS
 'INCLUSIVE preserves existing Event dates; EXCLUSIVE excludes checkout from occupied nights. Exclusive end must follow start.';
COMMENT ON COLUMN listing_occurrences.time_zone IS
 'IANA timezone for date-only service dates. Required for non-Event DATE_ONLY occurrences; optional for legacy Events/exact timestamps.';
COMMENT ON COLUMN listing_occurrences.schedule_precision IS
 'EXACT_TIME or DATE_ONLY. Date-only supported for EVENT, EXPERIENCE, SERVICE, TOUR and ACTIVITY listings.';

-- Retain the Event validator name so its existing trigger keeps calling it.
CREATE OR REPLACE FUNCTION kns_event_check_occurrence()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE listing_type text;
BEGIN
 IF NEW.time_zone IS NOT NULL AND NOT EXISTS(
  SELECT 1 FROM pg_timezone_names WHERE name=NEW.time_zone) THEN
  RAISE EXCEPTION 'Unknown IANA time zone: %',NEW.time_zone USING ERRCODE='23514';
 END IF;
 IF NEW.schedule_precision='DATE_ONLY' THEN
  PERFORM 1 FROM listings WHERE id=NEW.listing_id FOR UPDATE;
  SELECT upper(t.code) INTO listing_type FROM listings l
   JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.listing_id;
  IF listing_type IS NULL OR listing_type NOT IN ('EVENT','EXPERIENCE','SERVICE','TOUR','ACTIVITY') THEN
   RAISE EXCEPTION 'DATE_ONLY is not supported for listing type %',coalesce(listing_type,'missing') USING ERRCODE='23514';
  END IF;
  IF listing_type='EVENT' THEN
   PERFORM 1 FROM events WHERE listing_id=NEW.listing_id FOR KEY SHARE;
   IF NOT FOUND THEN RAISE EXCEPTION 'Event DATE_ONLY requires an Event subtype; create it first' USING ERRCODE='23514'; END IF;
   IF NEW.end_date_basis <> 'INCLUSIVE' THEN
    RAISE EXCEPTION 'Event DATE_ONLY end dates must remain INCLUSIVE' USING ERRCODE='23514';
   END IF;
  ELSIF NEW.time_zone IS NULL THEN
   RAISE EXCEPTION 'Date-only service occurrences require an explicit time_zone' USING ERRCODE='23514';
  END IF;
 END IF;
 -- Preserve schema 12's existing entry-time validation.
 IF EXISTS(SELECT 1 FROM event_occurrence_details d WHERE d.occurrence_id=NEW.id
  AND NEW.ends_at IS NOT NULL AND (d.doors_open_at > NEW.ends_at OR d.last_entry_at > NEW.ends_at)) THEN
  RAISE EXCEPTION 'Occurrence end precedes its doors-open or last-entry time' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END
$fn$;

-- Prevent retyping a date-only listing into an unsupported type or an Event
-- with incompatible date semantics. Existing subtype guards continue to apply.
CREATE FUNCTION kns15_guard_date_only_listing_type()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE next_type text;
BEGIN
 IF NEW.listing_type_id IS DISTINCT FROM OLD.listing_type_id AND EXISTS(
  SELECT 1 FROM listing_occurrences WHERE listing_id=OLD.id AND schedule_precision='DATE_ONLY') THEN
  SELECT upper(code) INTO next_type FROM listing_types WHERE id=NEW.listing_type_id;
  IF next_type IS NULL OR next_type NOT IN ('EVENT','EXPERIENCE','SERVICE','TOUR','ACTIVITY') THEN
   RAISE EXCEPTION 'Listing has date-only service occurrences; remove/reconcile them before retyping' USING ERRCODE='23514';
  END IF;
  IF next_type='EVENT' AND (NOT EXISTS(SELECT 1 FROM events WHERE listing_id=OLD.id)
   OR EXISTS(SELECT 1 FROM listing_occurrences WHERE listing_id=OLD.id
       AND schedule_precision='DATE_ONLY' AND end_date_basis<>'INCLUSIVE')) THEN
   RAISE EXCEPTION 'Date-only Event requires an Event subtype and inclusive dates' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_kns15_date_only_listing_type
 BEFORE UPDATE OF listing_type_id ON listings
 FOR EACH ROW EXECUTE FUNCTION kns15_guard_date_only_listing_type();

CREATE FUNCTION kns15_guard_used_listing_type_code()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS(
  SELECT 1 FROM listings l JOIN listing_occurrences o ON o.listing_id=l.id
  WHERE l.listing_type_id=OLD.id AND o.schedule_precision='DATE_ONLY') THEN
  RAISE EXCEPTION 'Listing type code is used by date-only occurrences; its identity cannot change' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_kns15_used_listing_type_code
 BEFORE UPDATE OF code ON listing_types
 FOR EACH ROW EXECUTE FUNCTION kns15_guard_used_listing_type_code();

-- One optional absolute cutoff avoids coupling expiry to Event/service dates.
ALTER TABLE listings ADD COLUMN expires_at timestamptz;
COMMENT ON COLUMN listings.expires_at IS
 'Exclusive cutoff for discovery/new requests. NULL means no automatic expiry. Application must enforce current_timestamp < expires_at; do not delete historical records.';
CREATE INDEX ix_listings_expires_at ON listings(expires_at) WHERE expires_at IS NOT NULL;

COMMIT;

-- Magma data mapping for the revised insert 16 (not executed by this migration):
-- Festival: DATE_ONLY, starts_on 2026-11-19, ends_on 2026-11-22,
--           end_date_basis INCLUSIVE, time_zone Africa/Kampala.
-- P01/P02/P03: DATE_ONLY, starts_on 2026-11-19, ends_on 2026-11-23,
--             end_date_basis EXCLUSIVE, time_zone Africa/Kampala (4 nights).
-- Generic accommodation listings can still accept other dates; do not restrict
-- every component to these festival package dates automatically.
-- A confirmed extra night on 23 Nov ends on 24 Nov; use the quoted/requested
-- service dates for that booking, not the original package's default checkout.
-- Packages expire at TIMESTAMPTZ '2026-11-24 00:00:00 Africa/Kampala'.
-- Both catalogue lookup AND the server-side booking-request endpoint must apply:
--    expires_at IS NULL OR CURRENT_TIMESTAMP < expires_at
-- is_live is still a separate publication control; no clock-driven DB trigger
-- or cron job is required when all reads/requests enforce this predicate.
-- Exact pickup/check-in/checkout times remain unknown until supplier confirmation.
