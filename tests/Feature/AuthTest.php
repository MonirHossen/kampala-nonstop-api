<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserConsent;
use App\Notifications\ResetPassword;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Password;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function registerPayload(array $overrides = []): array
    {
        return array_merge([
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'amina@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
            'marketing_consent' => true,
        ], $overrides);
    }

    public function test_register_creates_user_defaults_and_returns_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', $this->registerPayload());

        $response->assertCreated()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.email', 'amina@example.com')
            ->assertJsonPath('user.profile.first_name', 'Amina')
            ->assertJsonPath('user.profile.last_name', 'Okello')
            ->assertJsonStructure(['token', 'user' => ['id', 'preferences', 'notification_preferences', 'consents']]);

        $this->assertDatabaseHas('users', ['email' => 'amina@example.com', 'status' => 'active']);
        $this->assertDatabaseHas('user_profiles', ['first_name' => 'Amina', 'last_name' => 'Okello']);

        $user = User::query()->where('email', 'amina@example.com')->firstOrFail();
        $this->assertDatabaseHas('user_preferences', ['user_id' => $user->id]);
        $this->assertDatabaseHas('user_notification_preferences', [
            'user_id' => $user->id,
            'email_enabled' => true,
        ]);
        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_TERMS_OF_SERVICE,
            'is_granted' => true,
        ]);
        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_MARKETING,
            'is_granted' => true,
        ]);
    }

    public function test_register_requires_accepted_terms(): void
    {
        $this->postJson('/api/v1/auth/register', $this->registerPayload([
            'accept_terms' => false,
        ]))->assertUnprocessable()
            ->assertJsonValidationErrors(['accept_terms']);
    }

    public function test_login_returns_token_for_valid_credentials(): void
    {
        $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'amina@example.com',
            'password' => 'Password1!',
        ]);

        $response->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.email', 'amina@example.com')
            ->assertJsonStructure(['token', 'user']);
    }

    public function test_login_rejects_invalid_credentials(): void
    {
        $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'amina@example.com',
            'password' => 'WrongPassword1!',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_me_requires_authentication(): void
    {
        $this->getJson('/api/v1/auth/me')->assertUnauthorized();
    }

    public function test_me_returns_authenticated_user(): void
    {
        $register = $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();
        $token = $register->json('token');

        $this->withToken($token)
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('user.email', 'amina@example.com')
            ->assertJsonPath('user.profile.first_name', 'Amina');
    }

    public function test_logout_revokes_current_token(): void
    {
        $register = $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();
        $token = $register->json('token');

        $this->assertDatabaseCount('personal_access_tokens', 1);

        $this->withToken($token)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Logged out successfully.');

        $this->assertDatabaseCount('personal_access_tokens', 0);

        $this->withToken($token)
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized();
    }

    public function test_forgot_password_sends_reset_notification(): void
    {
        Notification::fake();

        $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();

        $this->postJson('/api/v1/auth/forgot-password', [
            'email' => 'amina@example.com',
        ])->assertOk();

        $user = User::query()->where('email', 'amina@example.com')->firstOrFail();

        Notification::assertSentTo($user, ResetPassword::class);
    }

    public function test_forgot_password_does_not_reveal_unknown_email(): void
    {
        Notification::fake();

        $this->postJson('/api/v1/auth/forgot-password', [
            'email' => 'missing@example.com',
        ])->assertOk();

        Notification::assertNothingSent();
    }

    public function test_reset_password_updates_password_and_revokes_tokens(): void
    {
        Notification::fake();

        $register = $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();
        $oldToken = $register->json('token');
        $user = User::query()->where('email', 'amina@example.com')->firstOrFail();

        $token = Password::broker()->createToken($user);

        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'amina@example.com',
            'token' => $token,
            'password' => 'NewPassword1!',
            'password_confirmation' => 'NewPassword1!',
        ])->assertOk();

        $this->assertTrue(Hash::check('NewPassword1!', $user->fresh()->password));

        $this->withToken($oldToken)
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'amina@example.com',
            'password' => 'NewPassword1!',
        ])->assertOk();
    }

    public function test_change_password_requires_current_password(): void
    {
        $register = $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();
        $token = $register->json('token');

        $this->withToken($token)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'WrongPassword1!',
                'password' => 'NewPassword1!',
                'password_confirmation' => 'NewPassword1!',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['current_password']);
    }

    public function test_change_password_updates_password(): void
    {
        $register = $this->postJson('/api/v1/auth/register', $this->registerPayload())->assertCreated();
        $token = $register->json('token');

        $this->withToken($token)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'Password1!',
                'password' => 'NewPassword1!',
                'password_confirmation' => 'NewPassword1!',
            ])
            ->assertOk();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'amina@example.com',
            'password' => 'NewPassword1!',
        ])->assertOk();
    }

    public function test_admin_waitlist_requires_authentication(): void
    {
        $this->getJson('/api/v1/admin/waitlist')->assertUnauthorized();
    }
}
