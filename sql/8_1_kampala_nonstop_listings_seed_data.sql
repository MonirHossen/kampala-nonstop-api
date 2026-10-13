-- Kampala Nonstop
-- Listing reference seed data
-- Directory listings, options, hours and rules are operational data and are not seeded here.
-- IDs use table DEFAULT gen_random_uuid() (do not hard-code non-RFC UUID literals).


BEGIN;


INSERT INTO listing_types (
    code,
    name,
    description,
    is_live,
    created_at,
    updated_at
)
VALUES
    (
        'ACTIVITY',
        'Activity',
        'A specific thing a traveller can do.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'EVENT',
        'Event',
        'A scheduled happening that travellers can attend or book.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'TOUR',
        'Tour',
        'A structured journey or route offered to travellers.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'SERVICE',
        'Service',
        'A bookable service delivered for a traveller.',
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
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
