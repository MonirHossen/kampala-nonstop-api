<?php

namespace Database\Factories;

use App\Models\WaitlistInvitation;
use App\Models\WaitlistSignup;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WaitlistInvitation>
 */
class WaitlistInvitationFactory extends Factory
{
    protected $model = WaitlistInvitation::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'inviter_waitlist_signup_id' => WaitlistSignup::factory(),
            'invitee_email' => fake()->unique()->safeEmail(),
            'sent_at' => now(),
        ];
    }
}
