-- Kampala Nonstop / Africa Nonstop - Services and shared listing configuration
-- File 11: PostgreSQL 13+; run ONCE after 9/resources (using places) and 10/Experiences.
-- Then run 11_1_kampala_nonstop_services_reference_seed.sql.
-- 18 new tables. Existing tables are retained; two nullable vehicle luggage columns
-- and validation triggers on existing parents/components are added non-destructively.
-- No provider, listing, document wording, price, booking or Magma data is fabricated.
-- IDs: gen_random_uuid() baseline (server-generated); audit actors default SYSTEM.
-- Runtime mode codes use CHECK constraints, NOT reference rows. Seedable reference
-- data is booking_information_fields and the existing experience_quantity_bases.
-- Audit triggers maintain timestamps/creator identity; the API supplies actor names.
-- On a missing/incompatible prerequisite or an existing target table, the transaction
-- fails and rolls back. Do not rerun blindly or wrap errors in an ignore-errors runner.
-- The readiness/booking engine remains application work, enumerated at the end.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';

DO $preflight$
DECLARE r record; actual_type text;
BEGIN
 IF current_setting('server_version_num')::integer < 130000 THEN
  RAISE EXCEPTION 'Services migration requires PostgreSQL 13 or newer';
 END IF;
 FOR r IN SELECT * FROM (VALUES
  ('listings','id','uuid'),
  ('listings','listing_type_id','uuid'),
  ('listing_types','id','uuid'),
  ('listing_types','code','varchar'),
  ('listing_options','id','uuid'),
  ('listing_options','listing_id','uuid'),
  ('resources','id','uuid'),
  ('places','resource_id','uuid'),
  ('places','geographic_area_id','uuid'),
  ('geographic_areas','id','uuid'),
  ('geographic_areas','parent_geographic_area_id','uuid'),
  ('vehicles','resource_id','uuid'),
  ('experiences','listing_id','uuid'),
  ('experience_components','id','uuid'),
  ('experience_components','experience_listing_id','uuid'),
  ('experience_components','experience_option_id','uuid'),
  ('experience_components','quantity_basis','varchar'),
  ('listing_occurrences','id','uuid'),
  ('listing_occurrences','listing_id','uuid'),
  ('experience_quantity_bases','id','uuid'),
  ('experience_quantity_bases','code','varchar'),
  ('experience_quantity_bases','name','varchar'),
  ('experience_quantity_bases','description','text'),
  ('experience_quantity_bases','is_live','bool'),
  ('experience_quantity_bases','created_by','varchar'),
  ('experience_quantity_bases','updated_by','varchar')
 ) AS deps(table_name,column_name,type_name) LOOP
  SELECT udt_name INTO actual_type FROM information_schema.columns
   WHERE table_schema='public' AND table_name=r.table_name AND column_name=r.column_name;
  IF actual_type IS DISTINCT FROM r.type_name THEN
   RAISE EXCEPTION 'Expected public.%.% type %, found %',r.table_name,r.column_name,r.type_name,coalesce(actual_type,'missing');
  END IF;
 END LOOP;
 FOR r IN SELECT unnest(ARRAY['services','listing_configuration_scopes','service_schedule_policies','service_delivery_configurations','service_coverage_areas','service_stay_policies','service_journey_policies','service_journey_legs','service_entitlement_policies','service_entitlement_resources','booking_information_fields','listing_customer_information_requirements','listing_adjustment_rules','booking_documents','booking_document_versions','listing_booking_obligations','listing_event_associations','experience_component_inclusion_rules']) AS name LOOP
 IF to_regclass('public.'||r.name) IS NOT NULL THEN RAISE EXCEPTION 'Target table % already exists; inspect applied migration history instead of rerunning',r.name; END IF; END LOOP;
END
$preflight$;

-- Composite FK targets must already have their agreed unique keys; PostgreSQL
-- validates them when the following FKs are created (no guessed keys added).

CREATE TABLE services (
 listing_id UUID NOT NULL,
 delivery_instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_services PRIMARY KEY (listing_id),
 CONSTRAINT fk_services_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE CASCADE
);

COMMENT ON TABLE services IS 'service configuration. TRIGGER: parent listing type must be SERVICE; no type changes while referenced.';

CREATE TABLE listing_configuration_scopes (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 listing_id UUID NOT NULL,
 listing_option_id UUID,
 configuration_kind VARCHAR(40) NOT NULL,
 configuration_mode VARCHAR(20) NOT NULL DEFAULT 'CUSTOM',
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_listing_configuration_scopes PRIMARY KEY (id),
 CONSTRAINT uq_listing_configuration_scopes_id_listing_id UNIQUE (id,listing_id),
 CONSTRAINT fk_listing_configuration_scopes_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_listing_configuration_scopes_listing_option_id_listing_id FOREIGN KEY (listing_option_id,listing_id) REFERENCES listing_options (id,listing_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_listing_configuration_scopes_configuration_kind CHECK (configuration_kind IN ('SERVICE_SCHEDULE','SERVICE_DELIVERY','SERVICE_STAY','SERVICE_JOURNEY','SERVICE_ENTITLEMENT','CUSTOMER_INFORMATION','ADJUSTMENTS','BOOKING_OBLIGATIONS')),
 CONSTRAINT chk_listing_configuration_scopes_configuration_mode CHECK (configuration_mode IN ('CUSTOM','INHERIT','DISABLED')),
 CONSTRAINT chk_listing_configuration_scopes_1 CHECK (listing_option_id IS NOT NULL OR configuration_mode <> 'INHERIT')
);

COMMENT ON TABLE listing_configuration_scopes IS 'shared configuration. UQ base: (listing_id, configuration_kind) WHERE option IS NULL.';

CREATE TABLE service_schedule_policies (
 scope_id UUID NOT NULL,
 schedule_mode VARCHAR(30) NOT NULL DEFAULT 'FLEXIBLE_START',
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_schedule_policies PRIMARY KEY (scope_id),
 CONSTRAINT fk_service_schedule_policies_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_service_schedule_policies_schedule_mode CHECK (schedule_mode IN ('APPOINTMENT','FLEXIBLE_START','SCHEDULED_START','DATE_RANGE'))
);

COMMENT ON TABLE service_schedule_policies IS 'service configuration. Scope kind = SERVICE_SCHEDULE; scope listing must be SERVICE.';

CREATE TABLE service_delivery_configurations (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 scope_id UUID NOT NULL,
 delivery_mode VARCHAR(30) NOT NULL,
 customer_location_policy VARCHAR(30),
 coverage_mode VARCHAR(30) NOT NULL DEFAULT 'NOT_APPLICABLE',
 instructions TEXT,
 is_live BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_delivery_configurations PRIMARY KEY (id),
 CONSTRAINT uq_service_delivery_configurations_scope_id_delivery_mode UNIQUE (scope_id,delivery_mode),
 CONSTRAINT fk_service_delivery_configurations_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_service_delivery_configurations_delivery_mode CHECK (delivery_mode IN ('PROVIDER_LOCATION','CUSTOMER_LOCATION','REMOTE','JOURNEY')),
 CONSTRAINT chk_service_delivery_configurations_customer_location_policy CHECK (customer_location_policy IN ('ADDRESS','PLACE','ADDRESS_OR_PLACE')),
 CONSTRAINT chk_service_delivery_configurations_coverage_mode CHECK (coverage_mode IN ('NOT_APPLICABLE','LISTED_AREAS','ANYWHERE')),
 CONSTRAINT chk_service_delivery_configurations_1 CHECK (delivery_mode = 'CUSTOMER_LOCATION' OR customer_location_policy IS NULL),
 CONSTRAINT chk_service_delivery_configurations_2 CHECK (delivery_mode NOT IN ('PROVIDER_LOCATION','REMOTE') OR coverage_mode = 'NOT_APPLICABLE')
);

COMMENT ON TABLE service_delivery_configurations IS 'service configuration. UQ (scope_id, delivery_mode). Scope kind = SERVICE_DELIVERY.';

CREATE TABLE service_coverage_areas (
 delivery_configuration_id UUID NOT NULL,
 geographic_area_id UUID NOT NULL,
 includes_descendants BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_coverage_areas PRIMARY KEY (delivery_configuration_id,geographic_area_id),
 CONSTRAINT fk_service_coverage_areas_delivery_configuration_id FOREIGN KEY (delivery_configuration_id) REFERENCES service_delivery_configurations (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_service_coverage_areas_geographic_area_id FOREIGN KEY (geographic_area_id) REFERENCES geographic_areas (id) ON UPDATE RESTRICT ON DELETE RESTRICT
);

COMMENT ON TABLE service_coverage_areas IS 'service configuration. Composite PK prevents duplicate coverage assignments.';

CREATE TABLE service_stay_policies (
 scope_id UUID NOT NULL,
 minimum_nights INTEGER NOT NULL DEFAULT 1,
 maximum_nights INTEGER,
 check_in_from TIME,
 check_in_until TIME,
 check_in_end_day_offset SMALLINT NOT NULL DEFAULT 0,
 check_out_by TIME,
 minimum_occupants SMALLINT NOT NULL DEFAULT 1,
 maximum_occupants SMALLINT,
 included_occupants SMALLINT,
 allows_extra_occupants BOOLEAN NOT NULL DEFAULT FALSE,
 allows_stay_extensions BOOLEAN NOT NULL DEFAULT FALSE,
 instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_stay_policies PRIMARY KEY (scope_id),
 CONSTRAINT fk_service_stay_policies_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_service_stay_policies_1 CHECK (minimum_nights > 0),
 CONSTRAINT chk_service_stay_policies_2 CHECK (maximum_nights IS NULL OR maximum_nights >= minimum_nights),
 CONSTRAINT chk_service_stay_policies_3 CHECK (minimum_occupants > 0),
 CONSTRAINT chk_service_stay_policies_4 CHECK (maximum_occupants IS NULL OR maximum_occupants >= minimum_occupants),
 CONSTRAINT chk_service_stay_policies_5 CHECK (included_occupants IS NULL OR (included_occupants > 0 AND (maximum_occupants IS NULL OR included_occupants <= maximum_occupants))),
 CONSTRAINT chk_service_stay_policies_6 CHECK ((check_in_from IS NULL) = (check_in_until IS NULL)),
 CONSTRAINT chk_service_stay_policies_7 CHECK (check_in_end_day_offset IN (0,1)),
 CONSTRAINT chk_service_stay_policies_8 CHECK (check_in_from IS NOT NULL OR check_in_end_day_offset = 0),
 CONSTRAINT chk_service_stay_policies_9 CHECK (check_in_from IS NULL OR ((EXTRACT(EPOCH FROM check_in_until) - EXTRACT(EPOCH FROM check_in_from) + check_in_end_day_offset * 86400) > 0 AND (EXTRACT(EPOCH FROM check_in_until) - EXTRACT(EPOCH FROM check_in_from) + check_in_end_day_offset * 86400) <= 86400))
);

COMMENT ON TABLE service_stay_policies IS 'service configuration. Scope kind = SERVICE_STAY; minimum nights/occupants >0; maxima >= minima.';

CREATE TABLE service_journey_policies (
 scope_id UUID NOT NULL,
 allocation_basis VARCHAR(30) NOT NULL,
 minimum_passengers SMALLINT NOT NULL DEFAULT 1,
 maximum_passengers SMALLINT,
 departure_condition VARCHAR(30) NOT NULL DEFAULT 'NO_MINIMUM',
 minimum_departure_passengers SMALLINT,
 maximum_intermediate_stops SMALLINT NOT NULL DEFAULT 0,
 included_waiting_minutes INTEGER,
 waiting_trigger VARCHAR(30),
 maximum_checked_bags SMALLINT,
 maximum_cabin_bags SMALLINT,
 meeting_instructions TEXT,
 delay_policy TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_journey_policies PRIMARY KEY (scope_id),
 CONSTRAINT fk_service_journey_policies_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_service_journey_policies_allocation_basis CHECK (allocation_basis IN ('EXCLUSIVE_RESOURCE','SHARED_CAPACITY')),
 CONSTRAINT chk_service_journey_policies_departure_condition CHECK (departure_condition IN ('NO_MINIMUM','MINIMUM_REACHED','FULL_CAPACITY')),
 CONSTRAINT chk_service_journey_policies_waiting_trigger CHECK (waiting_trigger IN ('SCHEDULED_PICKUP','ACTUAL_ARRIVAL','AGREED_MEETING')),
 CONSTRAINT chk_service_journey_policies_1 CHECK (minimum_passengers > 0),
 CONSTRAINT chk_service_journey_policies_2 CHECK (maximum_passengers IS NULL OR maximum_passengers >= minimum_passengers),
 CONSTRAINT chk_service_journey_policies_3 CHECK ((departure_condition = 'MINIMUM_REACHED') = (minimum_departure_passengers IS NOT NULL)),
 CONSTRAINT chk_service_journey_policies_4 CHECK (minimum_departure_passengers IS NULL OR (minimum_departure_passengers > 0 AND (maximum_passengers IS NULL OR minimum_departure_passengers <= maximum_passengers))),
 CONSTRAINT chk_service_journey_policies_5 CHECK (departure_condition = 'NO_MINIMUM' OR allocation_basis = 'SHARED_CAPACITY'),
 CONSTRAINT chk_service_journey_policies_6 CHECK (maximum_intermediate_stops >= 0),
 CONSTRAINT chk_service_journey_policies_7 CHECK (included_waiting_minutes IS NULL OR included_waiting_minutes >= 0),
 CONSTRAINT chk_service_journey_policies_8 CHECK ((included_waiting_minutes IS NULL) = (waiting_trigger IS NULL)),
 CONSTRAINT chk_service_journey_policies_9 CHECK (maximum_checked_bags IS NULL OR maximum_checked_bags >= 0),
 CONSTRAINT chk_service_journey_policies_10 CHECK (maximum_cabin_bags IS NULL OR maximum_cabin_bags >= 0)
);

COMMENT ON TABLE service_journey_policies IS 'service configuration. Scope kind = SERVICE_JOURNEY; passenger limits >0; maximum >= minimum.';

CREATE TABLE service_journey_legs (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 journey_policy_id UUID NOT NULL,
 sequence_order INTEGER NOT NULL,
 name VARCHAR(100) NOT NULL,
 leg_role VARCHAR(20) NOT NULL DEFAULT 'OUTBOUND',
 journey_context VARCHAR(30) NOT NULL DEFAULT 'GENERAL',
 is_required BOOLEAN NOT NULL DEFAULT TRUE,
 origin_selection_mode VARCHAR(30) NOT NULL,
 destination_selection_mode VARCHAR(30) NOT NULL,
 origin_place_id UUID,
 destination_place_id UUID,
 origin_area_id UUID,
 destination_area_id UUID,
 timing_basis VARCHAR(30) NOT NULL DEFAULT 'CUSTOMER_TIME',
 booking_event_code VARCHAR(30),
 offset_minutes INTEGER,
 instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_journey_legs PRIMARY KEY (id),
 CONSTRAINT uq_service_journey_legs_journey_policy_id_sequence_order UNIQUE (journey_policy_id,sequence_order),
 CONSTRAINT fk_service_journey_legs_journey_policy_id FOREIGN KEY (journey_policy_id) REFERENCES service_journey_policies (scope_id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_service_journey_legs_origin_place_id FOREIGN KEY (origin_place_id) REFERENCES places (resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_service_journey_legs_destination_place_id FOREIGN KEY (destination_place_id) REFERENCES places (resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_service_journey_legs_origin_area_id FOREIGN KEY (origin_area_id) REFERENCES geographic_areas (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_service_journey_legs_destination_area_id FOREIGN KEY (destination_area_id) REFERENCES geographic_areas (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_service_journey_legs_leg_role CHECK (leg_role IN ('OUTBOUND','RETURN','ONWARD')),
 CONSTRAINT chk_service_journey_legs_journey_context CHECK (journey_context IN ('GENERAL','AIRPORT_ARRIVAL','AIRPORT_DEPARTURE')),
 CONSTRAINT chk_service_journey_legs_origin_selection_mode CHECK (origin_selection_mode IN ('FIXED_PLACE','CUSTOMER_PLACE','CUSTOMER_ADDRESS')),
 CONSTRAINT chk_service_journey_legs_destination_selection_mode CHECK (destination_selection_mode IN ('FIXED_PLACE','CUSTOMER_PLACE','CUSTOMER_ADDRESS')),
 CONSTRAINT chk_service_journey_legs_timing_basis CHECK (timing_basis IN ('CUSTOMER_TIME','LISTING_OCCURRENCE','BOOKING_EVENT')),
 CONSTRAINT chk_service_journey_legs_booking_event_code CHECK (booking_event_code IN ('FLIGHT_ARRIVAL','FLIGHT_DEPARTURE','PREVIOUS_LEG_END')),
 CONSTRAINT chk_service_journey_legs_1 CHECK (sequence_order >= 0),
 CONSTRAINT chk_service_journey_legs_2 CHECK (btrim(name) <> ''),
 CONSTRAINT chk_service_journey_legs_3 CHECK ((origin_selection_mode = 'FIXED_PLACE') = (origin_place_id IS NOT NULL)),
 CONSTRAINT chk_service_journey_legs_4 CHECK ((destination_selection_mode = 'FIXED_PLACE') = (destination_place_id IS NOT NULL)),
 CONSTRAINT chk_service_journey_legs_5 CHECK ((timing_basis = 'BOOKING_EVENT') = (booking_event_code IS NOT NULL)),
 CONSTRAINT chk_service_journey_legs_6 CHECK ((timing_basis = 'BOOKING_EVENT') = (offset_minutes IS NOT NULL))
);

COMMENT ON TABLE service_journey_legs IS 'service configuration. UQ (journey_policy_id, sequence_order); sequence >=0; trimmed name non-empty.';

CREATE TABLE service_entitlement_policies (
 scope_id UUID NOT NULL,
 fulfilment_method VARCHAR(30) NOT NULL,
 validity_basis VARCHAR(30) NOT NULL,
 valid_from DATE,
 valid_until DATE,
 usage_policy VARCHAR(20) NOT NULL DEFAULT 'SINGLE_USE',
 maximum_uses INTEGER,
 is_transferable BOOLEAN NOT NULL DEFAULT FALSE,
 requires_collection BOOLEAN NOT NULL DEFAULT FALSE,
 collection_instructions TEXT,
 redemption_instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_entitlement_policies PRIMARY KEY (scope_id),
 CONSTRAINT fk_service_entitlement_policies_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_service_entitlement_policies_fulfilment_method CHECK (fulfilment_method IN ('DIRECT_PROVISION','REDEMPTION','ACCESS')),
 CONSTRAINT chk_service_entitlement_policies_validity_basis CHECK (validity_basis IN ('SELECTED_DATE','BOOKED_STAY','BOOKED_PERIOD','FIXED_DATE_RANGE')),
 CONSTRAINT chk_service_entitlement_policies_usage_policy CHECK (usage_policy IN ('SINGLE_USE','LIMITED_USE','UNLIMITED_USE')),
 CONSTRAINT chk_service_entitlement_policies_1 CHECK ((validity_basis = 'FIXED_DATE_RANGE') = (valid_from IS NOT NULL)),
 CONSTRAINT chk_service_entitlement_policies_2 CHECK ((validity_basis = 'FIXED_DATE_RANGE') = (valid_until IS NOT NULL)),
 CONSTRAINT chk_service_entitlement_policies_3 CHECK (valid_until IS NULL OR valid_until >= valid_from),
 CONSTRAINT chk_service_entitlement_policies_4 CHECK ((usage_policy = 'LIMITED_USE') = (maximum_uses IS NOT NULL)),
 CONSTRAINT chk_service_entitlement_policies_5 CHECK (maximum_uses IS NULL OR maximum_uses > 0)
);

COMMENT ON TABLE service_entitlement_policies IS 'service configuration. Scope kind = SERVICE_ENTITLEMENT; fixed dates iff FIXED_DATE_RANGE.';

CREATE TABLE service_entitlement_resources (
 entitlement_policy_id UUID NOT NULL,
 resource_id UUID NOT NULL,
 purpose VARCHAR(20) NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_service_entitlement_resources PRIMARY KEY (entitlement_policy_id,resource_id,purpose),
 CONSTRAINT fk_service_entitlement_resources_entitlement_policy_id FOREIGN KEY (entitlement_policy_id) REFERENCES service_entitlement_policies (scope_id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_service_entitlement_resources_resource_id FOREIGN KEY (resource_id) REFERENCES resources (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_service_entitlement_resources_purpose CHECK (purpose IN ('REDEEM_AT','COLLECT_FROM','ACCESS_AT'))
);

COMMENT ON TABLE service_entitlement_resources IS 'service configuration. Composite PK (policy, resource, purpose); purpose REDEEM_AT / COLLECT_FROM / ACCESS_AT.';

CREATE TABLE booking_information_fields (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 code VARCHAR(50) NOT NULL,
 name VARCHAR(100) NOT NULL,
 data_type VARCHAR(30) NOT NULL,
 description TEXT,
 is_live BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_booking_information_fields PRIMARY KEY (id),
 CONSTRAINT uq_booking_information_fields_code UNIQUE (code),
 CONSTRAINT chk_booking_information_fields_data_type CHECK (data_type IN ('TEXT','INTEGER','DECIMAL','BOOLEAN','DATE','DATETIME','ADDRESS','FLIGHT_DETAILS')),
 CONSTRAINT chk_booking_information_fields_1 CHECK (code ~ '^[A-Z][A-Z0-9_]*$'),
 CONSTRAINT chk_booking_information_fields_2 CHECK (btrim(name) <> '')
);

COMMENT ON TABLE booking_information_fields IS 'shared configuration. Code uppercase non-empty; name trimmed non-empty.';

CREATE TABLE listing_customer_information_requirements (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 scope_id UUID NOT NULL,
 information_field_id UUID NOT NULL,
 is_required BOOLEAN NOT NULL DEFAULT TRUE,
 applicability_code VARCHAR(30) NOT NULL DEFAULT 'ALWAYS',
 help_text TEXT,
 sort_order INTEGER NOT NULL DEFAULT 0,
 is_live BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_listing_customer_information_requirements PRIMARY KEY (id),
 CONSTRAINT uq_listing_customer_information_requirements_scope_id__96e1b73b UNIQUE (scope_id,information_field_id,applicability_code),
 CONSTRAINT fk_listing_customer_information_requirements_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_listing_customer_information_requirements_informati_0e39cde7 FOREIGN KEY (information_field_id) REFERENCES booking_information_fields (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_listing_customer_information_requirements_applicab_e0429f4f CHECK (applicability_code IN ('ALWAYS','ARRIVAL_LEG','DEPARTURE_LEG','RETURN_LEG')),
 CONSTRAINT chk_listing_customer_information_requirements_1 CHECK (sort_order >= 0)
);

COMMENT ON TABLE listing_customer_information_requirements IS 'shared configuration. Scope kind = CUSTOMER_INFORMATION; UQ (scope_id, field, applicability).';

CREATE TABLE listing_adjustment_rules (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 scope_id UUID NOT NULL,
 adjustment_type VARCHAR(30) NOT NULL,
 is_allowed BOOLEAN NOT NULL DEFAULT FALSE,
 minimum_quantity INTEGER,
 maximum_quantity INTEGER,
 requires_requote BOOLEAN NOT NULL DEFAULT TRUE,
 requires_provider_confirmation BOOLEAN NOT NULL DEFAULT TRUE,
 instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_listing_adjustment_rules PRIMARY KEY (id),
 CONSTRAINT uq_listing_adjustment_rules_scope_id_adjustment_type UNIQUE (scope_id,adjustment_type),
 CONSTRAINT fk_listing_adjustment_rules_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT chk_listing_adjustment_rules_adjustment_type CHECK (adjustment_type IN ('EXTRA_PARTICIPANT','PERIOD_EXTENSION','EXTRA_QUANTITY','OPTION_CHANGE')),
 CONSTRAINT chk_listing_adjustment_rules_1 CHECK (minimum_quantity IS NULL OR minimum_quantity > 0),
 CONSTRAINT chk_listing_adjustment_rules_2 CHECK (maximum_quantity IS NULL OR maximum_quantity > 0),
 CONSTRAINT chk_listing_adjustment_rules_3 CHECK (minimum_quantity IS NULL OR maximum_quantity IS NULL OR maximum_quantity >= minimum_quantity),
 CONSTRAINT chk_listing_adjustment_rules_4 CHECK ((is_allowed AND adjustment_type <> 'OPTION_CHANGE') OR (minimum_quantity IS NULL AND maximum_quantity IS NULL)),
 CONSTRAINT chk_listing_adjustment_rules_5 CHECK (requires_requote)
);

COMMENT ON TABLE listing_adjustment_rules IS 'shared configuration. Scope kind = ADJUSTMENTS; UQ (scope_id, adjustment_type).';

CREATE TABLE booking_documents (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 code VARCHAR(50) NOT NULL,
 name VARCHAR(150) NOT NULL,
 description TEXT,
 is_live BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_booking_documents PRIMARY KEY (id),
 CONSTRAINT uq_booking_documents_code UNIQUE (code),
 CONSTRAINT chk_booking_documents_1 CHECK (code ~ '^[A-Z][A-Z0-9_]*$'),
 CONSTRAINT chk_booking_documents_2 CHECK (btrim(name) <> '')
);

COMMENT ON TABLE booking_documents IS 'shared configuration. Uppercase non-empty code; non-empty name. Content is versioned separately.';

CREATE TABLE booking_document_versions (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 document_id UUID NOT NULL,
 version_number INTEGER NOT NULL,
 content_text TEXT,
 asset_url TEXT,
 content_sha256 CHAR(64) NOT NULL,
 published_at TIMESTAMPTZ,
 is_live BOOLEAN NOT NULL DEFAULT FALSE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_booking_document_versions PRIMARY KEY (id),
 CONSTRAINT uq_booking_document_versions_document_id_version_number UNIQUE (document_id,version_number),
 CONSTRAINT fk_booking_document_versions_document_id FOREIGN KEY (document_id) REFERENCES booking_documents (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_booking_document_versions_1 CHECK (version_number > 0),
 CONSTRAINT chk_booking_document_versions_2 CHECK (num_nonnulls(content_text,asset_url) = 1),
 CONSTRAINT chk_booking_document_versions_3 CHECK (content_text IS NULL OR btrim(content_text) <> ''),
 CONSTRAINT chk_booking_document_versions_4 CHECK (asset_url IS NULL OR btrim(asset_url) <> ''),
 CONSTRAINT chk_booking_document_versions_5 CHECK (content_sha256 ~ '^[a-f0-9]{64}$'),
 CONSTRAINT chk_booking_document_versions_6 CHECK (NOT is_live OR published_at IS NOT NULL)
);

COMMENT ON TABLE booking_document_versions IS 'shared configuration. UQ (document_id, version_number); version >0; exactly one content_text/asset_url.';

CREATE TABLE listing_booking_obligations (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 scope_id UUID NOT NULL,
 code VARCHAR(50) NOT NULL,
 obligation_type VARCHAR(30) NOT NULL,
 document_version_id UUID,
 is_required BOOLEAN NOT NULL DEFAULT TRUE,
 required_by_stage VARCHAR(30) NOT NULL,
 instructions TEXT,
 is_live BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_listing_booking_obligations PRIMARY KEY (id),
 CONSTRAINT uq_listing_booking_obligations_scope_id_code UNIQUE (scope_id,code),
 CONSTRAINT fk_listing_booking_obligations_scope_id FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_listing_booking_obligations_document_version_id FOREIGN KEY (document_version_id) REFERENCES booking_document_versions (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_listing_booking_obligations_obligation_type CHECK (obligation_type IN ('WAIVER','TERMS_ACCEPTANCE','DOCUMENT_PROVISION','PROVIDER_APPROVAL')),
 CONSTRAINT chk_listing_booking_obligations_required_by_stage CHECK (required_by_stage IN ('REQUEST','CONFIRMATION','BEFORE_DELIVERY')),
 CONSTRAINT chk_listing_booking_obligations_1 CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

COMMENT ON TABLE listing_booking_obligations IS 'shared configuration. Scope kind = BOOKING_OBLIGATIONS; UQ (scope_id, code); non-empty uppercase code.';

CREATE TABLE listing_event_associations (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 listing_id UUID NOT NULL,
 event_listing_id UUID NOT NULL,
 event_occurrence_id UUID,
 relationship_type VARCHAR(30) NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_listing_event_associations PRIMARY KEY (id),
 CONSTRAINT fk_listing_event_associations_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_listing_event_associations_event_listing_id FOREIGN KEY (event_listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_listing_event_associations_event_occurrence_id_even_15be63b3 FOREIGN KEY (event_occurrence_id,event_listing_id) REFERENCES listing_occurrences (id,listing_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_listing_event_associations_relationship_type CHECK (relationship_type IN ('SUPPORTING_SERVICE','ACCOMMODATION_OFFER','TRANSPORT_OFFER','RELATED_OFFER')),
 CONSTRAINT chk_listing_event_associations_1 CHECK (listing_id <> event_listing_id)
);

COMMENT ON TABLE listing_event_associations IS 'shared configuration. UQ base: (listing_id,event_listing_id,type) WHERE occurrence IS NULL.';

CREATE TABLE experience_component_inclusion_rules (
 id UUID NOT NULL DEFAULT gen_random_uuid(),
 experience_listing_id UUID NOT NULL,
 component_id UUID NOT NULL,
 quantity_anchor_component_id UUID,
 frequency_basis VARCHAR(30) NOT NULL DEFAULT 'ONCE',
 frequency_anchor_component_id UUID,
 day_count_basis VARCHAR(30),
 service_day_boundary TIME,
 maximum_included_units INTEGER,
 inclusion_instructions TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_experience_component_inclusion_rules PRIMARY KEY (id),
 CONSTRAINT uq_experience_component_inclusion_rules_component_id UNIQUE (component_id),
 CONSTRAINT fk_experience_component_inclusion_rules_experience_listing_id FOREIGN KEY (experience_listing_id) REFERENCES experiences (listing_id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_experience_component_inclusion_rules_component_id_e_24d71aa8 FOREIGN KEY (component_id,experience_listing_id) REFERENCES experience_components (id,experience_listing_id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_experience_component_inclusion_rules_quantity_ancho_099aa172 FOREIGN KEY (quantity_anchor_component_id,experience_listing_id) REFERENCES experience_components (id,experience_listing_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_experience_component_inclusion_rules_frequency_anch_ccee3897 FOREIGN KEY (frequency_anchor_component_id,experience_listing_id) REFERENCES experience_components (id,experience_listing_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT chk_experience_component_inclusion_rules_frequency_basis CHECK (frequency_basis IN ('ONCE','PER_NIGHT','PER_DAY','PER_OCCURRENCE')),
 CONSTRAINT chk_experience_component_inclusion_rules_day_count_basis CHECK (day_count_basis IN ('CALENDAR_DATE','SERVICE_DATE')),
 CONSTRAINT chk_experience_component_inclusion_rules_1 CHECK ((frequency_basis <> 'ONCE') = (frequency_anchor_component_id IS NOT NULL)),
 CONSTRAINT chk_experience_component_inclusion_rules_2 CHECK ((frequency_basis = 'PER_DAY') = (day_count_basis IS NOT NULL)),
 CONSTRAINT chk_experience_component_inclusion_rules_3 CHECK ((day_count_basis IS NOT DISTINCT FROM 'SERVICE_DATE') = (service_day_boundary IS NOT NULL)),
 CONSTRAINT chk_experience_component_inclusion_rules_4 CHECK (maximum_included_units IS NULL OR maximum_included_units > 0),
 CONSTRAINT chk_experience_component_inclusion_rules_5 CHECK (quantity_anchor_component_id IS NULL OR quantity_anchor_component_id <> component_id),
 CONSTRAINT chk_experience_component_inclusion_rules_6 CHECK (frequency_anchor_component_id IS NULL OR frequency_anchor_component_id <> component_id)
);

COMMENT ON TABLE experience_component_inclusion_rules IS 'extension configuration. Component and both anchors use composite FK (id, experience_listing_id).';


CREATE UNIQUE INDEX uq_config_scope_base ON listing_configuration_scopes(listing_id,configuration_kind) WHERE listing_option_id IS NULL;
CREATE UNIQUE INDEX uq_config_scope_option ON listing_configuration_scopes(listing_id,listing_option_id,configuration_kind) WHERE listing_option_id IS NOT NULL;
CREATE UNIQUE INDEX uq_listing_event_base ON listing_event_associations(listing_id,event_listing_id,relationship_type) WHERE event_occurrence_id IS NULL;
CREATE UNIQUE INDEX uq_listing_event_occurrence ON listing_event_associations(listing_id,event_listing_id,event_occurrence_id,relationship_type) WHERE event_occurrence_id IS NOT NULL;

CREATE INDEX ix_listing_configuration_scopes_listing_id ON listing_configuration_scopes (listing_id);
CREATE INDEX ix_listing_configuration_scopes_listing_option_id_listing_id ON listing_configuration_scopes (listing_option_id,listing_id);
CREATE INDEX ix_service_coverage_areas_geographic_area_id ON service_coverage_areas (geographic_area_id);
CREATE INDEX ix_service_journey_legs_origin_place_id ON service_journey_legs (origin_place_id);
CREATE INDEX ix_service_journey_legs_destination_place_id ON service_journey_legs (destination_place_id);
CREATE INDEX ix_service_journey_legs_origin_area_id ON service_journey_legs (origin_area_id);
CREATE INDEX ix_service_journey_legs_destination_area_id ON service_journey_legs (destination_area_id);
CREATE INDEX ix_service_entitlement_resources_resource_id ON service_entitlement_resources (resource_id);
CREATE INDEX ix_listing_customer_information_requirements_informati_4777f9bb ON listing_customer_information_requirements (information_field_id);
CREATE INDEX ix_listing_booking_obligations_document_version_id ON listing_booking_obligations (document_version_id);
CREATE INDEX ix_listing_event_associations_listing_id ON listing_event_associations (listing_id);
CREATE INDEX ix_listing_event_associations_event_listing_id ON listing_event_associations (event_listing_id);
CREATE INDEX ix_listing_event_associations_event_occurrence_id_even_afca74d8 ON listing_event_associations (event_occurrence_id,event_listing_id);
CREATE INDEX ix_experience_component_inclusion_rules_experience_listing_id ON experience_component_inclusion_rules (experience_listing_id);
CREATE INDEX ix_experience_component_inclusion_rules_component_id_e_69b0ddd7 ON experience_component_inclusion_rules (component_id,experience_listing_id);
CREATE INDEX ix_experience_component_inclusion_rules_quantity_ancho_18445cf3 ON experience_component_inclusion_rules (quantity_anchor_component_id,experience_listing_id);
CREATE INDEX ix_experience_component_inclusion_rules_frequency_anch_7abd0858 ON experience_component_inclusion_rules (frequency_anchor_component_id,experience_listing_id);

-- Optional existing luggage facts: validate existing columns before reusing them.
DO $luggage$
DECLARE col text; actual_type text;
BEGIN
 FOREACH col IN ARRAY ARRAY['checked_bag_capacity','cabin_bag_capacity'] LOOP
  SELECT udt_name INTO actual_type FROM information_schema.columns
   WHERE table_schema='public' AND table_name='vehicles' AND column_name=col;
  IF actual_type IS NULL THEN
   EXECUTE format('ALTER TABLE public.vehicles ADD COLUMN %I SMALLINT',col);
  ELSIF actual_type <> 'int2' THEN
   RAISE EXCEPTION 'Existing vehicles.% must be SMALLINT; inspect authoritative luggage model',col;
  END IF;
  EXECUTE format('ALTER TABLE public.vehicles ADD CONSTRAINT %I CHECK (%I IS NULL OR %I >= 0)', 'chk_kns11_'||col,col,col);
 END LOOP;
END
$luggage$;

CREATE FUNCTION kns11_touch_audit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 NEW.created_at := OLD.created_at;
 NEW.created_by := OLD.created_by;
 NEW.updated_at := CURRENT_TIMESTAMP;
 IF TG_TABLE_NAME <> 'services' AND TG_TABLE_NAME NOT IN ('service_schedule_policies','service_stay_policies','service_journey_policies','service_entitlement_policies','service_coverage_areas','service_entitlement_resources')
  AND (to_jsonb(NEW)->>'id') IS DISTINCT FROM (to_jsonb(OLD)->>'id') THEN
  RAISE EXCEPTION 'Record identity is immutable' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;

CREATE FUNCTION kns11_check_service() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_type text;
BEGIN
 IF TG_OP='UPDATE' AND NEW.listing_id <> OLD.listing_id THEN RAISE EXCEPTION 'Service identity is immutable' USING ERRCODE='23514'; END IF;
 PERFORM 1 FROM listings WHERE id=NEW.listing_id FOR UPDATE;
 SELECT t.code INTO parent_type FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.listing_id;
 IF parent_type IS DISTINCT FROM 'SERVICE' THEN RAISE EXCEPTION 'Service parent must have listing type SERVICE' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_service_parent BEFORE INSERT OR UPDATE ON services FOR EACH ROW EXECUTE FUNCTION kns11_check_service();

CREATE FUNCTION kns11_check_scope() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='UPDATE' AND (NEW.listing_id,NEW.listing_option_id,NEW.configuration_kind) IS DISTINCT FROM (OLD.listing_id,OLD.listing_option_id,OLD.configuration_kind) THEN
  RAISE EXCEPTION 'Scope listing, option and family are immutable' USING ERRCODE='23514';
 END IF;
 IF TG_OP='DELETE' THEN PERFORM 1 FROM listings WHERE id=OLD.listing_id FOR UPDATE; RETURN OLD; END IF;
 PERFORM 1 FROM listings WHERE id=NEW.listing_id FOR UPDATE;
 IF NEW.configuration_kind LIKE 'SERVICE_%' AND NOT EXISTS(SELECT 1 FROM services WHERE listing_id=NEW.listing_id) THEN
  RAISE EXCEPTION 'Service policy scopes require an existing Service subtype' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_scope_parent BEFORE INSERT OR UPDATE OR DELETE ON listing_configuration_scopes FOR EACH ROW EXECUTE FUNCTION kns11_check_scope();

CREATE FUNCTION kns11_guard_scope_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE sid uuid; s listing_configuration_scopes; keyname text:=TG_ARGV[0]; expected_kind text:=TG_ARGV[1];
BEGIN
 IF TG_OP='UPDATE' AND (to_jsonb(NEW)->>keyname) IS DISTINCT FROM (to_jsonb(OLD)->>keyname) THEN
  RAISE EXCEPTION 'Moving configuration between scopes is unsupported' USING ERRCODE='23514';
 END IF;
 IF TG_OP='DELETE' THEN sid:=(to_jsonb(OLD)->>keyname)::uuid; ELSE sid:=(to_jsonb(NEW)->>keyname)::uuid; END IF;
 SELECT * INTO s FROM listing_configuration_scopes WHERE id=sid;
 IF FOUND THEN
  PERFORM 1 FROM listings WHERE id=s.listing_id FOR UPDATE;
  IF TG_OP <> 'DELETE' AND (s.configuration_kind <> expected_kind OR s.configuration_mode <> 'CUSTOM') THEN
   RAISE EXCEPTION 'Configuration requires a CUSTOM scope of family %',expected_kind USING ERRCODE='23514';
  END IF;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;

CREATE FUNCTION kns11_validate_scope_final() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE sid uuid; s listing_configuration_scopes; n integer;
BEGIN
 IF TG_TABLE_NAME='listing_configuration_scopes' THEN
  IF TG_OP='DELETE' THEN sid:=OLD.id; ELSE sid:=NEW.id; END IF;
 ELSE
  IF TG_OP='DELETE' THEN sid:=OLD.scope_id; ELSE sid:=NEW.scope_id; END IF;
 END IF;
 SELECT * INTO s FROM listing_configuration_scopes WHERE id=sid;
 IF NOT FOUND THEN RETURN NULL; END IF;
 IF s.configuration_mode <> 'CUSTOM' THEN
  SELECT count(*) INTO n FROM (
   SELECT scope_id FROM service_schedule_policies WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM service_delivery_configurations WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM service_stay_policies WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM service_journey_policies WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM service_entitlement_policies WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM listing_customer_information_requirements WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM listing_adjustment_rules WHERE scope_id=sid UNION ALL
   SELECT scope_id FROM listing_booking_obligations WHERE scope_id=sid
  ) owned;
  IF n > 0 THEN RAISE EXCEPTION 'INHERIT/DISABLED scopes cannot retain owned configuration' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns11_scope_final AFTER INSERT OR UPDATE OR DELETE ON listing_configuration_scopes
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();

CREATE TRIGGER trg_kns11_service_schedule_policies_scope BEFORE INSERT OR UPDATE OR DELETE ON service_schedule_policies FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','SERVICE_SCHEDULE');
CREATE CONSTRAINT TRIGGER trg_kns11_service_schedule_policies_final AFTER INSERT OR UPDATE OR DELETE ON service_schedule_policies DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_service_delivery_configurations_scope BEFORE INSERT OR UPDATE OR DELETE ON service_delivery_configurations FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','SERVICE_DELIVERY');
CREATE CONSTRAINT TRIGGER trg_kns11_service_delivery_configurations_final AFTER INSERT OR UPDATE OR DELETE ON service_delivery_configurations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_service_stay_policies_scope BEFORE INSERT OR UPDATE OR DELETE ON service_stay_policies FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','SERVICE_STAY');
CREATE CONSTRAINT TRIGGER trg_kns11_service_stay_policies_final AFTER INSERT OR UPDATE OR DELETE ON service_stay_policies DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_service_journey_policies_scope BEFORE INSERT OR UPDATE OR DELETE ON service_journey_policies FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','SERVICE_JOURNEY');
CREATE CONSTRAINT TRIGGER trg_kns11_service_journey_policies_final AFTER INSERT OR UPDATE OR DELETE ON service_journey_policies DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_service_entitlement_policies_scope BEFORE INSERT OR UPDATE OR DELETE ON service_entitlement_policies FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','SERVICE_ENTITLEMENT');
CREATE CONSTRAINT TRIGGER trg_kns11_service_entitlement_policies_final AFTER INSERT OR UPDATE OR DELETE ON service_entitlement_policies DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_listing_customer_information_requirements_scope BEFORE INSERT OR UPDATE OR DELETE ON listing_customer_information_requirements FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','CUSTOMER_INFORMATION');
CREATE CONSTRAINT TRIGGER trg_kns11_listing_customer_information_requirements_final AFTER INSERT OR UPDATE OR DELETE ON listing_customer_information_requirements DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_listing_adjustment_rules_scope BEFORE INSERT OR UPDATE OR DELETE ON listing_adjustment_rules FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','ADJUSTMENTS');
CREATE CONSTRAINT TRIGGER trg_kns11_listing_adjustment_rules_final AFTER INSERT OR UPDATE OR DELETE ON listing_adjustment_rules DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();
CREATE TRIGGER trg_kns11_listing_booking_obligations_scope BEFORE INSERT OR UPDATE OR DELETE ON listing_booking_obligations FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','BOOKING_OBLIGATIONS');
CREATE CONSTRAINT TRIGGER trg_kns11_listing_booking_obligations_final AFTER INSERT OR UPDATE OR DELETE ON listing_booking_obligations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_scope_final();

CREATE FUNCTION kns11_guard_nested_child() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE sid uuid; lid uuid; rowjson jsonb; oldjson jsonb;
BEGIN
 IF TG_OP='DELETE' THEN rowjson:=to_jsonb(OLD); ELSE rowjson:=to_jsonb(NEW); END IF;
 IF TG_OP='UPDATE' THEN
  oldjson:=to_jsonb(OLD);
  IF (rowjson->>TG_ARGV[0]) IS DISTINCT FROM (oldjson->>TG_ARGV[0]) THEN RAISE EXCEPTION 'Moving owned rows between policies is unsupported' USING ERRCODE='23514'; END IF;
  IF TG_TABLE_NAME='service_entitlement_resources' AND (rowjson->>'resource_id',rowjson->>'purpose') IS DISTINCT FROM (oldjson->>'resource_id',oldjson->>'purpose') THEN
   RAISE EXCEPTION 'Entitlement resource identity is immutable; replace the association' USING ERRCODE='23514';
  ELSIF TG_TABLE_NAME='service_coverage_areas' AND (rowjson->>'geographic_area_id') IS DISTINCT FROM (oldjson->>'geographic_area_id') THEN
   RAISE EXCEPTION 'Coverage identity is immutable; replace the association' USING ERRCODE='23514';
  END IF;
 END IF;
 IF TG_TABLE_NAME='service_coverage_areas' THEN
  SELECT scope_id INTO sid FROM service_delivery_configurations WHERE id=(rowjson->>'delivery_configuration_id')::uuid;
  IF TG_OP <> 'DELETE' AND EXISTS(SELECT 1 FROM service_delivery_configurations WHERE id=(rowjson->>'delivery_configuration_id')::uuid AND coverage_mode <> 'LISTED_AREAS') THEN
   RAISE EXCEPTION 'Area assignments require LISTED_AREAS coverage' USING ERRCODE='23514';
  END IF;
 ELSIF TG_TABLE_NAME='service_journey_legs' THEN sid:=(rowjson->>'journey_policy_id')::uuid;
 ELSE sid:=(rowjson->>'entitlement_policy_id')::uuid;
 END IF;
 SELECT listing_id INTO lid FROM listing_configuration_scopes WHERE id=sid;
 IF FOUND THEN PERFORM 1 FROM listings WHERE id=lid FOR UPDATE; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_coverage_parent BEFORE INSERT OR UPDATE OR DELETE ON service_coverage_areas FOR EACH ROW EXECUTE FUNCTION kns11_guard_nested_child('delivery_configuration_id');
CREATE TRIGGER trg_kns11_leg_parent BEFORE INSERT OR UPDATE OR DELETE ON service_journey_legs FOR EACH ROW EXECUTE FUNCTION kns11_guard_nested_child('journey_policy_id');
CREATE TRIGGER trg_kns11_ent_resource_parent BEFORE INSERT OR UPDATE OR DELETE ON service_entitlement_resources FOR EACH ROW EXECUTE FUNCTION kns11_guard_nested_child('entitlement_policy_id');

CREATE FUNCTION kns11_validate_delivery_final() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE did uuid;
BEGIN
 IF TG_TABLE_NAME='service_delivery_configurations' THEN
  IF TG_OP='DELETE' THEN did:=OLD.id; ELSE did:=NEW.id; END IF;
 ELSE
  IF TG_OP='DELETE' THEN did:=OLD.delivery_configuration_id; ELSE did:=NEW.delivery_configuration_id; END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM service_delivery_configurations d JOIN service_coverage_areas a ON a.delivery_configuration_id=d.id WHERE d.id=did AND d.coverage_mode<>'LISTED_AREAS') THEN
  RAISE EXCEPTION 'Non-listed coverage cannot retain area assignments' USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns11_delivery_final AFTER INSERT OR UPDATE OR DELETE ON service_delivery_configurations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_delivery_final();
CREATE CONSTRAINT TRIGGER trg_kns11_coverage_final AFTER INSERT OR UPDATE OR DELETE ON service_coverage_areas DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_delivery_final();

CREATE FUNCTION kns11_check_document_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='DELETE' THEN PERFORM 1 FROM booking_documents WHERE id=OLD.document_id FOR UPDATE;
  IF OLD.published_at IS NOT NULL THEN RAISE EXCEPTION 'Published document versions cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 PERFORM 1 FROM booking_documents WHERE id=NEW.document_id FOR UPDATE;
 IF TG_OP='UPDATE' THEN
  IF (NEW.document_id,NEW.version_number) IS DISTINCT FROM (OLD.document_id,OLD.version_number) THEN RAISE EXCEPTION 'Document/version identity is immutable' USING ERRCODE='23514'; END IF;
  IF OLD.published_at IS NOT NULL AND (NEW.content_text,NEW.asset_url,NEW.content_sha256,NEW.published_at) IS DISTINCT FROM (OLD.content_text,OLD.asset_url,OLD.content_sha256,OLD.published_at) THEN
   RAISE EXCEPTION 'Published document content and publication identity are immutable' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_doc_version BEFORE INSERT OR UPDATE OR DELETE ON booking_document_versions FOR EACH ROW EXECUTE FUNCTION kns11_check_document_version();

CREATE FUNCTION kns11_guard_field_definition() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (NEW.code,NEW.data_type) IS DISTINCT FROM (OLD.code,OLD.data_type) THEN
  RAISE EXCEPTION 'Booking field code/type is immutable; introduce a new definition for a different meaning' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_field_definition BEFORE UPDATE ON booking_information_fields FOR EACH ROW EXECUTE FUNCTION kns11_guard_field_definition();

CREATE FUNCTION kns11_guard_listing_type() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.listing_type_id IS DISTINCT FROM OLD.listing_type_id AND (
  EXISTS(SELECT 1 FROM services WHERE listing_id=OLD.id) OR
  EXISTS(SELECT 1 FROM listing_event_associations WHERE event_listing_id=OLD.id)
 ) THEN RAISE EXCEPTION 'Listing type is immutable while Service/Event configuration references it' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_listing_type BEFORE UPDATE OF listing_type_id ON listings FOR EACH ROW EXECUTE FUNCTION kns11_guard_listing_type();
CREATE FUNCTION kns11_guard_type_code() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS(SELECT 1 FROM listings WHERE listing_type_id=OLD.id) THEN
  RAISE EXCEPTION 'Referenced listing type code is immutable' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_type_code BEFORE UPDATE OF code ON listing_types FOR EACH ROW EXECUTE FUNCTION kns11_guard_type_code();

CREATE FUNCTION kns11_guard_event_association() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE target_type text;
BEGIN
 IF TG_OP='UPDATE' AND NEW.listing_id <> OLD.listing_id THEN RAISE EXCEPTION 'Moving an Event association to another listing is unsupported' USING ERRCODE='23514'; END IF;
 -- Stable lock order prevents opposing source/target association edits deadlocking.
 PERFORM 1 FROM listings WHERE id IN (NEW.listing_id,NEW.event_listing_id) ORDER BY id FOR UPDATE;
 SELECT t.code INTO target_type FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.event_listing_id;
 IF target_type IS DISTINCT FROM 'EVENT' THEN RAISE EXCEPTION 'Association target must have listing type EVENT' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns11_event_target BEFORE INSERT OR UPDATE ON listing_event_associations FOR EACH ROW EXECUTE FUNCTION kns11_guard_event_association();

CREATE FUNCTION kns11_lock_inclusion_graph() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE eid uuid;
BEGIN
 IF TG_OP='DELETE' THEN eid:=OLD.experience_listing_id; ELSE eid:=NEW.experience_listing_id; END IF;
 IF TG_OP='UPDATE' AND NEW.experience_listing_id <> OLD.experience_listing_id THEN RAISE EXCEPTION 'Moving inclusion configuration between Experiences is unsupported' USING ERRCODE='23514'; END IF;
 IF TG_TABLE_NAME='experience_component_inclusion_rules' AND TG_OP='UPDATE' AND (to_jsonb(NEW)->>'component_id') IS DISTINCT FROM (to_jsonb(OLD)->>'component_id') THEN
  RAISE EXCEPTION 'Inclusion component identity is immutable' USING ERRCODE='23514';
 END IF;
 PERFORM 1 FROM experiences WHERE listing_id=eid FOR UPDATE;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;

CREATE FUNCTION kns11_validate_inclusion_graph() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE eid uuid;
BEGIN
 IF TG_OP='DELETE' THEN eid:=OLD.experience_listing_id; ELSE eid:=NEW.experience_listing_id; END IF;
 IF NOT EXISTS(SELECT 1 FROM experiences WHERE listing_id=eid) THEN RETURN NULL; END IF;
 IF EXISTS(SELECT 1 FROM experience_component_inclusion_rules r JOIN experience_components c ON c.id=r.component_id
  WHERE r.experience_listing_id=eid AND ((c.quantity_basis='PER_ALLOCATED_UNIT') <> (r.quantity_anchor_component_id IS NOT NULL))) THEN
  RAISE EXCEPTION 'Quantity anchor is required exactly for PER_ALLOCATED_UNIT' USING ERRCODE='23514';
 END IF;
 IF EXISTS(
  SELECT 1 FROM experience_component_inclusion_rules r JOIN experience_components c ON c.id=r.component_id
  JOIN experience_components a ON a.id IN (r.quantity_anchor_component_id,r.frequency_anchor_component_id)
  WHERE r.experience_listing_id=eid AND c.experience_option_id IS NOT NULL AND a.experience_option_id IS NOT NULL AND c.experience_option_id<>a.experience_option_id
 ) THEN RAISE EXCEPTION 'Inclusion anchors cannot join mutually exclusive Experience options' USING ERRCODE='23514'; END IF;
 IF EXISTS(
  WITH RECURSIVE edges(a,b) AS (
   SELECT component_id,quantity_anchor_component_id FROM experience_component_inclusion_rules WHERE experience_listing_id=eid AND quantity_anchor_component_id IS NOT NULL
   UNION SELECT component_id,frequency_anchor_component_id FROM experience_component_inclusion_rules WHERE experience_listing_id=eid AND frequency_anchor_component_id IS NOT NULL
  ), paths(a,b) AS (SELECT a,b FROM edges UNION SELECT p.a,e.b FROM paths p JOIN edges e ON p.b=e.a)
  SELECT 1 FROM paths WHERE a=b
 ) THEN RAISE EXCEPTION 'Inclusion anchors contain a cycle' USING ERRCODE='23514'; END IF;
 RETURN NULL;
END $$;
CREATE TRIGGER trg_kns11_inclusion_lock BEFORE INSERT OR UPDATE OR DELETE ON experience_component_inclusion_rules FOR EACH ROW EXECUTE FUNCTION kns11_lock_inclusion_graph();
CREATE CONSTRAINT TRIGGER trg_kns11_inclusion_graph AFTER INSERT OR UPDATE OR DELETE ON experience_component_inclusion_rules DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_inclusion_graph();
CREATE TRIGGER trg_kns11_component_lock BEFORE INSERT OR UPDATE OR DELETE ON experience_components FOR EACH ROW EXECUTE FUNCTION kns11_lock_inclusion_graph();
CREATE CONSTRAINT TRIGGER trg_kns11_component_inclusion AFTER INSERT OR UPDATE OR DELETE ON experience_components DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_inclusion_graph();

CREATE TRIGGER trg_kns11_services_audit BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_listing_configuration_scopes_audit BEFORE UPDATE ON listing_configuration_scopes FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_schedule_policies_audit BEFORE UPDATE ON service_schedule_policies FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_delivery_configurations_audit BEFORE UPDATE ON service_delivery_configurations FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_coverage_areas_audit BEFORE UPDATE ON service_coverage_areas FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_stay_policies_audit BEFORE UPDATE ON service_stay_policies FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_journey_policies_audit BEFORE UPDATE ON service_journey_policies FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_journey_legs_audit BEFORE UPDATE ON service_journey_legs FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_entitlement_policies_audit BEFORE UPDATE ON service_entitlement_policies FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_service_entitlement_resources_audit BEFORE UPDATE ON service_entitlement_resources FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_booking_information_fields_audit BEFORE UPDATE ON booking_information_fields FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_listing_customer_information_requirements_audit BEFORE UPDATE ON listing_customer_information_requirements FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_listing_adjustment_rules_audit BEFORE UPDATE ON listing_adjustment_rules FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_booking_documents_audit BEFORE UPDATE ON booking_documents FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_booking_document_versions_audit BEFORE UPDATE ON booking_document_versions FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_listing_booking_obligations_audit BEFORE UPDATE ON listing_booking_obligations FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_listing_event_associations_audit BEFORE UPDATE ON listing_event_associations FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TRIGGER trg_kns11_experience_component_inclusion_rules_audit BEFORE UPDATE ON experience_component_inclusion_rules FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();

COMMENT ON COLUMN listing_configuration_scopes.configuration_mode IS 'Missing option scope inherits base. CUSTOM replaces the complete family; INHERIT/DISABLED own no rows. Missing base means unconfigured.';
COMMENT ON COLUMN service_stay_policies.maximum_occupants IS 'Offer limit per allocated accommodation Unit, never an override of resource capacity.';
COMMENT ON COLUMN service_journey_legs.journey_policy_id IS 'References service_journey_policies.scope_id; templates never store customer flight details or dates.';
COMMENT ON COLUMN booking_document_versions.content_sha256 IS 'SHA256 of canonical published content/asset bytes; application verifies actual bytes before publication.';
COMMENT ON COLUMN experience_component_inclusion_rules.maximum_included_units IS 'Optional ceiling on component.quantity multiplied by quantity-basis count and frequency count.';

-- REQUIRED APPLICATION / READINESS / BOOKING CONTRACT (not claimed by SQL alone):
-- 1. Resolve each option's effective scope family. CUSTOM replaces all base rows;
--    INHERIT uses base; DISABLED suppresses. Require effective Service scheduling.
--    Require typed scalar policy/required collection content before publication;
--    empty CUSTOM scopes are valid drafts, never proof of readiness.
-- 2. CUSTOMER_LOCATION needs an address policy. Applicable coverage must be chosen;
--    LISTED_AREAS needs areas at publication. Validate endpoint Place/area ancestry
--    and geography changes; no geography column is treated as an implicit hard
--    DYNAMIC resource filter. Existing Place key is places.resource_id.
-- 3. Check-in windows use local Place/country zones; actual timestamps are UTC-aware.
--    Date-range occupancy interval is checkout-exclusive. Validate Unit capacities,
--    child participants and extra-guest/night adjustments against the effective stay.
-- 4. Journey: >=1 applicable leg at publication; PREVIOUS_LEG_END not first; valid
--    sequence/timing and supported endpoints. Select date/time/flight/address per
--    actual leg. Shared seats and exclusive vehicles are different allocations;
--    FULL_CAPACITY does not guarantee departure until actual capacity is filled.
--    Match compatible Vehicle+Driver+Operator, luggage and availability across legs.
-- 5. Entitlements: resolve supported redemption/collection/access resources,
--    selected-date/stay/period validity and any physical stock. Actual issuance,
--    redemption, usage count and fulfilment are booking/inventory records.
-- 6. Collect mode-required inputs automatically; admin information rows cannot
--    suppress required dates/counts. Conditions apply to matching actual journey
--    legs. Input codes/types require implemented renderers/validators.
-- 7. Required WAIVER/TERMS obligations need accessible published document versions;
--    verify immutable asset content/hash. Snapshot consent/upload/provider evidence
--    with the booking. Do not seed invented legal wording or acceptance records.
-- 8. Inclusion: resolve anchors in every effective Experience variant (including
--    substitutions/removals); reject missing anchors/capacity. Require inclusion
--    row for PER_ALLOCATED_UNIT before publish. PER_NIGHT counts stay nights;
--    PER_DAY counts eligible dates in [start,end), with explicit SERVICE_DATE
--    boundary; one date resolves [date,date+1). PER_OCCURRENCE counts occurrences,
--    not individual legs. Shared component anchors cannot depend on an option-only
--    row unless that row is determinately present in every effective offer.
-- 9. Honour price/benefit/resource revalidation for adjustments. Per-period units,
--    fees, quote/deposit/cancellation/currency/group thresholds remain shared pricing.
-- 10. Source/Event association does NOT include admission. Customer publication
--     checks eligible/live references, all effective policies and unresolved issues.
-- 11. Deleting Service subtype must remove SERVICE_* scopes first in the same
--     transaction; direct deletion leaving Service scopes is blocked below.
--     Inclusion anchors use RESTRICT: remove dependant rules explicitly before
--     deleting referenced components/Experiences. Prefer unpublishing history.
-- 12. API authenticates/authorises, supplies audits, prevents duplicate/idempotency
--     races, uses optimistic concurrency and maps public errors. Locks only protect
--     configuration writes; booking reservation/stock concurrency is not implemented.

CREATE FUNCTION kns11_validate_service_presence() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE lid uuid;
BEGIN
 IF TG_OP='DELETE' THEN lid:=OLD.listing_id; ELSE lid:=NEW.listing_id; END IF;
 IF EXISTS(SELECT 1 FROM listings WHERE id=lid)
  AND NOT EXISTS(SELECT 1 FROM services WHERE listing_id=lid)
  AND EXISTS(SELECT 1 FROM listing_configuration_scopes WHERE listing_id=lid AND configuration_kind LIKE 'SERVICE_%') THEN
  RAISE EXCEPTION 'Cannot remove Service subtype while Service scopes remain' USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns11_service_presence AFTER INSERT OR UPDATE OR DELETE ON services DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns11_validate_service_presence();
COMMIT;
