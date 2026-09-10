<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->createGeographicAreaTypesTable();
        $this->createGeographicAreasTable();
    }

    public function down(): void
    {
        Schema::dropIfExists('geographic_areas');
        Schema::dropIfExists('geographic_area_types');
    }

    private function createGeographicAreaTypesTable(): void
    {
        if (Schema::hasTable('geographic_area_types')) {
            return;
        }

        Schema::create('geographic_area_types', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE geographic_area_types
             ADD CONSTRAINT chk_geographic_area_types_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createGeographicAreasTable(): void
    {
        if (Schema::hasTable('geographic_areas')) {
            return;
        }

        Schema::create('geographic_areas', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('parent_geographic_area_id')->nullable();
            $table->uuid('geographic_area_type_id');
            $table->char('country_code', 2);
            $table->string('code', 50);
            $table->string('name', 255);
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(['country_code', 'code'], 'geographic_areas_country_code_code_key');
            $table->unique(['id', 'country_code'], 'geographic_areas_id_country_code_key');
            $table->index(['parent_geographic_area_id', 'country_code'], 'geographic_areas_parent_idx');
            $table->index('geographic_area_type_id', 'geographic_areas_type_idx');
        });

        Schema::table('geographic_areas', function (Blueprint $table) {
            $table->foreign('geographic_area_type_id', 'geographic_areas_type_fk')
                ->references('id')
                ->on('geographic_area_types')
                ->restrictOnUpdate()
                ->restrictOnDelete();
        });

        DB::statement(
            'ALTER TABLE geographic_areas
             ADD CONSTRAINT geographic_areas_parent_fk
             FOREIGN KEY (parent_geographic_area_id, country_code)
             REFERENCES geographic_areas (id, country_code)
             ON UPDATE RESTRICT ON DELETE RESTRICT'
        );

        DB::statement(
            "ALTER TABLE geographic_areas
             ADD CONSTRAINT geographic_areas_country_code_format
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );

        DB::statement(
            'ALTER TABLE geographic_areas
             ADD CONSTRAINT geographic_areas_not_own_parent
             CHECK (parent_geographic_area_id IS DISTINCT FROM id)'
        );

        DB::statement(
            "ALTER TABLE geographic_areas
             ADD CONSTRAINT chk_geographic_areas_code
             CHECK (code ~ '^[A-Z0-9_-]+$')"
        );
    }
};
