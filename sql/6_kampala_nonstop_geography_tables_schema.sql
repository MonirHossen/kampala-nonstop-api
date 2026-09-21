-- Kampala Nonstop - geographic reference tables
-- Run 01_create_geography_tables.sql before 02_insert_geography_data.sql.
-- PostgreSQL 13+ (built-in gen_random_uuid()). Target schema: public.
-- Fresh installation only: intentionally fails if these tables already exist.
-- No DROP statements. Each script runs in a transaction.
-- ISO country validity is checked in Laravel; the DB checks the two-letter format.
-- Application must maintain updated_at on subsequent UPDATEs (no trigger included).
-- Parent cycles beyond direct self-parenting must be prevented by the application.

BEGIN;

CREATE TABLE public.geographic_area_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.geographic_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_geographic_area_id UUID,
    geographic_area_type_id UUID NOT NULL,
    country_code CHAR(2) NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT geographic_areas_country_code_code_key UNIQUE (country_code, code),
    -- Enables the composite self-FK to enforce same-country parentage.
    CONSTRAINT geographic_areas_id_country_code_key UNIQUE (id, country_code),
    CONSTRAINT geographic_areas_country_code_format CHECK (country_code ~ '^[A-Z]{2}$'),
    CONSTRAINT geographic_areas_not_own_parent CHECK (parent_geographic_area_id IS DISTINCT FROM id),
    CONSTRAINT geographic_areas_type_fk
        FOREIGN KEY (geographic_area_type_id)
        REFERENCES public.geographic_area_types (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT geographic_areas_parent_fk
        FOREIGN KEY (parent_geographic_area_id, country_code)
        REFERENCES public.geographic_areas (id, country_code)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE INDEX geographic_areas_type_idx
    ON public.geographic_areas (geographic_area_type_id);
CREATE INDEX geographic_areas_parent_idx
    ON public.geographic_areas (parent_geographic_area_id, country_code);

COMMIT;

