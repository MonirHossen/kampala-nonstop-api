<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('users', 'password')) {
            DB::statement('ALTER TABLE users ALTER COLUMN password DROP NOT NULL');
        }

        if (! Schema::hasTable('social_accounts')) {
            Schema::create('social_accounts', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')
                    ->constrained('users')
                    ->cascadeOnDelete();
                $table->string('provider', 32);
                $table->string('provider_user_id', 191);
                $table->string('avatar_url', 500)->nullable();
                $table->timestampTz('created_at')->useCurrent();
                $table->timestampTz('updated_at')->useCurrent();

                $table->unique(['provider', 'provider_user_id']);
                $table->index('user_id');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('social_accounts');

        if (Schema::hasColumn('users', 'password')) {
            DB::statement('ALTER TABLE users ALTER COLUMN password SET NOT NULL');
        }
    }
};
