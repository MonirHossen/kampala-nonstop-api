<?php

namespace App\Services;

use App\Models\SocialAccount;
use App\Models\User;
use App\Models\UserConsent;
use App\Services\SocialAuth\Contracts\SocialTokenVerifier;
use App\Services\SocialAuth\FacebookTokenVerifier;
use App\Services\SocialAuth\GoogleTokenVerifier;
use App\Services\SocialAuth\VerifiedSocialIdentity;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Laravel\Socialite\Contracts\User as SocialiteUser;

class SocialAuthService
{
    public function __construct(
        private readonly GoogleTokenVerifier $googleTokenVerifier,
        private readonly FacebookTokenVerifier $facebookTokenVerifier,
    ) {}

    /**
     * Token-verify flow (SPA SDK). Kept for API clients that already use it.
     *
     * @param  array{provider: string, token: string, device_name?: string}  $data
     * @return array{user: User, token: string}
     */
    public function authenticate(array $data): array
    {
        $identity = $this->verifierFor($data['provider'])->verify($data['token']);

        return $this->issueSession($identity, $data['device_name'] ?? 'api');
    }

    /**
     * Laravel Socialite OAuth callback flow.
     *
     * @return array{user: User, token: string}
     */
    public function authenticateFromSocialite(string $provider, SocialiteUser $socialUser): array
    {
        $identity = $this->identityFromSocialite($provider, $socialUser);

        return $this->issueSession($identity, 'web');
    }

    public function userForExchange(string $userId): User
    {
        /** @var User $user */
        $user = User::query()->findOrFail($userId);
        $user->load(['profile', 'preferences', 'notificationPreferences', 'consents']);

        return $user;
    }

    /**
     * @return array{user: User, token: string}
     */
    private function issueSession(VerifiedSocialIdentity $identity, string $deviceName): array
    {
        if (! $identity->emailVerified) {
            throw ValidationException::withMessages([
                'token' => ['A verified email address is required to sign in with this provider.'],
            ]);
        }

        $user = $this->resolveUser($identity);

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'token' => ['This account is inactive.'],
            ]);
        }

        $user->load(['profile', 'preferences', 'notificationPreferences', 'consents']);

        return [
            'user' => $user,
            'token' => $user->createToken($deviceName)->plainTextToken,
        ];
    }

    private function identityFromSocialite(string $provider, SocialiteUser $socialUser): VerifiedSocialIdentity
    {
        $email = strtolower(trim((string) ($socialUser->getEmail() ?? '')));
        if ($email === '') {
            throw ValidationException::withMessages([
                'token' => ['The provider did not share an email address. Allow email access and try again.'],
            ]);
        }

        $providerUserId = (string) $socialUser->getId();
        if ($providerUserId === '') {
            throw ValidationException::withMessages([
                'token' => ['Unable to read the provider account id.'],
            ]);
        }

        $raw = method_exists($socialUser, 'getRaw') ? $socialUser->getRaw() : [];
        $raw = is_array($raw) ? $raw : [];

        $firstName = trim((string) ($raw['given_name'] ?? $raw['first_name'] ?? ''));
        $lastName = trim((string) ($raw['family_name'] ?? $raw['last_name'] ?? ''));

        if ($firstName === '' && $lastName === '') {
            $fullName = trim((string) ($socialUser->getName() ?? ''));
            if ($fullName !== '') {
                $parts = preg_split('/\s+/', $fullName, 2) ?: [];
                $firstName = $parts[0] !== '' ? $parts[0] : 'Traveller';
                $lastName = $parts[1] ?? 'User';
            } else {
                $local = strstr($email, '@', true) ?: 'traveller';
                $firstName = ucfirst($local);
                $lastName = 'User';
            }
        } elseif ($firstName === '') {
            $firstName = 'Traveller';
        } elseif ($lastName === '') {
            $lastName = 'User';
        }

        $avatar = $socialUser->getAvatar();
        $emailVerified = match ($provider) {
            SocialAccount::PROVIDER_GOOGLE => filter_var($raw['email_verified'] ?? true, FILTER_VALIDATE_BOOLEAN),
            // Facebook only returns email when granted/usable.
            SocialAccount::PROVIDER_FACEBOOK => true,
            default => true,
        };

        return new VerifiedSocialIdentity(
            provider: $provider,
            providerUserId: $providerUserId,
            email: $email,
            emailVerified: $emailVerified,
            firstName: $firstName,
            lastName: $lastName,
            avatarUrl: is_string($avatar) && $avatar !== '' ? $avatar : null,
        );
    }

    private function verifierFor(string $provider): SocialTokenVerifier
    {
        return match ($provider) {
            SocialAccount::PROVIDER_GOOGLE => $this->googleTokenVerifier,
            SocialAccount::PROVIDER_FACEBOOK => $this->facebookTokenVerifier,
            default => throw ValidationException::withMessages([
                'provider' => ['Unsupported social provider.'],
            ]),
        };
    }

    private function resolveUser(VerifiedSocialIdentity $identity): User
    {
        /** @var SocialAccount|null $existingAccount */
        $existingAccount = SocialAccount::query()
            ->where('provider', $identity->provider)
            ->where('provider_user_id', $identity->providerUserId)
            ->first();

        if ($existingAccount !== null) {
            if ($identity->avatarUrl !== null && $existingAccount->avatar_url !== $identity->avatarUrl) {
                $existingAccount->forceFill(['avatar_url' => $identity->avatarUrl])->save();
            }

            /** @var User $user */
            $user = $existingAccount->user()->firstOrFail();

            return $user;
        }

        /** @var User|null $userByEmail */
        $userByEmail = User::query()
            ->whereRaw('LOWER(email) = ?', [$identity->email])
            ->first();

        if ($userByEmail !== null) {
            $this->linkSocialAccount($userByEmail, $identity);

            return $userByEmail;
        }

        return $this->createSocialUser($identity);
    }

    private function linkSocialAccount(User $user, VerifiedSocialIdentity $identity): void
    {
        $user->socialAccounts()->create([
            'provider' => $identity->provider,
            'provider_user_id' => $identity->providerUserId,
            'avatar_url' => $identity->avatarUrl,
        ]);

        if ($user->email_verified_at === null) {
            $user->forceFill(['email_verified_at' => now()])->save();
        }

        if ($identity->avatarUrl !== null) {
            $profile = $user->profile;
            if ($profile !== null && $profile->profile_photo_url === null) {
                $profile->forceFill(['profile_photo_url' => $identity->avatarUrl])->save();
            }
        }
    }

    private function createSocialUser(VerifiedSocialIdentity $identity): User
    {
        return DB::transaction(function () use ($identity): User {
            /** @var User $user */
            $user = User::query()->create([
                'email' => $identity->email,
                'password' => null,
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            $user->profile()->create([
                'first_name' => $identity->firstName,
                'last_name' => $identity->lastName,
                'profile_photo_url' => $identity->avatarUrl,
            ]);

            $user->preferences()->create([]);
            $user->notificationPreferences()->create([]);

            $now = now();

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_TERMS_OF_SERVICE,
                'is_granted' => true,
                'granted_at' => $now,
                'policy_version' => 'v0',
            ]);

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_PRIVACY_POLICY,
                'is_granted' => true,
                'granted_at' => $now,
                'policy_version' => 'v0',
            ]);

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_MARKETING,
                'is_granted' => false,
                'granted_at' => null,
            ]);

            $user->socialAccounts()->create([
                'provider' => $identity->provider,
                'provider_user_id' => $identity->providerUserId,
                'avatar_url' => $identity->avatarUrl,
            ]);

            return $user;
        });
    }
}
