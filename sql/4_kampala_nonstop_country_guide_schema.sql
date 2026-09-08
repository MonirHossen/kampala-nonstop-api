-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Country Guide + Geographic Areas — Schema
-- PostgreSQL 18+
-- Mirrors Laravel migrations:
--   2026_09_08_000001_create_geographic_area_tables
--   2026_09_08_000002_create_country_guide_tables
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Geography foundation (Region Guide dependency)
-- ---------------------------------------------------------------------------

CREATE TABLE geographic_area_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_geographic_area_types_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE geographic_areas (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    parent_geographic_area_id UUID NULL,
    geographic_area_type_id UUID NOT NULL,
    country_code CHAR(2) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_geographic_areas_parent
        FOREIGN KEY (parent_geographic_area_id) REFERENCES geographic_areas(id) ON DELETE SET NULL,
    CONSTRAINT fk_geographic_areas_type
        FOREIGN KEY (geographic_area_type_id) REFERENCES geographic_area_types(id) ON DELETE RESTRICT,
    CONSTRAINT chk_geographic_areas_code CHECK (code ~ '^[A-Z0-9_-]+$'),
    CONSTRAINT chk_geographic_areas_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX idx_geographic_areas_parent ON geographic_areas (parent_geographic_area_id);
CREATE INDEX idx_geographic_areas_type ON geographic_areas (geographic_area_type_id);
CREATE INDEX idx_geographic_areas_country ON geographic_areas (country_code);

-- ---------------------------------------------------------------------------
-- Country Essentials
-- ---------------------------------------------------------------------------

CREATE TABLE country_guide_essential_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_country_guide_essential_types_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE country_guide_essential_values (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    country_code CHAR(2) NOT NULL,
    essential_type_id UUID NOT NULL,
    value_text TEXT NOT NULL,
    value_data JSONB NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_country_guide_essential_values_type
        FOREIGN KEY (essential_type_id) REFERENCES country_guide_essential_types(id) ON DELETE RESTRICT,
    CONSTRAINT uq_country_guide_essential_values_country_type UNIQUE (country_code, essential_type_id),
    CONSTRAINT chk_country_guide_essential_values_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX idx_country_guide_essential_values_country ON country_guide_essential_values (country_code);
CREATE INDEX idx_country_guide_essential_values_type ON country_guide_essential_values (essential_type_id);

-- ---------------------------------------------------------------------------
-- Travel Guide
-- ---------------------------------------------------------------------------

CREATE TABLE travel_guide_topics (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_travel_guide_topics_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE country_travel_guides (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    country_code CHAR(2) NOT NULL,
    topic_id UUID NOT NULL,
    content TEXT NOT NULL,
    image_link TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_country_travel_guides_topic
        FOREIGN KEY (topic_id) REFERENCES travel_guide_topics(id) ON DELETE RESTRICT,
    CONSTRAINT uq_country_travel_guides_country_topic UNIQUE (country_code, topic_id),
    CONSTRAINT chk_country_travel_guides_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX idx_country_travel_guides_country ON country_travel_guides (country_code);
CREATE INDEX idx_country_travel_guides_topic ON country_travel_guides (topic_id);

-- ---------------------------------------------------------------------------
-- Travel Information
-- ---------------------------------------------------------------------------

CREATE TABLE travel_information_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_travel_information_types_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE country_travel_information (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    country_code CHAR(2) NOT NULL,
    info_type_id UUID NOT NULL,
    value_text TEXT NOT NULL,
    value_data JSONB NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_country_travel_information_type
        FOREIGN KEY (info_type_id) REFERENCES travel_information_types(id) ON DELETE RESTRICT,
    CONSTRAINT uq_country_travel_information_country_type UNIQUE (country_code, info_type_id),
    CONSTRAINT chk_country_travel_information_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX idx_country_travel_information_country ON country_travel_information (country_code);
CREATE INDEX idx_country_travel_information_type ON country_travel_information (info_type_id);

-- ---------------------------------------------------------------------------
-- Region Guide
-- ---------------------------------------------------------------------------

CREATE TABLE country_region_guides (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    country_code CHAR(2) NOT NULL,
    geographic_area_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT NOT NULL,
    image_link TEXT NULL,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_country_region_guides_area
        FOREIGN KEY (geographic_area_id) REFERENCES geographic_areas(id) ON DELETE RESTRICT,
    CONSTRAINT uq_country_region_guides_country_area UNIQUE (country_code, geographic_area_id),
    CONSTRAINT chk_country_region_guides_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX idx_country_region_guides_country ON country_region_guides (country_code);
CREATE INDEX idx_country_region_guides_area ON country_region_guides (geographic_area_id);

COMMIT;
