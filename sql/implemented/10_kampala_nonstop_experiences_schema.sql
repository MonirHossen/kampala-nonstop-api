-- Kampala Nonstop: Experience composition and shared departures/occurrences
-- PostgreSQL 13+. Run this file once, then the companion seed file.
-- New tables only. Existing records are not altered. Existing table/name conflicts
-- fail and roll back rather than silently accepting an incompatible schema.
-- Assumed existing public tables: listings(id, listing_type_id), listing_types(id,code),
-- listing_options(id,listing_id) with UNIQUE(id,listing_id), places(resource_id),
-- geographic_areas(id). Places are renamed from locations as agreed.
-- All ID keys are UUID. Audit actors are VARCHAR(100), default SYSTEM.
-- The API must supply actual authenticated updated_by/created_by; timestamps
-- alone do not identify users. No Experience time_zone column: resolve via country.
-- UTC-aware actual starts/ends are TIMESTAMPTZ; recurring rules use local DATE/TIME.
-- No price amounts/formulas, quotes, inventory, matching criteria or booking tables
-- are created: these need their own agreed shared models.
-- Drafts may be incomplete. Publish validation must enforce all readiness rules
-- listed at the end. This migration is not a booking/scheduling engine.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
DO $$
BEGIN
 IF to_regclass('public.listings') IS NULL OR to_regclass('public.listing_types') IS NULL
 OR to_regclass('public.listing_options') IS NULL OR to_regclass('public.places') IS NULL
 OR to_regclass('public.geographic_areas') IS NULL THEN
  RAISE EXCEPTION 'Required existing tables missing: listings, listing_types, listing_options, places, geographic_areas';
 END IF;
 IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public'
 AND table_name='places' AND column_name='resource_id' AND data_type='uuid') THEN
  RAISE EXCEPTION 'Expected places.resource_id UUID. Adapt this migration to the actual Place key before running.';
 END IF;
END $$;

CREATE TABLE experience_schedule_modes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE experience_price_inclusions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE experience_quantity_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE experience_timing_modes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE experience_dependency_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE listing_occurrence_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (code = upper(code) AND btrim(code) <> '')
);

CREATE TABLE experiences (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE CASCADE,
    schedule_mode VARCHAR(40) NOT NULL DEFAULT 'FLEXIBLE_START'
        REFERENCES experience_schedule_modes(code),
    is_customisable BOOLEAN NOT NULL DEFAULT TRUE,
    anchor_component_id UUID,
    estimated_duration_minutes INTEGER CHECK (estimated_duration_minutes > 0),
    start_place_id UUID REFERENCES places(resource_id) ON DELETE RESTRICT,
    end_place_id UUID REFERENCES places(resource_id) ON DELETE RESTRICT,
    start_geographic_area_id UUID REFERENCES geographic_areas(id) ON DELETE RESTRICT,
    end_geographic_area_id UUID REFERENCES geographic_areas(id) ON DELETE RESTRICT,
    start_instructions TEXT,
    end_instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CHECK (anchor_component_id IS NULL OR schedule_mode = 'COMPONENT_ANCHORED')
);

CREATE TABLE listing_departure_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    listing_option_id UUID,
    day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    UNIQUE(id,listing_id),
    FOREIGN KEY(listing_option_id,listing_id) REFERENCES listing_options(id,listing_id) ON DELETE RESTRICT,
    CHECK(valid_to IS NULL OR valid_to >= valid_from)
);
CREATE UNIQUE INDEX uq_departure_rule_base ON listing_departure_rules
 (listing_id,day_of_week,start_time,valid_from) WHERE listing_option_id IS NULL;
CREATE UNIQUE INDEX uq_departure_rule_option ON listing_departure_rules
 (listing_id,listing_option_id,day_of_week,start_time,valid_from) WHERE listing_option_id IS NOT NULL;

CREATE TABLE listing_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    listing_option_id UUID,
    departure_rule_id UUID,
    generated_for_date DATE,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    status VARCHAR(40) NOT NULL DEFAULT 'SCHEDULED' REFERENCES listing_occurrence_statuses(code),
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    UNIQUE(id,listing_id),
    FOREIGN KEY(listing_option_id,listing_id) REFERENCES listing_options(id,listing_id) ON DELETE RESTRICT,
    FOREIGN KEY(departure_rule_id,listing_id) REFERENCES listing_departure_rules(id,listing_id) ON DELETE RESTRICT,
    UNIQUE(departure_rule_id,generated_for_date),
    CHECK((departure_rule_id IS NULL) = (generated_for_date IS NULL)),
    CHECK(ends_at IS NULL OR ends_at > starts_at),
    CHECK(cancellation_reason IS NULL OR status = 'CANCELLED')
);
CREATE UNIQUE INDEX uq_occurrence_base_start ON listing_occurrences(listing_id,starts_at)
 WHERE listing_option_id IS NULL;
CREATE UNIQUE INDEX uq_occurrence_option_start ON listing_occurrences(listing_id,listing_option_id,starts_at)
 WHERE listing_option_id IS NOT NULL;

CREATE TABLE experience_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experience_listing_id UUID NOT NULL REFERENCES experiences(listing_id) ON DELETE CASCADE,
    experience_option_id UUID,
    component_listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    component_listing_option_id UUID,
    replaces_component_id UUID,
    sequence_order INTEGER NOT NULL CHECK(sequence_order >= 0),
    title_override VARCHAR(150),
    notes TEXT,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    price_inclusion VARCHAR(40) NOT NULL DEFAULT 'PACKAGE_QUOTE' REFERENCES experience_price_inclusions(code),
    quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
    quantity_basis VARCHAR(40) NOT NULL DEFAULT 'PER_BOOKING' REFERENCES experience_quantity_bases(code),
    duration_override_minutes INTEGER CHECK(duration_override_minutes > 0),
    timing_mode VARCHAR(40) NOT NULL DEFAULT 'UNSCHEDULED' REFERENCES experience_timing_modes(code),
    start_offset_minutes INTEGER,
    fixed_start_at TIMESTAMPTZ,
    component_occurrence_id UUID,
    is_live BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    UNIQUE(id,experience_listing_id),
    FOREIGN KEY(experience_option_id,experience_listing_id) REFERENCES listing_options(id,listing_id) ON DELETE RESTRICT,
    FOREIGN KEY(component_listing_option_id,component_listing_id) REFERENCES listing_options(id,listing_id) ON DELETE RESTRICT,
    FOREIGN KEY(component_occurrence_id,component_listing_id) REFERENCES listing_occurrences(id,listing_id) ON DELETE RESTRICT,
    FOREIGN KEY(replaces_component_id,experience_listing_id) REFERENCES experience_components(id,experience_listing_id)
        DEFERRABLE INITIALLY DEFERRED,
    CHECK(component_listing_id <> experience_listing_id),
    CHECK(replaces_component_id IS NULL OR (experience_option_id IS NOT NULL AND replaces_component_id <> id)),
    CHECK((timing_mode = 'EXPERIENCE_OFFSET') = (start_offset_minutes IS NOT NULL)),
    CHECK((timing_mode = 'FIXED_START') = (fixed_start_at IS NOT NULL)),
    CHECK((timing_mode = 'OCCURRENCE') = (component_occurrence_id IS NOT NULL))
);
CREATE UNIQUE INDEX uq_component_base_sequence ON experience_components(experience_listing_id,sequence_order)
 WHERE experience_option_id IS NULL;
CREATE UNIQUE INDEX uq_component_option_sequence ON experience_components(experience_listing_id,experience_option_id,sequence_order)
 WHERE experience_option_id IS NOT NULL;
CREATE UNIQUE INDEX uq_component_option_replacement ON experience_components(experience_option_id,replaces_component_id)
 WHERE replaces_component_id IS NOT NULL;
ALTER TABLE experiences ADD CONSTRAINT fk_experience_anchor
 FOREIGN KEY(anchor_component_id,listing_id) REFERENCES experience_components(id,experience_listing_id)
 DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE experience_component_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experience_listing_id UUID NOT NULL REFERENCES experiences(listing_id) ON DELETE CASCADE,
    component_id UUID NOT NULL,
    related_component_id UUID NOT NULL,
    relation_type VARCHAR(40) NOT NULL REFERENCES experience_dependency_types(code),
    minimum_gap_minutes INTEGER NOT NULL DEFAULT 0 CHECK(minimum_gap_minutes >= 0),
    maximum_gap_minutes INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    FOREIGN KEY(component_id,experience_listing_id) REFERENCES experience_components(id,experience_listing_id) ON DELETE CASCADE,
    FOREIGN KEY(related_component_id,experience_listing_id) REFERENCES experience_components(id,experience_listing_id) ON DELETE CASCADE,
    UNIQUE(component_id,related_component_id,relation_type),
    CHECK(component_id <> related_component_id),
    CHECK(maximum_gap_minutes IS NULL OR maximum_gap_minutes >= minimum_gap_minutes)
);
CREATE INDEX ix_components_child ON experience_components(component_listing_id);
CREATE INDEX ix_components_occurrence ON experience_components(component_occurrence_id);
CREATE INDEX ix_occurrence_rule ON listing_occurrences(departure_rule_id);
CREATE INDEX ix_dependencies_related ON experience_component_dependencies(related_component_id);
CREATE INDEX ix_experience_start_place ON experiences(start_place_id);
CREATE INDEX ix_experience_end_place ON experiences(end_place_id);

CREATE FUNCTION kns_experience_touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 NEW.created_at := OLD.created_at;
 NEW.created_by := OLD.created_by;
 NEW.updated_at := CURRENT_TIMESTAMP;
 RETURN NEW;
END $$;

-- Validate type and occurrence-option coherence at write time.
CREATE FUNCTION kns_experience_check_record() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c text; opt uuid;
BEGIN
 IF TG_TABLE_NAME = 'experiences' THEN
  SELECT upper(t.code) INTO c FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.listing_id;
  IF c IS DISTINCT FROM 'EXPERIENCE' THEN RAISE EXCEPTION 'Experience parent must be an EXPERIENCE listing' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME = 'experience_components' THEN
  SELECT upper(t.code) INTO c FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.component_listing_id;
  IF c IS NULL OR c NOT IN ('ACTIVITY','EVENT','TOUR','SERVICE') THEN
   RAISE EXCEPTION 'Components must be ACTIVITY, EVENT, TOUR or SERVICE listings; nested Experiences are not supported' USING ERRCODE='23514';
  END IF;
  IF NEW.component_occurrence_id IS NOT NULL THEN
   SELECT listing_option_id INTO opt FROM listing_occurrences WHERE id=NEW.component_occurrence_id;
   IF opt IS NOT NULL AND opt IS DISTINCT FROM NEW.component_listing_option_id THEN
    RAISE EXCEPTION 'Selected child occurrence belongs to a different child option' USING ERRCODE='23514';
   END IF;
  END IF;
 ELSIF TG_TABLE_NAME = 'listing_occurrences' AND NEW.departure_rule_id IS NOT NULL THEN
  SELECT listing_option_id INTO opt FROM listing_departure_rules WHERE id=NEW.departure_rule_id;
  IF opt IS DISTINCT FROM NEW.listing_option_id THEN
   RAISE EXCEPTION 'Occurrence option must match its departure rule option' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;

-- Serialise graph edits for one Experience, then check final graph at commit.
-- Callers should acquire this same parent-row lock for package-wide edits.
CREATE FUNCTION kns_experience_lock_graph() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE eid uuid;
BEGIN
 IF TG_OP = 'DELETE' THEN eid := OLD.experience_listing_id; ELSE eid := NEW.experience_listing_id; END IF;
 IF TG_OP = 'UPDATE' AND NEW.experience_listing_id <> OLD.experience_listing_id THEN
  RAISE EXCEPTION 'Moving graph records between Experiences is unsupported' USING ERRCODE='23514';
 END IF;
 PERFORM 1 FROM experiences WHERE listing_id=eid FOR UPDATE;
 IF TG_OP='DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END $$;
CREATE FUNCTION kns_experience_validate_graph() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE eid uuid;
BEGIN
 IF TG_OP='DELETE' THEN eid := OLD.experience_listing_id; ELSE eid := NEW.experience_listing_id; END IF;
 IF NOT EXISTS(SELECT 1 FROM experiences WHERE listing_id=eid) THEN RETURN NULL; END IF;
 IF EXISTS (
  SELECT 1 FROM experience_components c JOIN experience_components b ON b.id=c.replaces_component_id
  WHERE c.experience_listing_id=eid AND b.experience_option_id IS NOT NULL
 ) THEN RAISE EXCEPTION 'Variant replacements must replace shared/base components' USING ERRCODE='23514'; END IF;
 IF EXISTS (
  SELECT 1 FROM experience_component_dependencies d
  JOIN experience_components c ON c.id=d.component_id JOIN experience_components r ON r.id=d.related_component_id
  WHERE d.experience_listing_id=eid AND c.experience_option_id IS NOT NULL
   AND r.experience_option_id IS NOT NULL AND c.experience_option_id <> r.experience_option_id
 ) THEN RAISE EXCEPTION 'Dependencies cannot connect mutually exclusive package options' USING ERRCODE='23514'; END IF;
 IF EXISTS (
  WITH RECURSIVE edges(a,b) AS (
   SELECT CASE WHEN relation_type='START_AFTER_END' THEN related_component_id ELSE component_id END,
          CASE WHEN relation_type='START_AFTER_END' THEN component_id ELSE related_component_id END
   FROM experience_component_dependencies WHERE experience_listing_id=eid
  ), paths(a,b) AS (
   SELECT a,b FROM edges UNION SELECT p.a,e.b FROM paths p JOIN edges e ON e.a=p.b
  ) SELECT 1 FROM paths WHERE a=b
 ) THEN RAISE EXCEPTION 'Experience component dependencies contain a cycle' USING ERRCODE='23514'; END IF;
 RETURN NULL;
END $$;

CREATE TRIGGER trg_experience_schedule_modes_audit BEFORE UPDATE ON experience_schedule_modes
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_price_inclusions_audit BEFORE UPDATE ON experience_price_inclusions
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_quantity_bases_audit BEFORE UPDATE ON experience_quantity_bases
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_timing_modes_audit BEFORE UPDATE ON experience_timing_modes
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_dependency_types_audit BEFORE UPDATE ON experience_dependency_types
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_listing_occurrence_statuses_audit BEFORE UPDATE ON listing_occurrence_statuses
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experiences_audit BEFORE UPDATE ON experiences
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_listing_departure_rules_audit BEFORE UPDATE ON listing_departure_rules
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_listing_occurrences_audit BEFORE UPDATE ON listing_occurrences
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_components_audit BEFORE UPDATE ON experience_components
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experience_component_dependencies_audit BEFORE UPDATE ON experience_component_dependencies
 FOR EACH ROW EXECUTE FUNCTION kns_experience_touch_updated_at();

CREATE TRIGGER trg_experiences_check BEFORE INSERT OR UPDATE ON experiences
 FOR EACH ROW EXECUTE FUNCTION kns_experience_check_record();

CREATE TRIGGER trg_experience_components_check BEFORE INSERT OR UPDATE ON experience_components
 FOR EACH ROW EXECUTE FUNCTION kns_experience_check_record();

CREATE TRIGGER trg_listing_occurrences_check BEFORE INSERT OR UPDATE ON listing_occurrences
 FOR EACH ROW EXECUTE FUNCTION kns_experience_check_record();

CREATE TRIGGER trg_experience_components_lock BEFORE INSERT OR UPDATE OR DELETE ON experience_components
 FOR EACH ROW EXECUTE FUNCTION kns_experience_lock_graph();
CREATE CONSTRAINT TRIGGER trg_experience_components_graph AFTER INSERT OR UPDATE OR DELETE ON experience_components
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns_experience_validate_graph();

CREATE TRIGGER trg_experience_component_dependencies_lock BEFORE INSERT OR UPDATE OR DELETE ON experience_component_dependencies
 FOR EACH ROW EXECUTE FUNCTION kns_experience_lock_graph();
CREATE CONSTRAINT TRIGGER trg_experience_component_dependencies_graph AFTER INSERT OR UPDATE OR DELETE ON experience_component_dependencies
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns_experience_validate_graph();


COMMENT ON COLUMN experiences.is_customisable IS 'Default true; customisation creates a booking-specific itinerary/quote, not edits to this template.';
COMMENT ON COLUMN experience_components.is_required IS 'Essential to package identity; nonessential components are included by default but removable through customisation.';
COMMENT ON COLUMN experience_components.price_inclusion IS 'PACKAGE_QUOTE or PAY_DIRECT. Inclusion does not imply a fixed price; quantities/distance can affect the final quote.';
COMMENT ON COLUMN experience_components.replaces_component_id IS 'Variant row replaces a shared component. When an option is selected, omit replaced base rows and include its variant rows; shared non-replaced rows remain.';
COMMENT ON COLUMN experience_components.start_offset_minutes IS 'Signed minutes relative to package start; negative values permitted.';
COMMENT ON COLUMN listing_departure_rules.day_of_week IS '0 Monday to 6 Sunday; local country-zone time. Not booking hours.';
COMMENT ON COLUMN listing_occurrences.generated_for_date IS 'Original local rule date, retained on rescheduling. Uniqueness prevents duplicate generation.';
COMMENT ON COLUMN experience_components.component_occurrence_id IS 'Optional pin to an actual child occurrence. For reusable anchored templates resolve occurrence during booking instead of pinning one date.';
COMMENT ON TABLE experience_component_dependencies IS 'minimum/maximum gap between boundary types. Transport duration and buffers must not be counted twice.';

-- REQUIRED APPLICATION/PUBLISH RULES (not claimed to be implemented by this DDL):
-- 1. Experience listing types/options and child type assignments are immutable
--    while referenced; updates on existing listings must revalidate these graphs.
-- 2. Live package: at least one active component; chosen children/options/references
--    eligible; timing valid and feasible. Require departures for FIXED_START.
--    Require an essential active anchor for COMPONENT_ANCHORED in each effective
--    variant. Resolve that anchor's actual occurrence at booking time.
-- 3. Effective variant = shared rows except replacements + selected variant rows.
--    Resolve ordering collisions and dependencies touching replacements/removals
--    explicitly; reject unresolved configurations. Do not silently drop constraints.
-- 4. Reject impossible windows, availability, travel gaps and unresolved required
--    timings at quote/confirmation. Duration overrides need provider support.
-- 5. Rule generation: local country zone, date validity + weekday, finite horizon,
--    idempotent rule/date key. Do not overwrite cancelled/amended occurrences.
--    Changing rules/occurrences must check downstream packages/bookings first.
-- 6. Catalogue prices, quantities, participant counts, transport distance/capacity,
--    variants, multiplier, from-price assumptions and snapshots need a separate
--    agreed pricing/quote model. PAY_DIRECT charges must be disclosed separately.
-- 7. API supplies audit actors; check permissions and optimistic concurrency.
--    Translate SQL constraints/errors to actionable field/row errors.
COMMIT;
