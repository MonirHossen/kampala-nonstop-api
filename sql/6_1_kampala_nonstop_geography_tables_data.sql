-- Kampala Nonstop - geography seed data
-- Source: https://docs.google.com/spreadsheets/d/1CsxSfz_Gqbdb6SMqa1t8C6wbtwhMIa4a27HxsoVQ-FM/edit
-- Tabs: Geographic Area Types; Geographic Areas.
-- Snapshot: 2026-09-09. 14 types; 32 areas.
-- Run after 01_create_geography_tables.sql.
-- Generates UUIDs on initial insert and resolves references by stable codes.
-- Reruns skip existing natural keys; they do NOT synchronise or overwrite changes.
-- sort_order has no source column; all rows use the schema default (0).
-- Source hierarchy and publication flags are preserved without geographic reinterpretation.
BEGIN;

INSERT INTO public.geographic_area_types (code, name, description, is_live)
VALUES
    ('REGION', 'Region', 'Primary destination region.', TRUE),
    ('SUBREGION', 'Subregion', 'Recognised subdivision within a region.', TRUE),
    ('CULTURAL_REGION', 'Cultural Region', 'Area associated with a cultural or historical community.', TRUE),
    ('CITY', 'City', 'Recognised city or urban authority.', TRUE),
    ('NEIGHBOURHOOD', 'Neighbourhood', 'Named neighbourhood within a city or town.', TRUE),
    ('LOCALITY', 'Locality', 'Named local area that is not represented as a city or neighbourhood.', TRUE),
    ('LAKE', 'Lake', 'Named lake or country-specific portion of a lake.', TRUE),
    ('CHANNEL', 'Channel', 'Named natural water channel.', TRUE),
    ('MOUNTAIN_RANGE', 'Mountain Range', 'Named mountain range or country-specific portion of one.', TRUE),
    ('NATIONAL_PARK', 'National Park', 'Protected area designated as a national park.', TRUE),
    ('WATERFALL', 'Waterfall', 'Named waterfall or falls.', TRUE),
    ('ARCHIPELAGO', 'Archipelago', 'Named group of islands.', TRUE),
    ('GEOGRAPHIC_FEATURE', 'Geographic Feature', 'Other named geographic feature.', TRUE),
    ('NATURAL_AREA', 'Natural Area', 'Named natural landscape or collection of related natural features.', TRUE)
ON CONFLICT (code) DO NOTHING;

-- Central (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('CENTRAL', 'Central',
     (SELECT id FROM public.geographic_area_types WHERE code = 'REGION'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- East (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('EAST', 'East',
     (SELECT id FROM public.geographic_area_types WHERE code = 'REGION'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- North (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('NORTH', 'North',
     (SELECT id FROM public.geographic_area_types WHERE code = 'REGION'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- West (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('WEST', 'West',
     (SELECT id FROM public.geographic_area_types WHERE code = 'REGION'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- South West (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('SOUTH_WEST', 'South West',
     (SELECT id FROM public.geographic_area_types WHERE code = 'SUBREGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Buganda (parent: CENTRAL)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('BUGANDA', 'Buganda',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'CENTRAL'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Busoga (parent: EAST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('BUSOGA', 'Busoga',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'EAST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Teso (parent: EAST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('TESO', 'Teso',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'EAST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Acholiland (parent: NORTH)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('ACHOLILAND', 'Acholiland',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'NORTH'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Ankole (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('ANKOLE', 'Ankole',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Kigezi (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('KIGEZI', 'Kigezi',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CULTURAL_REGION'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Kampala (parent: CENTRAL)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('KAMPALA', 'Kampala',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CITY'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'CENTRAL'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Katwe (parent: KAMPALA)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('KATWE', 'Katwe',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NEIGHBOURHOOD'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'KAMPALA'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Wakaliga (parent: KAMPALA)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('WAKALIGA', 'Wakaliga',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NEIGHBOURHOOD'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'KAMPALA'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake Victoria (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_VICTORIA', 'Lake Victoria',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Ssese Islands (parent: LAKE_VICTORIA)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('SSESE_ISLANDS', 'Ssese Islands',
     (SELECT id FROM public.geographic_area_types WHERE code = 'ARCHIPELAGO'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'LAKE_VICTORIA'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake Albert (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_ALBERT', 'Lake Albert',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake Edward (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_EDWARD', 'Lake Edward',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake George (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_GEORGE', 'Lake George',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake Bunyonyi (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_BUNYONYI', 'Lake Bunyonyi',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Lake Mutanda (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('LAKE_MUTANDA', 'Lake Mutanda',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LAKE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Rwenzori Mountains (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('RWENZORI_MOUNTAINS', 'Rwenzori Mountains',
     (SELECT id FROM public.geographic_area_types WHERE code = 'MOUNTAIN_RANGE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Virunga Mountains (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('VIRUNGA_MOUNTAINS', 'Virunga Mountains',
     (SELECT id FROM public.geographic_area_types WHERE code = 'MOUNTAIN_RANGE'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Queen Elizabeth National Park (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('QUEEN_ELIZABETH_NATIONAL_PARK', 'Queen Elizabeth National Park',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NATIONAL_PARK'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Bwindi Impenetrable National Park (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('BWINDI', 'Bwindi Impenetrable National Park',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NATIONAL_PARK'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Mgahinga Gorilla National Park (parent: SOUTH_WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('MGAHINGA', 'Mgahinga Gorilla National Park',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NATIONAL_PARK'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'SOUTH_WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Murchison Falls National Park (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('MURCHISON_FALLS_NATIONAL_PARK', 'Murchison Falls National Park',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NATIONAL_PARK'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Ishasha (parent: QUEEN_ELIZABETH_NATIONAL_PARK)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('ISHASHA', 'Ishasha',
     (SELECT id FROM public.geographic_area_types WHERE code = 'LOCALITY'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'QUEEN_ELIZABETH_NATIONAL_PARK'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Kazinga Channel (parent: QUEEN_ELIZABETH_NATIONAL_PARK)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('KAZINGA_CHANNEL', 'Kazinga Channel',
     (SELECT id FROM public.geographic_area_types WHERE code = 'CHANNEL'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'QUEEN_ELIZABETH_NATIONAL_PARK'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Murchison Falls (parent: MURCHISON_FALLS_NATIONAL_PARK)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('MURCHISON_FALLS', 'Murchison Falls',
     (SELECT id FROM public.geographic_area_types WHERE code = 'WATERFALL'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'MURCHISON_FALLS_NATIONAL_PARK'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Equator (country-level root)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('EQUATOR', 'Equator',
     (SELECT id FROM public.geographic_area_types WHERE code = 'GEOGRAPHIC_FEATURE'),
     NULL, 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

-- Crater Lakes (parent: WEST)
INSERT INTO public.geographic_areas
    (code, name, geographic_area_type_id, parent_geographic_area_id, country_code, is_live)
VALUES
    ('CRATER_LAKES', 'Crater Lakes',
     (SELECT id FROM public.geographic_area_types WHERE code = 'NATURAL_AREA'),
     (SELECT id FROM public.geographic_areas WHERE country_code = 'UG' AND code = 'WEST'), 'UG', TRUE)
ON CONFLICT (country_code, code) DO NOTHING;

COMMIT;

