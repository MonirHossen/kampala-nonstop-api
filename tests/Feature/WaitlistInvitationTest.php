<?php

namespace Tests\Feature;

use App\Mail\WaitlistInvitationMail;
use App\Mail\WaitlistWelcomeMail;
use App\Models\AcquisitionSource;
use App\Models\WaitlistInvitation;
use App\Models\WaitlistSignup;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class WaitlistInvitationTest extends TestCase
{
    use RefreshDatabase;

    private WaitlistSignup $inviter;

    protected function setUp(): void
    {
        parent::setUp();

        Mail::fake();

        $source = AcquisitionSource::factory()->create([
            'code' => 'UNAA_DENVER_2026',
            'name' => 'UNAA Denver 2026',
            'type' => 'event',
        ]);

        AcquisitionSource::factory()->create([
            'code' => 'REFERRAL',
            'name' => 'Referral from a friend',
            'type' => 'other',
        ]);

        $this->inviter = WaitlistSignup::factory()->create([
            'first_name' => 'Amina',
            'surname' => 'Okello',
            'email' => 'amina@example.com',
            'acquisition_source_id' => $source->id,
        ]);
    }

    public function test_signup_sends_a_welcome_email_for_new_registrants_only(): void
    {
        $source = AcquisitionSource::query()->where('code', 'UNAA_DENVER_2026')->sole();

        $this->postJson('/api/v1/waitlist', [
            'first_name' => 'Jordan',
            'surname' => 'Nalwanga',
            'email' => 'jordan@example.com',
            'country_code' => 'UG',
            'acquisition_source_code' => 'unaa_denver_2026',
            'interest_codes' => [],
            'marketing_consent' => true,
        ])->assertCreated();

        Mail::assertQueued(WaitlistWelcomeMail::class, function (WaitlistWelcomeMail $mail): bool {
            return $mail->hasTo('jordan@example.com');
        });

        Mail::fake();

        $this->postJson('/api/v1/waitlist', [
            'first_name' => 'Jordan',
            'surname' => 'Nalwanga',
            'email' => 'jordan@example.com',
            'country_code' => 'UG',
            'acquisition_source_code' => 'UNAA_DENVER_2026',
            'interest_codes' => [],
            'marketing_consent' => true,
        ])->assertCreated();

        Mail::assertNothingQueued();
        $this->assertSame($source->id, WaitlistSignup::query()->where('email', 'jordan@example.com')->sole()->acquisition_source_id);
    }

    public function test_invitation_is_stored_and_emailed(): void
    {
        $response = $this->postJson('/api/v1/waitlist/invitations', [
            'inviter_id' => $this->inviter->id,
            'invitee_email' => 'friend@example.com',
        ]);

        $response->assertCreated()
            ->assertJsonPath('invitee_email', 'friend@example.com');

        $this->assertDatabaseHas('waitlist_invitations', [
            'inviter_waitlist_signup_id' => $this->inviter->id,
            'invitee_email' => 'friend@example.com',
        ]);

        Mail::assertQueued(WaitlistInvitationMail::class, function (WaitlistInvitationMail $mail): bool {
            return $mail->hasTo('friend@example.com')
                && $mail->inviter->id === $this->inviter->id;
        });
    }

    public function test_repeat_invitation_to_the_same_email_updates_sent_at_without_duplicating(): void
    {
        $this->postJson('/api/v1/waitlist/invitations', [
            'inviter_id' => $this->inviter->id,
            'invitee_email' => 'friend@example.com',
        ])->assertCreated();

        $first = WaitlistInvitation::query()->where('invitee_email', 'friend@example.com')->sole();
        $firstSentAt = $first->sent_at;

        $this->travel(1)->minutes();

        $this->postJson('/api/v1/waitlist/invitations', [
            'inviter_id' => $this->inviter->id,
            'invitee_email' => 'friend@example.com',
        ])->assertCreated();

        $this->assertDatabaseCount('waitlist_invitations', 1);
        $this->assertTrue(
            WaitlistInvitation::query()->where('invitee_email', 'friend@example.com')->sole()->sent_at->gt($firstSentAt)
        );
    }

    public function test_cannot_invite_yourself(): void
    {
        $this->postJson('/api/v1/waitlist/invitations', [
            'inviter_id' => $this->inviter->id,
            'invitee_email' => 'amina@example.com',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('invitee_email');
    }
}
