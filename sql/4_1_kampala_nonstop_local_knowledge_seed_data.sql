-- Kampala Nonstop / Africa Nonstop
-- Local Knowledge lookup/reference data
-- PostgreSQL
--
-- This script is idempotent and can be re-run safely.

BEGIN;

-- =========================================================
-- Local Knowledge Types
-- =========================================================
INSERT INTO local_knowledge_types (code, name, description, is_active)
VALUES
    ('FUN_FACT', 'Fun Fact',
     'Interesting trivia or surprising information.',
     TRUE),

    ('PHRASE', 'Local Phrase',
     'A local-language word or phrase with its translation and contextual explanation.',
     TRUE),

    ('ETIQUETTE', 'Etiquette',
     'Social conventions, manners and cultural expectations useful to visitors.',
     TRUE),

    ('PRACTICAL_TIP', 'Practical Tip',
     'Useful visitor knowledge such as money, transport, connectivity or other practical guidance.',
     TRUE),

    ('CULTURAL_CONTEXT', 'Cultural Context',
     'Explains customs, traditions or why something is done.',
     TRUE),

    ('INSIDER_TIP', 'Insider Tip',
     'Locally informed advice that is not obvious from ordinary travel information.',
     TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

-- =========================================================
-- Local Languages
-- Initial Uganda-focused set only.
-- The schema supports adding further countries/languages later.
-- =========================================================
INSERT INTO local_languages (code, name, native_name, is_active)
VALUES
    ('en', 'English', 'English', TRUE),
    ('lg', 'Luganda', 'Luganda', TRUE),
    ('sw', 'Swahili', 'Kiswahili', TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    native_name = EXCLUDED.native_name,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

-- =========================================================
-- Language <-> Country mappings
-- Uganda only for initial population.
-- More country mappings can be added when Africa Nonstop expands.
-- =========================================================
INSERT INTO local_language_countries (language_code, country_code)
VALUES
    ('en', 'UG'),
    ('lg', 'UG'),
    ('sw', 'UG')
ON CONFLICT (language_code, country_code) DO NOTHING;

-- =========================================================
-- Local Knowledge Tags
-- One unified topic/context taxonomy.
-- =========================================================
INSERT INTO local_knowledge_tags (code, name, description, is_active)
VALUES
    ('TRANSPORT', 'Transport',
     'Transport, mobility and movement-related knowledge.', TRUE),
    ('GETTING_AROUND', 'Getting Around',
     'Practical knowledge about moving around a destination.', TRUE),
    ('ARRIVAL', 'Arrival',
     'Airport, entry and first-arrival context.', TRUE),
    ('MONEY', 'Money',
     'Currency, cash and general money-related knowledge.', TRUE),
    ('PAYMENTS', 'Payments',
     'Cards, mobile money and payment practices.', TRUE),
    ('MOBILE_MONEY', 'Mobile Money',
     'Knowledge specifically related to mobile-money use.', TRUE),
    ('CULTURE', 'Culture',
     'Cultural practices, norms and context.', TRUE),
    ('ETIQUETTE', 'Etiquette',
     'Social etiquette and visitor behaviour.', TRUE),
    ('LANGUAGE', 'Language',
     'Languages, phrases and communication-related knowledge.', TRUE),
    ('FOOD', 'Food',
     'Food, eating and local culinary culture.', TRUE),
    ('NIGHTLIFE', 'Nightlife',
     'Nightlife, entertainment and late-evening culture.', TRUE),
    ('HISTORY', 'History',
     'Historical context and facts.', TRUE),
    ('SAFETY', 'Safety',
     'Practical personal-safety context.', TRUE),
    ('HEALTH', 'Health',
     'Health-related local context distinct from formal medical advice.', TRUE),
    ('CONNECTIVITY', 'Connectivity',
     'SIM cards, mobile networks, data and internet-related knowledge.', TRUE),
    ('WEATHER', 'Weather & Climate',
     'Climate, seasons and weather-related local context.', TRUE),
    ('ACCOMMODATION', 'Accommodation',
     'Knowledge relevant to where visitors stay.', TRUE),
    ('SHOPPING', 'Shopping',
     'Shopping practices, markets and retail-related knowledge.', TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

-- =========================================================
-- Page Contexts
-- These are product surfaces/page classes, not URLs.
-- Geographic specificity is handled by geographic_areas.
-- =========================================================
INSERT INTO page_contexts (code, name, description, is_active)
VALUES
    ('HOME', 'Home',
     'Homepage Local Knowledge tooltip context.', TRUE),
    ('GUIDE', 'Guide',
     'General Guide pages and Guide landing experience.', TRUE),
    ('GUIDE_OVERVIEW', 'Guide Overview',
     'Country or destination overview content within Guide.', TRUE),
    ('GUIDE_ESSENTIALS', 'Guide Essentials',
     'Structured country essentials and quick-reference Guide content.', TRUE),
    ('GUIDE_TRAVEL', 'Guide Travel Information',
     'Travel Information content such as arrival, transport, money, health, connectivity, weather and etiquette.', TRUE),
    ('GUIDE_REGION', 'Guide Region',
     'Regional and destination-level Guide pages.', TRUE),
    ('DISCOVER', 'Discover',
     'Discovery catalogue and related browsing surfaces.', TRUE),
    ('LISTING_DETAIL', 'Listing Detail',
     'Individual listing detail pages.', TRUE),
    ('TRIP_PLANNER', 'Trip Planner',
     'Trip planning and orchestration surfaces.', TRUE)
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

COMMIT;
