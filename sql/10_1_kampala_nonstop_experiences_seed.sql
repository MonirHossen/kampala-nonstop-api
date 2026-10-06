-- Kampala Nonstop: controlled vocabularies for Experience composition/scheduling
-- Run AFTER 10_kampala_nonstop_experiences_schema.sql. Safe to run repeatedly.
-- Seeds actual supported configuration values only. No fabricated listings,
-- providers, departures or dates are inserted into your catalogue.
-- Existing code IDs are preserved; changed labels/descriptions are updated.
-- No EXPERIENCE listing_type is inserted: that existing reference must already
-- be present. Its unknown schema/required fields are not guessed here.
BEGIN;
SET LOCAL search_path = public, pg_catalog;

INSERT INTO experience_schedule_modes (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('d3cd5c0b-7db1-5526-b0ba-37225fdb99e0', 'FLEXIBLE_START', 'Flexible start', 'Start chosen during the booking request.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('51f25227-e0f7-5aa8-aa19-74a87ddc20ca', 'FIXED_START', 'Scheduled departure', 'Select an actual occurrence of the Experience.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('98eaa6a3-44f1-50fa-a3b5-1cbcccaf0fed', 'COMPONENT_ANCHORED', 'Component anchored', 'An occurrence of a component anchors the itinerary.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (experience_schedule_modes.name,experience_schedule_modes.description,experience_schedule_modes.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

INSERT INTO experience_price_inclusions (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('38599a2c-8bbf-58ba-af20-ac65837d696e', 'PACKAGE_QUOTE', 'Package quote', 'Component charges covered by the final package quote; not a fixed advertised price.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('5862eb38-f164-59a5-934c-dce91c02e6a0', 'PAY_DIRECT', 'Pay direct', 'Customer pays provider separately; disclose amount or calculation basis.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (experience_price_inclusions.name,experience_price_inclusions.description,experience_price_inclusions.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

INSERT INTO experience_quantity_bases (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('c4ef7ec4-cb45-5732-a8c7-6fe818cd13ad', 'PER_BOOKING', 'Per booking', 'Multiply quantity once per booking.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('a2c897c4-36f8-5d85-9412-1c13a3093696', 'PER_PARTICIPANT', 'Per participant', 'Multiply quantity by applicable participant count.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (experience_quantity_bases.name,experience_quantity_bases.description,experience_quantity_bases.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

INSERT INTO experience_timing_modes (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('b56df710-5440-5a13-a0cc-db0655a68370', 'UNSCHEDULED', 'Unscheduled', 'Timing unresolved in draft or confirmed by concierge.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('429bca00-7eba-59f5-8561-afb9a0a9161a', 'EXPERIENCE_OFFSET', 'Experience offset', 'Start relative to Experience start.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('19f0d918-1ae2-5156-bf43-4f4d0647286b', 'FIXED_START', 'Fixed start', 'One fixed timestamp for this component.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('f5b76b9b-812e-5b71-a619-363bbf284d9a', 'DEPENDENCY', 'Dependency', 'Timing calculated from component dependencies.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('00b54673-3dc9-51e1-b502-3c39e26e119b', 'OCCURRENCE', 'Selected occurrence', 'Timing supplied by selected child occurrence.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (experience_timing_modes.name,experience_timing_modes.description,experience_timing_modes.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

INSERT INTO experience_dependency_types (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('9ba4433c-1e9f-5ac6-8f11-a3e9d2e3c147', 'START_AFTER_END', 'Start after end', 'Constrained component starts after related component ends.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('da6ecfc4-d933-5e15-b905-8a1878ceb7c9', 'END_BEFORE_START', 'End before start', 'Constrained component ends before related component starts.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (experience_dependency_types.name,experience_dependency_types.description,experience_dependency_types.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

INSERT INTO listing_occurrence_statuses (id,code,name,description,is_live,created_by,updated_by) VALUES
 ('442b52fd-f0fc-5b06-adfc-52f6620729b3', 'SCHEDULED', 'Scheduled', 'Planned occurrence; does not guarantee inventory.', TRUE, 'SYSTEM', 'SYSTEM'),
 ('082b8dfd-06b0-5b35-8911-b00d9e876eb5', 'CANCELLED', 'Cancelled', 'Not selectable for new booking requests.', TRUE, 'SYSTEM', 'SYSTEM')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, description=EXCLUDED.description,
 is_live=EXCLUDED.is_live, updated_by='SYSTEM'
WHERE (listing_occurrence_statuses.name,listing_occurrence_statuses.description,listing_occurrence_statuses.is_live)
 IS DISTINCT FROM (EXCLUDED.name,EXCLUDED.description,EXCLUDED.is_live);

COMMIT;
