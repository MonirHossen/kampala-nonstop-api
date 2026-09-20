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
    }

    public function down(): void
    {
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
};
