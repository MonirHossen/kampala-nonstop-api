-- ============================================================================
-- Africa Nonstop / Kampala Nonstop
-- 16_1_kampala_nonstop_user_favourites_alter.sql
--
-- Convert user_favourites to a direct user -> listing relationship.
--
-- Final intended shape:
--   id
--   user_id
--   listing_id
--   created_at
--
-- UNIQUE (user_id, listing_id)
--
-- Safety:
--   * No legacy favourite columns are dropped.
--   * If legacy rows exist without listing_id, the script aborts before changes.
--   * Deprecated polymorphic columns are made nullable if present.
--   * Safe to re-run.
-- ============================================================================

BEGIN;

DO $preflight$
DECLARE
    legacy_rows BIGINT;
    has_listing_id BOOLEAN;
BEGIN
    IF to_regclass('public.user_favourites') IS NULL THEN
        RAISE EXCEPTION 'Required table public.user_favourites does not exist.';
    END IF;

    IF to_regclass('public.listings') IS NULL THEN
        RAISE EXCEPTION 'Required table public.listings does not exist.';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_favourites'
          AND column_name = 'listing_id'
    )
    INTO has_listing_id;

    IF has_listing_id THEN
        EXECUTE '
            SELECT COUNT(*)
            FROM public.user_favourites
            WHERE listing_id IS NULL
        '
        INTO legacy_rows;
    ELSE
        EXECUTE '
            SELECT COUNT(*)
            FROM public.user_favourites
        '
        INTO legacy_rows;
    END IF;

    IF legacy_rows > 0 THEN
        RAISE EXCEPTION
            'user_favourites contains % row(s) without listing_id. Map existing favourites to listings.id before running this migration.',
            legacy_rows;
    END IF;
END
$preflight$;

ALTER TABLE public.user_favourites
    ADD COLUMN IF NOT EXISTS listing_id UUID;

DO $fk$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'public.user_favourites'::regclass
          AND conname = 'fk_user_favourites_listing'
    ) THEN
        ALTER TABLE public.user_favourites
            ADD CONSTRAINT fk_user_favourites_listing
            FOREIGN KEY (listing_id)
            REFERENCES public.listings (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;
END
$fk$;

DO $legacy_columns$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_favourites'
          AND column_name = 'favouritable_type'
    ) THEN
        ALTER TABLE public.user_favourites
            ALTER COLUMN favouritable_type DROP NOT NULL;

        COMMENT ON COLUMN public.user_favourites.favouritable_type IS
            'Deprecated. New favourites reference listings through listing_id.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'user_favourites'
          AND column_name = 'favouritable_id'
    ) THEN
        ALTER TABLE public.user_favourites
            ALTER COLUMN favouritable_id DROP NOT NULL;

        COMMENT ON COLUMN public.user_favourites.favouritable_id IS
            'Deprecated. New favourites reference listings through listing_id.';
    END IF;
END
$legacy_columns$;

ALTER TABLE public.user_favourites
    ALTER COLUMN listing_id SET NOT NULL;

DO $unique_constraint$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'public.user_favourites'::regclass
          AND conname = 'uq_user_favourites_user_listing'
    ) THEN
        ALTER TABLE public.user_favourites
            ADD CONSTRAINT uq_user_favourites_user_listing
            UNIQUE (user_id, listing_id);
    END IF;
END
$unique_constraint$;

-- user_favourites is a simple user-action junction:
-- INSERT = favourite, DELETE = unfavourite.
-- Remove generic audit fields if the earlier global audit migration added them.
ALTER TABLE public.user_favourites
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS created_by,
    DROP COLUMN IF EXISTS updated_by;

COMMENT ON COLUMN public.user_favourites.listing_id IS
    'Customer-bookmarked listing. A user may bookmark a listing only once.';

COMMIT;

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'user_favourites'
ORDER BY c.ordinal_position;

SELECT
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
WHERE con.conrelid = 'public.user_favourites'::regclass
ORDER BY con.conname;
