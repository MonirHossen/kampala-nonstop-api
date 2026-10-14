<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Trip planning foundation.
 * Mirrors admin-kampala-nonstop/sql/16_kampala_nonstop_trip_planning_schema.sql
 */
return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('users')) {
            throw new \RuntimeException('Required table users does not exist.');
        }

        if (! Schema::hasTable('listings')) {
            throw new \RuntimeException('Required table listings does not exist.');
        }

        $this->ensureUuidV7();

        if (! Schema::hasTable('trips')) {
            Schema::create('trips', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('owner_user_id');
                $table->string('name', 150)->nullable();
                $table->char('country_code', 2)->default('UG');
                $table->date('start_date')->nullable();
                $table->date('end_date')->nullable();
                $table->string('status_code', 30)->default('DRAFT');
                $table->text('notes')->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
                $table->string('created_by', 255)->default('SYSTEM');
                $table->string('updated_by', 255)->default('SYSTEM');

                $table->foreign('owner_user_id', 'fk_trips_owner_user')
                    ->references('id')
                    ->on('users')
                    ->cascadeOnUpdate()
                    ->restrictOnDelete();

                $table->index('owner_user_id', 'idx_trips_owner_user_id');
                $table->index(['owner_user_id', 'status_code'], 'idx_trips_owner_status');
            });

            DB::statement(
                'ALTER TABLE trips
                 ADD CONSTRAINT chk_trips_country_code
                 CHECK (country_code = UPPER(country_code))'
            );

            DB::statement(
                'ALTER TABLE trips
                 ADD CONSTRAINT chk_trips_date_range
                 CHECK (
                    end_date IS NULL
                    OR start_date IS NULL
                    OR end_date >= start_date
                 )'
            );

            DB::statement(
                "ALTER TABLE trips
                 ADD CONSTRAINT chk_trips_status_code
                 CHECK (
                    status_code IN (
                        'DRAFT',
                        'PLANNING',
                        'SUBMITTED',
                        'IN_PROGRESS',
                        'COMPLETED',
                        'CANCELLED'
                    )
                 )"
            );

            DB::statement(
                "COMMENT ON COLUMN trips.owner_user_id IS 'Registered Nonstop user who owns/manages the trip. This does not imply that the user is necessarily one of the trip customers.'"
            );
        }

        if (! Schema::hasTable('trip_customers')) {
            Schema::create('trip_customers', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('trip_id');
                $table->uuid('user_id')->nullable();
                $table->string('first_name', 100)->nullable();
                $table->string('middle_name', 100)->nullable();
                $table->string('last_name', 100)->nullable();
                $table->date('date_of_birth')->nullable();
                $table->char('country_of_residence', 2)->nullable();
                $table->boolean('is_primary_customer')->default(false);
                $table->text('notes')->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
                $table->string('created_by', 255)->default('SYSTEM');
                $table->string('updated_by', 255)->default('SYSTEM');

                $table->foreign('trip_id', 'fk_trip_customers_trip')
                    ->references('id')
                    ->on('trips')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->foreign('user_id', 'fk_trip_customers_user')
                    ->references('id')
                    ->on('users')
                    ->cascadeOnUpdate()
                    ->nullOnDelete();

                $table->unique(['id', 'trip_id'], 'uq_trip_customers_id_trip');
                $table->index('trip_id', 'idx_trip_customers_trip_id');
            });

            DB::statement(
                'ALTER TABLE trip_customers
                 ADD CONSTRAINT chk_trip_customers_identity
                 CHECK (
                    user_id IS NOT NULL
                    OR (
                        first_name IS NOT NULL
                        AND last_name IS NOT NULL
                    )
                 )'
            );

            DB::statement(
                'ALTER TABLE trip_customers
                 ADD CONSTRAINT chk_trip_customers_country_code
                 CHECK (
                    country_of_residence IS NULL
                    OR country_of_residence = UPPER(country_of_residence)
                 )'
            );

            DB::statement(
                'CREATE UNIQUE INDEX uq_trip_customers_registered_user
                 ON trip_customers (trip_id, user_id)
                 WHERE user_id IS NOT NULL'
            );

            DB::statement(
                'CREATE UNIQUE INDEX uq_trip_customers_one_primary
                 ON trip_customers (trip_id)
                 WHERE is_primary_customer = TRUE'
            );

            DB::statement(
                "COMMENT ON TABLE trip_customers IS 'People the trip or plan is for. Customer terminology is used rather than traveller because Nonstop also supports local users.'"
            );
        }

        if (! Schema::hasTable('trip_requirements')) {
            Schema::create('trip_requirements', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('trip_id');
                $table->uuid('trip_customer_id')->nullable();
                $table->string('requirement_code', 50);
                $table->jsonb('value_json')->default(DB::raw("'{}'::jsonb"));
                $table->text('notes')->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
                $table->string('created_by', 255)->default('SYSTEM');
                $table->string('updated_by', 255)->default('SYSTEM');

                $table->foreign('trip_id', 'fk_trip_requirements_trip')
                    ->references('id')
                    ->on('trips')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->index('trip_id', 'idx_trip_requirements_trip_id');
            });

            DB::statement(
                'ALTER TABLE trip_requirements
                 ADD CONSTRAINT fk_trip_requirements_customer
                 FOREIGN KEY (trip_customer_id, trip_id)
                 REFERENCES trip_customers (id, trip_id)
                 ON UPDATE CASCADE
                 ON DELETE CASCADE'
            );

            DB::statement(
                'ALTER TABLE trip_requirements
                 ADD CONSTRAINT chk_trip_requirements_code
                 CHECK (requirement_code = UPPER(requirement_code))'
            );

            DB::statement(
                'ALTER TABLE trip_requirements
                 ADD CONSTRAINT uq_trip_requirements_scope
                 UNIQUE NULLS NOT DISTINCT (trip_id, trip_customer_id, requirement_code)'
            );

            DB::statement(
                'CREATE INDEX idx_trip_requirements_customer_id
                 ON trip_requirements (trip_customer_id)
                 WHERE trip_customer_id IS NOT NULL'
            );

            DB::statement(
                'CREATE INDEX idx_trip_requirements_value_json
                 ON trip_requirements USING GIN (value_json)'
            );
        }

        if (! Schema::hasTable('trip_listings')) {
            Schema::create('trip_listings', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('trip_id');
                $table->uuid('listing_id');
                $table->timestampTz('created_at')->useCurrent();

                $table->foreign('trip_id', 'fk_trip_listings_trip')
                    ->references('id')
                    ->on('trips')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->foreign('listing_id', 'fk_trip_listings_listing')
                    ->references('id')
                    ->on('listings')
                    ->cascadeOnUpdate()
                    ->restrictOnDelete();

                $table->unique(['trip_id', 'listing_id'], 'uq_trip_listings_trip_listing');
                $table->index('listing_id', 'idx_trip_listings_listing_id');
            });

            DB::statement(
                "COMMENT ON TABLE trip_listings IS 'Explicit customer Add to Trip selections. These are planner inputs, not scheduled itinerary items.'"
            );
        }

        if (! Schema::hasTable('itineraries')) {
            Schema::create('itineraries', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('trip_id');
                $table->integer('version_number')->default(1);
                $table->string('status_code', 30)->default('DRAFT');
                $table->boolean('is_current')->default(true);
                $table->text('notes')->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
                $table->string('created_by', 255)->default('SYSTEM');
                $table->string('updated_by', 255)->default('SYSTEM');

                $table->foreign('trip_id', 'fk_itineraries_trip')
                    ->references('id')
                    ->on('trips')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->unique(['trip_id', 'version_number'], 'uq_itineraries_trip_version');
                $table->index('trip_id', 'idx_itineraries_trip_id');
            });

            DB::statement(
                'ALTER TABLE itineraries
                 ADD CONSTRAINT chk_itineraries_version
                 CHECK (version_number > 0)'
            );

            DB::statement(
                "ALTER TABLE itineraries
                 ADD CONSTRAINT chk_itineraries_status
                 CHECK (
                    status_code IN (
                        'DRAFT',
                        'PROPOSED',
                        'ACCEPTED',
                        'SUPERSEDED'
                    )
                 )"
            );

            DB::statement(
                'CREATE UNIQUE INDEX uq_itineraries_one_current
                 ON itineraries (trip_id)
                 WHERE is_current = TRUE'
            );
        }

        if (! Schema::hasTable('itinerary_items')) {
            Schema::create('itinerary_items', function (Blueprint $table) {
                $table->uuid('id')->primary()->default(DB::raw('uuidv7()'));
                $table->uuid('itinerary_id');
                $table->uuid('listing_id');
                $table->uuid('source_trip_listing_id')->nullable();
                $table->date('scheduled_date')->nullable();
                $table->time('start_time')->nullable();
                $table->time('end_time')->nullable();
                $table->smallInteger('end_day_offset')->default(0);
                $table->integer('sort_order')->default(0);
                $table->boolean('is_optional')->default(false);
                $table->text('notes')->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
                $table->string('created_by', 255)->default('SYSTEM');
                $table->string('updated_by', 255)->default('SYSTEM');

                $table->foreign('itinerary_id', 'fk_itinerary_items_itinerary')
                    ->references('id')
                    ->on('itineraries')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->foreign('listing_id', 'fk_itinerary_items_listing')
                    ->references('id')
                    ->on('listings')
                    ->cascadeOnUpdate()
                    ->restrictOnDelete();

                $table->foreign('source_trip_listing_id', 'fk_itinerary_items_source_trip_listing')
                    ->references('id')
                    ->on('trip_listings')
                    ->cascadeOnUpdate()
                    ->nullOnDelete();

                $table->index(
                    ['itinerary_id', 'scheduled_date', 'sort_order'],
                    'idx_itinerary_items_itinerary_order'
                );
                $table->index('listing_id', 'idx_itinerary_items_listing_id');
            });

            DB::statement(
                'ALTER TABLE itinerary_items
                 ADD CONSTRAINT chk_itinerary_items_end_day_offset
                 CHECK (end_day_offset IN (0, 1))'
            );

            DB::statement(
                'ALTER TABLE itinerary_items
                 ADD CONSTRAINT chk_itinerary_items_sort_order
                 CHECK (sort_order >= 0)'
            );

            DB::statement(
                'ALTER TABLE itinerary_items
                 ADD CONSTRAINT chk_itinerary_items_time_pair
                 CHECK (
                    (start_time IS NULL AND end_time IS NULL)
                    OR
                    (start_time IS NOT NULL AND end_time IS NOT NULL)
                 )'
            );

            DB::statement(
                'ALTER TABLE itinerary_items
                 ADD CONSTRAINT chk_itinerary_items_time_window
                 CHECK (
                    start_time IS NULL
                    OR end_time IS NULL
                    OR end_day_offset = 1
                    OR end_time > start_time
                 )'
            );

            DB::statement(
                'CREATE INDEX idx_itinerary_items_source_trip_listing
                 ON itinerary_items (source_trip_listing_id)
                 WHERE source_trip_listing_id IS NOT NULL'
            );

            DB::statement(
                "COMMENT ON COLUMN itinerary_items.source_trip_listing_id IS 'Optional trace back to a customer-selected trip_listings row. NULL means the item may have been recommended or added by the planner/admin.'"
            );
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('itinerary_items');
        Schema::dropIfExists('itineraries');
        Schema::dropIfExists('trip_listings');
        Schema::dropIfExists('trip_requirements');
        Schema::dropIfExists('trip_customers');
        Schema::dropIfExists('trips');
    }

    private function ensureUuidV7(): void
    {
        $exists = DB::selectOne(
            "SELECT 1 AS present
             FROM pg_proc p
             JOIN pg_namespace n ON n.oid = p.pronamespace
             WHERE n.nspname = 'public'
               AND p.proname = 'uuidv7'
               AND pg_get_function_identity_arguments(p.oid) = ''"
        );

        if ($exists !== null) {
            return;
        }

        // PostgreSQL 18+ has native uuidv7(); on older versions fall back to gen_random_uuid().
        DB::unprepared(
            "CREATE OR REPLACE FUNCTION public.uuidv7()
             RETURNS uuid
             LANGUAGE sql
             VOLATILE
             AS $$
                 SELECT gen_random_uuid();
             $$;"
        );

        DB::statement(
            "COMMENT ON FUNCTION public.uuidv7() IS 'Compatibility shim for PostgreSQL < 18. Uses gen_random_uuid() until native uuidv7() is available.'"
        );
    }
};
