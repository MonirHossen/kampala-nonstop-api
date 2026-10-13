-- Kampala Nonstop
-- Resource reference seed data
-- IDs use table DEFAULT gen_random_uuid() (do not hard-code non-RFC UUID literals).

BEGIN;

INSERT INTO resource_types (
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        'LOCATION',
        'Location',
        'A physical establishment or site that provides capability for a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'ORGANISATION',
        'Organisation',
        'A business or institution that provides or manages resources used to fulfil listings.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'PROFESSIONAL',
        'Professional',
        'An individual who personally provides capability for a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'VEHICLE',
        'Vehicle',
        'A transport asset that may be assigned to fulfil a listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
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
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        'VENUE',
        'Venue',
        'Hosts the activity, event, tour component or service.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'OPERATOR',
        'Operator',
        'Operates or coordinates delivery of the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'GUIDE',
        'Guide',
        'Guides travellers during an activity, tour or experience.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'DRIVER',
        'Driver',
        'Provides driving capability for traveller transport.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'CONCIERGE',
        'Concierge',
        'Coordinates or accompanies the traveller during delivery.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'THERAPIST',
        'Therapist',
        'Delivers a treatment, massage or related wellness service.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'VEHICLE',
        'Vehicle',
        'Provides the transport capacity required by the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'ACCOMMODATION',
        'Accommodation',
        'Provides the accommodation needed to fulfil the listing.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
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
        'OPERATES',
        'Operates',
        'Operated By',
        'The source resource operates the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'EMPLOYS',
        'Employs',
        'Employed By',
        'The source resource employs the target professional.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'CONTRACTS',
        'Contracts',
        'Contracted By',
        'The source resource contracts the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'OWNS',
        'Owns',
        'Owned By',
        'The source resource owns the target resource.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
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
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        'NIGHTCLUB',
        'Nightclub',
        'A nightlife venue principally used for music, dancing and entertainment.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'RESTAURANT',
        'Restaurant',
        'A location where prepared food and drink are served to guests.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'HOSPITAL',
        'Hospital',
        'A medical facility providing inpatient, outpatient or emergency care.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'SPA',
        'Spa',
        'A location providing wellness, beauty or therapeutic treatments.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
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
