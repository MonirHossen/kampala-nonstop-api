-- Kampala Nonstop
-- Listings catalogue and booking-configuration schema
-- Requires the existing subcategories, tags, attributes and geographic_areas tables.
-- Actual resources, resource availability, assignments and bookings are outside this script.


BEGIN;


CREATE TABLE listing_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(50) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_live     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE listings (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_type_id       UUID NOT NULL,
    subcategory_id        UUID NOT NULL,
    name                  VARCHAR(150) NOT NULL,
    slug                  VARCHAR(180) NOT NULL,
    summary               TEXT,
    description           TEXT,
    country_code          CHAR(2) NOT NULL,
    geographic_area_id    UUID,
    inclusions            TEXT,
    exclusions            TEXT,
    what_to_bring         TEXT,
    important_information TEXT,
    booking_instructions  TEXT,
    is_local_gem          BOOLEAN NOT NULL DEFAULT FALSE,
    is_hot_pick           BOOLEAN NOT NULL DEFAULT FALSE,
    is_live               BOOLEAN NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listings_listing_type
        FOREIGN KEY (listing_type_id)
        REFERENCES listing_types (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,


    CONSTRAINT fk_listings_subcategory
        FOREIGN KEY (subcategory_id)
        REFERENCES subcategories (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,


    CONSTRAINT fk_listings_geographic_area
        FOREIGN KEY (geographic_area_id)
        REFERENCES geographic_areas (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,


    CONSTRAINT uq_listings_country_slug
        UNIQUE (country_code, slug),


    CONSTRAINT chk_listings_country_code
        CHECK (country_code = UPPER(country_code))
);


CREATE TABLE listing_tags (
    listing_id UUID NOT NULL,
    tag_id     UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT pk_listing_tags
        PRIMARY KEY (listing_id, tag_id),


    CONSTRAINT fk_listing_tags_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT fk_listing_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES tags (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


CREATE TABLE listing_attribute_values (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id    UUID NOT NULL,
    attribute_id  UUID NOT NULL,
    text_value    TEXT,
    number_value  NUMERIC,
    boolean_value BOOLEAN,
    unit          VARCHAR(50),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listing_attribute_values_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT fk_listing_attribute_values_attribute
        FOREIGN KEY (attribute_id)
        REFERENCES attributes (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,


    CONSTRAINT chk_listing_attribute_values_one_value
        CHECK (num_nonnulls(text_value, number_value, boolean_value) = 1),


    CONSTRAINT chk_listing_attribute_values_unit
        CHECK (unit IS NULL OR number_value IS NOT NULL)
);


CREATE TABLE listing_options (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id       UUID NOT NULL,
    name             VARCHAR(100) NOT NULL,
    description      TEXT,
    duration_minutes INTEGER,
    min_participants INTEGER,
    max_participants INTEGER,
    is_default       BOOLEAN NOT NULL DEFAULT FALSE,
    is_live          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listing_options_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT uq_listing_options_id_listing
        UNIQUE (id, listing_id),


    CONSTRAINT uq_listing_options_name
        UNIQUE (listing_id, name),


    CONSTRAINT chk_listing_options_duration
        CHECK (duration_minutes IS NULL OR duration_minutes > 0),


    CONSTRAINT chk_listing_options_min_participants
        CHECK (min_participants IS NULL OR min_participants > 0),


    CONSTRAINT chk_listing_options_max_participants
        CHECK (max_participants IS NULL OR max_participants > 0),


    CONSTRAINT chk_listing_options_participant_range
        CHECK (
            min_participants IS NULL
            OR max_participants IS NULL
            OR min_participants <= max_participants
        )
);


CREATE UNIQUE INDEX uq_listing_options_one_default
    ON listing_options (listing_id)
    WHERE is_default = TRUE;


CREATE TABLE listing_media (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL,
    media_url  TEXT NOT NULL,
    media_type VARCHAR(30) NOT NULL,
    caption    TEXT,
    alt_text   TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_cover   BOOLEAN NOT NULL DEFAULT FALSE,
    is_live    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listing_media_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT chk_listing_media_sort_order
        CHECK (sort_order >= 0)
);


CREATE UNIQUE INDEX uq_listing_media_one_cover
    ON listing_media (listing_id)
    WHERE is_cover = TRUE;


CREATE TABLE listing_booking_rules (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id               UUID NOT NULL,
    listing_option_id        UUID,
    minimum_notice_minutes   INTEGER,
    maximum_advance_days     INTEGER,
    buffer_before_minutes    INTEGER NOT NULL DEFAULT 0,
    buffer_after_minutes     INTEGER NOT NULL DEFAULT 0,
    earliest_arrival_time    TIME,
    latest_arrival_time      TIME,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listing_booking_rules_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT fk_listing_booking_rules_option
        FOREIGN KEY (listing_option_id, listing_id)
        REFERENCES listing_options (id, listing_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT chk_listing_booking_rules_notice
        CHECK (minimum_notice_minutes IS NULL OR minimum_notice_minutes >= 0),


    CONSTRAINT chk_listing_booking_rules_advance
        CHECK (maximum_advance_days IS NULL OR maximum_advance_days >= 0),


    CONSTRAINT chk_listing_booking_rules_buffer_before
        CHECK (buffer_before_minutes >= 0),


    CONSTRAINT chk_listing_booking_rules_buffer_after
        CHECK (buffer_after_minutes >= 0),


    CONSTRAINT chk_listing_booking_rules_arrival_pair
        CHECK (
            (earliest_arrival_time IS NULL AND latest_arrival_time IS NULL)
            OR
            (earliest_arrival_time IS NOT NULL AND latest_arrival_time IS NOT NULL)
        )
);


CREATE UNIQUE INDEX uq_listing_booking_rules_base
    ON listing_booking_rules (listing_id)
    WHERE listing_option_id IS NULL;


CREATE UNIQUE INDEX uq_listing_booking_rules_option
    ON listing_booking_rules (listing_id, listing_option_id)
    WHERE listing_option_id IS NOT NULL;


CREATE TABLE listing_booking_hours (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id         UUID NOT NULL,
    listing_option_id  UUID,
    day_of_week        SMALLINT NOT NULL,
    start_time         TIME NOT NULL,
    end_time           TIME NOT NULL,
    end_day_offset     SMALLINT NOT NULL DEFAULT 0,
    is_live            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_listing_booking_hours_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT fk_listing_booking_hours_option
        FOREIGN KEY (listing_option_id, listing_id)
        REFERENCES listing_options (id, listing_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,


    CONSTRAINT chk_listing_booking_hours_day
        CHECK (day_of_week BETWEEN 0 AND 6),


    CONSTRAINT chk_listing_booking_hours_end_day_offset
        CHECK (end_day_offset IN (0, 1)),


    CONSTRAINT chk_listing_booking_hours_window
        CHECK (
            (end_day_offset = 0 AND end_time > start_time)
            OR
            (end_day_offset = 1)
        )
);


CREATE INDEX idx_listings_listing_type_id
    ON listings (listing_type_id);


CREATE INDEX idx_listings_subcategory_id
    ON listings (subcategory_id);


CREATE INDEX idx_listings_geographic_area_id
    ON listings (geographic_area_id);


CREATE INDEX idx_listings_discovery
    ON listings (country_code, is_live, subcategory_id);


CREATE INDEX idx_listing_tags_tag_id
    ON listing_tags (tag_id);


CREATE INDEX idx_listing_attribute_values_listing
    ON listing_attribute_values (listing_id);


CREATE INDEX idx_listing_attribute_values_attribute
    ON listing_attribute_values (attribute_id);


CREATE INDEX idx_listing_options_listing
    ON listing_options (listing_id);


CREATE INDEX idx_listing_media_listing_order
    ON listing_media (listing_id, sort_order);


CREATE INDEX idx_listing_booking_rules_listing
    ON listing_booking_rules (listing_id);


CREATE INDEX idx_listing_booking_hours_lookup
    ON listing_booking_hours (listing_id, day_of_week, is_live);


COMMENT ON COLUMN listings.country_code IS
    'ISO 3166-1 alpha-2 code validated against the application country package.';


COMMENT ON COLUMN listing_booking_hours.day_of_week IS
    'ISO weekday number: 0 = Monday through 6 = Sunday.';


COMMENT ON COLUMN listing_booking_hours.end_day_offset IS
    '0 when the window ends on the same day; 1 when it ends on the following day.';


COMMIT;