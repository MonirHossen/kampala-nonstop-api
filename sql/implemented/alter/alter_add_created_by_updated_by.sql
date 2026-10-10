-- ============================================================================
-- Africa Nonstop / Kampala Nonstop
-- Add created_by / updated_by actor attribution to existing application tables
--
-- Purpose
-- -------
-- Adds lightweight row-level authorship metadata:
--
--   created_by  = actor that created the row
--   updated_by  = actor that most recently changed the row
--
-- Default actor:
--   SYSTEM
--
-- Recommended application actor format:
--   SYSTEM
--   USER:<uuid>
--
-- Example:
--   USER:0199f9b6-1234-7abc-8def-1234567890ab
--
-- Do NOT use a mutable display name as the canonical stored actor value.
-- The UI can resolve the UUID to the current user's/admin's display name.
--
-- IMPORTANT
-- ---------
-- This is intentionally NOT a foreign key to users:
--   * SYSTEM is a valid non-user actor.
--   * automated imports/jobs may also be actors.
--   * audit attribution should survive user deactivation/deletion.
--
-- This script:
--   * is non-destructive: no existing columns/data are dropped or changed.
--   * uses ADD COLUMN IF NOT EXISTS.
--   * gives existing rows the effective value SYSTEM.
--   * excludes waitlist_signups and waitlist_invitations as requested.
--   * excludes common Laravel/framework-owned infrastructure tables.
--   * excludes PostgreSQL extension-owned tables automatically.
--   * ignores child partitions because altering the partitioned parent propagates
--     the new columns to its partitions.
--
-- Assumption:
--   Application tables are in schema "public".
--
-- NOTE:
--   The database cannot know which logged-in Laravel user performed an action.
--   Laravel/service-layer save logic must explicitly populate created_by and
--   updated_by when the actor is not SYSTEM.
-- ============================================================================

BEGIN;

DO $audit_columns$
DECLARE
    r RECORD;

    -- Project exclusions plus common Laravel / package infrastructure.
    -- Entries that do not exist in the database are harmless.
    excluded_tables CONSTANT TEXT[] := ARRAY[
        -- Explicit project exclusions
        'waitlist_signups',
        'waitlist_invitations',

        -- Laravel core/framework infrastructure
        'migrations',
        'password_reset_tokens',
        'sessions',
        'cache',
        'cache_locks',
        'jobs',
        'job_batches',
        'failed_jobs',

        -- Laravel Sanctum / Passport infrastructure
        'personal_access_tokens',
        'oauth_auth_codes',
        'oauth_access_tokens',
        'oauth_refresh_tokens',
        'oauth_clients',
        'oauth_personal_access_clients',

        -- Laravel Telescope infrastructure
        'telescope_entries',
        'telescope_entries_tags',
        'telescope_monitoring',

        -- Laravel Pulse infrastructure
        'pulse_entries',
        'pulse_values',
        'pulse_aggregates'
    ];
BEGIN
    FOR r IN
        SELECT
            n.nspname AS schema_name,
            c.relname AS table_name
        FROM pg_class c
        JOIN pg_namespace n
          ON n.oid = c.relnamespace
        WHERE n.nspname = 'public'
          -- ordinary and partitioned tables only
          AND c.relkind IN ('r', 'p')
          -- do not independently alter child partitions
          AND NOT c.relispartition
          -- skip explicit exclusions
          AND NOT (c.relname = ANY (excluded_tables))
          -- skip tables owned by installed PostgreSQL extensions
          AND NOT EXISTS (
              SELECT 1
              FROM pg_depend d
              JOIN pg_extension e
                ON e.oid = d.refobjid
              WHERE d.classid = 'pg_class'::regclass
                AND d.objid = c.oid
                AND d.deptype = 'e'
          )
        ORDER BY c.relname
    LOOP
        RAISE NOTICE 'Adding audit actor columns to %.%', r.schema_name, r.table_name;

        EXECUTE format(
            'ALTER TABLE %I.%I
                ADD COLUMN IF NOT EXISTS created_by VARCHAR(255) NOT NULL DEFAULT %L,
                ADD COLUMN IF NOT EXISTS updated_by VARCHAR(255) NOT NULL DEFAULT %L',
            r.schema_name,
            r.table_name,
            'SYSTEM',
            'SYSTEM'
        );

        -- Add documentation only when the columns now exist.
        EXECUTE format(
            'COMMENT ON COLUMN %I.%I.created_by IS %L',
            r.schema_name,
            r.table_name,
            'Stable actor identifier that created the row. SYSTEM denotes an automated/system/legacy origin.'
        );

        EXECUTE format(
            'COMMENT ON COLUMN %I.%I.updated_by IS %L',
            r.schema_name,
            r.table_name,
            'Stable actor identifier that most recently changed the row. SYSTEM denotes an automated/system origin.'
        );
    END LOOP;
END
$audit_columns$;

COMMIT;


-- ============================================================================
-- Verification
-- ============================================================================
-- Shows all public-schema tables that now contain one or both actor columns,
-- including type, nullability and default.
-- ============================================================================

SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.character_maximum_length,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.column_name IN ('created_by', 'updated_by')
ORDER BY c.table_name, c.column_name;


-- ============================================================================
-- Application behaviour required after this migration
-- ============================================================================
--
-- INSERT created through admin panel:
--   created_by = 'USER:<logged_in_user_uuid>'
--   updated_by = 'USER:<logged_in_user_uuid>'
--
-- UPDATE through admin panel:
--   created_by remains unchanged
--   updated_by = 'USER:<logged_in_user_uuid>'
--
-- Automated/system-created row:
--   omit both columns and allow DEFAULT 'SYSTEM'
--
-- Existing rows:
--   read as SYSTEM after this migration because historical actor identity
--   cannot be reconstructed reliably.
--
-- IMPORTANT:
-- These columns record only the creator and the MOST RECENT updater.
-- If a complete before/after history is later required, introduce a dedicated
-- append-only audit/change-log mechanism rather than trying to reconstruct
-- history from created_by / updated_by.
-- ============================================================================
