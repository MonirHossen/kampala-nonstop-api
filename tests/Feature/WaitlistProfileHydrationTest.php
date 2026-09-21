<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserCitizenship;
use App\Models\UserConsent;
use App\Models\WaitlistSignup;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WaitlistProfileHydrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.google.client_id' => 'test-google-client-id.apps.googleusercontent.com',
        ]);
    }

    public function test_register_fills_gaps_from_waitlist_without_overwriting(): void
    {
        WaitlistSignup::factory()->create([
            'first_name' => 'WaitlistFirst',
            'surname' => 'WaitlistLast',
            'email' => 'hydrate-register@example.com',
            'country_code' => 'KE',
            'marketing_consent' => true,
        ]);

        $response = $this->postJson('/api/v1/auth/register', [
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'hydrate-register@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
            'marketing_consent' => false,
        ]);

        $response->assertCreated()
            ->assertJsonPath('user.profile.first_name', 'Amina')
            ->assertJsonPath('user.profile.last_name', 'Okello')
            ->assertJsonPath('user.profile.country_of_residence', 'KE');

        $user = User::query()->where('email', 'hydrate-register@example.com')->firstOrFail();

        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_MARKETING,
            'is_granted' => true,
        ]);

        $this->assertSame(0, UserCitizenship::query()->where('user_id', $user->id)->count());
    }

    public function test_social_create_fills_residence_and_marketing_from_waitlist(): void
    {
        WaitlistSignup::factory()->create([
            'first_name' => 'WaitlistFirst',
            'surname' => 'WaitlistLast',
            'email' => 'hydrate.social@example.com',
            'country_code' => 'UG',
            'marketing_consent' => true,
        ]);

        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-hydrate-1',
                'email' => 'hydrate.social@example.com',
                'email_verified' => 'true',
                'given_name' => 'Grace',
                'family_name' => 'Nabirye',
                'picture' => 'https://example.com/grace.jpg',
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtaHlkcmF0ZS0xIn0.signature',
        ])
            ->assertOk()
            ->assertJsonPath('user.profile.first_name', 'Grace')
            ->assertJsonPath('user.profile.last_name', 'Nabirye')
            ->assertJsonPath('user.profile.country_of_residence', 'UG')
            ->assertJsonPath('user.profile.profile_photo_url', 'https://example.com/grace.jpg');

        $user = User::query()->where('email', 'hydrate.social@example.com')->firstOrFail();

        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_MARKETING,
            'is_granted' => true,
        ]);

        $this->assertSame(0, UserCitizenship::query()->where('user_id', $user->id)->count());
    }

    public function test_me_fills_gaps_for_existing_user_without_overwriting(): void
    {
        WaitlistSignup::factory()->create([
            'first_name' => 'WaitlistFirst',
            'surname' => 'WaitlistLast',
            'email' => 'hydrate-me@example.com',
            'country_code' => 'TZ',
            'marketing_consent' => true,
        ]);

        $this->postJson('/api/v1/auth/register', [
            'first_name' => 'Existing',
            'last_name' => 'User',
            'email' => 'hydrate-me@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
            'marketing_consent' => false,
        ])->assertCreated();

        $user = User::query()->where('email', 'hydrate-me@example.com')->firstOrFail();

        // Simulate a pre-hydrator user: wipe residence and marketing that register already filled.
        $user->profile?->forceFill(['country_of_residence' => null])->save();
        $user->consents()
            ->where('consent_type', UserConsent::TYPE_MARKETING)
            ->update(['is_granted' => false, 'granted_at' => null]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('user.profile.first_name', 'Existing')
            ->assertJsonPath('user.profile.last_name', 'User')
            ->assertJsonPath('user.profile.country_of_residence', 'TZ');

        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_MARKETING,
            'is_granted' => true,
        ]);
    }
}
