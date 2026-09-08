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
            $table->boolean('is_active')->default(true);
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
            $table->string('code', 50)->unique();
            $table->string('name', 255);
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->index('parent_geographic_area_id', 'idx_geographic_areas_parent');
            $table->index('geographic_area_type_id', 'idx_geographic_areas_type');
            $table->index('country_code', 'idx_geographic_areas_country');
        });

        Schema::table('geographic_areas', function (Blueprint $table) {
            $table->foreign('parent_geographic_area_id', 'fk_geographic_areas_parent')
                ->references('id')
                ->on('geographic_areas')
                ->nullOnDelete();

            $table->foreign('geographic_area_type_id', 'fk_geographic_areas_type')
                ->references('id')
                ->on('geographic_area_types')
                ->restrictOnDelete();
        });

        DB::statement(
            "ALTER TABLE geographic_areas
             ADD CONSTRAINT chk_geographic_areas_code
             CHECK (code ~ '^[A-Z0-9_-]+$')"
        );

        DB::statement(
            "ALTER TABLE geographic_areas
             ADD CONSTRAINT chk_geographic_areas_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }
};
