-- Kampala Nonstop
-- Resource reference seed data

BEGIN;

INSERT INTO resource_types (
    id,
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        '0199-4c00-7001-8000-000000000001',
        'LOCATION',
        'Location',
        'A physical establishment or site that provides capability for a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7002-8000-000000000002',
        'ORGANISATION',
        'Organisation',
        'A business or institution that provides or manages resources used to fulfil listings.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7003-8000-000000000003',
        'PROFESSIONAL',
        'Professional',
        'An individual who personally provides capability for a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7004-8000-000000000004',
        'VEHICLE',
        'Vehicle',
        'A transport asset that may be assigned to fulfil a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7005-8000-000000000005',
        'UNIT',
        'Unit',
        'An assignable space within a location, such as a table or treatment room.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_live     = EXCLUDED.is_live,
    updated_at  = CURRENT_TIMESTAMP;

INSERT INTO resource_roles (
    id,
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        '0199-4c00-7101-8000-000000000001',
        'VENUE',
        'Venue',
        'Hosts the activity, event, tour component or service.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7102-8000-000000000002',
        'OPERATOR',
        'Operator',
        'Operates or coordinates delivery of the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7103-8000-000000000003',
        'GUIDE',
        'Guide',
        'Guides travellers during an activity, tour or experience.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7104-8000-000000000004',
        'DRIVER',
        'Driver',
        'Provides driving capability for traveller transport.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7105-8000-000000000005',
        'CONCIERGE',
        'Concierge',
        'Coordinates or accompanies the traveller during delivery.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7106-8000-000000000006',
        'THERAPIST',
        'Therapist',
        'Delivers a treatment, massage or related wellness service.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7107-8000-000000000007',
        'VEHICLE',
        'Vehicle',
        'Provides the transport capacity required by the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7108-8000-000000000008',
        'ACCOMMODATION',
        'Accommodation',
        'Provides the accommodation needed to fulfil the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7109-8000-000000000009',
        'TREATMENT_SPACE',
        'Treatment Space',
        'Provides the room or space needed to deliver a treatment.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_live     = EXCLUDED.is_live,
    updated_at  = CURRENT_TIMESTAMP;

INSERT INTO resource_relationship_types (
    id,
    code,
    name,
    inverse_name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        '0199-4c00-7201-8000-000000000001',
        'OPERATES',
        'Operates',
        'Operated By',
        'The source resource operates the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7202-8000-000000000002',
        'EMPLOYS',
        'Employs',
        'Employed By',
        'The source resource employs the target professional.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7203-8000-000000000003',
        'CONTRACTS',
        'Contracts',
        'Contracted By',
        'The source resource contracts the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7204-8000-000000000004',
        'OWNS',
        'Owns',
        'Owned By',
        'The source resource owns the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7205-8000-000000000005',
        'MANAGES',
        'Manages',
        'Managed By',
        'The source resource manages the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (code) DO UPDATE
SET
    name         = EXCLUDED.name,
    inverse_name = EXCLUDED.inverse_name,
    description  = EXCLUDED.description,
    is_live      = EXCLUDED.is_live,
    updated_at   = CURRENT_TIMESTAMP;

INSERT INTO location_types (
    id,
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        '0199-4c00-7301-8000-000000000001',
        'NIGHTCLUB',
        'Nightclub',
        'A nightlife venue principally used for music, dancing and entertainment.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7302-8000-000000000002',
        'RESTAURANT',
        'Restaurant',
        'A location where prepared food and drink are served to guests.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7303-8000-000000000003',
        'HOSPITAL',
        'Hospital',
        'A medical facility providing inpatient, outpatient or emergency care.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7304-8000-000000000004',
        'SPA',
        'Spa',
        'A location providing wellness, beauty or therapeutic treatments.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-4c00-7305-8000-000000000005',
        'HOTEL',
        'Hotel',
        'A location providing paid short-term accommodation and related facilities.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (code) DO UPDATE
SET
    name        = EXCLUDED.name,
    description = EXCLUDED.description,
    is_live     = EXCLUDED.is_live,
    updated_at  = CURRENT_TIMESTAMP;

COMMIT;
