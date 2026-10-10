-- ============================================================================
-- DEPRECATED — do not use as the current geography schema.
-- Canonical geography schema: 6_kampala_nonstop_geography_tables_schema.sql
-- Canonical geography seed:   6_1_kampala_nonstop_geography_tables_data.sql
-- Laravel source of truth:    database/migrations/2026_09_08_000001_create_geographic_area_tables.php
-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Geographic Areas — Schema (legacy mirror; superseded)
-- PostgreSQL 18+
-- ============================================================================

BEGIN;

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

COMMIT;
