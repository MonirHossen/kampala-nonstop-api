<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waitlist_signup_interests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('waitlist_signup_id')
                ->index()
                ->constrained('waitlist_signups')
                ->cascadeOnDelete();
            $table->foreignUuid('interest_type_id')
                ->index()
                ->constrained('interest_types')
                ->restrictOnDelete();
            $table->timestampTz('created_at')->useCurrent();

            $table->unique(['waitlist_signup_id', 'interest_type_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlist_signup_interests');
    }
};
