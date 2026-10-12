-- Kampala Nonstop / Africa Nonstop — shared listing catalogue pricing (admin V0)
-- Run ONCE after sql/8_* listings schema. Extends all listing types (Experience, Service, Tour, Event, Activity).
-- Indicative from-price and named tiers; not a full quote/booking snapshot engine.

BEGIN;

CREATE TABLE IF NOT EXISTS listing_pricing_profiles (
    listing_id            UUID PRIMARY KEY,
    default_currency      CHAR(3) NOT NULL DEFAULT 'UGX',
    display_mode          VARCHAR(30) NOT NULL DEFAULT 'TIERS',
    from_price_amount     NUMERIC(18, 2),
    from_price_currency   CHAR(3),
    price_assumptions     TEXT,
    is_live               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by            VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by            VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT fk_listing_pricing_profiles_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_listing_pricing_profiles_currency
        CHECK (default_currency = UPPER(default_currency)),

    CONSTRAINT chk_listing_pricing_profiles_display_mode
        CHECK (display_mode IN ('FROM_PRICE', 'TIERS', 'REQUEST_ONLY')),

    CONSTRAINT chk_listing_pricing_profiles_from_price_currency
        CHECK (from_price_currency IS NULL OR from_price_currency = UPPER(from_price_currency)),

    CONSTRAINT chk_listing_pricing_profiles_from_price_amount
        CHECK (from_price_amount IS NULL OR from_price_amount > 0)
);

CREATE TABLE IF NOT EXISTS listing_price_offers (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id            UUID NOT NULL,
    listing_option_id     UUID,
    offer_code            VARCHAR(50) NOT NULL,
    label                 VARCHAR(150) NOT NULL,
    amount                NUMERIC(18, 2) NOT NULL,
    currency              CHAR(3) NOT NULL,
    occupancy_description TEXT,
    sort_order            INTEGER NOT NULL DEFAULT 0,
    is_live               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by            VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by            VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT fk_listing_price_offers_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_listing_price_offers_option
        FOREIGN KEY (listing_option_id, listing_id)
        REFERENCES listing_options (id, listing_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_listing_price_offers_currency
        CHECK (currency = UPPER(currency)),

    CONSTRAINT chk_listing_price_offers_amount
        CHECK (amount > 0),

    CONSTRAINT chk_listing_price_offers_code
        CHECK (offer_code ~ '^[A-Z][A-Z0-9_]*$')
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_listing_price_offers_base
    ON listing_price_offers (listing_id, offer_code)
    WHERE listing_option_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_listing_price_offers_option
    ON listing_price_offers (listing_id, listing_option_id, offer_code)
    WHERE listing_option_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_listing_price_offers_listing
    ON listing_price_offers (listing_id);

COMMENT ON TABLE listing_pricing_profiles IS 'Per-listing indicative pricing profile (from-price and assumptions).';
COMMENT ON TABLE listing_price_offers IS 'Named price tiers (e.g. STANDARD, SOLO, GROUP) for listing or option.';

COMMIT;
