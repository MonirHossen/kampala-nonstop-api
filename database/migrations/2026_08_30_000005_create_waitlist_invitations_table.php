<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waitlist_invitations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('inviter_waitlist_signup_id')
                ->constrained('waitlist_signups')
                ->cascadeOnDelete();
            $table->string('invitee_email', 254);
            $table->timestampTz('sent_at')->nullable();
            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();

            $table->unique(
                ['inviter_waitlist_signup_id', 'invitee_email'],
                'waitlist_invitations_inviter_invitee_unique'
            );
            $table->index('invitee_email');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlist_invitations');
    }
};
