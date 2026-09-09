-- Kampala Nonstop / Africa Nonstop
-- Uganda Country Guide Essentials population script
-- PostgreSQL
--
-- Prerequisite:
--   country_guide_essential_types must already be populated.
--
-- Idempotent:
--   Re-running this script updates existing Uganda values by
--   (country_code, essential_type_id).

BEGIN;

WITH essential_values (
    essential_type_code,
    value_text,
    value_data,
    is_live
) AS (
    VALUES
        (
            'ABOUT',
            E'Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region''s most energetic capitals within a relatively small area.\n\nDubbed the "Pearl of Africa" by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.',
            '{
                "display": "narrative",
                "heading": "About Uganda",
                "paragraphs": [
                    "Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region''s most energetic capitals within a relatively small area.",
                    "Dubbed the \"Pearl of Africa\" by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders."
                ]
            }'::jsonb,
            TRUE
        ),
        (
            'HISTORY',
            E'Uganda''s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.\n\nBefore modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.\n\nUganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.\n\nToday, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.',
            '{
                "display": "narrative",
                "heading": "History of Uganda",
                "paragraphs": [
                    "Uganda''s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.",
                    "Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.",
                    "Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.",
                    "Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence."
                ]
            }'::jsonb,
            TRUE
        ),
        (
            'CAPITAL',
            'Kampala',
            '{"name":"Kampala"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY',
            'Ugandan Shilling',
            '{"name":"Ugandan Shilling"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY_CODE',
            'UGX',
            '{"code":"UGX"}'::jsonb,
            TRUE
        ),
        (
            'LANGUAGES',
            'English; Swahili (second official language); Luganda widely spoken',
            '{
                "official": ["English"],
                "second_official": ["Swahili"],
                "widely_spoken": ["Luganda"]
            }'::jsonb,
            TRUE
        ),
        (
            'TIME_ZONE',
            'East Africa Time (EAT), UTC+3',
            '{
                "name": "East Africa Time",
                "abbreviation": "EAT",
                "utc_offset": "+03:00"
            }'::jsonb,
            TRUE
        ),
        (
            'CALLING_CODE',
            '+256',
            '{"calling_code":"+256"}'::jsonb,
            TRUE
        ),
        (
            'DRIVING_SIDE',
            'Left',
            '{"side":"LEFT"}'::jsonb,
            TRUE
        ),
        (
            'ELECTRICITY',
            '240 V, 50 Hz',
            '{
                "voltage": 240,
                "frequency_hz": 50
            }'::jsonb,
            TRUE
        ),
        (
            'PLUG_TYPE',
            'Type G',
            '{"types":["G"]}'::jsonb,
            TRUE
        ),
        (
            'MAIN_AIRPORT',
            'Entebbe International Airport (EBB)',
            '{
                "name": "Entebbe International Airport",
                "iata_code": "EBB"
            }'::jsonb,
            TRUE
        ),
        (
            'EMERGENCY_NUMBERS',
            'General emergency: 112 or 999; Fire & Rescue: 0800 121 222; Traffic: 0800 199 099',
            '{
                "general": ["112", "999"],
                "fire_rescue": "0800121222",
                "traffic": "0800199099"
            }'::jsonb,
            TRUE
        ),
        (
            'MOBILE_INTERNET',
            '2G, 3G and 4G mobile services are available; 4G coverage is not yet nationwide.',
            '{
                "available_networks": ["2G", "3G", "4G"],
                "4g_nationwide": false
            }'::jsonb,
            TRUE
        )
)
INSERT INTO country_guide_essential_values (
    country_code,
    essential_type_id,
    value_text,
    value_data,
    is_live
)
SELECT
    'UG' AS country_code,
    t.id AS essential_type_id,
    v.value_text,
    v.value_data,
    v.is_live
FROM essential_values v
JOIN country_guide_essential_types t
    ON t.code = v.essential_type_code
ON CONFLICT (country_code, essential_type_id)
DO UPDATE SET
    value_text = EXCLUDED.value_text,
    value_data = EXCLUDED.value_data,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;
