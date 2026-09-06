<?php

namespace Tests\Feature;

use App\Models\SocialAccount;
use App\Models\User;
use App\Models\UserConsent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class SocialAuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.google.client_id' => 'test-google-client-id.apps.googleusercontent.com',
            'services.facebook.app_id' => '1234567890',
            'services.facebook.app_secret' => 'test-facebook-app-secret',
        ]);
    }

    public function test_social_login_creates_user_for_new_google_identity(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-user-1',
                'email' => 'new.google@example.com',
                'email_verified' => 'true',
                'given_name' => 'Grace',
                'family_name' => 'Nabirye',
                'picture' => 'https://example.com/grace.jpg',
            ]),
        ]);

        $response = $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtdXNlci0xIn0.signature',
            'device_name' => 'web',
        ]);

        $response->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.email', 'new.google@example.com')
            ->assertJsonPath('user.profile.first_name', 'Grace')
            ->assertJsonPath('user.profile.last_name', 'Nabirye')
            ->assertJsonStructure(['token', 'user']);

        $user = User::query()->where('email', 'new.google@example.com')->firstOrFail();
        $this->assertNull($user->password);
        $this->assertNotNull($user->email_verified_at);

        $this->assertDatabaseHas('social_accounts', [
            'user_id' => $user->id,
            'provider' => SocialAccount::PROVIDER_GOOGLE,
            'provider_user_id' => 'google-user-1',
        ]);

        $this->assertDatabaseHas('user_consents', [
            'user_id' => $user->id,
            'consent_type' => UserConsent::TYPE_TERMS_OF_SERVICE,
            'is_granted' => true,
        ]);
    }

    public function test_social_login_reuses_linked_account(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-user-2',
                'email' => 'linked@example.com',
                'email_verified' => true,
                'given_name' => 'Lina',
                'family_name' => 'Okello',
            ]),
        ]);

        $first = $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtdXNlci0yIn0.one',
        ])->assertOk();

        $second = $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtdXNlci0yIn0.two',
        ])->assertOk();

        $this->assertSame($first->json('user.id'), $second->json('user.id'));
        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseCount('social_accounts', 1);
    }

    public function test_social_login_links_existing_email_account(): void
    {
        $this->postJson('/api/v1/auth/register', [
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'amina@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
        ])->assertCreated();

        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-amina',
                'email' => 'amina@example.com',
                'email_verified' => true,
                'given_name' => 'Amina',
                'family_name' => 'Okello',
            ]),
        ]);

        $response = $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtYW1pbmEifQ.sig',
        ])->assertOk();

        $user = User::query()->where('email', 'amina@example.com')->firstOrFail();
        $this->assertSame($user->id, $response->json('user.id'));
        $this->assertTrue(Hash::check('Password1!', $user->password));
        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseHas('social_accounts', [
            'user_id' => $user->id,
            'provider' => 'google',
            'provider_user_id' => 'google-amina',
        ]);
    }

    public function test_social_login_rejects_inactive_user(): void
    {
        $user = User::factory()->create([
            'email' => 'inactive@example.com',
            'status' => 'inactive',
            'password' => Hash::make('Password1!'),
        ]);

        $user->socialAccounts()->create([
            'provider' => 'google',
            'provider_user_id' => 'google-inactive',
        ]);

        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-inactive',
                'email' => 'inactive@example.com',
                'email_verified' => true,
                'given_name' => 'In',
                'family_name' => 'Active',
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJnb29nbGUtaW5hY3RpdmUifQ.sig',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['token']);
    }

    public function test_social_login_rejects_invalid_google_token(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response(['error' => 'invalid_token'], 400),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJiYWQifQ.sig',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['token']);
    }

    public function test_social_login_rejects_unverified_google_email(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-unverified',
                'email' => 'unverified@example.com',
                'email_verified' => false,
                'given_name' => 'Un',
                'family_name' => 'Verified',
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1bnZlcmlmaWVkIn0.sig',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['token']);
    }

    public function test_social_login_accepts_google_access_token(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'azp' => 'test-google-client-id.apps.googleusercontent.com',
                'scope' => 'openid email profile',
            ]),
            'www.googleapis.com/oauth2/v3/userinfo*' => Http::response([
                'sub' => 'google-access-user',
                'email' => 'access.token@example.com',
                'email_verified' => true,
                'given_name' => 'Access',
                'family_name' => 'Token',
                'picture' => 'https://example.com/access.jpg',
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'ya29.google-access-token-without-dots',
        ])->assertOk()
            ->assertJsonPath('user.email', 'access.token@example.com');

        $this->assertDatabaseHas('social_accounts', [
            'provider' => 'google',
            'provider_user_id' => 'google-access-user',
        ]);
    }

    public function test_facebook_social_login_creates_user(): void
    {
        Http::fake([
            'graph.facebook.com/debug_token*' => Http::response([
                'data' => [
                    'is_valid' => true,
                    'app_id' => '1234567890',
                    'user_id' => 'fb-user-1',
                ],
            ]),
            'graph.facebook.com/me*' => Http::response([
                'id' => 'fb-user-1',
                'email' => 'fb.user@example.com',
                'first_name' => 'Fiona',
                'last_name' => 'Batte',
                'picture' => [
                    'data' => [
                        'url' => 'https://example.com/fiona.jpg',
                    ],
                ],
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'facebook',
            'token' => 'fake-facebook-access-token',
        ])->assertOk()
            ->assertJsonPath('user.email', 'fb.user@example.com')
            ->assertJsonPath('user.profile.first_name', 'Fiona');

        $this->assertDatabaseHas('social_accounts', [
            'provider' => 'facebook',
            'provider_user_id' => 'fb-user-1',
        ]);
    }

    public function test_password_login_guides_social_only_accounts(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'test-google-client-id.apps.googleusercontent.com',
                'sub' => 'google-social-only',
                'email' => 'social.only@example.com',
                'email_verified' => true,
                'given_name' => 'Social',
                'family_name' => 'Only',
            ]),
        ]);

        $this->postJson('/api/v1/auth/social', [
            'provider' => 'google',
            'token' => 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJzb2NpYWwtb25seSJ9.sig',
        ])->assertOk();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'social.only@example.com',
            'password' => 'Anything1!',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_social_login_validates_provider(): void
    {
        $this->postJson('/api/v1/auth/social', [
            'provider' => 'twitter',
            'token' => 'x',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['provider']);
    }
}
