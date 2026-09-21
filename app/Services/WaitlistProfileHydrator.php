<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserConsent;
use App\Models\WaitlistSignup;

/**
 * Fill empty traveller profile gaps from a matching waitlist signup (by email).
 * Never overwrites non-empty Google/user-entered values.
 */
class WaitlistProfileHydrator
{
    public function hydrate(User $user): void
    {
        $email = strtolower(trim((string) $user->email));
        if ($email === '') {
            return;
        }

        /** @var WaitlistSignup|null $signup */
        $signup = WaitlistSignup::query()
            ->whereRaw('LOWER(email) = ?', [$email])
            ->first();

        if ($signup === null) {
            return;
        }

        $this->hydrateProfile($user, $signup);
        $this->hydrateMarketingConsent($user, $signup);
    }

    private function hydrateProfile(User $user, WaitlistSignup $signup): void
    {
        $profile = $user->profile;
        if ($profile === null) {
            return;
        }

        $updates = [];

        if ($this->isBlank($profile->first_name) && $this->isFilled($signup->first_name)) {
            $updates['first_name'] = trim((string) $signup->first_name);
        }

        if ($this->isBlank($profile->last_name) && $this->isFilled($signup->surname)) {
            $updates['last_name'] = trim((string) $signup->surname);
        }

        if ($this->isBlank($profile->country_of_residence) && $this->isFilled($signup->country_code)) {
            $updates['country_of_residence'] = strtoupper(trim((string) $signup->country_code));
        }

        if ($updates === []) {
            return;
        }

        $profile->forceFill($updates)->save();
    }

    private function hydrateMarketingConsent(User $user, WaitlistSignup $signup): void
    {
        if (! $signup->marketing_consent) {
            return;
        }

        /** @var UserConsent|null $consent */
        $consent = $user->consents()
            ->where('consent_type', UserConsent::TYPE_MARKETING)
            ->first();

        if ($consent === null || $consent->is_granted) {
            return;
        }

        $consent->forceFill([
            'is_granted' => true,
            'granted_at' => $consent->granted_at ?? now(),
            'withdrawn_at' => null,
        ])->save();
    }

    private function isBlank(mixed $value): bool
    {
        return ! $this->isFilled($value);
    }

    private function isFilled(mixed $value): bool
    {
        return is_string($value) && trim($value) !== '';
    }
}
