<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Convert user_favourites to a direct user -> listing relationship.
 * Mirrors admin-kampala-nonstop/sql/16_1_kampala_nonstop_user_favourites_alter.sql
 */
return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('user_favourites')) {
            throw new \RuntimeException('Required table user_favourites does not exist.');
        }

        if (! Schema::hasTable('listings')) {
            throw new \RuntimeException('Required table listings does not exist.');
        }

        if (! Schema::hasColumn('user_favourites', 'listing_id')) {
            $legacyRows = (int) DB::table('user_favourites')->count();
            if ($legacyRows > 0) {
                throw new \RuntimeException(
                    "user_favourites contains {$legacyRows} row(s) without listing_id. Map existing favourites to listings.id before running this migration."
                );
            }

            Schema::table('user_favourites', function (Blueprint $table) {
                $table->uuid('listing_id')->nullable();
            });
        } else {
            $legacyRows = (int) DB::table('user_favourites')->whereNull('listing_id')->count();
            if ($legacyRows > 0) {
                throw new \RuntimeException(
                    "user_favourites contains {$legacyRows} row(s) without listing_id. Map existing favourites to listings.id before running this migration."
                );
            }
        }

        if (! $this->constraintExists('user_favourites', 'fk_user_favourites_listing')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->foreign('listing_id', 'fk_user_favourites_listing')
                    ->references('id')
                    ->on('listings')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();
            });
        }

        if (Schema::hasColumn('user_favourites', 'favouritable_type')) {
            DB::statement('ALTER TABLE user_favourites ALTER COLUMN favouritable_type DROP NOT NULL');
            DB::statement(
                "COMMENT ON COLUMN user_favourites.favouritable_type IS 'Deprecated. New favourites reference listings through listing_id.'"
            );
        }

        if (Schema::hasColumn('user_favourites', 'favouritable_id')) {
            DB::statement('ALTER TABLE user_favourites ALTER COLUMN favouritable_id DROP NOT NULL');
            DB::statement(
                "COMMENT ON COLUMN user_favourites.favouritable_id IS 'Deprecated. New favourites reference listings through listing_id.'"
            );
        }

        DB::statement('ALTER TABLE user_favourites ALTER COLUMN listing_id SET NOT NULL');

        if (! $this->constraintExists('user_favourites', 'uq_user_favourites_user_listing')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->unique(['user_id', 'listing_id'], 'uq_user_favourites_user_listing');
            });
        }

        $dropColumns = array_values(array_filter([
            Schema::hasColumn('user_favourites', 'updated_at') ? 'updated_at' : null,
            Schema::hasColumn('user_favourites', 'created_by') ? 'created_by' : null,
            Schema::hasColumn('user_favourites', 'updated_by') ? 'updated_by' : null,
        ]));

        if ($dropColumns !== []) {
            Schema::table('user_favourites', function (Blueprint $table) use ($dropColumns) {
                $table->dropColumn($dropColumns);
            });
        }

        DB::statement(
            "COMMENT ON COLUMN user_favourites.listing_id IS 'Customer-bookmarked listing. A user may bookmark a listing only once.'"
        );
    }

    public function down(): void
    {
        if (! Schema::hasTable('user_favourites')) {
            return;
        }

        if ($this->constraintExists('user_favourites', 'uq_user_favourites_user_listing')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->dropUnique('uq_user_favourites_user_listing');
            });
        }

        if ($this->constraintExists('user_favourites', 'fk_user_favourites_listing')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->dropForeign('fk_user_favourites_listing');
            });
        }

        if (Schema::hasColumn('user_favourites', 'listing_id')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->dropColumn('listing_id');
            });
        }

        if (! Schema::hasColumn('user_favourites', 'updated_at')) {
            Schema::table('user_favourites', function (Blueprint $table) {
                $table->timestampTz('updated_at')->useCurrent();
            });
        }

        if (Schema::hasColumn('user_favourites', 'favouritable_type')) {
            DB::statement('ALTER TABLE user_favourites ALTER COLUMN favouritable_type SET NOT NULL');
        }

        if (Schema::hasColumn('user_favourites', 'favouritable_id')) {
            DB::statement('ALTER TABLE user_favourites ALTER COLUMN favouritable_id SET NOT NULL');
        }
    }

    private function constraintExists(string $table, string $constraint): bool
    {
        $result = DB::selectOne(
            'SELECT 1 AS present
             FROM pg_constraint
             WHERE conrelid = ?::regclass
               AND conname = ?',
            [$table, $constraint]
        );

        return $result !== null;
    }
};
