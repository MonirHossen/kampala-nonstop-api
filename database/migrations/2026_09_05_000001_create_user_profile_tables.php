<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('user_profiles')) {
            Schema::create('user_profiles', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->unique()
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->string('title', 20)->nullable();
                $table->string('first_name', 100);
                $table->string('middle_name', 100)->nullable();
                $table->string('last_name', 100);
                $table->string('gender', 30)->nullable();
                $table->date('date_of_birth')->nullable();
                $table->string('phone_number', 32)->nullable();
                $table->string('city_of_residence', 100)->nullable();
                $table->char('country_of_residence', 2)->nullable();
                $table->string('profile_photo_url', 500)->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
            });

            DB::statement(
                'ALTER TABLE user_profiles
                 ADD CONSTRAINT chk_user_profiles_country_of_residence
                 CHECK (
                    country_of_residence IS NULL
                    OR country_of_residence = UPPER(country_of_residence)
                 )'
            );
        }

        if (! Schema::hasTable('user_citizenships')) {
            Schema::create('user_citizenships', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->char('country_code', 2);
                $table->boolean('is_primary')->default(false);
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();

                $table->unique(['user_id', 'country_code'], 'uq_user_citizenships_country');
                $table->index('user_id', 'idx_user_citizenships_user');
            });

            DB::statement(
                'ALTER TABLE user_citizenships
                 ADD CONSTRAINT chk_user_citizenships_country_code
                 CHECK (country_code = UPPER(country_code))'
            );

            DB::statement(
                'CREATE UNIQUE INDEX uq_user_citizenships_primary
                 ON user_citizenships (user_id)
                 WHERE is_primary = TRUE'
            );
        }

        if (! Schema::hasTable('user_preferences')) {
            Schema::create('user_preferences', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->unique()
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->string('preferred_language', 10)->default('en');
                $table->char('preferred_currency', 3)->nullable();
                $table->string('distance_unit', 2)->default('km');
                $table->char('temperature_unit', 1)->default('c');
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
            });

            DB::statement(
                "ALTER TABLE user_preferences
                 ADD CONSTRAINT chk_user_preferences_distance_unit
                 CHECK (distance_unit IN ('km', 'mi'))"
            );

            DB::statement(
                "ALTER TABLE user_preferences
                 ADD CONSTRAINT chk_user_preferences_temperature_unit
                 CHECK (temperature_unit IN ('c', 'f'))"
            );

            DB::statement(
                'ALTER TABLE user_preferences
                 ADD CONSTRAINT chk_user_preferences_currency
                 CHECK (
                    preferred_currency IS NULL
                    OR preferred_currency = UPPER(preferred_currency)
                 )'
            );
        }

        if (! Schema::hasTable('user_favourites')) {
            Schema::create('user_favourites', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->string('favouritable_type', 32);
                $table->uuid('favouritable_id');
                $table->string('notes', 500)->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();

                $table->unique(
                    ['user_id', 'favouritable_type', 'favouritable_id'],
                    'uq_user_favourites_item'
                );
                $table->index('user_id', 'idx_user_favourites_user');
                $table->index(
                    ['favouritable_type', 'favouritable_id'],
                    'idx_user_favourites_target'
                );
            });

            DB::statement(
                "ALTER TABLE user_favourites
                 ADD CONSTRAINT chk_user_favourites_type
                 CHECK (
                    favouritable_type IN (
                        'place',
                        'activity',
                        'event',
                        'tour',
                        'service',
                        'organisation',
                        'experience'
                    )
                 )"
            );
        }

        if (! Schema::hasTable('user_consents')) {
            Schema::create('user_consents', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->string('consent_type', 50);
                $table->boolean('is_granted')->default(false);
                $table->timestampTz('granted_at')->nullable();
                $table->timestampTz('withdrawn_at')->nullable();
                $table->string('policy_version', 20)->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();

                $table->unique(['user_id', 'consent_type'], 'uq_user_consents_type');
                $table->index('user_id', 'idx_user_consents_user');
            });

            DB::statement(
                "ALTER TABLE user_consents
                 ADD CONSTRAINT chk_user_consents_type
                 CHECK (
                    consent_type IN (
                        'marketing',
                        'terms_of_service',
                        'privacy_policy'
                    )
                 )"
            );

            DB::statement(
                'ALTER TABLE user_consents
                 ADD CONSTRAINT chk_user_consents_granted_at
                 CHECK (is_granted = FALSE OR granted_at IS NOT NULL)'
            );

            DB::statement(
                'ALTER TABLE user_consents
                 ADD CONSTRAINT chk_user_consents_withdrawn
                 CHECK (withdrawn_at IS NULL OR is_granted = FALSE)'
            );
        }

        if (! Schema::hasTable('user_notification_preferences')) {
            Schema::create('user_notification_preferences', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->unique()
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->boolean('email_enabled')->default(true);
                $table->boolean('sms_enabled')->default(false);
                $table->boolean('push_enabled')->default(false);
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('user_notification_preferences');
        Schema::dropIfExists('user_consents');
        Schema::dropIfExists('user_favourites');
        Schema::dropIfExists('user_preferences');
        Schema::dropIfExists('user_citizenships');
        Schema::dropIfExists('user_profiles');
    }
};
