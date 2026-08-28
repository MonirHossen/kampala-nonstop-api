<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waitlist_signups', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('first_name', 100);
            $table->string('surname', 100);
            $table->string('email', 254)->unique();
            $table->char('country_code', 2);
            $table->foreignUuid('acquisition_source_id')
                ->index()
                ->constrained('acquisition_sources')
                ->restrictOnDelete();
            $table->boolean('marketing_consent')->default(false);
            $table->timestampTz('marketing_consent_at')->nullable();
            $table->boolean('unsubscribed')->default(false);
            $table->text('source_details')->nullable();
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });

        // Blueprint has no native PostgreSQL array type, so this column is added directly.
        DB::statement(
            "ALTER TABLE waitlist_signups ADD COLUMN countries_of_interest text[] NOT NULL DEFAULT ARRAY['UG']::text[]"
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlist_signups');
    }
};
