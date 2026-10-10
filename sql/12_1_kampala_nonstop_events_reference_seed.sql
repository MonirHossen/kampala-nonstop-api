-- Kampala Nonstop / Africa Nonstop - Event reference seed
-- File 12_1. Run after 12_kampala_nonstop_events_schema.sql.
-- 15 system-supported reference rows. No Nyege Nyege/Magma business records.
-- Idempotent: existing rows matched by code are preserved, including admin labels
-- and is_live. Stable UUIDs are used on first insert; existing IDs are not replaced.
-- DATE_ONLY / EXACT_TIME are runtime CHECK codes, not seedable reference tables.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';

INSERT INTO event_admission_requirements (id,code,name,description) VALUES
 ('a6276358-535f-5ba9-8644-0aab58bd4a41','UNKNOWN','Not confirmed','Admission requirements have not been verified.'),
 ('8f17b706-1579-5bc1-aaed-03dc763fa60c','FREE','Free admission','Admission is free; registration may still be described in the entry instructions.'),
 ('5badfc37-4ae7-5c85-84c6-629fa1b70e9d','TICKET_REQUIRED','Ticket required','A valid admission ticket is required. This does not imply KNS sells tickets.'),
 ('a9fd1c4b-34ef-5ff1-a98a-bf6eaf3a6665','REGISTRATION_REQUIRED','Registration required','Guests must register before attending; registration may be free or paid.')
ON CONFLICT (code) DO NOTHING;

INSERT INTO event_attendance_modes (id,code,name,description) VALUES
 ('4b720b9f-0b8f-5f7d-802b-226b7e650cc3','IN_PERSON','In person','Attendance at a physical venue.'),
 ('3f230001-9529-5d4e-bfe2-6b9b49178d18','ONLINE','Online','Attendance through an online channel.'),
 ('eb3b8fd6-d422-5bb1-9767-37743b546b9d','HYBRID','Hybrid','Both physical and online attendance are supported.')
ON CONFLICT (code) DO NOTHING;

INSERT INTO event_organisation_roles (id,code,name,description) VALUES
 ('86ecf7f5-d3ca-5ba9-b420-17ae06808dfc','ORGANISER','Organiser','Responsible for organising the Event.'),
 ('854e75c2-5a88-5793-aa01-a3eb336680bc','CO_ORGANISER','Co-organiser','Shares Event organisation responsibilities.'),
 ('1a95b962-b8a9-5729-b1c6-e062879a229e','HOST','Host','Hosts the Event; not automatically its organiser.'),
 ('10f099f8-9f39-5664-aae5-15d1542cb5e8','SPONSOR','Sponsor','Supports the Event through sponsorship.')
ON CONFLICT (code) DO NOTHING;

INSERT INTO event_place_roles (id,code,name,description) VALUES
 ('74715fdb-17c8-5d35-b623-6ba3e6ea776c','MAIN_VENUE','Main venue','Principal physical Event venue.'),
 ('bb59539c-01ef-5da7-b806-b8b5e702d0ef','ADDITIONAL_VENUE','Additional venue','An additional Event venue.'),
 ('95cbae48-39aa-58ce-a71a-f91c27bc3890','ENTRY_POINT','Entry point','A physical entrance or access point.'),
 ('0558ee2c-857a-5539-8f98-f5d5a0fd4e43','MEETING_POINT','Meeting point','An Event arrival or gathering point.')
ON CONFLICT (code) DO NOTHING;

COMMIT;
