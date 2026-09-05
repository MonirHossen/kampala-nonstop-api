<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('personal_access_tokens')) {
            return;
        }

        $column = DB::selectOne(
            "SELECT data_type
             FROM information_schema.columns
             WHERE table_schema = 'public'
               AND table_name = 'personal_access_tokens'
               AND column_name = 'tokenable_id'"
        );

        if ($column === null || $column->data_type === 'uuid') {
            return;
        }

        DB::statement('TRUNCATE TABLE personal_access_tokens');
        DB::statement('DROP INDEX IF EXISTS personal_access_tokens_tokenable_type_tokenable_id_index');
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id DROP DEFAULT');
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id TYPE uuid USING (NULL::uuid)');
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id SET NOT NULL');
        DB::statement(
            'CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index
             ON personal_access_tokens (tokenable_type, tokenable_id)'
        );
    }

    public function down(): void
    {
        if (! Schema::hasTable('personal_access_tokens')) {
            return;
        }

        DB::statement('TRUNCATE TABLE personal_access_tokens');
        DB::statement('DROP INDEX IF EXISTS personal_access_tokens_tokenable_type_tokenable_id_index');
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id TYPE bigint USING 0');
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id SET NOT NULL');
        DB::statement(
            'CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index
             ON personal_access_tokens (tokenable_type, tokenable_id)'
        );
    }
};
