<?php

namespace App\Services\SocialAuth;

use App\Models\SocialAccount;
use App\Services\SocialAuth\Contracts\SocialTokenVerifier;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;

class GoogleTokenVerifier implements SocialTokenVerifier
{
    public function verify(string $token): VerifiedSocialIdentity
    {
        $clientId = config('services.google.client_id');

        if (! is_string($clientId) || $clientId === '') {
            throw ValidationException::withMessages([
                'provider' => ['Google sign-in is not configured.'],
            ]);
        }

        // JWT ID tokens contain two dots; otherwise treat as OAuth access token.
        if (substr_count($token, '.') === 2) {
            return $this->fromIdToken($token, $clientId);
        }

        return $this->fromAccessToken($token, $clientId);
    }

    private function fromIdToken(string $token, string $clientId): VerifiedSocialIdentity
    {
        $response = Http::timeout(10)
            ->acceptJson()
            ->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $token,
            ]);

        if (! $response->successful()) {
            throw ValidationException::withMessages([
                'token' => ['Unable to verify the Google token.'],
            ]);
        }

        /** @var array<string, mixed> $payload */
        $payload = $response->json() ?? [];

        $audience = (string) ($payload['aud'] ?? '');
        if ($audience !== $clientId) {
            throw ValidationException::withMessages([
                'token' => ['The Google token is invalid for this application.'],
            ]);
        }

        return $this->identityFromGooglePayload($payload);
    }

    private function fromAccessToken(string $token, string $clientId): VerifiedSocialIdentity
    {
        $tokenInfoResponse = Http::timeout(10)
            ->acceptJson()
            ->get('https://oauth2.googleapis.com/tokeninfo', [
                'access_token' => $token,
            ]);

        if (! $tokenInfoResponse->successful()) {
            throw ValidationException::withMessages([
                'token' => ['Unable to verify the Google token.'],
            ]);
        }

        /** @var array<string, mixed> $tokenInfo */
        $tokenInfo = $tokenInfoResponse->json() ?? [];
        $audience = (string) ($tokenInfo['aud'] ?? $tokenInfo['azp'] ?? '');

        if ($audience !== $clientId) {
            throw ValidationException::withMessages([
                'token' => ['The Google token is invalid for this application.'],
            ]);
        }

        $profileResponse = Http::timeout(10)
            ->withToken($token)
            ->acceptJson()
            ->get('https://www.googleapis.com/oauth2/v3/userinfo');

        if (! $profileResponse->successful()) {
            throw ValidationException::withMessages([
                'token' => ['Unable to load the Google profile.'],
            ]);
        }

        /** @var array<string, mixed> $payload */
        $payload = $profileResponse->json() ?? [];

        return $this->identityFromGooglePayload($payload);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function identityFromGooglePayload(array $payload): VerifiedSocialIdentity
    {
        $subject = (string) ($payload['sub'] ?? '');
        $email = strtolower(trim((string) ($payload['email'] ?? '')));
        $emailVerified = filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOLEAN);

        if ($subject === '' || $email === '') {
            throw ValidationException::withMessages([
                'token' => ['The Google token is invalid for this application.'],
            ]);
        }

        $firstName = trim((string) ($payload['given_name'] ?? ''));
        $lastName = trim((string) ($payload['family_name'] ?? ''));

        if ($firstName === '' && $lastName === '') {
            $fullName = trim((string) ($payload['name'] ?? ''));
            [$firstName, $lastName] = $this->splitName($fullName, $email);
        } elseif ($firstName === '') {
            $firstName = 'Traveller';
        } elseif ($lastName === '') {
            $lastName = 'User';
        }

        $avatar = isset($payload['picture']) ? (string) $payload['picture'] : null;

        return new VerifiedSocialIdentity(
            provider: SocialAccount::PROVIDER_GOOGLE,
            providerUserId: $subject,
            email: $email,
            emailVerified: $emailVerified,
            firstName: $firstName,
            lastName: $lastName,
            avatarUrl: $avatar !== '' ? $avatar : null,
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
