<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('users')) {
            return;
        }

        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'status')) {
                $table->string('status', 20)->default('active')->after('remember_token');
            }

            if (! Schema::hasColumn('users', 'deleted_at')) {
                $table->timestampTz('deleted_at')->nullable()->after('updated_at');
            }
        });

        $this->ensureUsersStatusCheck();
        $this->ensureUsersActiveIndex();
        $this->ensureCaseInsensitiveEmailUnique();
        $this->backfillUserProfilesFromName();
        $this->dropUsersNameColumn();
    }

    public function down(): void
    {
        if (! Schema::hasTable('users')) {
            return;
        }

        if (! Schema::hasColumn('users', 'name')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('name')->default('')->after('id');
            });

            if (Schema::hasTable('user_profiles')) {
                DB::statement(
                    "UPDATE users u
                     SET name = TRIM(CONCAT_WS(' ', p.first_name, p.middle_name, p.last_name))
                     FROM user_profiles p
                     WHERE p.user_id = u.id"
                );
            }
        }

        DB::statement('DROP INDEX IF EXISTS uq_users_email_ci');
        DB::statement('DROP INDEX IF EXISTS idx_users_active');
        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_users_status');

        if (! $this->usersEmailHasUniqueIndex()) {
            Schema::table('users', function (Blueprint $table) {
                $table->unique('email');
            });
        }

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'deleted_at')) {
                $table->dropColumn('deleted_at');
            }

            if (Schema::hasColumn('users', 'status')) {
                $table->dropColumn('status');
            }
        });
    }

    private function ensureUsersStatusCheck(): void
    {
        if (! Schema::hasColumn('users', 'status')) {
            return;
        }

        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_users_status');
        DB::statement(
            "ALTER TABLE users
             ADD CONSTRAINT chk_users_status
             CHECK (status IN ('active', 'inactive'))"
        );
    }

    private function ensureUsersActiveIndex(): void
    {
        DB::statement('DROP INDEX IF EXISTS idx_users_active');
        DB::statement(
            'CREATE INDEX idx_users_active
             ON users (status)
             WHERE deleted_at IS NULL'
        );
    }

    private function ensureCaseInsensitiveEmailUnique(): void
    {
        // Constraint-backed uniques must be dropped as constraints first.
        DB::statement('ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_unique');

        $indexes = DB::select(
            "SELECT indexname, indexdef
             FROM pg_indexes
             WHERE schemaname = 'public'
               AND tablename = 'users'
               AND indexdef ILIKE '%email%'"
        );

        foreach ($indexes as $index) {
            $def = strtolower($index->indexdef);
            $name = strtolower($index->indexname);

            if ($name === 'uq_users_email_ci') {
                continue;
            }

            if (str_contains($def, 'unique') && str_contains($def, 'email')) {
                DB::statement('DROP INDEX IF EXISTS '.$index->indexname);
            }
        }

        DB::statement('DROP INDEX IF EXISTS uq_users_email_ci');
        DB::statement('CREATE UNIQUE INDEX uq_users_email_ci ON users (LOWER(email))');
    }

    private function backfillUserProfilesFromName(): void
    {
        if (! Schema::hasColumn('users', 'name') || ! Schema::hasTable('user_profiles')) {
            return;
        }

        $users = DB::table('users')
            ->leftJoin('user_profiles', 'user_profiles.user_id', '=', 'users.id')
            ->whereNull('user_profiles.id')
            ->select('users.id', 'users.name')
            ->get();

        $now = now();

        foreach ($users as $user) {
            [$firstName, $lastName] = $this->splitName((string) $user->name);

            DB::table('user_profiles')->insert([
                'id' => (string) Str::uuid7(),
                'user_id' => $user->id,
                'first_name' => $firstName,
                'last_name' => $lastName,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    /**
     * @return array{0: string, 1: string}
     */
    private function splitName(string $name): array
    {
        $trimmed = trim(preg_replace('/\s+/', ' ', $name) ?? '');

        if ($trimmed === '') {
            return ['Unknown', 'User'];
        }

        $parts = explode(' ', $trimmed, 2);

        return [
            $parts[0],
            $parts[1] ?? $parts[0],
        ];
    }

    private function dropUsersNameColumn(): void
    {
        if (! Schema::hasColumn('users', 'name')) {
            return;
        }

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('name');
        });
    }

    private function usersEmailHasUniqueIndex(): bool
    {
        $indexes = DB::select(
            "SELECT indexname, indexdef
             FROM pg_indexes
             WHERE schemaname = 'public'
               AND tablename = 'users'
               AND indexdef ILIKE '%(email)%'"
        );

        foreach ($indexes as $index) {
            if (str_contains(strtolower($index->indexdef), 'unique')) {
                return true;
            }
        }

        return false;
    }
};
