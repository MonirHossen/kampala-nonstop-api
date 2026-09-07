-- Kampala Nonstop / Africa Nonstop
-- Country Guide lookup/reference data
-- PostgreSQL
--
-- Populates:
--   1. country_guide_essential_types
--   2. travel_guide_topics
--   3. travel_information_types
--
-- Idempotent: safe to re-run.

BEGIN;

-- =========================================================
-- 1. Country Guide Essential Types
-- Short, mostly static country facts.
-- =========================================================
INSERT INTO country_guide_essential_types
    (code, name, description, sort_order, is_active)
VALUES
    ('CAPITAL',
     'Capital',
     'The capital city of the country.',
     10, TRUE),

    ('CURRENCY',
     'Currency',
     'The primary currency used in the country.',
     20, TRUE),

    ('CURRENCY_CODE',
     'Currency Code',
     'The ISO currency code for the primary currency.',
     30, TRUE),

    ('LANGUAGES',
     'Languages',
     'Main official and commonly used languages relevant to visitors.',
     40, TRUE),

    ('TIME_ZONE',
     'Time Zone',
     'The country''s primary time zone.',
     50, TRUE),

    ('CALLING_CODE',
     'International Calling Code',
     'The international telephone dialling code.',
     60, TRUE),

    ('DRIVING_SIDE',
     'Driving Side',
     'The side of the road on which vehicles drive.',
     70, TRUE),

    ('ELECTRICITY',
     'Electricity',
     'Standard electricity voltage and frequency.',
     80, TRUE),

    ('PLUG_TYPE',
     'Plug Type',
     'Electrical plug/socket type commonly used.',
     90, TRUE),

    ('MAIN_AIRPORT',
     'Main International Airport',
     'The principal international airport for the country.',
     100, TRUE),

    ('EMERGENCY_NUMBERS',
     'Emergency Numbers',
     'Key emergency telephone numbers useful to visitors.',
     110, TRUE),

    ('MOBILE_INTERNET',
     'Mobile & Internet Basics',
     'Short practical overview of mobile network and internet access.',
     120, TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    sort_order  = EXCLUDED.sort_order,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;


-- =========================================================
-- 2. Travel Guide Topics
-- Longer editorial answers / paragraph-based guide content.
-- EXCHANGE_RATE is an indicative/estimated guide topic;
-- live/current rates can still be supplied separately via
-- country_travel_information now or an API later.
-- =========================================================
INSERT INTO travel_guide_topics
    (code, name, description, sort_order, is_active)
VALUES
    ('ENTRY_VISAS',
     'Entry & Visas',
     'Long-form guidance on entry requirements, visas and related visitor considerations.',
     10, TRUE),

    ('ARRIVAL',
     'Getting Here & Arrival',
     'Long-form guidance on arriving in the country, airports and practical arrival considerations.',
     20, TRUE),

    ('GETTING_AROUND',
     'Getting Around',
     'Long-form guidance on local transport, road travel and moving around the country.',
     30, TRUE),

    ('MONEY_PAYMENTS',
     'Money & Payments',
     'Long-form guidance on cash, cards, mobile money, tipping and payment practices.',
     40, TRUE),

    ('EXCHANGE_RATE',
     'Exchange Rate',
     'Indicative exchange-rate guidance and context for travellers; not intended to be a guaranteed live rate.',
     50, TRUE),

    ('HEALTH_SAFETY',
     'Health & Safety',
     'Long-form practical guidance on health preparation, safety and traveller precautions.',
     60, TRUE),

    ('MOBILE_INTERNET',
     'Mobile & Internet',
     'Long-form guidance on mobile networks, SIM/eSIM options, data, Wi-Fi, roaming and internet access.',
     70, TRUE),

    ('WEATHER',
     'Weather',
     'General weather overview, seasonal patterns and practical context for visitors.',
     80, TRUE),

    ('CULTURE_ETIQUETTE',
     'Culture & Etiquette',
     'Long-form guidance on local customs, etiquette, social behaviour and cultural context.',
     90, TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    sort_order  = EXCLUDED.sort_order,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;


-- =========================================================
-- 3. Travel Information Types
-- Short/current operational information.
-- These values may be manually maintained initially and
-- substituted with API-fed values in future.
-- =========================================================
INSERT INTO travel_information_types
    (code, name, description, sort_order, is_active)
VALUES
    ('EXCHANGE_RATE',
     'Exchange Rate',
     'Current or recently refreshed exchange-rate information.',
     10, TRUE),

    ('WEATHER',
     'Weather',
     'Current or recently refreshed weather overview.',
     20, TRUE),

    ('LOCAL_TIME',
     'Local Time',
     'Current local time for the destination.',
     30, TRUE),

    ('ENTRY_STATUS',
     'Entry / Visa Status',
     'Short current status or operational entry information relevant to visitors.',
     40, TRUE),

    ('TRAVEL_ADVISORY',
     'Current Travel Advisory',
     'Short current travel advisory or official visitor notice.',
     50, TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    sort_order  = EXCLUDED.sort_order,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

COMMIT;
