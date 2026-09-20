<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->createReferenceTable('categories', 'chk_categories_code');
        $this->createSubcategoriesTable();
        $this->createReferenceTable('activity_types', 'chk_activity_types_code');
        $this->createReferenceTable('tags', 'chk_tags_code');
        $this->createReferenceTable('attributes', 'chk_attributes_code');
        $this->createReferenceTable('amenities', 'chk_amenities_code');
        $this->createReferenceTable('event_types', 'chk_event_types_code');
    }

    public function down(): void
    {
        Schema::dropIfExists('event_types');
        Schema::dropIfExists('amenities');
        Schema::dropIfExists('attributes');
        Schema::dropIfExists('tags');
        Schema::dropIfExists('activity_types');
        Schema::dropIfExists('subcategories');
        Schema::dropIfExists('categories');
    }

    private function createReferenceTable(string $table, string $codeCheckName): void
    {
        if (Schema::hasTable($table)) {
            return;
        }

        Schema::create($table, function (Blueprint $blueprint) {
            $blueprint->uuid('id')->primary();
            $blueprint->string('code', 100)->unique();
            $blueprint->string('name', 150);
            $blueprint->text('description')->nullable();
            $blueprint->boolean('is_live')->default(true);
            $blueprint->timestampTz('created_at')->useCurrent();
            $blueprint->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE {$table}
             ADD CONSTRAINT {$codeCheckName}
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createSubcategoriesTable(): void
    {
        if (Schema::hasTable('subcategories')) {
            return;
        }

        Schema::create('subcategories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('category_id')
                ->constrained('categories')
                ->restrictOnDelete();
            $table->string('code', 120)->unique();
            $table->string('name', 150);
            $table->text('description')->nullable();
            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(['category_id', 'name'], 'uq_subcategories_category_name');
            $table->index('category_id', 'idx_subcategories_category_id');
        });

        DB::statement(
            "ALTER TABLE subcategories
             ADD CONSTRAINT chk_subcategories_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }
};
