-- Kampala Nonstop / Africa Nonstop - Tour-associated shared reference seed
-- File 13_1. Run after schema 13 and existing shared reference seeds.
-- Tour runtime modes are CHECK-constrained codes; they are NOT lookup rows.
-- Reuse existing classification/resource roles; no fictional tours or guide pools.
-- Adds two generic booking-input definitions for Tour request forms.
-- Repeatable: preserves existing IDs, labels, descriptions and disabled state.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';
LOCK TABLE booking_information_fields IN SHARE ROW EXCLUSIVE MODE;
DO $$ BEGIN
 IF to_regclass('public.tours') IS NULL THEN RAISE EXCEPTION 'Apply schema 13 first'; END IF;
 IF NOT EXISTS(SELECT 1 FROM listing_types WHERE code='TOUR') THEN RAISE EXCEPTION 'Existing TOUR listing type is required'; END IF;
 IF EXISTS(SELECT 1 FROM booking_information_fields WHERE (code='REQUESTED_START_DATE' AND data_type<>'DATE') OR (code='PARTICIPANT_COUNT' AND data_type<>'INTEGER')) THEN
  RAISE EXCEPTION 'Existing input code has an incompatible datatype; do not overwrite its meaning';
 END IF;
END $$;
INSERT INTO booking_information_fields(id,code,name,data_type,description,is_live,created_by,updated_by) VALUES
 ('63bc9045-4d65-5781-bd59-ff1ea9ccde8b','REQUESTED_START_DATE','Requested start date','DATE','Requested local start date for a date-selectable offer. Actual departure time and timezone are resolved at booking; not a listing itinerary date.',TRUE,'SYSTEM','SYSTEM'),
 ('e93618f0-a842-5b42-b639-52b0b73f386f','PARTICIPANT_COUNT','Participant count','INTEGER','Number of participating customers in this booking party; excludes delivering staff. Positivity and effective offer limits are validated at booking.',TRUE,'SYSTEM','SYSTEM')
ON CONFLICT(code) DO NOTHING;
COMMIT;
