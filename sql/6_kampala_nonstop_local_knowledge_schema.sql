-- Kampala Nonstop / Africa Nonstop
-- Local Knowledge schema
-- PostgreSQL
-- Mirrors Laravel migration:
--   2026_09_09_000003_create_local_knowledge_tables
--
-- Dependency:
--   public.geographic_areas(id UUID) must already exist.
--
-- Country data is NOT stored in a custom countries table.
-- country_code values are ISO 3166-1 alpha-2 codes and should be validated
-- by the application using the Laravel ISO/country package.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- 1. Local Knowledge Types
-- =========================================================
CREATE TABLE IF NOT EXISTS local_knowledge_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. Local Languages
-- Natural key is the language code.
-- VARCHAR(10) allows ISO 639 / BCP 47-style identifiers.
-- =========================================================
CREATE TABLE IF NOT EXISTS local_languages (
    code            VARCHAR(10) PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    native_name     VARCHAR(100),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 3. Language <-> Country mapping
-- Country is represented by ISO code rather than a countries table.
-- =========================================================
CREATE TABLE IF NOT EXISTS local_language_countries (
    language_code   VARCHAR(10) NOT NULL,
    country_code    CHAR(2) NOT NULL,
    PRIMARY KEY (language_code, country_code),

    CONSTRAINT fk_local_language_countries_language
        FOREIGN KEY (language_code)
        REFERENCES local_languages(code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_local_language_countries_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE INDEX IF NOT EXISTS idx_local_language_countries_country
    ON local_language_countries(country_code);

-- =========================================================
-- 4. Local Knowledge Tags
-- Tags are the topic/context taxonomy.
-- Examples: TRANSPORT, MONEY, CULTURE, NIGHTLIFE.
-- =========================================================
CREATE TABLE IF NOT EXISTS local_knowledge_tags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 5. Page Contexts
-- Describes product surfaces/page classes where Local Knowledge may appear.
-- Geography and semantic topics are handled separately.
-- =========================================================
CREATE TABLE IF NOT EXISTS page_contexts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 6. Local Knowledge
-- One item has one country and, optionally, one geographic anchor.
-- Geographic inheritance is resolved via geographic_areas hierarchy.
-- =========================================================
CREATE TABLE IF NOT EXISTS local_knowledge (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    local_knowledge_type_id     UUID NOT NULL,
    country_code                CHAR(2) NOT NULL,
    geographic_area_id          UUID,
    local_language_code         VARCHAR(10),

    title                       TEXT,
    content                     TEXT NOT NULL,
    explanation                 TEXT,

    image_link                  TEXT,
    source_url                  TEXT,

    is_live                     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_local_knowledge_type
        FOREIGN KEY (local_knowledge_type_id)
        REFERENCES local_knowledge_types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_local_knowledge_geographic_area
        FOREIGN KEY (geographic_area_id)
        REFERENCES geographic_areas(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_local_knowledge_language
        FOREIGN KEY (local_language_code)
        REFERENCES local_languages(code)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_local_knowledge_country_code
        CHECK (country_code ~ '^[A-Z]{2}$')
);

COMMENT ON COLUMN local_knowledge.country_code IS
'ISO 3166-1 alpha-2 country code. Validated by the application using the Laravel ISO/country package; no custom countries table is used.';

COMMENT ON COLUMN local_knowledge.geographic_area_id IS
'Optional geographic anchor. Relevance can inherit through the existing geographic_areas parent hierarchy. NULL means country-wide.';

COMMENT ON COLUMN local_knowledge.local_language_code IS
'Optional local language, used primarily for language-specific Local Knowledge such as PHRASE records.';

COMMENT ON COLUMN local_knowledge.image_link IS
'Optional image URL for Local Knowledge items that benefit from a visual example.';

COMMENT ON COLUMN local_knowledge.source_url IS
'Optional external URL identifying the source or provenance of a factual Local Knowledge item.';

CREATE INDEX IF NOT EXISTS idx_local_knowledge_type
    ON local_knowledge(local_knowledge_type_id);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_country
    ON local_knowledge(country_code);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_geographic_area
    ON local_knowledge(geographic_area_id);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_language
    ON local_knowledge(local_language_code);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_live_country
    ON local_knowledge(country_code, is_live);

-- =========================================================
-- 7. Local Knowledge <-> Tags
-- =========================================================
CREATE TABLE IF NOT EXISTS local_knowledge_tag_links (
    local_knowledge_id      UUID NOT NULL,
    tag_id                  UUID NOT NULL,
    PRIMARY KEY (local_knowledge_id, tag_id),

    CONSTRAINT fk_local_knowledge_tag_links_knowledge
        FOREIGN KEY (local_knowledge_id)
        REFERENCES local_knowledge(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_local_knowledge_tag_links_tag
        FOREIGN KEY (tag_id)
        REFERENCES local_knowledge_tags(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_tag_links_tag
    ON local_knowledge_tag_links(tag_id);

-- =========================================================
-- 8. Local Knowledge <-> Page Contexts
-- =========================================================
CREATE TABLE IF NOT EXISTS local_knowledge_page_contexts (
    local_knowledge_id      UUID NOT NULL,
    page_context_id         UUID NOT NULL,
    PRIMARY KEY (local_knowledge_id, page_context_id),

    CONSTRAINT fk_local_knowledge_page_contexts_knowledge
        FOREIGN KEY (local_knowledge_id)
        REFERENCES local_knowledge(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_local_knowledge_page_contexts_context
        FOREIGN KEY (page_context_id)
        REFERENCES page_contexts(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_local_knowledge_page_contexts_context
    ON local_knowledge_page_contexts(page_context_id);

COMMIT;
