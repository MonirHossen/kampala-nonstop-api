-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Listing Catalogue + Listing Detail - Reference Data Tables
-- PostgreSQL 18+
-- ============================================================================

BEGIN;

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_categories_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE subcategories (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    category_id UUID NOT NULL,
    code VARCHAR(120) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subcategories_category
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    CONSTRAINT uq_subcategories_category_name UNIQUE (category_id, name),
    CONSTRAINT chk_subcategories_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE INDEX idx_subcategories_category_id ON subcategories (category_id);

CREATE TABLE activity_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_activity_types_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tags_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE attributes (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_attributes_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE amenities (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_amenities_code CHECK (code ~ '^[A-Z0-9_]+$')
);

CREATE TABLE event_types (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_event_types_code CHECK (code ~ '^[A-Z0-9_]+$')
);

COMMENT ON TABLE activity_types IS
'Controlled values describing WHAT an Activity is. Category/subcategory mapping is deliberately deferred because an Activity Type may span more than one taxonomy branch.';

COMMENT ON COLUMN categories.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN subcategories.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN activity_types.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN tags.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN attributes.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN amenities.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';
COMMENT ON COLUMN event_types.is_live IS
'TRUE = available to customer-facing experiences; FALSE remains available to authorised admin tooling.';

COMMIT;

-- Notes:
-- * Geography is deferred until actual location storage is designed.
-- * Currency codes should use the chosen Laravel/ISO framework, not a duplicate table.
-- * Laravel should manage updated_at during normal application writes.
