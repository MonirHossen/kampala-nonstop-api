<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('user_favourites')) {
            return;
        }

        DB::statement('ALTER TABLE user_favourites DROP CONSTRAINT IF EXISTS chk_user_favourites_type');

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
                    'experience',
                    'listing'
                )
             )"
        );
    }

    public function down(): void
    {
        if (! Schema::hasTable('user_favourites')) {
            return;
        }

        DB::table('user_favourites')
            ->where('favouritable_type', 'listing')
            ->delete();

        DB::statement('ALTER TABLE user_favourites DROP CONSTRAINT IF EXISTS chk_user_favourites_type');

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
};
