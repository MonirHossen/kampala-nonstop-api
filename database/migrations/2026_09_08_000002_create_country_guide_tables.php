<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->createEssentialTypesTable();
        $this->createEssentialValuesTable();
        $this->createTravelGuideTopicsTable();
        $this->createCountryTravelGuidesTable();
        $this->createTravelInformationTypesTable();
        $this->createCountryTravelInformationTable();
        $this->createCountryRegionGuidesTable();
    }

    public function down(): void
    {
        Schema::dropIfExists('country_region_guides');
        Schema::dropIfExists('country_travel_information');
        Schema::dropIfExists('travel_information_types');
        Schema::dropIfExists('country_travel_guides');
        Schema::dropIfExists('travel_guide_topics');
        Schema::dropIfExists('country_guide_essential_values');
        Schema::dropIfExists('country_guide_essential_types');
    }

    private function createEssentialTypesTable(): void
    {
        if (Schema::hasTable('country_guide_essential_types')) {
            return;
        }

        Schema::create('country_guide_essential_types', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE country_guide_essential_types
             ADD CONSTRAINT chk_country_guide_essential_types_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createEssentialValuesTable(): void
    {
        if (Schema::hasTable('country_guide_essential_values')) {
            return;
        }

        Schema::create('country_guide_essential_values', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->char('country_code', 2);
            $table->foreignUuid('essential_type_id')
                ->constrained('country_guide_essential_types')
                ->restrictOnDelete();
            $table->text('value_text');
            $table->jsonb('value_data')->nullable();
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(
                ['country_code', 'essential_type_id'],
                'uq_country_guide_essential_values_country_type'
            );
            $table->index('country_code', 'idx_country_guide_essential_values_country');
            $table->index('essential_type_id', 'idx_country_guide_essential_values_type');
        });

        DB::statement(
            "ALTER TABLE country_guide_essential_values
             ADD CONSTRAINT chk_country_guide_essential_values_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }

    private function createTravelGuideTopicsTable(): void
    {
        if (Schema::hasTable('travel_guide_topics')) {
            return;
        }

        Schema::create('travel_guide_topics', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE travel_guide_topics
             ADD CONSTRAINT chk_travel_guide_topics_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createCountryTravelGuidesTable(): void
    {
        if (Schema::hasTable('country_travel_guides')) {
            return;
        }

        Schema::create('country_travel_guides', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->char('country_code', 2);
            $table->foreignUuid('topic_id')
                ->constrained('travel_guide_topics')
                ->restrictOnDelete();
            $table->text('content');
            $table->text('image_link')->nullable();
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(
                ['country_code', 'topic_id'],
                'uq_country_travel_guides_country_topic'
            );
            $table->index('country_code', 'idx_country_travel_guides_country');
            $table->index('topic_id', 'idx_country_travel_guides_topic');
        });

        DB::statement(
            "ALTER TABLE country_travel_guides
             ADD CONSTRAINT chk_country_travel_guides_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }

    private function createTravelInformationTypesTable(): void
    {
        if (Schema::hasTable('travel_information_types')) {
            return;
        }

        Schema::create('travel_information_types', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE travel_information_types
             ADD CONSTRAINT chk_travel_information_types_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createCountryTravelInformationTable(): void
    {
        if (Schema::hasTable('country_travel_information')) {
            return;
        }

        Schema::create('country_travel_information', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->char('country_code', 2);
            $table->foreignUuid('info_type_id')
                ->constrained('travel_information_types')
                ->restrictOnDelete();
            $table->text('value_text');
            $table->jsonb('value_data')->nullable();
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(
                ['country_code', 'info_type_id'],
                'uq_country_travel_information_country_type'
            );
            $table->index('country_code', 'idx_country_travel_information_country');
            $table->index('info_type_id', 'idx_country_travel_information_type');
        });

        DB::statement(
            "ALTER TABLE country_travel_information
             ADD CONSTRAINT chk_country_travel_information_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }

    private function createCountryRegionGuidesTable(): void
    {
        if (Schema::hasTable('country_region_guides')) {
            return;
        }

        Schema::create('country_region_guides', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->char('country_code', 2);
            $table->foreignUuid('geographic_area_id')
                ->constrained('geographic_areas')
                ->restrictOnDelete();
            $table->string('title', 255);
            $table->text('summary');
            $table->text('image_link')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(
                ['country_code', 'geographic_area_id'],
                'uq_country_region_guides_country_area'
            );
            $table->index('country_code', 'idx_country_region_guides_country');
            $table->index('geographic_area_id', 'idx_country_region_guides_area');
        });

        DB::statement(
            "ALTER TABLE country_region_guides
             ADD CONSTRAINT chk_country_region_guides_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }
};
