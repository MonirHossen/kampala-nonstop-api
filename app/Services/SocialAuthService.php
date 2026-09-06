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

class SocialAuthService
{
    public function __construct(
        private readonly GoogleTokenVerifier $googleTokenVerifier,
        private readonly FacebookTokenVerifier $facebookTokenVerifier,
    ) {}

    /**
     * @param  array{provider: string, token: string, device_name?: string}  $data
     * @return array{user: User, token: string}
     */
    public function authenticate(array $data): array
    {
        $identity = $this->verifierFor($data['provider'])->verify($data['token']);

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

        $deviceName = $data['device_name'] ?? 'api';

        return [
            'user' => $user,
            'token' => $user->createToken($deviceName)->plainTextToken,
        ];
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
