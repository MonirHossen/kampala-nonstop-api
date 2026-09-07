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
