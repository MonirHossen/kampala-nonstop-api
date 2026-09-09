-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Geographic Areas — Uganda seed data
-- PostgreSQL 18+
-- Idempotent: ON CONFLICT updates name / parent / live flags.
-- ============================================================================

BEGIN;

INSERT INTO geographic_area_types (id, code, name, description, is_active)
VALUES
    (uuidv7(), 'COUNTRY', 'Country', 'National root geography node', TRUE),
    (uuidv7(), 'REGION', 'Region', 'Primary sub-national region', TRUE),
    (uuidv7(), 'CITY', 'City', 'City or major urban settlement', TRUE)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

WITH country_type AS (
    SELECT id FROM geographic_area_types WHERE code = 'COUNTRY'
),
region_type AS (
    SELECT id FROM geographic_area_types WHERE code = 'REGION'
),
city_type AS (
    SELECT id FROM geographic_area_types WHERE code = 'CITY'
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
),
regions AS (
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
        updated_at = CURRENT_TIMESTAMP
    RETURNING id, code
)
INSERT INTO geographic_areas (id, parent_geographic_area_id, geographic_area_type_id, country_code, code, name, is_live)
SELECT uuidv7(), regions.id, city_type.id, 'UG', 'UG-KAMPALA', 'Kampala', TRUE
FROM regions
CROSS JOIN city_type
WHERE regions.code = 'UG-CENTRAL'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    parent_geographic_area_id = EXCLUDED.parent_geographic_area_id,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;
