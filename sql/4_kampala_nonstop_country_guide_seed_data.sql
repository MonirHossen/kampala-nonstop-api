-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Country Guide — Reference + Uganda seed data
-- PostgreSQL 18+
-- Idempotent: ON CONFLICT updates name/sort/live flags; does not overwrite
-- free-text descriptions/content where noted.
-- ============================================================================

BEGIN;

-- Geographic area types
INSERT INTO geographic_area_types (id, code, name, description, is_active)
VALUES
    (uuidv7(), 'COUNTRY', 'Country', 'National root geography node', TRUE),
    (uuidv7(), 'REGION', 'Region', 'Primary sub-national region', TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Essential types
INSERT INTO country_guide_essential_types (id, code, name, description, sort_order, is_active)
VALUES
    (uuidv7(), 'CAPITAL', 'Capital', 'National capital city', 10, TRUE),
    (uuidv7(), 'CURRENCY', 'Currency', 'Currency name and ISO code', 20, TRUE),
    (uuidv7(), 'LANGUAGES', 'Languages', 'Official and commonly spoken languages', 30, TRUE),
    (uuidv7(), 'TIME_ZONE', 'Time zone', 'Primary time zone used in the country', 40, TRUE),
    (uuidv7(), 'CALLING_CODE', 'International calling code', 'Country dialling code', 50, TRUE),
    (uuidv7(), 'DRIVING_SIDE', 'Driving side', 'Left or right side of the road', 60, TRUE),
    (uuidv7(), 'ELECTRICITY', 'Electricity / plug type', 'Mains voltage and common plug types', 70, TRUE),
    (uuidv7(), 'MAIN_AIRPORT', 'Main international airport', 'Primary international gateway', 80, TRUE),
    (uuidv7(), 'EMERGENCY_NUMBERS', 'Emergency numbers', 'Key emergency contact numbers', 90, TRUE),
    (uuidv7(), 'MOBILE_INTERNET', 'Mobile & internet basics', 'Short SIM, data and connectivity summary', 100, TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Travel guide topics (Africa Nonstop Travel Guide Topics catalogue)
UPDATE travel_guide_topics
SET code = 'ARRIVAL',
    name = 'Getting Here & Arrival',
    description = 'Long-form guidance on arriving in the country, airports and practical arrival considerations.',
    sort_order = 20,
    is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP
WHERE code = 'GETTING_HERE'
  AND NOT EXISTS (SELECT 1 FROM travel_guide_topics WHERE code = 'ARRIVAL');

INSERT INTO travel_guide_topics (id, code, name, description, sort_order, is_active)
VALUES
    (uuidv7(), 'ENTRY_VISAS', 'Entry & Visas', 'Long-form guidance on entry requirements, visas and related visitor considerations.', 10, TRUE),
    (uuidv7(), 'ARRIVAL', 'Getting Here & Arrival', 'Long-form guidance on arriving in the country, airports and practical arrival considerations.', 20, TRUE),
    (uuidv7(), 'GETTING_AROUND', 'Getting Around', 'Long-form guidance on local transport, road travel and moving around the country.', 30, TRUE),
    (uuidv7(), 'MONEY_PAYMENTS', 'Money & Payments', 'Long-form guidance on cash, cards, mobile money, tipping and payment practices.', 40, TRUE),
    (uuidv7(), 'EXCHANGE_RATE', 'Exchange Rate', 'Indicative exchange-rate guidance and context for travellers; not intended to be a guaranteed live rate.', 50, TRUE),
    (uuidv7(), 'HEALTH_SAFETY', 'Health & Safety', 'Long-form practical guidance on health preparation, safety and traveller precautions.', 60, TRUE),
    (uuidv7(), 'MOBILE_INTERNET', 'Mobile & Internet', 'Long-form guidance on mobile networks, SIM/eSIM options, data, Wi-Fi, roaming and internet access.', 70, TRUE),
    (uuidv7(), 'WEATHER', 'Weather', 'General weather overview, seasonal patterns and practical context for visitors.', 80, TRUE),
    (uuidv7(), 'CULTURE_ETIQUETTE', 'Culture & Etiquette', 'Long-form guidance on local customs, etiquette, social behaviour and cultural context.', 90, TRUE),
    (uuidv7(), 'WHAT_TO_PACK', 'What to Pack', 'Long-form guidance on appropriate clothing, footwear, adapters, medication/personal items, rain protection and destination-specific practicalities.', 100, TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Travel information types
INSERT INTO travel_information_types (id, code, name, description, sort_order, is_active)
VALUES
    (uuidv7(), 'EXCHANGE_RATE', 'Exchange Rate', 'Current or indicative FX snapshot', 10, TRUE),
    (uuidv7(), 'WEATHER', 'Weather', 'Current weather overview', 20, TRUE),
    (uuidv7(), 'LOCAL_TIME', 'Local Time', 'Current local time context', 30, TRUE),
    (uuidv7(), 'ENTRY_VISA_STATUS', 'Entry / Visa Status', 'Current entry and visa operational notes', 40, TRUE),
    (uuidv7(), 'TRAVEL_ADVISORY', 'Current Travel Advisory', 'Current travel advisory summary', 50, TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Uganda geography
WITH country_type AS (
    SELECT id FROM geographic_area_types WHERE code = 'COUNTRY'
),
region_type AS (
    SELECT id FROM geographic_area_types WHERE code = 'REGION'
),
uganda AS (
    INSERT INTO geographic_areas (id, parent_geographic_area_id, geographic_area_type_id, country_code, code, name, is_live)
    SELECT uuidv7(), NULL, country_type.id, 'UG', 'UG', 'Uganda', TRUE
    FROM country_type
    ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        is_live = EXCLUDED.is_live,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id
)
INSERT INTO geographic_areas (id, parent_geographic_area_id, geographic_area_type_id, country_code, code, name, is_live)
SELECT uuidv7(), uganda.id, region_type.id, 'UG', region.code, region.name, TRUE
FROM uganda
CROSS JOIN region_type
CROSS JOIN (VALUES
    ('UG-CENTRAL', 'Central'),
    ('UG-WEST', 'West'),
    ('UG-EAST', 'East'),
    ('UG-NORTH', 'North')
) AS region(code, name)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    parent_geographic_area_id = EXCLUDED.parent_geographic_area_id,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;
