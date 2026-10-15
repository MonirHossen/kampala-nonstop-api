-- ============================================================================
-- Africa Nonstop / Kampala Nonstop
-- 16_kampala_nonstop_trip_planning_schema.sql
--
-- Trip planning foundation
--
-- Terminology:
--   "customer" is used instead of "traveller" because Nonstop also supports
--   local users who may be planning activities without travelling to Uganda.
--
-- Dependencies:
--   users(id)
--   listings(id)
--
-- PostgreSQL:
--   Uses native uuidv7() (PostgreSQL 18+).
--
-- Model:
--   users -> trips -> trip_customers
--                  -> trip_requirements
--                  -> trip_listings       [customer's Add to Trip selections]
--                  -> itineraries
--                       -> itinerary_items [planner/admin output]
--
-- Audit convention:
--   created_by / updated_by are retained where records may be changed by
--   customers, admins, concierge or automated planning processes.
--
--   trip_listings is intentionally different: it is a simple user-action
--   junction (INSERT = add to trip, DELETE = remove from trip), so it carries
--   created_at only.
-- ============================================================================

BEGIN;

CREATE TABLE trips (
    id                  UUID PRIMARY KEY DEFAULT uuidv7(),
    owner_user_id       UUID NOT NULL,
    name                VARCHAR(150),
    country_code        CHAR(2) NOT NULL DEFAULT 'UG',
    start_date          DATE,
    end_date            DATE,
    status_code         VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    updated_by          VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_trips_owner_user
        FOREIGN KEY (owner_user_id)
        REFERENCES users (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_trips_country_code
        CHECK (country_code = UPPER(country_code)),
    CONSTRAINT chk_trips_date_range
        CHECK (
            end_date IS NULL
            OR start_date IS NULL
            OR end_date >= start_date
        ),
    CONSTRAINT chk_trips_status_code
        CHECK (
            status_code IN (
                'DRAFT',
                'PLANNING',
                'SUBMITTED',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
            )
        )
);

CREATE INDEX idx_trips_owner_user_id
    ON trips (owner_user_id);

CREATE INDEX idx_trips_owner_status
    ON trips (owner_user_id, status_code);


CREATE TABLE trip_customers (
    id                      UUID PRIMARY KEY DEFAULT uuidv7(),
    trip_id                 UUID NOT NULL,
    user_id                 UUID,
    first_name              VARCHAR(100),
    middle_name             VARCHAR(100),
    last_name               VARCHAR(100),
    date_of_birth           DATE,
    country_of_residence    CHAR(2),
    is_primary_customer     BOOLEAN NOT NULL DEFAULT FALSE,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    updated_by              VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_trip_customers_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_trip_customers_user
        FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT uq_trip_customers_id_trip
        UNIQUE (id, trip_id),
    CONSTRAINT chk_trip_customers_identity
        CHECK (
            user_id IS NOT NULL
            OR (
                first_name IS NOT NULL
                AND last_name IS NOT NULL
            )
        ),
    CONSTRAINT chk_trip_customers_country_code
        CHECK (
            country_of_residence IS NULL
            OR country_of_residence = UPPER(country_of_residence)
        )
);

CREATE INDEX idx_trip_customers_trip_id
    ON trip_customers (trip_id);

CREATE UNIQUE INDEX uq_trip_customers_registered_user
    ON trip_customers (trip_id, user_id)
    WHERE user_id IS NOT NULL;

CREATE UNIQUE INDEX uq_trip_customers_one_primary
    ON trip_customers (trip_id)
    WHERE is_primary_customer = TRUE;


CREATE TABLE trip_requirements (
    id                  UUID PRIMARY KEY DEFAULT uuidv7(),
    trip_id             UUID NOT NULL,
    trip_customer_id    UUID,
    requirement_code    VARCHAR(50) NOT NULL,
    value_json          JSONB NOT NULL DEFAULT '{}'::jsonb,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    updated_by          VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_trip_requirements_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_trip_requirements_customer
        FOREIGN KEY (trip_customer_id, trip_id)
        REFERENCES trip_customers (id, trip_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_trip_requirements_code
        CHECK (requirement_code = UPPER(requirement_code)),
    CONSTRAINT uq_trip_requirements_scope
        UNIQUE NULLS NOT DISTINCT (
            trip_id,
            trip_customer_id,
            requirement_code
        )
);

CREATE INDEX idx_trip_requirements_trip_id
    ON trip_requirements (trip_id);

CREATE INDEX idx_trip_requirements_customer_id
    ON trip_requirements (trip_customer_id)
    WHERE trip_customer_id IS NOT NULL;

CREATE INDEX idx_trip_requirements_value_json
    ON trip_requirements USING GIN (value_json);


CREATE TABLE trip_listings (
    id          UUID PRIMARY KEY DEFAULT uuidv7(),
    trip_id     UUID NOT NULL,
    listing_id  UUID NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trip_listings_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_trip_listings_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_trip_listings_trip_listing
        UNIQUE (trip_id, listing_id)
);

CREATE INDEX idx_trip_listings_listing_id
    ON trip_listings (listing_id);


CREATE TABLE itineraries (
    id              UUID PRIMARY KEY DEFAULT uuidv7(),
    trip_id         UUID NOT NULL,
    version_number  INTEGER NOT NULL DEFAULT 1,
    status_code     VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    is_current      BOOLEAN NOT NULL DEFAULT TRUE,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    updated_by      VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_itineraries_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT uq_itineraries_trip_version
        UNIQUE (trip_id, version_number),
    CONSTRAINT chk_itineraries_version
        CHECK (version_number > 0),
    CONSTRAINT chk_itineraries_status
        CHECK (
            status_code IN (
                'DRAFT',
                'PROPOSED',
                'ACCEPTED',
                'SUPERSEDED'
            )
        )
);

CREATE UNIQUE INDEX uq_itineraries_one_current
    ON itineraries (trip_id)
    WHERE is_current = TRUE;

CREATE INDEX idx_itineraries_trip_id
    ON itineraries (trip_id);


CREATE TABLE itinerary_items (
    id                      UUID PRIMARY KEY DEFAULT uuidv7(),
    itinerary_id            UUID NOT NULL,
    listing_id              UUID NOT NULL,
    source_trip_listing_id  UUID,
    scheduled_date          DATE,
    start_time              TIME,
    end_time                TIME,
    end_day_offset          SMALLINT NOT NULL DEFAULT 0,
    sort_order              INTEGER NOT NULL DEFAULT 0,
    is_optional             BOOLEAN NOT NULL DEFAULT FALSE,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    updated_by              VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_itinerary_items_itinerary
        FOREIGN KEY (itinerary_id)
        REFERENCES itineraries (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_itinerary_items_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_itinerary_items_source_trip_listing
        FOREIGN KEY (source_trip_listing_id)
        REFERENCES trip_listings (id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT chk_itinerary_items_end_day_offset
        CHECK (end_day_offset IN (0, 1)),
    CONSTRAINT chk_itinerary_items_sort_order
        CHECK (sort_order >= 0),
    CONSTRAINT chk_itinerary_items_time_pair
        CHECK (
            (start_time IS NULL AND end_time IS NULL)
            OR
            (start_time IS NOT NULL AND end_time IS NOT NULL)
        ),
    CONSTRAINT chk_itinerary_items_time_window
        CHECK (
            start_time IS NULL
            OR end_time IS NULL
            OR end_day_offset = 1
            OR end_time > start_time
        )
);

CREATE INDEX idx_itinerary_items_itinerary_order
    ON itinerary_items (itinerary_id, scheduled_date, sort_order);

CREATE INDEX idx_itinerary_items_listing_id
    ON itinerary_items (listing_id);

CREATE INDEX idx_itinerary_items_source_trip_listing
    ON itinerary_items (source_trip_listing_id)
    WHERE source_trip_listing_id IS NOT NULL;


COMMENT ON COLUMN trips.owner_user_id IS
    'Registered Nonstop user who owns/manages the trip. This does not imply that the user is necessarily one of the trip customers.';

COMMENT ON TABLE trip_customers IS
    'People the trip or plan is for. Customer terminology is used rather than traveller because Nonstop also supports local users.';

COMMENT ON TABLE trip_listings IS
    'Explicit customer Add to Trip selections. These are planner inputs, not scheduled itinerary items.';

COMMENT ON COLUMN itinerary_items.source_trip_listing_id IS
    'Optional trace back to a customer-selected trip_listings row. NULL means the item may have been recommended or added by the planner/admin.';

COMMIT;
