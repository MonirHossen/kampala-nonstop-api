-- Kampala Nonstop / Africa Nonstop
-- 15_kampala_nonstop_listing_pricing_enhancements.sql
--
-- Purpose:
--   Non-destructively extend the catalogue pricing schema introduced by the
--   renamed script 14_kampala_nonstop_listing_pricing_schema.sql.
--
-- Adds:
--   * structured pricing basis
--   * optional pricing period
--   * structured guest/group limits
--   * optional occupancy type
--   * price validity dates
--   * non-overlapping live validity windows for the same offer code
--
-- Scope:
--   Catalogue / advertised pricing only.
--   This does NOT implement quote, booking, payment or transactional price snapshots.
--
-- Run once AFTER script 14.

BEGIN;

-- ============================================================================
-- 1. REFERENCE DATA — PRICING BASIS
-- ============================================================================

CREATE TABLE IF NOT EXISTS pricing_basis_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(40) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_live         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT uq_pricing_basis_types_code UNIQUE (code),
    CONSTRAINT chk_pricing_basis_types_code CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

COMMENT ON TABLE pricing_basis_types IS
    'Reference values describing what one catalogue price amount applies to, e.g. person, room, vehicle or group.';

INSERT INTO pricing_basis_types
    (code, name, description, sort_order, created_by, updated_by)
VALUES
    ('PER_PERSON',  'Per person',  'Price applies to each traveller/person.', 10, 'SYSTEM', 'SYSTEM'),
    ('PER_GROUP',   'Per group',   'Price applies once to the qualifying group.', 20, 'SYSTEM', 'SYSTEM'),
    ('PER_ROOM',    'Per room',    'Price applies to one room/unit of accommodation.', 30, 'SYSTEM', 'SYSTEM'),
    ('PER_VEHICLE', 'Per vehicle', 'Price applies to one vehicle.', 40, 'SYSTEM', 'SYSTEM'),
    ('PER_GUIDE',   'Per guide',   'Price applies to one guide.', 50, 'SYSTEM', 'SYSTEM'),
    ('PER_SESSION', 'Per session', 'Price applies to one defined session/appointment.', 60, 'SYSTEM', 'SYSTEM'),
    ('FLAT_RATE',   'Flat rate',   'Single flat catalogue price not calculated per person/resource.', 70, 'SYSTEM', 'SYSTEM')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 2. REFERENCE DATA — PRICING PERIOD
-- ============================================================================

CREATE TABLE IF NOT EXISTS pricing_period_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(40) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_live         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT uq_pricing_period_types_code UNIQUE (code),
    CONSTRAINT chk_pricing_period_types_code CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

COMMENT ON TABLE pricing_period_types IS
    'Optional time period applied to a catalogue pricing basis, e.g. per room per night or per guide per day.';

INSERT INTO pricing_period_types
    (code, name, description, sort_order, created_by, updated_by)
VALUES
    ('PER_HOUR',  'Per hour',  'Price basis repeats for each hour.', 10, 'SYSTEM', 'SYSTEM'),
    ('PER_DAY',   'Per day',   'Price basis repeats for each day.', 20, 'SYSTEM', 'SYSTEM'),
    ('PER_NIGHT', 'Per night', 'Price basis repeats for each night.', 30, 'SYSTEM', 'SYSTEM'),
    ('PER_WEEK',  'Per week',  'Price basis repeats for each week.', 40, 'SYSTEM', 'SYSTEM')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 3. REFERENCE DATA — OCCUPANCY TYPE
-- ============================================================================

CREATE TABLE IF NOT EXISTS occupancy_types (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(30) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_live         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT uq_occupancy_types_code UNIQUE (code),
    CONSTRAINT chk_occupancy_types_code CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

COMMENT ON TABLE occupancy_types IS
    'Optional occupancy classification used by catalogue price offers, primarily for accommodation/shared-capacity pricing.';

INSERT INTO occupancy_types
    (code, name, description, sort_order, created_by, updated_by)
VALUES
    ('SINGLE',  'Single',  'Single occupancy.', 10, 'SYSTEM', 'SYSTEM'),
    ('DOUBLE',  'Double',  'Double occupancy, normally one shared bed.', 20, 'SYSTEM', 'SYSTEM'),
    ('TWIN',    'Twin',    'Two-person occupancy with separate beds where applicable.', 30, 'SYSTEM', 'SYSTEM'),
    ('TRIPLE',  'Triple',  'Three-person occupancy.', 40, 'SYSTEM', 'SYSTEM'),
    ('QUAD',    'Quad',    'Four-person occupancy.', 50, 'SYSTEM', 'SYSTEM'),
    ('SHARED',  'Shared',  'Shared occupancy/capacity arrangement.', 60, 'SYSTEM', 'SYSTEM'),
    ('PRIVATE', 'Private', 'Private occupancy or exclusive use.', 70, 'SYSTEM', 'SYSTEM')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 4. EXTEND LISTING PRICE OFFERS
-- ============================================================================

ALTER TABLE listing_price_offers
    ADD COLUMN IF NOT EXISTS pricing_basis_code  VARCHAR(40),
    ADD COLUMN IF NOT EXISTS pricing_period_code VARCHAR(40),
    ADD COLUMN IF NOT EXISTS min_guests          INTEGER,
    ADD COLUMN IF NOT EXISTS max_guests          INTEGER,
    ADD COLUMN IF NOT EXISTS occupancy_code      VARCHAR(30),
    ADD COLUMN IF NOT EXISTS valid_from          DATE,
    ADD COLUMN IF NOT EXISTS valid_to            DATE;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_listing_price_offers_pricing_basis'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT fk_listing_price_offers_pricing_basis
            FOREIGN KEY (pricing_basis_code)
            REFERENCES pricing_basis_types (code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_listing_price_offers_pricing_period'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT fk_listing_price_offers_pricing_period
            FOREIGN KEY (pricing_period_code)
            REFERENCES pricing_period_types (code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_listing_price_offers_occupancy'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT fk_listing_price_offers_occupancy
            FOREIGN KEY (occupancy_code)
            REFERENCES occupancy_types (code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT;
    END IF;
END $$;

-- ============================================================================
-- 5. VALIDATION CONSTRAINTS
-- ============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_listing_price_offers_min_guests'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT chk_listing_price_offers_min_guests
            CHECK (min_guests IS NULL OR min_guests > 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_listing_price_offers_max_guests'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT chk_listing_price_offers_max_guests
            CHECK (max_guests IS NULL OR max_guests > 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_listing_price_offers_guest_range'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT chk_listing_price_offers_guest_range
            CHECK (
                min_guests IS NULL
                OR max_guests IS NULL
                OR max_guests >= min_guests
            );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_listing_price_offers_validity'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT chk_listing_price_offers_validity
            CHECK (
                valid_from IS NULL
                OR valid_to IS NULL
                OR valid_to >= valid_from
            );
    END IF;
END $$;

-- Non-destructive legacy handling:
-- Existing live rows may have no pricing_basis_code. The NOT VALID constraint
-- preserves them, while still enforcing the rule for new/changed rows.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_listing_price_offers_live_basis'
          AND conrelid = 'listing_price_offers'::regclass
    ) THEN
        ALTER TABLE listing_price_offers
            ADD CONSTRAINT chk_listing_price_offers_live_basis
            CHECK (
                is_live = FALSE
                OR pricing_basis_code IS NOT NULL
            )
            NOT VALID;
    END IF;
END $$;

-- ============================================================================
-- 6. REPLACE OLD UNIQUENESS RULES
-- ============================================================================

DROP INDEX IF EXISTS uq_listing_price_offers_base;
DROP INDEX IF EXISTS uq_listing_price_offers_option;

CREATE INDEX IF NOT EXISTS ix_listing_price_offers_lookup
    ON listing_price_offers
       (listing_id, listing_option_id, offer_code, is_live, valid_from, valid_to);

CREATE INDEX IF NOT EXISTS ix_listing_price_offers_validity
    ON listing_price_offers
       (valid_from, valid_to)
    WHERE is_live = TRUE;

-- ============================================================================
-- 7. PREVENT OVERLAPPING LIVE PRICE PERIODS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validate_listing_price_offer_overlap()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    conflict_id UUID;
BEGIN
    IF NEW.is_live = FALSE THEN
        RETURN NEW;
    END IF;

    SELECT existing.id
      INTO conflict_id
      FROM listing_price_offers existing
     WHERE existing.id <> NEW.id
       AND existing.is_live = TRUE
       AND existing.listing_id = NEW.listing_id
       AND existing.offer_code = NEW.offer_code
       AND (
            (existing.listing_option_id IS NULL AND NEW.listing_option_id IS NULL)
            OR existing.listing_option_id = NEW.listing_option_id
       )
       AND daterange(
               COALESCE(existing.valid_from, '-infinity'::date),
               COALESCE(existing.valid_to,   'infinity'::date),
               '[]'
           )
           &&
           daterange(
               COALESCE(NEW.valid_from, '-infinity'::date),
               COALESCE(NEW.valid_to,   'infinity'::date),
               '[]'
           )
     LIMIT 1;

    IF conflict_id IS NOT NULL THEN
        RAISE EXCEPTION
            'Live listing price offer overlaps existing offer % for listing %, option %, offer_code %',
            conflict_id,
            NEW.listing_id,
            COALESCE(NEW.listing_option_id::text, 'BASE'),
            NEW.offer_code
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_listing_price_offers_no_overlap
    ON listing_price_offers;

CREATE TRIGGER trg_listing_price_offers_no_overlap
BEFORE INSERT OR UPDATE OF
    listing_id,
    listing_option_id,
    offer_code,
    valid_from,
    valid_to,
    is_live
ON listing_price_offers
FOR EACH ROW
EXECUTE FUNCTION fn_validate_listing_price_offer_overlap();

-- ============================================================================
-- 8. COMMENTS
-- ============================================================================

COMMENT ON COLUMN listing_price_offers.pricing_basis_code IS
    'Structured basis for the amount, e.g. PER_PERSON, PER_GROUP, PER_ROOM, PER_VEHICLE.';

COMMENT ON COLUMN listing_price_offers.pricing_period_code IS
    'Optional repeating time period, e.g. PER_NIGHT or PER_DAY. Combine with pricing_basis_code where required.';

COMMENT ON COLUMN listing_price_offers.min_guests IS
    'Minimum traveller/guest count for which this catalogue price offer applies.';

COMMENT ON COLUMN listing_price_offers.max_guests IS
    'Maximum traveller/guest count for which this catalogue price offer applies.';

COMMENT ON COLUMN listing_price_offers.occupancy_code IS
    'Optional structured occupancy classification, primarily for accommodation/shared-capacity offers.';

COMMENT ON COLUMN listing_price_offers.occupancy_description IS
    'Human-readable occupancy/guest assumptions. Retained for display even when structured guest/occupancy fields are populated.';

COMMENT ON COLUMN listing_price_offers.valid_from IS
    'First calendar date on which this catalogue price offer is valid; NULL means no lower date bound.';

COMMENT ON COLUMN listing_price_offers.valid_to IS
    'Last calendar date on which this catalogue price offer is valid; NULL means no upper date bound.';

COMMIT;
