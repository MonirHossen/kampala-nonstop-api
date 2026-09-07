-- Kampala Nonstop / Africa Nonstop
-- Country Guide schema
-- PostgreSQL
--
-- Notes:
-- 1. Country data is supplied by the Laravel ISO/country package.
--    No custom countries table is created here.
-- 2. country_code values use ISO 3166-1 alpha-2 codes (e.g. UG).
-- 3. geographic_areas is an existing shared table and must already exist.
-- 4. Local Knowledge is managed in its own separate schema/module.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- 1. Country Guide Essential Types
-- Reusable list of short country facts/questions.
-- =========================================================
CREATE TABLE IF NOT EXISTS country_guide_essential_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. Country Guide Essential Values
-- Country-specific answers to the reusable essential types.
-- value_data is optional structured data where useful.
-- =========================================================
CREATE TABLE IF NOT EXISTS country_guide_essential_values (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code        CHAR(2) NOT NULL,
    essential_type_id   UUID NOT NULL,
    value_text          TEXT NOT NULL,
    value_data          JSONB,
    is_live             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_country_guide_essential_values_type
        FOREIGN KEY (essential_type_id)
        REFERENCES country_guide_essential_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_country_guide_essential_value
        UNIQUE (country_code, essential_type_id),

    CONSTRAINT chk_country_guide_essential_values_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

COMMENT ON COLUMN country_guide_essential_values.country_code IS
'ISO 3166-1 alpha-2 country code. Validate against the Laravel ISO/country package at application level.';

CREATE INDEX IF NOT EXISTS idx_country_guide_essential_values_country
    ON country_guide_essential_values(country_code);

CREATE INDEX IF NOT EXISTS idx_country_guide_essential_values_type
    ON country_guide_essential_values(essential_type_id);

-- =========================================================
-- 3. Travel Guide Topics
-- Reusable list of longer-form editorial Guide topics.
-- Ordering belongs here, not on country-specific content.
-- =========================================================
CREATE TABLE IF NOT EXISTS travel_guide_topics (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 4. Country Travel Guides
-- Country-specific long-form editorial content for each topic.
-- =========================================================
CREATE TABLE IF NOT EXISTS country_travel_guides (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code    CHAR(2) NOT NULL,
    topic_id        UUID NOT NULL,
    content         TEXT NOT NULL,
    image_link      TEXT,
    is_live         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_country_travel_guides_topic
        FOREIGN KEY (topic_id)
        REFERENCES travel_guide_topics(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_country_travel_guide_topic
        UNIQUE (country_code, topic_id),

    CONSTRAINT chk_country_travel_guides_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

COMMENT ON COLUMN country_travel_guides.country_code IS
'ISO 3166-1 alpha-2 country code. Validate against the Laravel ISO/country package at application level.';

CREATE INDEX IF NOT EXISTS idx_country_travel_guides_country
    ON country_travel_guides(country_code);

CREATE INDEX IF NOT EXISTS idx_country_travel_guides_topic
    ON country_travel_guides(topic_id);

-- =========================================================
-- 5. Travel Information Types
-- Reusable list of short/current/operational information items.
-- These may later be populated by external APIs, but the table
-- itself remains provider-agnostic.
-- =========================================================
CREATE TABLE IF NOT EXISTS travel_information_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 6. Country Travel Information
-- Country-specific current/operational values.
-- value_data allows structured values where useful.
-- No API-provider metadata is included at this stage.
-- =========================================================
CREATE TABLE IF NOT EXISTS country_travel_information (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code    CHAR(2) NOT NULL,
    info_type_id    UUID NOT NULL,
    value_text      TEXT NOT NULL,
    value_data      JSONB,
    is_live         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_country_travel_information_type
        FOREIGN KEY (info_type_id)
        REFERENCES travel_information_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_country_travel_information_type
        UNIQUE (country_code, info_type_id),

    CONSTRAINT chk_country_travel_information_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

COMMENT ON COLUMN country_travel_information.country_code IS
'ISO 3166-1 alpha-2 country code. Validate against the Laravel ISO/country package at application level.';

CREATE INDEX IF NOT EXISTS idx_country_travel_information_country
    ON country_travel_information(country_code);

CREATE INDEX IF NOT EXISTS idx_country_travel_information_type
    ON country_travel_information(info_type_id);

-- =========================================================
-- 7. Country Region Guides
-- Short editorial overview for a country-specific geographic area.
-- geographic_area_id points to the existing hierarchical geography.
-- =========================================================
CREATE TABLE IF NOT EXISTS country_region_guides (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code        CHAR(2) NOT NULL,
    geographic_area_id  UUID NOT NULL,
    title               VARCHAR(255),
    summary             TEXT NOT NULL,
    image_link          TEXT,
    is_featured         BOOLEAN NOT NULL DEFAULT FALSE,
    is_live             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_country_region_guides_geographic_area
        FOREIGN KEY (geographic_area_id)
        REFERENCES geographic_areas(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_country_region_guide_area
        UNIQUE (country_code, geographic_area_id),

    CONSTRAINT chk_country_region_guides_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

COMMENT ON COLUMN country_region_guides.country_code IS
'ISO 3166-1 alpha-2 country code. Validate against the Laravel ISO/country package at application level.';

CREATE INDEX IF NOT EXISTS idx_country_region_guides_country
    ON country_region_guides(country_code);

CREATE INDEX IF NOT EXISTS idx_country_region_guides_geographic_area
    ON country_region_guides(geographic_area_id);

COMMIT;
