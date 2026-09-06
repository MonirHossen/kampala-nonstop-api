<?php

namespace Tests\Feature;

use App\Models\SocialAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\User as SocialiteUser;
use Mockery;
use Tests\TestCase;

class SocialiteAuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.google.client_id' => 'google-client-id',
            'services.google.client_secret' => 'google-client-secret',
            'services.google.redirect' => 'http://localhost:8000/api/v1/auth/social/google/callback',
            'services.facebook.client_id' => 'facebook-app-id',
            'services.facebook.client_secret' => 'facebook-app-secret',
            'services.facebook.redirect' => 'http://localhost:8000/api/v1/auth/social/facebook/callback',
            'app.frontend_url' => 'http://localhost:4201',
        ]);
    }

    public function test_socialite_redirect_sends_user_to_provider(): void
    {
        $provider = Mockery::mock();
        $provider->shouldReceive('stateless')->once()->andReturnSelf();
        $provider->shouldReceive('scopes')->once()->with(['openid', 'profile', 'email'])->andReturnSelf();
        $provider->shouldReceive('with')->once()->andReturnSelf();
        $provider->shouldReceive('redirect')->once()->andReturn(redirect('https://accounts.google.com/o/oauth2/auth'));

        Socialite::shouldReceive('driver')->once()->with('google')->andReturn($provider);

        $this->get('/api/v1/auth/social/google/redirect?return_url=/dashboard')
            ->assertRedirect('https://accounts.google.com/o/oauth2/auth');
    }

    public function test_socialite_callback_creates_user_and_redirects_with_exchange_code(): void
    {
        $socialUser = (new SocialiteUser)->map([
            'id' => 'google-123',
            'nickname' => null,
            'name' => 'Amina Okello',
            'email' => 'amina.social@example.com',
            'avatar' => 'https://example.com/a.jpg',
        ]);
        $socialUser->user = [
            'given_name' => 'Amina',
            'family_name' => 'Okello',
            'email_verified' => true,
        ];

        $provider = Mockery::mock();
        $provider->shouldReceive('stateless')->once()->andReturnSelf();
        $provider->shouldReceive('user')->once()->andReturn($socialUser);
        Socialite::shouldReceive('driver')->once()->with('google')->andReturn($provider);

        $response = $this->get('/api/v1/auth/social/google/callback');

        $response->assertRedirect();
        $location = $response->headers->get('Location');
        $this->assertNotNull($location);
        $this->assertStringStartsWith('http://localhost:4201/auth/social/callback?', $location);

        parse_str(parse_url($location, PHP_URL_QUERY) ?: '', $query);
        $this->assertNotEmpty($query['code'] ?? null);

        $this->assertDatabaseHas('users', ['email' => 'amina.social@example.com']);
        $this->assertDatabaseHas('social_accounts', [
            'provider' => SocialAccount::PROVIDER_GOOGLE,
            'provider_user_id' => 'google-123',
        ]);

        $this->postJson('/api/v1/auth/social/exchange', [
            'code' => $query['code'],
        ])->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.email', 'amina.social@example.com');
    }

    public function test_social_exchange_rejects_invalid_code(): void
    {
        $this->postJson('/api/v1/auth/social/exchange', [
            'code' => str_repeat('x', 64),
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['code']);
    }

    public function test_socialite_callback_links_existing_email_user(): void
    {
        $user = User::factory()->create([
            'email' => 'linked@example.com',
            'password' => Hash::make('Password1!'),
            'status' => 'active',
        ]);
        $user->profile()->create([
            'first_name' => 'Link',
            'last_name' => 'Existing',
        ]);
        $user->preferences()->create([]);
        $user->notificationPreferences()->create([]);

        $socialUser = (new SocialiteUser)->map([
            'id' => 'fb-999',
            'nickname' => null,
            'name' => 'Link Existing',
            'email' => 'linked@example.com',
            'avatar' => null,
        ]);
        $socialUser->user = [
            'first_name' => 'Link',
            'last_name' => 'Existing',
        ];

        $provider = Mockery::mock();
        $provider->shouldReceive('stateless')->once()->andReturnSelf();
        $provider->shouldReceive('user')->once()->andReturn($socialUser);
        Socialite::shouldReceive('driver')->once()->with('facebook')->andReturn($provider);

        $this->get('/api/v1/auth/social/facebook/callback')->assertRedirect();

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseHas('social_accounts', [
            'user_id' => $user->id,
            'provider' => 'facebook',
            'provider_user_id' => 'fb-999',
        ]);
    }
}
