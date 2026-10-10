-- Kampala Nonstop / Africa Nonstop - Tour creation schema
-- File 13. PostgreSQL 13+. Run ONCE after files 9, 10, 11 and 12.
-- Then run 13_1_kampala_nonstop_tours_reference_seed.sql.
-- Six new Tour tables; extends shared scopes and adds nullable departure time_zone.
-- Design ERD: kampala_nonstop_tours_schema_erd.pdf. No invented operators/tours/prices.
-- Guide gender preferences and booking-time matching are deliberately deferred.
-- Draft structure is enforced here; application publication/readiness rules below.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';
DO $preflight$
DECLARE r record; actual text;
BEGIN
 IF current_setting('server_version_num')::integer < 130000 THEN RAISE EXCEPTION 'Tour schema requires PostgreSQL 13+'; END IF;
 FOR r IN SELECT * FROM (VALUES
 ('listings','id','uuid'),('listings','listing_type_id','uuid'),('listing_types','code','varchar'),
 ('listing_options','listing_id','uuid'),('places','resource_id','uuid'),
 ('geographic_areas','parent_geographic_area_id','uuid'),
 ('listing_configuration_scopes','configuration_kind','varchar'),
 ('listing_fulfilment_requirements','listing_option_id','uuid'),
 ('listing_departure_rules','start_time','time'),('listing_occurrences','schedule_precision','varchar'),
 ('booking_information_fields','data_type','varchar'),('events','listing_id','uuid')
 ) AS d(tbl,col,typ) LOOP
  SELECT udt_name INTO actual FROM information_schema.columns WHERE table_schema='public' AND table_name=r.tbl AND column_name=r.col;
  IF actual IS DISTINCT FROM r.typ THEN RAISE EXCEPTION 'Expected public.%.% type %, found %',r.tbl,r.col,r.typ,coalesce(actual,'missing'); END IF;
 END LOOP;
 IF to_regprocedure('public.kns11_guard_scope_child()') IS NULL OR to_regprocedure('public.kns11_touch_audit()') IS NULL THEN
  RAISE EXCEPTION 'Expected shared scope/audit functions from file 11';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM listing_types WHERE code='TOUR') THEN RAISE EXCEPTION 'Apply existing listing reference seed: TOUR listing type is required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conrelid='listing_configuration_scopes'::regclass AND conname='chk_listing_configuration_scopes_configuration_kind' AND contype='c') THEN
  RAISE EXCEPTION 'Expected scope-kind check from file 11; inspect current scope migration';
 END IF;
 FOR r IN SELECT unnest(ARRAY['tours','tour_policies','tour_itinerary_days','tour_itinerary_items','tour_meeting_points','tour_itinerary_fulfilment_links']) AS tbl LOOP
 IF to_regclass('public.'||r.tbl) IS NOT NULL THEN RAISE EXCEPTION 'Target table % already exists; inspect migration history',r.tbl; END IF; END LOOP;
END $preflight$;
CREATE TABLE tours (
 listing_id uuid NOT NULL,
 operating_instructions text,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tours PRIMARY KEY (listing_id),
 CONSTRAINT fk_tours_1 FOREIGN KEY (listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE CASCADE
);
CREATE TRIGGER trg_kns13_tours_audit BEFORE UPDATE ON tours FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TABLE tour_policies (
 scope_id uuid NOT NULL,
 schedule_mode varchar(30) NOT NULL,
 participation_mode varchar(20) NOT NULL,
 minimum_participants smallint NOT NULL DEFAULT 1,
 maximum_participants smallint,
 departure_condition varchar(30) NOT NULL DEFAULT 'NO_MINIMUM',
 minimum_departure_participants smallint,
 itinerary_day_count integer NOT NULL DEFAULT 1,
 overnight_count integer NOT NULL DEFAULT 0,
 time_zone varchar(50),
 is_customisable boolean NOT NULL DEFAULT FALSE,
 customisation_instructions text,
 preparation_instructions text,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tour_policies PRIMARY KEY (scope_id),
 CONSTRAINT fk_tour_policies_1 FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT ck_tour_policies_1 CHECK (schedule_mode IN ('FIXED_START','REQUESTED_START')),
 CONSTRAINT ck_tour_policies_2 CHECK (participation_mode IN ('PRIVATE','SHARED')),
 CONSTRAINT ck_tour_policies_3 CHECK (minimum_participants > 0),
 CONSTRAINT ck_tour_policies_4 CHECK (maximum_participants IS NULL OR maximum_participants >= minimum_participants),
 CONSTRAINT ck_tour_policies_5 CHECK (departure_condition IN ('NO_MINIMUM','MINIMUM_REACHED')),
 CONSTRAINT ck_tour_policies_6 CHECK ((departure_condition = 'MINIMUM_REACHED') = (minimum_departure_participants IS NOT NULL)),
 CONSTRAINT ck_tour_policies_7 CHECK (minimum_departure_participants IS NULL OR (minimum_departure_participants > 0 AND participation_mode = 'SHARED')),
 CONSTRAINT ck_tour_policies_8 CHECK (itinerary_day_count > 0),
 CONSTRAINT ck_tour_policies_9 CHECK (overnight_count >= 0),
 CONSTRAINT ck_tour_policies_10 CHECK (time_zone IS NULL OR btrim(time_zone) <> '')
);
CREATE TRIGGER trg_kns13_tour_policies_audit BEFORE UPDATE ON tour_policies FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TABLE tour_itinerary_days (
 id uuid NOT NULL DEFAULT gen_random_uuid(),
 scope_id uuid NOT NULL,
 day_number integer NOT NULL,
 title varchar(150) NOT NULL,
 description text,
 time_zone varchar(50),
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tour_itinerary_days PRIMARY KEY (id),
 CONSTRAINT fk_tour_itinerary_days_1 FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT ck_tour_itinerary_days_1 CHECK (day_number > 0),
 CONSTRAINT ck_tour_itinerary_days_2 CHECK (btrim(title) <> ''),
 CONSTRAINT ck_tour_itinerary_days_3 CHECK (time_zone IS NULL OR btrim(time_zone) <> ''),
 CONSTRAINT uq_tour_day UNIQUE(scope_id,day_number) DEFERRABLE INITIALLY IMMEDIATE
);
CREATE TRIGGER trg_kns13_tour_itinerary_days_audit BEFORE UPDATE ON tour_itinerary_days FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TABLE tour_itinerary_items (
 id uuid NOT NULL DEFAULT gen_random_uuid(),
 itinerary_day_id uuid NOT NULL,
 sequence_order integer NOT NULL,
 item_kind varchar(20) NOT NULL,
 title varchar(150) NOT NULL,
 description text,
 place_id uuid,
 referenced_listing_id uuid,
 referenced_listing_option_id uuid,
 timing_mode varchar(30) NOT NULL DEFAULT 'UNSPECIFIED',
 local_start_time time,
 start_offset_minutes integer,
 duration_minutes integer,
 is_required boolean NOT NULL DEFAULT TRUE,
 cost_treatment varchar(30) NOT NULL DEFAULT 'INCLUDED',
 instructions text,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tour_itinerary_items PRIMARY KEY (id),
 CONSTRAINT fk_tour_itinerary_items_1 FOREIGN KEY (itinerary_day_id) REFERENCES tour_itinerary_days (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_tour_itinerary_items_2 FOREIGN KEY (place_id) REFERENCES places (resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_tour_itinerary_items_3 FOREIGN KEY (referenced_listing_id) REFERENCES listings (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_tour_itinerary_items_4 FOREIGN KEY (referenced_listing_option_id,referenced_listing_id) REFERENCES listing_options (id,listing_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT ck_tour_itinerary_items_1 CHECK (sequence_order >= 0),
 CONSTRAINT ck_tour_itinerary_items_2 CHECK (btrim(title) <> ''),
 CONSTRAINT ck_tour_itinerary_items_3 CHECK (item_kind IN ('VISIT','ACTIVITY','TRAVEL','MEAL','STAY','FREE_TIME')),
 CONSTRAINT ck_tour_itinerary_items_4 CHECK (timing_mode IN ('UNSPECIFIED','DAY_LOCAL_TIME','FROM_TOUR_START')),
 CONSTRAINT ck_tour_itinerary_items_5 CHECK ((timing_mode = 'DAY_LOCAL_TIME') = (local_start_time IS NOT NULL)),
 CONSTRAINT ck_tour_itinerary_items_6 CHECK ((timing_mode = 'FROM_TOUR_START') = (start_offset_minutes IS NOT NULL)),
 CONSTRAINT ck_tour_itinerary_items_7 CHECK (start_offset_minutes IS NULL OR start_offset_minutes >= 0),
 CONSTRAINT ck_tour_itinerary_items_8 CHECK (duration_minutes IS NULL OR duration_minutes > 0),
 CONSTRAINT ck_tour_itinerary_items_9 CHECK (referenced_listing_option_id IS NULL OR referenced_listing_id IS NOT NULL),
 CONSTRAINT ck_tour_itinerary_items_10 CHECK (cost_treatment IN ('INCLUDED','PAY_DIRECT','OPTIONAL_EXTRA')),
 CONSTRAINT uq_tour_item_sequence UNIQUE(itinerary_day_id,sequence_order) DEFERRABLE INITIALLY IMMEDIATE
);
CREATE TRIGGER trg_kns13_tour_itinerary_items_audit BEFORE UPDATE ON tour_itinerary_items FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TABLE tour_meeting_points (
 id uuid NOT NULL DEFAULT gen_random_uuid(),
 scope_id uuid NOT NULL,
 purpose varchar(20) NOT NULL,
 selection_mode varchar(30) NOT NULL,
 place_id uuid,
 geographic_area_id uuid,
 includes_descendants boolean NOT NULL DEFAULT TRUE,
 minutes_before_start integer,
 instructions text,
 sort_order integer NOT NULL DEFAULT 0,
 is_live boolean NOT NULL DEFAULT TRUE,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tour_meeting_points PRIMARY KEY (id),
 CONSTRAINT fk_tour_meeting_points_1 FOREIGN KEY (scope_id) REFERENCES listing_configuration_scopes (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_tour_meeting_points_2 FOREIGN KEY (place_id) REFERENCES places (resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT fk_tour_meeting_points_3 FOREIGN KEY (geographic_area_id) REFERENCES geographic_areas (id) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT ck_tour_meeting_points_1 CHECK (purpose IN ('MEET','PICKUP','FINISH','DROPOFF')),
 CONSTRAINT ck_tour_meeting_points_2 CHECK (selection_mode IN ('FIXED_PLACE','CUSTOMER_PLACE','CUSTOMER_ADDRESS')),
 CONSTRAINT ck_tour_meeting_points_3 CHECK ((selection_mode = 'FIXED_PLACE') = (place_id IS NOT NULL)),
 CONSTRAINT ck_tour_meeting_points_4 CHECK (minutes_before_start IS NULL OR (minutes_before_start >= 0 AND purpose IN ('MEET','PICKUP'))),
 CONSTRAINT ck_tour_meeting_points_5 CHECK (sort_order >= 0)
);
CREATE TRIGGER trg_kns13_tour_meeting_points_audit BEFORE UPDATE ON tour_meeting_points FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();
CREATE TABLE tour_itinerary_fulfilment_links (
 itinerary_item_id uuid NOT NULL,
 fulfilment_requirement_id uuid NOT NULL,
 created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 updated_by varchar(100) NOT NULL DEFAULT 'SYSTEM',
 CONSTRAINT pk_tour_itinerary_fulfilment_links PRIMARY KEY (itinerary_item_id,fulfilment_requirement_id),
 CONSTRAINT fk_tour_itinerary_fulfilment_links_1 FOREIGN KEY (itinerary_item_id) REFERENCES tour_itinerary_items (id) ON UPDATE RESTRICT ON DELETE CASCADE,
 CONSTRAINT fk_tour_itinerary_fulfilment_links_2 FOREIGN KEY (fulfilment_requirement_id) REFERENCES listing_fulfilment_requirements (id) ON UPDATE RESTRICT ON DELETE RESTRICT
);
CREATE TRIGGER trg_kns13_tour_itinerary_fulfilment_links_audit BEFORE UPDATE ON tour_itinerary_fulfilment_links FOR EACH ROW EXECUTE FUNCTION kns11_touch_audit();

-- Preserve any existing scope kinds added after file 11. Extend only the known
-- kind check, retaining all other scope constraints. No existing rows rewritten.
DO $extend$
DECLARE definition text;
BEGIN
 SELECT pg_get_constraintdef(oid) INTO definition FROM pg_constraint
 WHERE conrelid='listing_configuration_scopes'::regclass AND conname='chk_listing_configuration_scopes_configuration_kind';
 EXECUTE 'ALTER TABLE listing_configuration_scopes DROP CONSTRAINT chk_listing_configuration_scopes_configuration_kind';
 EXECUTE 'ALTER TABLE listing_configuration_scopes ADD CONSTRAINT chk_listing_configuration_scopes_configuration_kind CHECK ((' || substring(definition FROM 7) || ') OR configuration_kind IN (''TOUR_POLICY'',''TOUR_ITINERARY'',''TOUR_MEETING''))';
END $extend$;

CREATE UNIQUE INDEX uq_tour_meeting_fixed ON tour_meeting_points(scope_id,purpose,place_id) WHERE selection_mode='FIXED_PLACE';
CREATE UNIQUE INDEX uq_tour_meeting_customer_area ON tour_meeting_points(scope_id,purpose,selection_mode,geographic_area_id) WHERE selection_mode<>'FIXED_PLACE' AND geographic_area_id IS NOT NULL;
CREATE UNIQUE INDEX uq_tour_meeting_customer_no_area ON tour_meeting_points(scope_id,purpose,selection_mode) WHERE selection_mode<>'FIXED_PLACE' AND geographic_area_id IS NULL;
CREATE INDEX ix_tour_item_place ON tour_itinerary_items(place_id) WHERE place_id IS NOT NULL;
CREATE INDEX ix_tour_item_reference ON tour_itinerary_items(referenced_listing_id) WHERE referenced_listing_id IS NOT NULL;
CREATE INDEX ix_tour_item_reference_option ON tour_itinerary_items(referenced_listing_option_id,referenced_listing_id) WHERE referenced_listing_option_id IS NOT NULL;
CREATE INDEX ix_tour_meeting_place ON tour_meeting_points(place_id) WHERE place_id IS NOT NULL;
CREATE INDEX ix_tour_meeting_area ON tour_meeting_points(geographic_area_id) WHERE geographic_area_id IS NOT NULL;
CREATE INDEX ix_tour_link_requirement ON tour_itinerary_fulfilment_links(fulfilment_requirement_id);

-- The Event migration leaves departure rules unchanged. If a compatible zone
-- column was independently added, preserve it. Legacy NULL needs explicit review.
DO $timezone$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='listing_departure_rules' AND column_name='time_zone') THEN
  ALTER TABLE listing_departure_rules ADD COLUMN time_zone varchar(50);
 ELSIF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='listing_departure_rules' AND column_name='time_zone' AND data_type IN ('character varying','text')) THEN
  RAISE EXCEPTION 'Existing departure time_zone must be text/varchar';
 END IF;
END $timezone$;
CREATE FUNCTION kns13_check_timezone() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.time_zone IS NOT NULL AND NOT EXISTS(SELECT 1 FROM pg_timezone_names WHERE name=NEW.time_zone) THEN
  RAISE EXCEPTION 'Unknown timezone: %',NEW.time_zone USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_policy_zone BEFORE INSERT OR UPDATE OF time_zone ON tour_policies FOR EACH ROW EXECUTE FUNCTION kns13_check_timezone();
CREATE TRIGGER trg_kns13_day_zone BEFORE INSERT OR UPDATE OF time_zone ON tour_itinerary_days FOR EACH ROW EXECUTE FUNCTION kns13_check_timezone();
CREATE TRIGGER trg_kns13_departure_zone BEFORE INSERT OR UPDATE OF time_zone ON listing_departure_rules FOR EACH ROW EXECUTE FUNCTION kns13_check_timezone();

CREATE FUNCTION kns13_check_tour() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c text;
BEGIN
 IF TG_OP='UPDATE' AND NEW.listing_id<>OLD.listing_id THEN RAISE EXCEPTION 'Tour identity is immutable' USING ERRCODE='23514'; END IF;
 PERFORM 1 FROM listings WHERE id=NEW.listing_id FOR UPDATE;
 SELECT t.code INTO c FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.listing_id;
 IF c IS DISTINCT FROM 'TOUR' THEN RAISE EXCEPTION 'Tour parent must have listing type TOUR' USING ERRCODE='23514'; END IF;
 IF EXISTS(SELECT 1 FROM listing_occurrences WHERE listing_id=NEW.listing_id AND schedule_precision<>'EXACT_TIME') THEN
  RAISE EXCEPTION 'Existing Tour occurrences must use exact instants' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_tour_parent BEFORE INSERT OR UPDATE ON tours FOR EACH ROW EXECUTE FUNCTION kns13_check_tour();

CREATE FUNCTION kns13_check_scope() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP <> 'DELETE' AND NEW.configuration_kind IN ('TOUR_POLICY','TOUR_ITINERARY','TOUR_MEETING')
 AND NOT EXISTS(SELECT 1 FROM tours WHERE listing_id=NEW.listing_id) THEN
  RAISE EXCEPTION 'Tour scope requires an existing Tour subtype' USING ERRCODE='23514';
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_scope BEFORE INSERT OR UPDATE ON listing_configuration_scopes FOR EACH ROW EXECUTE FUNCTION kns13_check_scope();
CREATE TRIGGER trg_kns13_policy_scope BEFORE INSERT OR UPDATE OR DELETE ON tour_policies FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','TOUR_POLICY');
CREATE TRIGGER trg_kns13_days_scope BEFORE INSERT OR UPDATE OR DELETE ON tour_itinerary_days FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','TOUR_ITINERARY');
CREATE TRIGGER trg_kns13_meeting_scope BEFORE INSERT OR UPDATE OR DELETE ON tour_meeting_points FOR EACH ROW EXECUTE FUNCTION kns11_guard_scope_child('scope_id','TOUR_MEETING');

CREATE FUNCTION kns13_validate_scope_final() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE sid uuid; m text;
BEGIN
 IF TG_TABLE_NAME='listing_configuration_scopes' THEN
  IF TG_OP='DELETE' THEN sid:=OLD.id; ELSE sid:=NEW.id; END IF;
 ELSE
  IF TG_OP='DELETE' THEN sid:=OLD.scope_id; ELSE sid:=NEW.scope_id; END IF;
 END IF;
 SELECT configuration_mode INTO m FROM listing_configuration_scopes WHERE id=sid;
 IF FOUND AND m<>'CUSTOM' AND (
  EXISTS(SELECT 1 FROM tour_policies WHERE scope_id=sid) OR
  EXISTS(SELECT 1 FROM tour_itinerary_days WHERE scope_id=sid) OR
  EXISTS(SELECT 1 FROM tour_meeting_points WHERE scope_id=sid)) THEN
  RAISE EXCEPTION 'INHERIT/DISABLED scopes cannot own Tour configuration' USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns13_scope_final AFTER INSERT OR UPDATE OR DELETE ON listing_configuration_scopes DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_scope_final();
CREATE CONSTRAINT TRIGGER trg_kns13_policy_final AFTER INSERT OR UPDATE OR DELETE ON tour_policies DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_scope_final();
CREATE CONSTRAINT TRIGGER trg_kns13_days_final AFTER INSERT OR UPDATE OR DELETE ON tour_itinerary_days DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_scope_final();
CREATE CONSTRAINT TRIGGER trg_kns13_meeting_final AFTER INSERT OR UPDATE OR DELETE ON tour_meeting_points DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_scope_final();

CREATE FUNCTION kns13_guard_item() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE s listing_configuration_scopes; c text;
BEGIN
 IF TG_OP='UPDATE' AND NEW.itinerary_day_id<>OLD.itinerary_day_id THEN RAISE EXCEPTION 'Item parent is immutable; copy to move between days' USING ERRCODE='23514'; END IF;
 IF TG_OP='DELETE' THEN
  SELECT sc.* INTO s FROM listing_configuration_scopes sc JOIN tour_itinerary_days d ON d.scope_id=sc.id WHERE d.id=OLD.itinerary_day_id;
 ELSE
  SELECT sc.* INTO s FROM listing_configuration_scopes sc JOIN tour_itinerary_days d ON d.scope_id=sc.id WHERE d.id=NEW.itinerary_day_id;
 END IF;
 IF s.id IS NOT NULL THEN
  PERFORM 1 FROM listings WHERE id=s.listing_id FOR UPDATE;
  IF TG_OP <> 'DELETE' AND (s.configuration_kind<>'TOUR_ITINERARY' OR s.configuration_mode<>'CUSTOM') THEN
   RAISE EXCEPTION 'Itinerary item requires a CUSTOM Tour itinerary scope' USING ERRCODE='23514';
  END IF;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 IF NEW.referenced_listing_id IS NOT NULL THEN
  SELECT t.code INTO c FROM listings l JOIN listing_types t ON t.id=l.listing_type_id WHERE l.id=NEW.referenced_listing_id;
  IF c IS NULL OR c NOT IN ('ACTIVITY','SERVICE','EVENT') THEN RAISE EXCEPTION 'Itinerary reference must be ACTIVITY, SERVICE or EVENT' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_item_guard BEFORE INSERT OR UPDATE OR DELETE ON tour_itinerary_items FOR EACH ROW EXECUTE FUNCTION kns13_guard_item();

-- Link checks run on final aggregate state and on edits to either side.
CREATE FUNCTION kns13_lock_link() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE iid uuid; lid uuid;
BEGIN
 IF TG_OP='UPDATE' AND (NEW.itinerary_item_id,NEW.fulfilment_requirement_id) IS DISTINCT FROM (OLD.itinerary_item_id,OLD.fulfilment_requirement_id) THEN
  RAISE EXCEPTION 'Link identity is immutable; replace the association' USING ERRCODE='23514';
 END IF;
 IF TG_OP='DELETE' THEN iid:=OLD.itinerary_item_id; ELSE iid:=NEW.itinerary_item_id; END IF;
 SELECT sc.listing_id INTO lid FROM tour_itinerary_items i JOIN tour_itinerary_days d ON d.id=i.itinerary_day_id JOIN listing_configuration_scopes sc ON sc.id=d.scope_id WHERE i.id=iid;
 PERFORM 1 FROM listings WHERE id=lid FOR UPDATE;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_link_lock BEFORE INSERT OR UPDATE OR DELETE ON tour_itinerary_fulfilment_links FOR EACH ROW EXECUTE FUNCTION kns13_lock_link();
CREATE FUNCTION kns13_validate_links() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE rid uuid; iid uuid; j jsonb;
BEGIN
 IF TG_OP='DELETE' THEN j:=to_jsonb(OLD); ELSE j:=to_jsonb(NEW); END IF;
 IF TG_TABLE_NAME='listing_fulfilment_requirements' THEN rid:=(j->>'id')::uuid; ELSE rid:=(j->>'fulfilment_requirement_id')::uuid; iid:=(j->>'itinerary_item_id')::uuid; END IF;
 IF EXISTS(SELECT 1 FROM tour_itinerary_fulfilment_links x
  JOIN tour_itinerary_items i ON i.id=x.itinerary_item_id JOIN tour_itinerary_days d ON d.id=i.itinerary_day_id
  JOIN listing_configuration_scopes sc ON sc.id=d.scope_id JOIN listing_fulfilment_requirements r ON r.id=x.fulfilment_requirement_id
  WHERE r.id=rid AND (iid IS NULL OR i.id=iid) AND (sc.listing_id<>r.listing_id OR (sc.listing_option_id IS NOT NULL AND r.listing_option_id IS NOT NULL AND sc.listing_option_id<>r.listing_option_id))) THEN
  RAISE EXCEPTION 'Itinerary requirement must belong to the same Tour and compatible option' USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns13_links_final AFTER INSERT OR UPDATE OR DELETE ON tour_itinerary_fulfilment_links DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_links();
CREATE FUNCTION kns13_lock_requirement() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM tour_itinerary_fulfilment_links WHERE fulfilment_requirement_id=OLD.id) THEN
  PERFORM 1 FROM listings WHERE id IN (OLD.listing_id,NEW.listing_id) ORDER BY id FOR UPDATE;
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_requirement_lock BEFORE UPDATE ON listing_fulfilment_requirements FOR EACH ROW EXECUTE FUNCTION kns13_lock_requirement();
CREATE CONSTRAINT TRIGGER trg_kns13_req_links_final AFTER UPDATE ON listing_fulfilment_requirements DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_links();
-- Shared base itinerary + option-only requirement is not automatically invalid:
-- application must prove resolution in EVERY effective offered option at publish.

CREATE FUNCTION kns13_guard_listing_type() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.listing_type_id IS DISTINCT FROM OLD.listing_type_id AND (
  EXISTS(SELECT 1 FROM tours WHERE listing_id=OLD.id) OR
  EXISTS(SELECT 1 FROM tour_itinerary_items WHERE referenced_listing_id=OLD.id)) THEN
  RAISE EXCEPTION 'Referenced Tour/listing type cannot change' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_listing_type BEFORE UPDATE OF listing_type_id ON listings FOR EACH ROW EXECUTE FUNCTION kns13_guard_listing_type();
CREATE FUNCTION kns13_guard_type_code() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS(
  SELECT 1 FROM listings l WHERE l.listing_type_id=OLD.id AND (
   EXISTS(SELECT 1 FROM tours WHERE listing_id=l.id) OR EXISTS(SELECT 1 FROM tour_itinerary_items WHERE referenced_listing_id=l.id))) THEN
  RAISE EXCEPTION 'Referenced Tour/itinerary type code is immutable' USING ERRCODE='23514';
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_type_code BEFORE UPDATE OF code ON listing_types FOR EACH ROW EXECUTE FUNCTION kns13_guard_type_code();
CREATE FUNCTION kns13_guard_option_parent() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.listing_id IS DISTINCT FROM OLD.listing_id AND EXISTS(SELECT 1 FROM tour_itinerary_items WHERE referenced_listing_option_id=OLD.id) THEN
  RAISE EXCEPTION 'Referenced itinerary option cannot move to another listing' USING ERRCODE='23514';
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_option_parent BEFORE UPDATE OF listing_id ON listing_options FOR EACH ROW EXECUTE FUNCTION kns13_guard_option_parent();
CREATE FUNCTION kns13_validate_tour_presence() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE lid uuid;
BEGIN
 IF TG_OP='DELETE' THEN lid:=OLD.listing_id; ELSE lid:=NEW.listing_id; END IF;
 IF EXISTS(SELECT 1 FROM listings WHERE id=lid) AND NOT EXISTS(SELECT 1 FROM tours WHERE listing_id=lid)
 AND EXISTS(SELECT 1 FROM listing_configuration_scopes WHERE listing_id=lid AND configuration_kind IN ('TOUR_POLICY','TOUR_ITINERARY','TOUR_MEETING')) THEN
  RAISE EXCEPTION 'Cannot remove Tour subtype while Tour scopes remain' USING ERRCODE='23514';
 END IF; RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_kns13_tour_presence AFTER INSERT OR UPDATE OR DELETE ON tours DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION kns13_validate_tour_presence();

CREATE FUNCTION kns13_guard_tour_occurrence() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM tours WHERE listing_id=NEW.listing_id) AND NEW.schedule_precision<>'EXACT_TIME' THEN
  RAISE EXCEPTION 'Scheduled Tour departures require exact instants; requested dates belong to booking requests' USING ERRCODE='23514';
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER trg_kns13_tour_occurrence BEFORE INSERT OR UPDATE ON listing_occurrences FOR EACH ROW EXECUTE FUNCTION kns13_guard_tour_occurrence();

COMMENT ON TABLE tours IS 'One reusable Tour offer; shared listing controls classification, visibility and bookability.';
COMMENT ON TABLE tour_policies IS 'TOUR_POLICY family. Party size differs from shared-departure participant threshold; no reserved inventory here.';
COMMENT ON TABLE tour_itinerary_days IS 'TOUR_ITINERARY family; ordered template days, not actual calendar dates. Day zone overrides effective policy zone.';
COMMENT ON TABLE tour_itinerary_items IS 'Ordered operator-delivered itinerary; optional referenced listings are descriptive, not independent reservations or Event admission.';
COMMENT ON TABLE tour_meeting_points IS 'TOUR_MEETING family; templates for fixed/customer-selected endpoints. Actual customer locations are booking data.';
COMMENT ON TABLE tour_itinerary_fulfilment_links IS 'Marks where shared fulfilment requirements are used; does not multiply counts or reserve resources.';
COMMENT ON COLUMN listing_departure_rules.time_zone IS 'Explicit validated departure timezone. Legacy NULL remains unreviewed; backfill/require at publication in the application.';

-- REQUIRED APPLICATION CONTRACT (not implemented by DDL):
-- 1. Resolve each family per offered option: missing/INHERIT uses base; CUSTOM
--    replaces entire family; DISABLED owns nothing. Complete Tour policy/itinerary
--    required at publish, but missing/empty CUSTOM configuration can be a draft.
-- 2. Complete day numbers 1..effective itinerary_day_count; required items present;
--    overnight count supported by actual stays (not blindly days minus one).
--    Verify chronology, travel gaps, daylight/provider windows and local DST.
-- 3. Resolve explicit policy/day IANA zones before interpreting local item times.
--    For cross-zone travel, validate actual endpoint zones/instants at booking.
--    FIXED_START needs eligible exact-time occurrences; REQUESTED_START needs
--    supported shared availability/request rules. No date-only fake departures.
--    Shared rule generation uses rule.time_zone; preserve rule/date idempotency
--    and amended/cancelled/booked instances. Review legacy NULL zones explicitly.
-- 4. Reference listings/options/Places live and compatible; same-listing option
--    ownership. Links do not imply admission, independent booking or included price.
--    Shared itinerary's option-specific links must resolve for EVERY offered variant.
-- 5. Resolve eligible Guide/Vehicle/Driver/Operator/Unit requirements and capacities.
--    Use existing FIXED/RESTRICTED/DYNAMIC structure. Dynamic matching criteria,
--    professional capability and gender preferences are separate deferred work.
--    Do not claim GUIDE role alone proves competence for every Tour.
-- 6. Validate fixed point/area ancestry; includes_descendants is explicit.
--    Customer points need coherent supported coverage at publication. Derive booking
--    inputs (start date/time, participant count, pickup location) from effective modes.
-- 7. Existing customer requirements, adjustments, documents/obligations, Event
--    associations, media and pricing apply. Published edits need existing revision/
--    withdrawal flow. Snapshot bookings/quotes separately; no historical rewrites.
-- 8. Exact duplicate checks, safe errors, authorisation, audit actors, idempotency
--    and optimistic concurrency belong to API. Parent locking contract applies to
--    ALL aggregate write paths. No reservation/stock/payment concurrency is defined.
-- 9. Ordered collection saves may defer uq_tour_day/uq_tour_item_sequence for
--    swaps within one transaction; keep row IDs stable and scope/day identity fixed.
--    Physical moving across days requires an explicit copy/delete operation.
-- 10. Seed 13_1 adds input definitions only. Renderer/mandatory-input semantics
--     need application support; never collect actual customer answers here.
COMMIT;
