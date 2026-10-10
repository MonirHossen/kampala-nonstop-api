-- Kampala Nonstop / Africa Nonstop - Services reference seed
-- File 11_1: run AFTER 11_kampala_nonstop_services_schema.sql and shared listing /
-- Experience reference seeds. This seed is repeatable and preserves existing IDs,
-- labels, descriptions and disabled states. Conflicting code/data-type meanings fail.
-- Seed scope: booking input definitions + PER_ALLOCATED_UNIT quantity basis.
-- Runtime mode CHECK values are defined in 11, not duplicated as unlinked lookup rows.
-- No Service listings, classifications, suppliers, prices or legal documents seeded.
-- SERVICE/EXPERIENCE/EVENT listing types must come from the existing shared reference
-- model. This file validates those dependencies rather than inventing a second taxonomy.
-- Structured ADDRESS/FLIGHT_DETAILS fields require API/UI implementation; reference
-- existence alone is not evidence that a renderer or flight lookup is implemented.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';
DO $$
BEGIN
 IF to_regclass('public.booking_information_fields') IS NULL THEN RAISE EXCEPTION 'Run schema file 11 first'; END IF;
 IF NOT EXISTS(SELECT 1 FROM listing_types WHERE code='SERVICE') THEN RAISE EXCEPTION 'Missing shared listing_types SERVICE code; apply the approved shared reference seed first'; END IF;
 IF NOT EXISTS(SELECT 1 FROM experience_quantity_bases WHERE code='PER_BOOKING')
 OR NOT EXISTS(SELECT 1 FROM experience_quantity_bases WHERE code='PER_PARTICIPANT') THEN
  RAISE EXCEPTION 'Missing existing Experience quantity-basis seed; apply 10_1 first';
 END IF;
END $$;
LOCK TABLE booking_information_fields, experience_quantity_bases IN SHARE ROW EXCLUSIVE MODE;

DO $meaning$
DECLARE r record; existing_type text;
BEGIN
 FOR r IN SELECT * FROM (VALUES
  ('CHECK_IN_DATE','DATE'),
  ('CHECK_OUT_DATE','DATE'),
  ('GUEST_COUNT','INTEGER'),
  ('ROOM_PREFERENCES','TEXT'),
  ('APPOINTMENT_TIME','DATETIME'),
  ('PICKUP_TIME','DATETIME'),
  ('PICKUP_ADDRESS','ADDRESS'),
  ('DROPOFF_ADDRESS','ADDRESS'),
  ('SERVICE_ADDRESS','ADDRESS'),
  ('FLIGHT_DETAILS','FLIGHT_DETAILS'),
  ('FLIGHT_NUMBER','TEXT'),
  ('FLIGHT_DATE','DATE'),
  ('PASSENGER_COUNT','INTEGER'),
  ('CHECKED_BAG_COUNT','INTEGER'),
  ('CABIN_BAG_COUNT','INTEGER'),
  ('ACCESSIBILITY_NEEDS','TEXT'),
  ('REQUESTED_TASKS','TEXT'),
  ('SERVICE_START_AT','DATETIME'),
  ('SERVICE_END_AT','DATETIME'),
  ('QUANTITY','INTEGER'),
  ('PREPARATION_INFORMATION','TEXT')
 ) AS expected(code,data_type) LOOP
  SELECT data_type INTO existing_type FROM booking_information_fields WHERE code=r.code;
  IF FOUND AND existing_type IS DISTINCT FROM r.data_type THEN
   RAISE EXCEPTION 'Booking information field % already has type %, expected %',r.code,existing_type,r.data_type;
  END IF;
 END LOOP;
END $meaning$;
INSERT INTO booking_information_fields(id,code,name,data_type,description,is_live,created_by,updated_by) VALUES
 ('a95ba9fd-829a-53e0-8165-95f3e86286df','CHECK_IN_DATE','Check-in date','DATE','Requested first accommodation night; mode-required for a stay.',TRUE,'SYSTEM','SYSTEM'),
 ('2dd15759-a5fd-58e9-a9d7-b44dc9614962','CHECK_OUT_DATE','Checkout date','DATE','Checkout-exclusive end date; mode-required for a stay.',TRUE,'SYSTEM','SYSTEM'),
 ('f1028ee2-0c3e-5ff2-b349-5bd95b8a1710','GUEST_COUNT','Guest count','INTEGER','Total guests; validate actual allocations and occupancy separately.',TRUE,'SYSTEM','SYSTEM'),
 ('1794125b-b402-5f4d-b133-f6ac42c002b6','ROOM_PREFERENCES','Room preferences','TEXT','Requested room preferences, not confirmed allocation.',TRUE,'SYSTEM','SYSTEM'),
 ('ccbe9f91-12d7-5e23-a205-4a1c38bfafc6','APPOINTMENT_TIME','Preferred appointment time','DATETIME','Requested appointment with an explicit offset/time zone.',TRUE,'SYSTEM','SYSTEM'),
 ('3a30ffe7-530e-562c-916b-733d77755352','PICKUP_TIME','Pickup time','DATETIME','Actual requested pickup datetime for an applicable journey leg.',TRUE,'SYSTEM','SYSTEM'),
 ('e68b1426-e580-5324-a501-717bc7cd814e','PICKUP_ADDRESS','Pickup address','ADDRESS','Structured customer pickup address, validated against coverage.',TRUE,'SYSTEM','SYSTEM'),
 ('522fc9e5-17a6-5a80-8af4-1ee5e7af1519','DROPOFF_ADDRESS','Drop-off address','ADDRESS','Structured customer destination address, validated against coverage.',TRUE,'SYSTEM','SYSTEM'),
 ('d4f0af4e-8147-505d-bfa3-9cd74a890a74','SERVICE_ADDRESS','Service address','ADDRESS','Where a customer-location Service is requested.',TRUE,'SYSTEM','SYSTEM'),
 ('5d108d2f-18eb-5d3f-acbf-89b322e78b85','FLIGHT_DETAILS','Flight details','FLIGHT_DETAILS','Flight identifier, date, airport and relevant leg context; booking input only.',TRUE,'SYSTEM','SYSTEM'),
 ('c2f97d9d-6d02-54fa-801e-449f575e95e1','FLIGHT_NUMBER','Flight number','TEXT','Flight number alone where a simpler input is supported.',TRUE,'SYSTEM','SYSTEM'),
 ('2c9f9365-2ba3-544a-bc40-b75b79fb172a','FLIGHT_DATE','Flight date','DATE','Date used to identify the requested flight.',TRUE,'SYSTEM','SYSTEM'),
 ('f12f9484-783e-58d7-beb9-67fbb5827f04','PASSENGER_COUNT','Passenger count','INTEGER','Travelling passengers excluding the driver.',TRUE,'SYSTEM','SYSTEM'),
 ('9ef08181-679d-5b0d-93d2-4ac60c8a431d','CHECKED_BAG_COUNT','Checked bag count','INTEGER','Checked bags of the documented standard size.',TRUE,'SYSTEM','SYSTEM'),
 ('63d99db6-8986-5c35-9ef9-469b68c5b66c','CABIN_BAG_COUNT','Cabin bag count','INTEGER','Cabin bags of the documented standard size.',TRUE,'SYSTEM','SYSTEM'),
 ('4437a16f-3bf4-5d09-bde2-16006580e735','ACCESSIBILITY_NEEDS','Accessibility and support needs','TEXT','Customer requested support; structured matching capabilities remain resource facts.',TRUE,'SYSTEM','SYSTEM'),
 ('0c9562b8-3e5b-5e17-83f3-9770f5315089','REQUESTED_TASKS','Requested tasks','TEXT','Scope requested for a concierge or other assistance Service.',TRUE,'SYSTEM','SYSTEM'),
 ('f0b8c42f-84b0-54cf-949a-36f0a04148e6','SERVICE_START_AT','Service start','DATETIME','Actual requested start datetime; not a reusable listing date.',TRUE,'SYSTEM','SYSTEM'),
 ('94b485a6-6b61-5e01-a93f-3b1bcc55dddb','SERVICE_END_AT','Service end','DATETIME','Requested end datetime; validate against start and duration rules.',TRUE,'SYSTEM','SYSTEM'),
 ('a513fb26-1182-5182-9827-f0d8aa9a84d2','QUANTITY','Requested quantity','INTEGER','Quantity requested in the offer-defined unit.',TRUE,'SYSTEM','SYSTEM'),
 ('192aac89-3494-5663-b1eb-6fca2678d0be','PREPARATION_INFORMATION','Preparation information','TEXT','Information requested for preparation; not a substitute for document evidence.',TRUE,'SYSTEM','SYSTEM')
ON CONFLICT (code) DO NOTHING;
INSERT INTO experience_quantity_bases(id,code,name,description,is_live,created_by,updated_by) VALUES ('221dcdde-2d8d-5823-b38c-6918a3a8e326','PER_ALLOCATED_UNIT','Per allocated Unit','Multiply by the actual allocated Unit count from the explicit quantity anchor; never assume one Unit per booking.',TRUE,'SYSTEM','SYSTEM') ON CONFLICT (code) DO NOTHING;
COMMIT;
