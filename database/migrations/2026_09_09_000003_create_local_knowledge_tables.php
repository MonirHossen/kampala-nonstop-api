<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->createLocalKnowledgeTypesTable();
        $this->createLocalLanguagesTable();
        $this->createLocalLanguageCountriesTable();
        $this->createLocalKnowledgeTagsTable();
        $this->createPageContextsTable();
        $this->createLocalKnowledgeTable();
        $this->createLocalKnowledgeTagLinksTable();
        $this->createLocalKnowledgePageContextsTable();
    }

    public function down(): void
    {
        Schema::dropIfExists('local_knowledge_page_contexts');
        Schema::dropIfExists('local_knowledge_tag_links');
        Schema::dropIfExists('local_knowledge');
        Schema::dropIfExists('page_contexts');
        Schema::dropIfExists('local_knowledge_tags');
        Schema::dropIfExists('local_language_countries');
        Schema::dropIfExists('local_languages');
        Schema::dropIfExists('local_knowledge_types');
    }

    private function createLocalKnowledgeTypesTable(): void
    {
        if (Schema::hasTable('local_knowledge_types')) {
            return;
        }

        Schema::create('local_knowledge_types', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE local_knowledge_types
             ADD CONSTRAINT chk_local_knowledge_types_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createLocalLanguagesTable(): void
    {
        if (Schema::hasTable('local_languages')) {
            return;
        }

        Schema::create('local_languages', function (Blueprint $table) {
            $table->string('code', 10)->primary();
            $table->string('name', 100);
            $table->string('native_name', 100)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });
    }

    private function createLocalLanguageCountriesTable(): void
    {
        if (Schema::hasTable('local_language_countries')) {
            return;
        }

        Schema::create('local_language_countries', function (Blueprint $table) {
            $table->string('language_code', 10);
            $table->char('country_code', 2);

            $table->primary(['language_code', 'country_code']);
            $table->index('country_code', 'idx_local_language_countries_country');

            $table->foreign('language_code', 'fk_local_language_countries_language')
                ->references('code')
                ->on('local_languages')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
        });

        DB::statement(
            "ALTER TABLE local_language_countries
             ADD CONSTRAINT chk_local_language_countries_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );
    }

    private function createLocalKnowledgeTagsTable(): void
    {
        if (Schema::hasTable('local_knowledge_tags')) {
            return;
        }

        Schema::create('local_knowledge_tags', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE local_knowledge_tags
             ADD CONSTRAINT chk_local_knowledge_tags_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createPageContextsTable(): void
    {
        if (Schema::hasTable('page_contexts')) {
            return;
        }

        Schema::create('page_contexts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::statement(
            "ALTER TABLE page_contexts
             ADD CONSTRAINT chk_page_contexts_code
             CHECK (code ~ '^[A-Z0-9_]+$')"
        );
    }

    private function createLocalKnowledgeTable(): void
    {
        if (Schema::hasTable('local_knowledge')) {
            return;
        }

        Schema::create('local_knowledge', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('local_knowledge_type_id');
            $table->char('country_code', 2);
            $table->uuid('geographic_area_id')->nullable();
            $table->string('local_language_code', 10)->nullable();

            $table->text('title')->nullable();
            $table->text('content');
            $table->text('explanation')->nullable();

            $table->text('image_link')->nullable();
            $table->text('source_url')->nullable();

            $table->boolean('is_live')->default(true);
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->index('local_knowledge_type_id', 'idx_local_knowledge_type');
            $table->index('country_code', 'idx_local_knowledge_country');
            $table->index('geographic_area_id', 'idx_local_knowledge_geographic_area');
            $table->index('local_language_code', 'idx_local_knowledge_language');
            $table->index(['country_code', 'is_live'], 'idx_local_knowledge_live_country');
        });

        Schema::table('local_knowledge', function (Blueprint $table) {
            $table->foreign('local_knowledge_type_id', 'fk_local_knowledge_type')
                ->references('id')
                ->on('local_knowledge_types')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreign('geographic_area_id', 'fk_local_knowledge_geographic_area')
                ->references('id')
                ->on('geographic_areas')
                ->cascadeOnUpdate()
                ->nullOnDelete();

            $table->foreign('local_language_code', 'fk_local_knowledge_language')
                ->references('code')
                ->on('local_languages')
                ->cascadeOnUpdate()
                ->nullOnDelete();
        });

        DB::statement(
            "ALTER TABLE local_knowledge
             ADD CONSTRAINT chk_local_knowledge_country_code
             CHECK (country_code ~ '^[A-Z]{2}$')"
        );

        DB::statement(
            "COMMENT ON COLUMN local_knowledge.geographic_area_id IS
             'Optional geographic anchor. Relevance inherits through the geographic_areas parent hierarchy. NULL means country-wide.'"
        );
    }

    private function createLocalKnowledgeTagLinksTable(): void
    {
        if (Schema::hasTable('local_knowledge_tag_links')) {
            return;
        }

        Schema::create('local_knowledge_tag_links', function (Blueprint $table) {
            $table->uuid('local_knowledge_id');
            $table->uuid('tag_id');

            $table->primary(['local_knowledge_id', 'tag_id']);
            $table->index('tag_id', 'idx_local_knowledge_tag_links_tag');

            $table->foreign('local_knowledge_id', 'fk_local_knowledge_tag_links_knowledge')
                ->references('id')
                ->on('local_knowledge')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->foreign('tag_id', 'fk_local_knowledge_tag_links_tag')
                ->references('id')
                ->on('local_knowledge_tags')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
        });
    }

    private function createLocalKnowledgePageContextsTable(): void
    {
        if (Schema::hasTable('local_knowledge_page_contexts')) {
            return;
        }

        Schema::create('local_knowledge_page_contexts', function (Blueprint $table) {
            $table->uuid('local_knowledge_id');
            $table->uuid('page_context_id');

            $table->primary(['local_knowledge_id', 'page_context_id']);
            $table->index('page_context_id', 'idx_local_knowledge_page_contexts_context');

            $table->foreign('local_knowledge_id', 'fk_local_knowledge_page_contexts_knowledge')
                ->references('id')
                ->on('local_knowledge')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->foreign('page_context_id', 'fk_local_knowledge_page_contexts_context')
                ->references('id')
                ->on('page_contexts')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
        });
    }
};
