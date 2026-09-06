<?php

namespace App\Services\SocialAuth;

use App\Models\SocialAccount;
use App\Services\SocialAuth\Contracts\SocialTokenVerifier;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;

class FacebookTokenVerifier implements SocialTokenVerifier
{
    public function verify(string $token): VerifiedSocialIdentity
    {
        $appId = config('services.facebook.app_id');
        $appSecret = config('services.facebook.app_secret');

        if (! is_string($appId) || $appId === '' || ! is_string($appSecret) || $appSecret === '') {
            throw ValidationException::withMessages([
                'provider' => ['Facebook sign-in is not configured.'],
            ]);
        }

        $debugResponse = Http::timeout(10)
            ->acceptJson()
            ->get('https://graph.facebook.com/debug_token', [
                'input_token' => $token,
                'access_token' => "{$appId}|{$appSecret}",
            ]);

        if (! $debugResponse->successful()) {
            throw ValidationException::withMessages([
                'token' => ['Unable to verify the Facebook token.'],
            ]);
        }

        /** @var array<string, mixed> $debugData */
        $debugData = $debugResponse->json('data') ?? [];

        $isValid = (bool) ($debugData['is_valid'] ?? false);
        $tokenAppId = (string) ($debugData['app_id'] ?? '');
        $userId = (string) ($debugData['user_id'] ?? '');

        if (! $isValid || $tokenAppId !== $appId || $userId === '') {
            throw ValidationException::withMessages([
                'token' => ['The Facebook token is invalid for this application.'],
            ]);
        }

        $profileResponse = Http::timeout(10)
            ->acceptJson()
            ->get('https://graph.facebook.com/me', [
                'fields' => 'id,email,first_name,last_name,name,picture.type(large)',
                'access_token' => $token,
            ]);

        if (! $profileResponse->successful()) {
            throw ValidationException::withMessages([
                'token' => ['Unable to load the Facebook profile.'],
            ]);
        }

        /** @var array<string, mixed> $profile */
        $profile = $profileResponse->json() ?? [];

        $providerUserId = (string) ($profile['id'] ?? $userId);
        $email = strtolower(trim((string) ($profile['email'] ?? '')));

        if ($email === '') {
            throw ValidationException::withMessages([
                'token' => [
                    'Facebook did not provide an email address. In Meta App Dashboard, open Use cases → Facebook Login and enable the email permission, then try again.',
                ],
            ]);
        }

        $firstName = trim((string) ($profile['first_name'] ?? ''));
        $lastName = trim((string) ($profile['last_name'] ?? ''));

        if ($firstName === '' && $lastName === '') {
            $fullName = trim((string) ($profile['name'] ?? ''));
            [$firstName, $lastName] = $this->splitName($fullName, $email);
        } elseif ($firstName === '') {
            $firstName = 'Traveller';
        } elseif ($lastName === '') {
            $lastName = 'User';
        }

        $avatar = null;
        if (isset($profile['picture']) && is_array($profile['picture'])) {
            $pictureData = $profile['picture']['data'] ?? null;
            if (is_array($pictureData) && ! empty($pictureData['url'])) {
                $avatar = (string) $pictureData['url'];
            }
        }

        // Facebook only returns email when the user granted it and it is usable.
        return new VerifiedSocialIdentity(
            provider: SocialAccount::PROVIDER_FACEBOOK,
            providerUserId: $providerUserId,
            email: $email,
            emailVerified: true,
            firstName: $firstName,
            lastName: $lastName,
            avatarUrl: $avatar,
        );
    }

    /**
     * @return array{0: string, 1: string}
     */
    private function splitName(string $fullName, string $email): array
    {
        if ($fullName !== '') {
            $parts = preg_split('/\s+/', $fullName, 2) ?: [];

            return [
                $parts[0] !== '' ? $parts[0] : 'Traveller',
                $parts[1] ?? 'User',
            ];
        }

        $local = strstr($email, '@', true) ?: 'traveller';

        return [ucfirst($local), 'User'];
    }
}
