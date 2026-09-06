<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SocialExchangeRequest;
use App\Http\Resources\UserResource;
use App\Models\SocialAccount;
use App\Services\SocialAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Laravel\Socialite\Facades\Socialite;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class SocialiteAuthController extends Controller
{
    public function __construct(private readonly SocialAuthService $socialAuthService) {}

    public function redirect(Request $request, string $provider): RedirectResponse|JsonResponse
    {
        $frontend = rtrim((string) config('app.frontend_url'), '/');

        try {
            $this->assertSupportedProvider($provider);
            $this->assertProviderConfigured($provider);

            $returnUrl = $this->sanitizeReturnUrl($request->query('return_url'));

            // Carry return path through OAuth `state` (stateless Socialite).
            $state = base64_encode(json_encode([
                'return_url' => $returnUrl,
                'nonce' => Str::random(32),
            ], JSON_THROW_ON_ERROR));

            $driver = Socialite::driver($provider)->stateless();

            if ($provider === SocialAccount::PROVIDER_FACEBOOK) {
                $driver->scopes(['email', 'public_profile']);
            }

            if ($provider === SocialAccount::PROVIDER_GOOGLE) {
                $driver->scopes(['openid', 'profile', 'email']);
            }

            return $driver->with(['state' => $state])->redirect();
        } catch (ValidationException $e) {
            $message = collect($e->errors())->flatten()->first() ?: 'Social sign-in is not configured.';

            return redirect()->away($frontend.'/login?'.http_build_query([
                'social_error' => $message,
            ]));
        } catch (Throwable $e) {
            report($e);

            return redirect()->away($frontend.'/login?'.http_build_query([
                'social_error' => 'Unable to start social sign-in.',
            ]));
        }
    }

    public function callback(Request $request, string $provider): RedirectResponse
    {
        $frontend = rtrim((string) config('app.frontend_url'), '/');
        $loginErrorUrl = $frontend.'/login';

        try {
            $this->assertSupportedProvider($provider);
            $this->assertProviderConfigured($provider);

            $socialUser = Socialite::driver($provider)->stateless()->user();
            $result = $this->socialAuthService->authenticateFromSocialite($provider, $socialUser);

            $code = Str::random(64);
            Cache::put($this->exchangeCacheKey($code), [
                'token' => $result['token'],
                'user_id' => $result['user']->id,
            ], now()->addMinutes(2));

            $returnUrl = $this->returnUrlFromState($request->query('state')) ?? '/dashboard';

            $query = http_build_query([
                'code' => $code,
                'return_url' => $returnUrl,
            ]);

            return redirect()->away($frontend.'/auth/social/callback?'.$query);
        } catch (ValidationException $e) {
            $message = collect($e->errors())->flatten()->first() ?: 'Social sign-in failed.';

            return redirect()->away($loginErrorUrl.'?'.http_build_query([
                'social_error' => $message,
            ]));
        } catch (Throwable $e) {
            report($e);

            return redirect()->away($loginErrorUrl.'?'.http_build_query([
                'social_error' => 'Social sign-in failed. Please try again.',
            ]));
        }
    }

    public function exchange(SocialExchangeRequest $request): JsonResponse
    {
        $code = $request->validated('code');
        $payload = Cache::pull($this->exchangeCacheKey($code));

        if (! is_array($payload) || empty($payload['token'])) {
            throw ValidationException::withMessages([
                'code' => ['This social sign-in link is invalid or has expired.'],
            ]);
        }

        $user = $this->socialAuthService->userForExchange((string) $payload['user_id']);

        return response()->json([
            'token' => $payload['token'],
            'token_type' => 'Bearer',
            'user' => new UserResource($user),
        ]);
    }

    private function assertSupportedProvider(string $provider): void
    {
        if (! in_array($provider, SocialAccount::PROVIDERS, true)) {
            abort(Response::HTTP_NOT_FOUND);
        }
    }

    private function assertProviderConfigured(string $provider): void
    {
        if ($provider === SocialAccount::PROVIDER_GOOGLE) {
            $id = config('services.google.client_id');
            $secret = config('services.google.client_secret');
            if (! is_string($id) || $id === '' || ! is_string($secret) || $secret === '') {
                throw ValidationException::withMessages([
                    'provider' => ['Google sign-in is not configured.'],
                ]);
            }
        }

        if ($provider === SocialAccount::PROVIDER_FACEBOOK) {
            $id = config('services.facebook.client_id');
            $secret = config('services.facebook.client_secret');
            if (! is_string($id) || $id === '' || ! is_string($secret) || $secret === '') {
                throw ValidationException::withMessages([
                    'provider' => ['Facebook sign-in is not configured.'],
                ]);
            }
        }
    }

    private function sanitizeReturnUrl(mixed $returnUrl): string
    {
        if (! is_string($returnUrl) || $returnUrl === '') {
            return '/dashboard';
        }

        // Only allow relative app paths (open-redirect safe).
        if (! str_starts_with($returnUrl, '/') || str_starts_with($returnUrl, '//')) {
            return '/dashboard';
        }

        return $returnUrl;
    }

    private function returnUrlFromState(mixed $state): ?string
    {
        if (! is_string($state) || $state === '') {
            return null;
        }

        try {
            $decoded = base64_decode($state, true);
            if ($decoded === false) {
                return null;
            }

            /** @var array{return_url?: mixed}|null $payload */
            $payload = json_decode($decoded, true, 512, JSON_THROW_ON_ERROR);

            return $this->sanitizeReturnUrl($payload['return_url'] ?? null);
        } catch (Throwable) {
            return null;
        }
    }

    private function exchangeCacheKey(string $code): string
    {
        return 'social_oauth_exchange:'.$code;
    }
}
