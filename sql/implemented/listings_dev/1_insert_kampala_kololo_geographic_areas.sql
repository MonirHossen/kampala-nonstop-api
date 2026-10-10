-- Africa Nonstop geographic-area seed
-- Adds Kampala beneath Central, then Kololo beneath Kampala.
-- Assumes geographic area type codes CITY and NEIGHBOURHOOD already exist.
-- Requires pgcrypto (or another provider of gen_random_uuid()).

BEGIN;

INSERT INTO geographic_areas (
    id,
    country_code,
    geographic_area_type_id,
    parent_geographic_area_id,
    code,
    name
)
SELECT
    gen_random_uuid(),
    'UG',
    area_type.id,
    parent_area.id,
    'KAMPALA',
    'Kampala'
FROM geographic_area_types AS area_type
JOIN geographic_areas AS parent_area
  ON parent_area.country_code = 'UG'
 AND parent_area.code = 'CENTRAL'
WHERE area_type.code = 'CITY'
  AND NOT EXISTS (
      SELECT 1
      FROM geographic_areas
      WHERE country_code = 'UG'
        AND code = 'KAMPALA'
  );

INSERT INTO geographic_areas (
    id,
    country_code,
    geographic_area_type_id,
    parent_geographic_area_id,
    code,
    name
)
SELECT
    gen_random_uuid(),
    'UG',
    area_type.id,
    parent_area.id,
    'KOLOLO',
    'Kololo'
FROM geographic_area_types AS area_type
JOIN geographic_areas AS parent_area
  ON parent_area.country_code = 'UG'
 AND parent_area.code = 'KAMPALA'
WHERE area_type.code = 'NEIGHBOURHOOD'
  AND NOT EXISTS (
      SELECT 1
      FROM geographic_areas
      WHERE country_code = 'UG'
        AND code = 'KOLOLO'
  );

COMMIT;
