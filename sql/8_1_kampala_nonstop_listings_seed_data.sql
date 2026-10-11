-- Kampala Nonstop
-- Listing reference seed data
-- Directory listings, options, hours and rules are operational data and are not seeded here.


BEGIN;


INSERT INTO listing_types (
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
        '0199-3ab1-7001-8000-000000000001',
        'ACTIVITY',
        'Activity',
        'A specific thing a traveller can do.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-3ab1-7002-8000-000000000002',
        'EVENT',
        'Event',
        'A scheduled happening that travellers can attend or book.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-3ab1-7003-8000-000000000003',
        'TOUR',
        'Tour',
        'A structured journey or route offered to travellers.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-3ab1-7004-8000-000000000004',
        'SERVICE',
        'Service',
        'A bookable service delivered for a traveller.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        '0199-3ab1-7005-8000-000000000005',
        'EXPERIENCE',
        'Experience',
        'A curated combination or sequence of activities.',
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