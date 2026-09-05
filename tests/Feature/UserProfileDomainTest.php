<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserConsent;
use App\Models\UserFavourite;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UserProfileDomainTest extends TestCase
{
    use RefreshDatabase;

    private function authenticatedUser(array $registerOverrides = []): User
    {
        $payload = array_merge([
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'amina@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
            'marketing_consent' => true,
        ], $registerOverrides);

        $this->postJson('/api/v1/auth/register', $payload)->assertCreated();

        return User::query()->where('email', $payload['email'])->firstOrFail();
    }

    public function test_profile_endpoints_require_authentication(): void
    {
        $this->getJson('/api/v1/user/profile')->assertUnauthorized();
        $this->putJson('/api/v1/user/profile', ['first_name' => 'X'])->assertUnauthorized();
    }

    public function test_user_can_view_and_update_profile(): void
    {
        $user = $this->authenticatedUser();
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/user/profile')
            ->assertOk()
            ->assertJsonPath('profile.first_name', 'Amina')
            ->assertJsonPath('profile.last_name', 'Okello');

        $this->putJson('/api/v1/user/profile', [
            'first_name' => 'Amina',
            'last_name' => 'Nansubuga',
            'city_of_residence' => 'Kampala',
            'country_of_residence' => 'ug',
            'phone_number' => '+256700000000',
        ])
            ->assertOk()
            ->assertJsonPath('profile.last_name', 'Nansubuga')
            ->assertJsonPath('profile.city_of_residence', 'Kampala')
            ->assertJsonPath('profile.country_of_residence', 'UG');
    }

    public function test_user_can_update_preferences_and_notification_preferences(): void
    {
        $user = $this->authenticatedUser();
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/user/preferences', [
            'preferred_language' => 'en',
            'preferred_currency' => 'ugx',
            'distance_unit' => 'mi',
            'temperature_unit' => 'f',
        ])
            ->assertOk()
            ->assertJsonPath('preferences.preferred_currency', 'UGX')
            ->assertJsonPath('preferences.distance_unit', 'mi')
            ->assertJsonPath('preferences.temperature_unit', 'f');

        $this->putJson('/api/v1/user/notification-preferences', [
            'email_enabled' => true,
            'sms_enabled' => true,
            'push_enabled' => false,
        ])
            ->assertOk()
            ->assertJsonPath('notification_preferences.sms_enabled', true)
            ->assertJsonPath('notification_preferences.push_enabled', false);
    }

    public function test_citizenship_crud_enforces_one_primary(): void
    {
        $user = $this->authenticatedUser();
        Sanctum::actingAs($user);

        $ug = $this->postJson('/api/v1/user/citizenships', [
            'country_code' => 'UG',
            'is_primary' => true,
        ])->assertCreated()->json('citizenship');

        $this->assertTrue($ug['is_primary']);

        $gb = $this->postJson('/api/v1/user/citizenships', [
            'country_code' => 'GB',
            'is_primary' => true,
        ])->assertCreated()->json('citizenship');

        $this->assertTrue($gb['is_primary']);

        $this->getJson('/api/v1/user/citizenships')
            ->assertOk()
            ->assertJsonPath('citizenships.0.country_code', 'GB')
            ->assertJsonPath('citizenships.0.is_primary', true)
            ->assertJsonPath('citizenships.1.country_code', 'UG')
            ->assertJsonPath('citizenships.1.is_primary', false);

        $this->postJson('/api/v1/user/citizenships', [
            'country_code' => 'UG',
        ])->assertUnprocessable();

        $this->deleteJson('/api/v1/user/citizenships/'.$gb['id'])
            ->assertOk();

        $this->getJson('/api/v1/user/citizenships')
            ->assertOk()
            ->assertJsonCount(1, 'citizenships')
            ->assertJsonPath('citizenships.0.country_code', 'UG')
            ->assertJsonPath('citizenships.0.is_primary', true);
    }

    public function test_user_cannot_manage_another_users_citizenship(): void
    {
        $owner = $this->authenticatedUser();
        Sanctum::actingAs($owner);

        $citizenship = $this->postJson('/api/v1/user/citizenships', [
            'country_code' => 'UG',
            'is_primary' => true,
        ])->assertCreated()->json('citizenship');

        $other = $this->authenticatedUser([
            'email' => 'other@example.com',
        ]);
        Sanctum::actingAs($other);

        $this->putJson('/api/v1/user/citizenships/'.$citizenship['id'], [
            'is_primary' => true,
        ])->assertNotFound();

        $this->deleteJson('/api/v1/user/citizenships/'.$citizenship['id'])
            ->assertNotFound();
    }

    public function test_consents_can_be_listed_and_updated(): void
    {
        $user = $this->authenticatedUser();
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/user/consents')
            ->assertOk()
            ->assertJsonCount(3, 'consents');

        $this->putJson('/api/v1/user/consents/'.UserConsent::TYPE_MARKETING, [
            'is_granted' => false,
        ])
            ->assertOk()
            ->assertJsonPath('consent.is_granted', false)
            ->assertJsonPath('consent.consent_type', UserConsent::TYPE_MARKETING);

        $this->assertNotNull(
            $user->consents()->where('consent_type', UserConsent::TYPE_MARKETING)->value('withdrawn_at')
        );

        $this->putJson('/api/v1/user/consents/invalid_type', [
            'is_granted' => true,
        ])->assertUnprocessable();
    }

    public function test_favourites_crud(): void
    {
        $user = $this->authenticatedUser();
        Sanctum::actingAs($user);

        $placeId = (string) Str::uuid7();

        $favourite = $this->postJson('/api/v1/user/favourites', [
            'favouritable_type' => 'place',
            'favouritable_id' => $placeId,
            'notes' => 'Must visit',
        ])
            ->assertCreated()
            ->assertJsonPath('favourite.favouritable_type', 'place')
            ->assertJsonPath('favourite.notes', 'Must visit')
            ->json('favourite');

        $this->postJson('/api/v1/user/favourites', [
            'favouritable_type' => 'place',
            'favouritable_id' => $placeId,
        ])->assertUnprocessable();

        $this->getJson('/api/v1/user/favourites')
            ->assertOk()
            ->assertJsonCount(1, 'favourites');

        $this->deleteJson('/api/v1/user/favourites/'.$favourite['id'])
            ->assertOk();

        $this->assertDatabaseMissing('user_favourites', ['id' => $favourite['id']]);
    }

    public function test_user_cannot_delete_another_users_favourite(): void
    {
        $owner = $this->authenticatedUser();
        Sanctum::actingAs($owner);

        $favourite = $this->postJson('/api/v1/user/favourites', [
            'favouritable_type' => 'tour',
            'favouritable_id' => (string) Str::uuid7(),
        ])->assertCreated()->json('favourite');

        $other = $this->authenticatedUser(['email' => 'other@example.com']);
        Sanctum::actingAs($other);

        $this->deleteJson('/api/v1/user/favourites/'.$favourite['id'])
            ->assertNotFound();

        $this->assertDatabaseHas('user_favourites', ['id' => $favourite['id']]);
    }
}
