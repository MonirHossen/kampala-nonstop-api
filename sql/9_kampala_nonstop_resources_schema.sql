-- Kampala Nonstop
-- Resources, fulfilment and Nonstop Connect partner schema
--
-- Existing dependencies:
--   listings, listing_options, users, geographic_areas,
--   tags, attributes and amenities.

BEGIN;

CREATE TABLE resource_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(50) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_live     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE resource_roles (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(50) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_live     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE resource_relationship_types (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code         VARCHAR(50) NOT NULL UNIQUE,
    name         VARCHAR(100) NOT NULL,
    inverse_name VARCHAR(100) NOT NULL,
    description  TEXT,
    is_live      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE location_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(50) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_live     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE resources (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_type_id   UUID NOT NULL,
    name               VARCHAR(150) NOT NULL,
    summary            TEXT,
    description        TEXT,
    operational_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    is_live            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resources_resource_type
        FOREIGN KEY (resource_type_id)
        REFERENCES resource_types (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_resources_operational_status
        CHECK (
            operational_status IN (
                'ACTIVE',
                'SUSPENDED',
                'TEMPORARILY_UNAVAILABLE',
                'CLOSED'
            )
        )
);

CREATE TABLE locations (
    resource_id                 UUID PRIMARY KEY,
    geographic_area_id          UUID NOT NULL,
    address_line_1              VARCHAR(200),
    address_line_2              VARCHAR(200),
    postcode                    VARCHAR(20),
    latitude                    NUMERIC(9, 6),
    longitude                   NUMERIC(9, 6),
    directions                  TEXT,
    arrival_instructions        TEXT,
    pickup_dropoff_instructions TEXT,
    time_zone                   VARCHAR(50) NOT NULL,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_locations_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_locations_geographic_area
        FOREIGN KEY (geographic_area_id)
        REFERENCES geographic_areas (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_locations_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),

    CONSTRAINT chk_locations_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),

    CONSTRAINT chk_locations_coordinate_pair
        CHECK (
            (latitude IS NULL AND longitude IS NULL)
            OR
            (latitude IS NOT NULL AND longitude IS NOT NULL)
        )
);

CREATE TABLE organisations (
    resource_id               UUID PRIMARY KEY,
    legal_name                VARCHAR(150),
    registration_number       VARCHAR(100),
    registration_country_code CHAR(2),
    created_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_organisations_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_organisations_country_code
        CHECK (
            registration_country_code IS NULL
            OR registration_country_code = UPPER(registration_country_code)
        )
);

CREATE TABLE professionals (
    resource_id UUID PRIMARY KEY,
    given_name  VARCHAR(100),
    family_name VARCHAR(100),
    biography   TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_professionals_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_professionals_name
        CHECK (given_name IS NOT NULL OR family_name IS NOT NULL)
);

CREATE TABLE vehicles (
    resource_id         UUID PRIMARY KEY,
    registration_number VARCHAR(50),
    make                VARCHAR(100),
    model               VARCHAR(100),
    manufacture_year    SMALLINT,
    passenger_capacity  SMALLINT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vehicles_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_vehicles_manufacture_year
        CHECK (
            manufacture_year IS NULL
            OR manufacture_year BETWEEN 1900 AND 2200
        ),

    CONSTRAINT chk_vehicles_passenger_capacity
        CHECK (passenger_capacity IS NULL OR passenger_capacity > 0)
);

CREATE TABLE resource_units (
    resource_id               UUID PRIMARY KEY,
    location_id               UUID NOT NULL,
    unit_code                 VARCHAR(50),
    capacity                  INTEGER,
    is_individually_assignable BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_units_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resource_units_location
        FOREIGN KEY (location_id)
        REFERENCES locations (resource_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_resource_units_location_code
        UNIQUE (location_id, unit_code),

    CONSTRAINT chk_resource_units_capacity
        CHECK (capacity IS NULL OR capacity > 0),

    CONSTRAINT chk_resource_units_not_parent
        CHECK (resource_id <> location_id)
);

CREATE TABLE location_type_assignments (
    location_id      UUID NOT NULL,
    location_type_id UUID NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_location_type_assignments
        PRIMARY KEY (location_id, location_type_id),

    CONSTRAINT fk_location_type_assignments_location
        FOREIGN KEY (location_id)
        REFERENCES locations (resource_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_location_type_assignments_type
        FOREIGN KEY (location_type_id)
        REFERENCES location_types (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE listing_fulfilment_requirements (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id        UUID NOT NULL,
    listing_option_id UUID,
    resource_role_id  UUID NOT NULL,
    is_required       BOOLEAN NOT NULL DEFAULT TRUE,
    minimum_count     SMALLINT NOT NULL DEFAULT 1,
    maximum_count     SMALLINT,
    selection_mode    VARCHAR(20) NOT NULL DEFAULT 'DYNAMIC',
    notes             TEXT,
    is_live           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_listing_fulfilment_requirements_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_listing_fulfilment_requirements_option
        FOREIGN KEY (listing_option_id, listing_id)
        REFERENCES listing_options (id, listing_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_listing_fulfilment_requirements_role
        FOREIGN KEY (resource_role_id)
        REFERENCES resource_roles (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_listing_fulfilment_requirement_counts
        CHECK (
            minimum_count >= 0
            AND (maximum_count IS NULL OR maximum_count >= minimum_count)
        ),

    CONSTRAINT chk_listing_fulfilment_required_minimum
        CHECK (
            (is_required = TRUE AND minimum_count >= 1)
            OR
            (is_required = FALSE AND minimum_count = 0)
        ),

    CONSTRAINT chk_listing_fulfilment_selection_mode
        CHECK (selection_mode IN ('DYNAMIC', 'FIXED', 'RESTRICTED'))
);

CREATE UNIQUE INDEX uq_listing_fulfilment_requirement_listing_role
    ON listing_fulfilment_requirements (listing_id, resource_role_id)
    WHERE listing_option_id IS NULL;

CREATE UNIQUE INDEX uq_listing_fulfilment_requirement_option_role
    ON listing_fulfilment_requirements (
        listing_id,
        listing_option_id,
        resource_role_id
    )
    WHERE listing_option_id IS NOT NULL;

CREATE TABLE listing_resources (
    fulfilment_requirement_id UUID NOT NULL,
    resource_id               UUID NOT NULL,
    is_preferred              BOOLEAN NOT NULL DEFAULT FALSE,
    is_live                   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_listing_resources
        PRIMARY KEY (fulfilment_requirement_id, resource_id),

    CONSTRAINT fk_listing_resources_requirement
        FOREIGN KEY (fulfilment_requirement_id)
        REFERENCES listing_fulfilment_requirements (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_listing_resources_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE resource_relationships (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_resource_id   UUID NOT NULL,
    relationship_type_id UUID NOT NULL,
    target_resource_id   UUID NOT NULL,
    valid_from           DATE,
    valid_to             DATE,
    is_live              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_relationships_source
        FOREIGN KEY (source_resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resource_relationships_type
        FOREIGN KEY (relationship_type_id)
        REFERENCES resource_relationship_types (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_resource_relationships_target
        FOREIGN KEY (target_resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_resource_relationships
        UNIQUE (
            source_resource_id,
            relationship_type_id,
            target_resource_id
        ),

    CONSTRAINT chk_resource_relationships_not_self
        CHECK (source_resource_id <> target_resource_id),

    CONSTRAINT chk_resource_relationships_dates
        CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from)
);

CREATE TABLE partners (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL UNIQUE,
    partner_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    is_live        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_partners_user
        FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_partners_status
        CHECK (partner_status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'CLOSED'))
);

CREATE TABLE partner_resources (
    partner_id         UUID NOT NULL,
    resource_id        UUID NOT NULL,
    is_primary_contact BOOLEAN NOT NULL DEFAULT FALSE,
    can_manage_bookings BOOLEAN NOT NULL DEFAULT TRUE,
    is_live            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_partner_resources
        PRIMARY KEY (partner_id, resource_id),

    CONSTRAINT fk_partner_resources_partner
        FOREIGN KEY (partner_id)
        REFERENCES partners (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_partner_resources_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX uq_partner_resources_primary_contact
    ON partner_resources (resource_id)
    WHERE is_primary_contact = TRUE AND is_live = TRUE;

CREATE TABLE resource_contacts (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_id   UUID NOT NULL,
    contact_type  VARCHAR(30) NOT NULL,
    label         VARCHAR(100),
    contact_value TEXT NOT NULL,
    is_primary    BOOLEAN NOT NULL DEFAULT FALSE,
    is_public     BOOLEAN NOT NULL DEFAULT FALSE,
    is_live       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_contacts_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_resource_contacts_type
        CHECK (contact_type IN ('PHONE', 'EMAIL', 'WEBSITE', 'WHATSAPP', 'OTHER'))
);

CREATE UNIQUE INDEX uq_resource_contacts_primary
    ON resource_contacts (resource_id, contact_type)
    WHERE is_primary = TRUE AND is_live = TRUE;

CREATE TABLE resource_media (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_id UUID NOT NULL,
    media_url  TEXT NOT NULL,
    media_type VARCHAR(30) NOT NULL,
    caption    TEXT,
    alt_text   TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_cover   BOOLEAN NOT NULL DEFAULT FALSE,
    is_live    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_media_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_resource_media_type
        CHECK (media_type IN ('IMAGE', 'VIDEO')),

    CONSTRAINT chk_resource_media_sort_order
        CHECK (sort_order >= 0)
);

CREATE UNIQUE INDEX uq_resource_media_one_cover
    ON resource_media (resource_id)
    WHERE is_cover = TRUE AND is_live = TRUE;

CREATE TABLE resource_tags (
    resource_id UUID NOT NULL,
    tag_id      UUID NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_resource_tags
        PRIMARY KEY (resource_id, tag_id),

    CONSTRAINT fk_resource_tags_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resource_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES tags (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE resource_attribute_values (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_id   UUID NOT NULL,
    attribute_id  UUID NOT NULL,
    text_value    TEXT,
    number_value  NUMERIC,
    boolean_value BOOLEAN,
    unit          VARCHAR(50),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_attribute_values_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resource_attribute_values_attribute
        FOREIGN KEY (attribute_id)
        REFERENCES attributes (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_resource_attribute_values_one_value
        CHECK (num_nonnulls(text_value, number_value, boolean_value) = 1),

    CONSTRAINT chk_resource_attribute_values_unit
        CHECK (unit IS NULL OR number_value IS NOT NULL)
);

CREATE TABLE resource_amenities (
    resource_id UUID NOT NULL,
    amenity_id  UUID NOT NULL,
    details     TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_resource_amenities
        PRIMARY KEY (resource_id, amenity_id),

    CONSTRAINT fk_resource_amenities_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resource_amenities_amenity
        FOREIGN KEY (amenity_id)
        REFERENCES amenities (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE location_opening_hours (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id    UUID NOT NULL,
    day_of_week    SMALLINT NOT NULL,
    start_time     TIME NOT NULL,
    end_time       TIME NOT NULL,
    end_day_offset SMALLINT NOT NULL DEFAULT 0,
    is_live        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_location_opening_hours_location
        FOREIGN KEY (location_id)
        REFERENCES locations (resource_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_location_opening_hours_day
        CHECK (day_of_week BETWEEN 0 AND 6),

    CONSTRAINT chk_location_opening_hours_offset
        CHECK (end_day_offset IN (0, 1)),

    CONSTRAINT chk_location_opening_hours_window
        CHECK (
            (end_day_offset = 0 AND end_time > start_time)
            OR end_day_offset = 1
        )
);

CREATE TABLE location_hours_exceptions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id    UUID NOT NULL,
    exception_date DATE NOT NULL,
    is_closed      BOOLEAN NOT NULL DEFAULT TRUE,
    start_time     TIME,
    end_time       TIME,
    end_day_offset SMALLINT NOT NULL DEFAULT 0,
    reason         TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_location_hours_exceptions_location
        FOREIGN KEY (location_id)
        REFERENCES locations (resource_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_location_hours_exceptions_offset
        CHECK (end_day_offset IN (0, 1)),

    CONSTRAINT chk_location_hours_exceptions_times
        CHECK (
            (is_closed = TRUE AND start_time IS NULL AND end_time IS NULL)
            OR
            (
                is_closed = FALSE
                AND start_time IS NOT NULL
                AND end_time IS NOT NULL
            )
        ),

    CONSTRAINT chk_location_hours_exceptions_window
        CHECK (
            start_time IS NULL
            OR (end_day_offset = 0 AND end_time > start_time)
            OR end_day_offset = 1
        )
);

CREATE TABLE resource_availability_hours (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_id    UUID NOT NULL,
    day_of_week    SMALLINT NOT NULL,
    start_time     TIME NOT NULL,
    end_time       TIME NOT NULL,
    end_day_offset SMALLINT NOT NULL DEFAULT 0,
    is_live        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_availability_hours_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_resource_availability_hours_day
        CHECK (day_of_week BETWEEN 0 AND 6),

    CONSTRAINT chk_resource_availability_hours_offset
        CHECK (end_day_offset IN (0, 1)),

    CONSTRAINT chk_resource_availability_hours_window
        CHECK (
            (end_day_offset = 0 AND end_time > start_time)
            OR end_day_offset = 1
        )
);

CREATE TABLE resource_availability_exceptions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_id    UUID NOT NULL,
    exception_date DATE NOT NULL,
    is_available   BOOLEAN NOT NULL DEFAULT FALSE,
    start_time     TIME,
    end_time       TIME,
    end_day_offset SMALLINT NOT NULL DEFAULT 0,
    reason         TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_availability_exceptions_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_resource_availability_exceptions_offset
        CHECK (end_day_offset IN (0, 1)),

    CONSTRAINT chk_resource_availability_exceptions_time_pair
        CHECK (
            (start_time IS NULL AND end_time IS NULL)
            OR
            (start_time IS NOT NULL AND end_time IS NOT NULL)
        ),

    CONSTRAINT chk_resource_availability_exceptions_window
        CHECK (
            start_time IS NULL
            OR (end_day_offset = 0 AND end_time > start_time)
            OR end_day_offset = 1
        )
);

CREATE INDEX idx_resources_resource_type
    ON resources (resource_type_id);

CREATE INDEX idx_resources_operational_lookup
    ON resources (resource_type_id, operational_status, is_live);

CREATE INDEX idx_locations_geographic_area
    ON locations (geographic_area_id);

CREATE INDEX idx_location_type_assignments_type
    ON location_type_assignments (location_type_id);

CREATE INDEX idx_resource_units_location
    ON resource_units (location_id);

CREATE INDEX idx_listing_fulfilment_requirements_listing
    ON listing_fulfilment_requirements (listing_id);

CREATE INDEX idx_listing_fulfilment_requirements_option
    ON listing_fulfilment_requirements (listing_option_id)
    WHERE listing_option_id IS NOT NULL;

CREATE INDEX idx_listing_fulfilment_requirements_role
    ON listing_fulfilment_requirements (resource_role_id);

CREATE INDEX idx_listing_resources_resource
    ON listing_resources (resource_id);

CREATE INDEX idx_resource_relationships_target
    ON resource_relationships (target_resource_id);

CREATE INDEX idx_resource_relationships_type
    ON resource_relationships (relationship_type_id);

CREATE INDEX idx_partner_resources_resource
    ON partner_resources (resource_id);

CREATE INDEX idx_resource_contacts_resource
    ON resource_contacts (resource_id);

CREATE INDEX idx_resource_media_order
    ON resource_media (resource_id, sort_order);

CREATE INDEX idx_resource_tags_tag
    ON resource_tags (tag_id);

CREATE INDEX idx_resource_attribute_values_resource
    ON resource_attribute_values (resource_id);

CREATE INDEX idx_resource_attribute_values_attribute
    ON resource_attribute_values (attribute_id);

CREATE INDEX idx_resource_amenities_amenity
    ON resource_amenities (amenity_id);

CREATE INDEX idx_location_opening_hours_lookup
    ON location_opening_hours (location_id, day_of_week, is_live);

CREATE INDEX idx_location_hours_exceptions_lookup
    ON location_hours_exceptions (location_id, exception_date);

CREATE INDEX idx_resource_availability_hours_lookup
    ON resource_availability_hours (resource_id, day_of_week, is_live);

CREATE INDEX idx_resource_availability_exceptions_lookup
    ON resource_availability_exceptions (resource_id, exception_date);

COMMENT ON TABLE listing_fulfilment_requirements IS
    'Resource capabilities needed to deliver a listing or listing option.';

COMMENT ON TABLE listing_resources IS
    'Specific resources allowed for FIXED or RESTRICTED fulfilment requirements. DYNAMIC requirements are matched at booking time.';

COMMENT ON COLUMN resources.operational_status IS
    'Operational eligibility status: ACTIVE, SUSPENDED, TEMPORARILY_UNAVAILABLE or CLOSED.';

COMMENT ON COLUMN listing_fulfilment_requirements.selection_mode IS
    'DYNAMIC searches matching active resources; FIXED or RESTRICTED uses listing_resources.';

COMMENT ON COLUMN location_opening_hours.day_of_week IS
    'ISO weekday number: 0 = Monday through 6 = Sunday.';

COMMENT ON COLUMN resource_availability_hours.day_of_week IS
    'ISO weekday number: 0 = Monday through 6 = Sunday.';

COMMENT ON COLUMN location_opening_hours.end_day_offset IS
    '0 for the same day and 1 for the following day.';

COMMENT ON COLUMN resource_availability_hours.end_day_offset IS
    '0 for the same day and 1 for the following day.';

COMMIT;
