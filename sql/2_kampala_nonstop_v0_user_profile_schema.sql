-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- V0 Booking Customer - User Profile Schema
--
-- Target database : PostgreSQL 18+
-- Application     : Laravel
-- Primary keys    : Native PostgreSQL UUID, UUIDv7
-- Timestamps      : TIMESTAMPTZ
--
-- Deferred from this feature:
--   - user_interests       -> Trip feature
--   - user_support_needs   -> Trip / Concierge feature
--   - roles / permissions  -> Authentication & Authorisation feature
--
-- Country values use ISO 3166-1 alpha-2 codes (e.g. GB, UG) and should be
-- validated by the Laravel ISO package. No duplicate Nonstop countries table
-- is required for this schema.
-- ============================================================================

BEGIN;

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuidv7(),
    email               VARCHAR(255) NOT NULL,
    password            VARCHAR(255) NOT NULL,
    email_verified_at   TIMESTAMPTZ NULL,
    remember_token      VARCHAR(100) NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'inactive')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at          TIMESTAMPTZ NULL
);

CREATE UNIQUE INDEX uq_users_email_ci ON users (LOWER(email));
CREATE INDEX idx_users_active ON users (status) WHERE deleted_at IS NULL;

CREATE TABLE user_profiles (
    id                      UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id                 UUID NOT NULL UNIQUE,
    title                   VARCHAR(20) NULL,
    first_name              VARCHAR(100) NOT NULL,
    middle_name             VARCHAR(100) NULL,
    last_name               VARCHAR(100) NOT NULL,
    gender                  VARCHAR(30) NULL,
    date_of_birth           DATE NULL,
    phone_number            VARCHAR(32) NULL,
    city_of_residence       VARCHAR(100) NULL,
    country_of_residence    CHAR(2) NULL,
    profile_photo_url       VARCHAR(500) NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT chk_user_profiles_country_of_residence
        CHECK (
            country_of_residence IS NULL
            OR country_of_residence = UPPER(country_of_residence)
        )
);

CREATE TABLE user_citizenships (
    id              UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id         UUID NOT NULL,
    country_code    CHAR(2) NOT NULL,
    is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_citizenships_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT uq_user_citizenships_country
        UNIQUE (user_id, country_code),

    CONSTRAINT chk_user_citizenships_country_code
        CHECK (country_code = UPPER(country_code))
);

CREATE UNIQUE INDEX uq_user_citizenships_primary
    ON user_citizenships (user_id)
    WHERE is_primary = TRUE;

CREATE INDEX idx_user_citizenships_user
    ON user_citizenships (user_id);

CREATE TABLE user_preferences (
    id                      UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id                 UUID NOT NULL UNIQUE,
    preferred_language      VARCHAR(10) NOT NULL DEFAULT 'en',
    preferred_currency      CHAR(3) NULL,
    distance_unit           VARCHAR(2) NOT NULL DEFAULT 'km'
                            CHECK (distance_unit IN ('km', 'mi')),
    temperature_unit        CHAR(1) NOT NULL DEFAULT 'c'
                            CHECK (temperature_unit IN ('c', 'f')),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_preferences_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT chk_user_preferences_currency
        CHECK (
            preferred_currency IS NULL
            OR preferred_currency = UPPER(preferred_currency)
        )
);

CREATE TABLE user_favourites (
    id                  UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id             UUID NOT NULL,
    favouritable_type   VARCHAR(32) NOT NULL
                        CHECK (
                            favouritable_type IN (
                                'place',
                                'activity',
                                'event',
                                'tour',
                                'service',
                                'organisation',
                                'experience'
                            )
                        ),
    favouritable_id     UUID NOT NULL,
    notes               VARCHAR(500) NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_favourites_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT uq_user_favourites_item
        UNIQUE (user_id, favouritable_type, favouritable_id)
);

CREATE INDEX idx_user_favourites_user
    ON user_favourites (user_id);

CREATE INDEX idx_user_favourites_target
    ON user_favourites (favouritable_type, favouritable_id);

CREATE TABLE user_consents (
    id                  UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id             UUID NOT NULL,
    consent_type        VARCHAR(50) NOT NULL
                        CHECK (
                            consent_type IN (
                                'marketing',
                                'terms_of_service',
                                'privacy_policy'
                            )
                        ),
    is_granted          BOOLEAN NOT NULL DEFAULT FALSE,
    granted_at          TIMESTAMPTZ NULL,
    withdrawn_at        TIMESTAMPTZ NULL,
    policy_version      VARCHAR(20) NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_consents_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT uq_user_consents_type
        UNIQUE (user_id, consent_type),

    CONSTRAINT chk_user_consents_granted_at
        CHECK (is_granted = FALSE OR granted_at IS NOT NULL),

    CONSTRAINT chk_user_consents_withdrawn
        CHECK (withdrawn_at IS NULL OR is_granted = FALSE)
);

CREATE INDEX idx_user_consents_user
    ON user_consents (user_id);

CREATE TABLE user_notification_preferences (
    id              UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id         UUID NOT NULL UNIQUE,
    email_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
    push_enabled    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_notification_preferences_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

COMMENT ON TABLE users IS
    'Core customer account and authentication identity.';

COMMENT ON TABLE user_profiles IS
    'Booking-customer personal profile. One row per user.';

COMMENT ON COLUMN user_profiles.phone_number IS
    'Normalise to international/E.164 format in the application where possible.';

COMMENT ON COLUMN user_profiles.country_of_residence IS
    'ISO 3166-1 alpha-2 country code, validated by the Laravel ISO package.';

COMMENT ON TABLE user_citizenships IS
    'One or more citizenships held by a user.';

COMMENT ON COLUMN user_citizenships.country_code IS
    'ISO 3166-1 alpha-2 country code, validated by the Laravel ISO package.';

COMMENT ON TABLE user_preferences IS
    'Persistent platform/localisation preferences only; trip-specific preferences are excluded.';

COMMENT ON COLUMN user_preferences.preferred_currency IS
    'ISO 4217 currency code, e.g. GBP or UGX.';

COMMENT ON TABLE user_favourites IS
    'Discovery entities saved/favourited by a user.';

COMMENT ON COLUMN user_favourites.favouritable_type IS
    'Stable Laravel morph-map code, not a PHP class name.';

COMMENT ON TABLE user_consents IS
    'Current legal/permission consent state for a user.';

COMMENT ON TABLE user_notification_preferences IS
    'Communication delivery-channel preferences; these settings do not themselves constitute marketing consent.';

COMMIT;

-- PostgreSQL 18 introduced native uuidv7().
-- Laravel should manage updated_at on normal application writes.
-- Full residential addresses/postcodes are deliberately not collected in V0.
