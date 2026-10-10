-- Kampala Nonstop / Africa Nonstop - Events and associated details
-- File 12. PostgreSQL 13+. Run ONCE after 9/resources, 10/Experiences,
-- and 11/Services; then run 12_1_kampala_nonstop_events_reference_seed.sql.
-- Five business tables (including optional-use event_series), four references.
-- Reuses listing_event_associations; no duplicate package/Event link table.
-- No Event, provider, venue, package, price or ticket business data is seeded.
-- Transactional: incompatible dependencies or an already-applied migration fail.
-- IMPORTANT shared change: listing_occurrences.starts_at becomes nullable ONLY
-- for explicitly DATE_ONLY Event occurrences. Existing exact timestamps remain.
-- New starts_on/ends_on are inclusive local calendar dates. Exact-time legacy
-- occurrences may leave both null: do not infer local dates from session timezone.
-- Resolve country timezone in the application, as in files 10 and 11.
-- is_bookable: existing column is preserved when compatible. If absent, old rows
-- remain NULL (unreviewed); newly inserted rows default FALSE. Preserve current
-- catalogue behaviour for legacy NULL until reviewed. Never equate NULL to FALSE
-- in a blanket catalogue filter without migrating existing commercial listings.
-- Neither is_live nor is_bookable constitutes admission, inventory or ticket stock.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';

DO $preflight$
DECLARE r record; actual text;
BEGIN
 IF current_setting('server_version_num')::int < 130000 THEN
  RAISE EXCEPTION 'Events schema requires PostgreSQL 13+';
 END IF;
 FOR r IN SELECT * FROM (VALUES
 ('listings','id','uuid'), ('listings','listing_type_id','uuid'),
 ('listing_types','id','uuid'), ('listing_types','code','varchar'),
 ('organisations','resource_id','uuid'), ('places','resource_id','uuid'),
 ('listing_occurrences','id','uuid'), ('listing_occurrences','listing_id','uuid'),
 ('listing_occurrences','listing_option_id','uuid'),
 ('listing_occurrences','departure_rule_id','uuid'),
 ('listing_occurrences','generated_for_date','date'),
 ('listing_occurrences','starts_at','timestamptz'),
 ('listing_occurrences','ends_at','timestamptz'),
 ('listing_event_associations','event_listing_id','uuid')
 ) AS d(tbl,col,typ) LOOP
  SELECT udt_name INTO actual FROM information_schema.columns
   WHERE table_schema='public' AND table_name=r.tbl AND column_name=r.col;
  IF actual IS DISTINCT FROM r.typ THEN
   RAISE EXCEPTION 'Expected public.%.% type %, found %',r.tbl,r.col,r.typ,coalesce(actual,'missing');
  END IF;
 END LOOP;
 FOR r IN SELECT unnest(ARRAY['events','event_series','event_organisations',
 'event_occurrence_details','event_occurrence_places','event_admission_requirements',
 'event_attendance_modes','event_organisation_roles','event_place_roles']) AS tbl LOOP
  IF to_regclass('public.'||r.tbl) IS NOT NULL THEN
   RAISE EXCEPTION 'Target table % already exists: inspect migration history',r.tbl;
  END IF;
 END LOOP;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
  AND table_name='listing_occurrences' AND column_name IN ('starts_on','ends_on','schedule_precision')) THEN
  RAISE EXCEPTION 'Occurrence date extension already exists: inspect its definition';
 END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
  AND table_name='listings' AND column_name='is_bookable' AND udt_name <> 'bool') THEN
  RAISE EXCEPTION 'Existing listings.is_bookable must be boolean';
 END IF;
END $preflight$;

CREATE TABLE event_admission_requirements (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 code varchar(30) NOT NULL UNIQUE CHECK(code IN ('UNKNOWN','FREE','TICKET_REQUIRED','REGISTRATION_REQUIRED')),
 name varchar(100) NOT NULL CHECK(btrim(name) <> ''),
 description text,
 is_live boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
COMMENT ON TABLE event_admission_requirements IS 'System-supported reference codes; seeded by file 12_1. Labels are editable; codes are immutable.';

CREATE TABLE event_attendance_modes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 code varchar(30) NOT NULL UNIQUE CHECK(code IN ('IN_PERSON','ONLINE','HYBRID')),
 name varchar(100) NOT NULL CHECK(btrim(name) <> ''),
 description text,
 is_live boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
COMMENT ON TABLE event_attendance_modes IS 'System-supported reference codes; seeded by file 12_1. Labels are editable; codes are immutable.';

CREATE TABLE event_organisation_roles (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 code varchar(30) NOT NULL UNIQUE CHECK(code IN ('ORGANISER','CO_ORGANISER','HOST','SPONSOR')),
 name varchar(100) NOT NULL CHECK(btrim(name) <> ''),
 description text,
 is_live boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
COMMENT ON TABLE event_organisation_roles IS 'System-supported reference codes; seeded by file 12_1. Labels are editable; codes are immutable.';

CREATE TABLE event_place_roles (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 code varchar(30) NOT NULL UNIQUE CHECK(code IN ('MAIN_VENUE','ADDITIONAL_VENUE','ENTRY_POINT','MEETING_POINT')),
 name varchar(100) NOT NULL CHECK(btrim(name) <> ''),
 description text,
 is_live boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
COMMENT ON TABLE event_place_roles IS 'System-supported reference codes; seeded by file 12_1. Labels are editable; codes are immutable.';

CREATE TABLE event_series (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name varchar(255) NOT NULL CHECK(btrim(name) <> ''),
 slug varchar(255) NOT NULL UNIQUE CHECK(slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
 description text,
 official_website_url text CHECK(official_website_url IS NULL OR official_website_url ~ '^https?://[^[:space:]]+$'),
 is_live boolean NOT NULL DEFAULT FALSE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
CREATE TABLE events (
 listing_id uuid PRIMARY KEY REFERENCES listings(id) ON DELETE CASCADE ON UPDATE RESTRICT,
 event_series_id uuid REFERENCES event_series(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 official_website_url text CHECK(official_website_url IS NULL OR official_website_url ~ '^https?://[^[:space:]]+$'),
 admission_requirement varchar(30) NOT NULL DEFAULT 'UNKNOWN'
  REFERENCES event_admission_requirements(code) ON DELETE RESTRICT ON UPDATE RESTRICT,
 admission_information text,
 official_ticket_url text CHECK(official_ticket_url IS NULL OR official_ticket_url ~ '^https?://[^[:space:]]+$'),
 attendance_mode varchar(30) NOT NULL DEFAULT 'IN_PERSON'
  REFERENCES event_attendance_modes(code) ON DELETE RESTRICT ON UPDATE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM'
);
CREATE INDEX ix_events_series ON events(event_series_id);
CREATE INDEX ix_events_admission ON events(admission_requirement);
CREATE INDEX ix_events_attendance ON events(attendance_mode);
COMMENT ON TABLE events IS 'One EVENT subtype per Listing; admission requirement is independent of KNS bookability. Shared visibility is listings.is_live.';

CREATE TABLE event_organisations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 event_listing_id uuid NOT NULL REFERENCES events(listing_id) ON DELETE CASCADE ON UPDATE RESTRICT,
 organisation_resource_id uuid NOT NULL REFERENCES organisations(resource_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 role_code varchar(30) NOT NULL REFERENCES event_organisation_roles(code) ON DELETE RESTRICT ON UPDATE RESTRICT,
 is_primary boolean NOT NULL DEFAULT FALSE,
 is_public boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 UNIQUE(event_listing_id,organisation_resource_id,role_code)
);
CREATE UNIQUE INDEX uq_event_organisation_primary ON event_organisations(event_listing_id,role_code) WHERE is_primary;
CREATE INDEX ix_event_organisations_resource ON event_organisations(organisation_resource_id);
CREATE INDEX ix_event_organisations_role ON event_organisations(role_code);

CREATE TABLE event_occurrence_details (
 occurrence_id uuid PRIMARY KEY,
 event_listing_id uuid NOT NULL REFERENCES events(listing_id) ON DELETE CASCADE ON UPDATE RESTRICT,
 doors_open_at timestamptz,
 last_entry_at timestamptz,
 arrival_instructions text,
 accessibility_information text,
 online_join_url text CHECK(online_join_url IS NULL OR online_join_url ~ '^https?://[^[:space:]]+$'),
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 FOREIGN KEY(occurrence_id,event_listing_id) REFERENCES listing_occurrences(id,listing_id)
  ON DELETE CASCADE ON UPDATE RESTRICT,
 CHECK(last_entry_at IS NULL OR doors_open_at IS NULL OR last_entry_at >= doors_open_at)
);
CREATE INDEX ix_event_occurrence_details_event ON event_occurrence_details(event_listing_id);
COMMENT ON COLUMN event_occurrence_details.online_join_url IS 'Public joining information only; private access tokens belong in booking communications.';

CREATE TABLE event_occurrence_places (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 occurrence_id uuid NOT NULL REFERENCES event_occurrence_details(occurrence_id) ON DELETE CASCADE ON UPDATE RESTRICT,
 place_resource_id uuid NOT NULL REFERENCES places(resource_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 role_code varchar(30) NOT NULL REFERENCES event_place_roles(code) ON DELETE RESTRICT ON UPDATE RESTRICT,
 is_primary boolean NOT NULL DEFAULT FALSE,
 instructions text,
 sort_order integer NOT NULL DEFAULT 0 CHECK(sort_order >= 0),
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 UNIQUE(occurrence_id,place_resource_id,role_code),
 CHECK(NOT is_primary OR role_code IN ('MAIN_VENUE','ADDITIONAL_VENUE'))
);
CREATE UNIQUE INDEX uq_event_occurrence_primary_venue ON event_occurrence_places(occurrence_id) WHERE is_primary;
CREATE INDEX ix_event_occurrence_places_place ON event_occurrence_places(place_resource_id);
CREATE INDEX ix_event_occurrence_places_role ON event_occurrence_places(role_code);

-- Preserve existing exact schedules, options, departure rules and status constraints.
ALTER TABLE listing_occurrences
 ADD COLUMN schedule_precision varchar(20) NOT NULL DEFAULT 'EXACT_TIME',
 ADD COLUMN starts_on date,
 ADD COLUMN ends_on date,
 ALTER COLUMN starts_at DROP NOT NULL,
 ADD CONSTRAINT ck_occurrence_schedule_precision CHECK(schedule_precision IN ('DATE_ONLY','EXACT_TIME')),
 ADD CONSTRAINT ck_occurrence_local_date_pair CHECK((starts_on IS NULL) = (ends_on IS NULL)),
 ADD CONSTRAINT ck_occurrence_local_date_order CHECK(ends_on IS NULL OR ends_on >= starts_on),
 ADD CONSTRAINT ck_occurrence_schedule_shape CHECK(
  (schedule_precision='EXACT_TIME' AND starts_at IS NOT NULL)
  OR (schedule_precision='DATE_ONLY' AND starts_on IS NOT NULL AND ends_on IS NOT NULL
      AND starts_at IS NULL AND ends_at IS NULL AND departure_rule_id IS NULL AND generated_for_date IS NULL));
-- Existing timestamp indexes still constrain exact occurrences. New indexes close
-- the null-timestamp duplicate gap for date-only occurrences, including options.
CREATE UNIQUE INDEX uq_event_date_only_base ON listing_occurrences(listing_id,starts_on)
 WHERE schedule_precision='DATE_ONLY' AND listing_option_id IS NULL;
CREATE UNIQUE INDEX uq_event_date_only_option ON listing_occurrences(listing_id,listing_option_id,starts_on)
 WHERE schedule_precision='DATE_ONLY' AND listing_option_id IS NOT NULL;
CREATE INDEX ix_occurrence_date_only_calendar ON listing_occurrences(starts_on,ends_on)
 WHERE schedule_precision='DATE_ONLY';
COMMENT ON COLUMN listing_occurrences.starts_on IS 'Inclusive first local date. Required for DATE_ONLY. Exact legacy rows may have null date fields.';
COMMENT ON COLUMN listing_occurrences.ends_on IS 'Inclusive last local date; not a checkout date and not a midnight timestamp.';
COMMENT ON COLUMN listing_occurrences.schedule_precision IS 'DATE_ONLY currently enabled for Event subtype listings only; other engines continue using EXACT_TIME.';

DO $bookability$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
  AND table_name='listings' AND column_name='is_bookable') THEN
  ALTER TABLE listings ADD COLUMN is_bookable boolean;
  ALTER TABLE listings ALTER COLUMN is_bookable SET DEFAULT FALSE;
  COMMENT ON COLUMN listings.is_bookable IS 'KNS can accept a booking request for this listing. Independent of publication and admission. Legacy NULL means pending review; retain prior catalogue behaviour until backfilled.';
 END IF;
END $bookability$;

CREATE FUNCTION kns_event_touch_audit() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 NEW.created_at := OLD.created_at;
 NEW.created_by := OLD.created_by;
 NEW.updated_at := CURRENT_TIMESTAMP;
 RETURN NEW;
END $fn$;

CREATE FUNCTION kns_event_check_type() RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE c text;
BEGIN
 IF TG_OP='UPDATE' AND NEW.listing_id <> OLD.listing_id THEN
  RAISE EXCEPTION 'Cannot move an Event subtype to another Listing' USING ERRCODE='23514';
 END IF;
 PERFORM 1 FROM listings WHERE id=NEW.listing_id FOR UPDATE;
 SELECT upper(t.code) INTO c FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.listing_id;
 IF c IS DISTINCT FROM 'EVENT' THEN
  RAISE EXCEPTION 'Event parent must be an EVENT Listing' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER trg_event_check_type BEFORE INSERT OR UPDATE ON events FOR EACH ROW EXECUTE FUNCTION kns_event_check_type();

CREATE FUNCTION kns_event_guard_listing_type() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 IF NEW.listing_type_id IS DISTINCT FROM OLD.listing_type_id
  AND EXISTS(SELECT 1 FROM events WHERE listing_id=OLD.id) THEN
  RAISE EXCEPTION 'Cannot change listing type while an Event subtype exists' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER trg_event_guard_listing_type BEFORE UPDATE OF listing_type_id ON listings
 FOR EACH ROW EXECUTE FUNCTION kns_event_guard_listing_type();

CREATE FUNCTION kns_event_guard_type_code() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 IF upper(OLD.code)='EVENT' AND NEW.code IS DISTINCT FROM OLD.code THEN
  RAISE EXCEPTION 'EVENT is a system-supported Listing type code; its identity cannot be changed' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER trg_event_guard_type_code BEFORE UPDATE OF code ON listing_types
 FOR EACH ROW EXECUTE FUNCTION kns_event_guard_type_code();

CREATE FUNCTION kns_event_check_occurrence() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 IF NEW.schedule_precision='DATE_ONLY' THEN
  PERFORM 1 FROM events WHERE listing_id=NEW.listing_id FOR KEY SHARE;
  IF NOT FOUND THEN
   RAISE EXCEPTION 'DATE_ONLY requires an Event subtype; create it first' USING ERRCODE='23514';
  END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM event_occurrence_details d WHERE d.occurrence_id=NEW.id
  AND NEW.ends_at IS NOT NULL AND (d.doors_open_at > NEW.ends_at OR d.last_entry_at > NEW.ends_at)) THEN
  RAISE EXCEPTION 'Occurrence end precedes its doors-open or last-entry time' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER trg_event_check_occurrence BEFORE INSERT OR UPDATE ON listing_occurrences
 FOR EACH ROW EXECUTE FUNCTION kns_event_check_occurrence();

CREATE FUNCTION kns_event_check_details() RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE occurrence_end timestamptz;
BEGIN
 IF TG_OP='UPDATE' AND (NEW.occurrence_id <> OLD.occurrence_id OR NEW.event_listing_id <> OLD.event_listing_id) THEN
  RAISE EXCEPTION 'Cannot move Event occurrence details between occurrences' USING ERRCODE='23514';
 END IF;
 SELECT ends_at INTO occurrence_end FROM listing_occurrences WHERE id=NEW.occurrence_id FOR UPDATE;
 IF occurrence_end IS NOT NULL AND (NEW.doors_open_at > occurrence_end OR NEW.last_entry_at > occurrence_end) THEN
  RAISE EXCEPTION 'Entry times cannot be after occurrence end' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER trg_event_check_details BEFORE INSERT OR UPDATE ON event_occurrence_details
 FOR EACH ROW EXECUTE FUNCTION kns_event_check_details();

CREATE FUNCTION kns_event_guard_delete() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 -- Normal Listing deletion is already restricted by shared association FKs.
 -- Explicit subtype deletion must not orphan date-only schedules or associations.
 IF EXISTS(SELECT 1 FROM listings WHERE id=OLD.listing_id) AND (
  EXISTS(SELECT 1 FROM listing_occurrences WHERE listing_id=OLD.listing_id AND schedule_precision='DATE_ONLY')
  OR EXISTS(SELECT 1 FROM listing_event_associations WHERE event_listing_id=OLD.listing_id)) THEN
  RAISE EXCEPTION 'Event is referenced by date-only schedules or associated offers; unpublish instead of deleting' USING ERRCODE='23503';
 END IF;
 RETURN OLD;
END $fn$;
CREATE TRIGGER trg_event_guard_delete BEFORE DELETE ON events FOR EACH ROW EXECUTE FUNCTION kns_event_guard_delete();

CREATE FUNCTION kns_event_guard_reference_code() RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code THEN
  RAISE EXCEPTION 'Reference codes are immutable; edit name/description or deactivate the row' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $fn$;

CREATE TRIGGER trg_event_admission_requirements_audit BEFORE UPDATE ON event_admission_requirements FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_attendance_modes_audit BEFORE UPDATE ON event_attendance_modes FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_organisation_roles_audit BEFORE UPDATE ON event_organisation_roles FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_place_roles_audit BEFORE UPDATE ON event_place_roles FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_series_audit BEFORE UPDATE ON event_series FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_events_audit BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_organisations_audit BEFORE UPDATE ON event_organisations FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_occurrence_details_audit BEFORE UPDATE ON event_occurrence_details FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_occurrence_places_audit BEFORE UPDATE ON event_occurrence_places FOR EACH ROW EXECUTE FUNCTION kns_event_touch_audit();
CREATE TRIGGER trg_event_admission_requirements_code BEFORE UPDATE OF code ON event_admission_requirements FOR EACH ROW EXECUTE FUNCTION kns_event_guard_reference_code();
CREATE TRIGGER trg_event_attendance_modes_code BEFORE UPDATE OF code ON event_attendance_modes FOR EACH ROW EXECUTE FUNCTION kns_event_guard_reference_code();
CREATE TRIGGER trg_event_organisation_roles_code BEFORE UPDATE OF code ON event_organisation_roles FOR EACH ROW EXECUTE FUNCTION kns_event_guard_reference_code();
CREATE TRIGGER trg_event_place_roles_code BEFORE UPDATE OF code ON event_place_roles FOR EACH ROW EXECUTE FUNCTION kns_event_guard_reference_code();

-- APPLICATION CONTRACT (not claimed to be enforced by the database):
-- 1. Apply seed 12_1 before inserting Event business records. Drafts may lack
--    organiser/venue details. Publication requires a complete Event occurrence.
-- 2. IN_PERSON/HYBRID publication needs a primary physical venue; ONLINE/HYBRID
--    needs joining guidance. Verify venue geography, resource capability and access.
-- 3. Compare dates/times in the resolved country zone, never the browser/session
--    zone. Exact starts_on/ends_on, when supplied, must match actual local dates.
--    Validate date-only gate times against the inclusive date range in that zone.
-- 4. Date-only Event association is contextual. Do not run timestamp arithmetic on
--    it or accept it as a timed Experience anchor/component. Resolve actual times
--    before scheduling a timed itinerary, shuttle or fulfilment commitment.
-- 5. Event occurrence end, accommodation checkout and transport service-day end
--    are independent. Linked offers can extend outside the festival date range.
-- 6. Event association never includes admission. Package inclusion/exclusion and
--    booking evidence explicitly identify any purchased admission entitlement.
-- 7. Existing listing_event_associations target EVENT Listing types under file 11;
--    require a populated events subtype before publishing the related offers.
--    Do not manufacture admissions or silently insert incomplete Event business rows.
-- 8. is_live controls publication; is_bookable controls KNS booking requests.
--    An external ticket URL alone does not make the Event bookable through KNS.
--    If is_bookable was newly added, review/backfill legacy NULL individually.
-- 9. Check duplicate Event identity by edition, organiser, venue and dates; slug
--    uniqueness alone cannot detect renamed duplicate festivals. Shared classification
--    references remain authoritative; no new parallel Event taxonomy is introduced.
-- 10. Event cancellation/rescheduling must flag associated offers and existing
--     requests for admin review; never automatically cancel unrelated services.
-- 11. API supplies authenticated audit actors, RBAC and optimistic concurrency;
--     map SQLSTATE 23503/23505/23514 and trigger messages to actionable UI errors.
-- 12. Reference is_live affects new choices, not historical display. Do not permit
--     unsupported codes. URLs are syntax-checked only: verify official destinations.
-- 13. Ticket products, inventory locks, issuance, redemption and booking transactions
--     are outside this migration. Do not treat this schema as a ticket sales engine.
COMMIT;
