<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserCitizenship;
use App\Models\UserConsent;
use App\Models\UserFavourite;
use App\Models\UserNotificationPreference;
use App\Models\UserPreference;
use App\Models\UserProfile;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class UserProfileService
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function updateProfile(User $user, array $data): UserProfile
    {
        $profile = $user->profile;

        if ($profile === null) {
            $profile = $user->profile()->create(array_merge([
                'first_name' => $data['first_name'] ?? 'Unknown',
                'last_name' => $data['last_name'] ?? 'User',
            ], $data));
        } else {
            $profile->fill($data)->save();
        }

        return $profile->fresh();
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updatePreferences(User $user, array $data): UserPreference
    {
        $preferences = $user->preferences;

        if ($preferences === null) {
            $preferences = $user->preferences()->create($data);
        } else {
            $preferences->fill($data)->save();
        }

        return $preferences->fresh();
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateNotificationPreferences(User $user, array $data): UserNotificationPreference
    {
        $preferences = $user->notificationPreferences;

        if ($preferences === null) {
            $preferences = $user->notificationPreferences()->create($data);
        } else {
            $preferences->fill($data)->save();
        }

        return $preferences->fresh();
    }

    /**
     * @param  array{country_code: string, is_primary?: bool}  $data
     */
    public function addCitizenship(User $user, array $data): UserCitizenship
    {
        return DB::transaction(function () use ($user, $data): UserCitizenship {
            $isPrimary = (bool) ($data['is_primary'] ?? false);

            if ($isPrimary) {
                $user->citizenships()->update(['is_primary' => false]);
            } elseif ($user->citizenships()->doesntExist()) {
                $isPrimary = true;
            }

            return $user->citizenships()->create([
                'country_code' => $data['country_code'],
                'is_primary' => $isPrimary,
            ]);
        });
    }

    /**
     * @param  array{country_code?: string, is_primary?: bool}  $data
     */
    public function updateCitizenship(User $user, UserCitizenship $citizenship, array $data): UserCitizenship
    {
        if ($citizenship->user_id !== $user->id) {
            throw new NotFoundHttpException('Citizenship not found.');
        }

        return DB::transaction(function () use ($user, $citizenship, $data): UserCitizenship {
            if (array_key_exists('is_primary', $data) && $data['is_primary'] === true) {
                $user->citizenships()
                    ->where('id', '!=', $citizenship->id)
                    ->update(['is_primary' => false]);
            }

            if (
                array_key_exists('is_primary', $data)
                && $data['is_primary'] === false
                && $citizenship->is_primary
                && $user->citizenships()->where('id', '!=', $citizenship->id)->doesntExist()
            ) {
                throw ValidationException::withMessages([
                    'is_primary' => ['At least one citizenship must remain primary when it is the only citizenship.'],
                ]);
            }

            $citizenship->fill($data)->save();

            return $citizenship->fresh();
        });
    }

    public function deleteCitizenship(User $user, UserCitizenship $citizenship): void
    {
        if ($citizenship->user_id !== $user->id) {
            throw new NotFoundHttpException('Citizenship not found.');
        }

        DB::transaction(function () use ($user, $citizenship): void {
            $wasPrimary = $citizenship->is_primary;
            $citizenship->delete();

            if ($wasPrimary) {
                $next = $user->citizenships()->orderBy('created_at')->first();
                if ($next !== null) {
                    $next->update(['is_primary' => true]);
                }
            }
        });
    }

    /**
     * @param  array{is_granted: bool, policy_version?: string|null}  $data
     */
    public function updateConsent(User $user, string $type, array $data): UserConsent
    {
        if (! in_array($type, UserConsent::TYPES, true)) {
            throw ValidationException::withMessages([
                'type' => ['The consent type is invalid.'],
            ]);
        }

        $consent = $user->consents()->firstOrNew(['consent_type' => $type]);
        $granted = (bool) $data['is_granted'];
        $now = now();

        if ($granted) {
            $consent->is_granted = true;
            $consent->granted_at = $consent->granted_at ?? $now;
            $consent->withdrawn_at = null;
        } else {
            $consent->is_granted = false;
            $consent->withdrawn_at = $now;
        }

        if (array_key_exists('policy_version', $data)) {
            $consent->policy_version = $data['policy_version'];
        }

        $consent->user_id = $user->id;
        $consent->save();

        return $consent->fresh();
    }

    /**
     * @param  array{favouritable_type: string, favouritable_id: string, notes?: string|null}  $data
     */
    public function addFavourite(User $user, array $data): UserFavourite
    {
        return $user->favourites()->create($data);
    }

    public function deleteFavourite(User $user, UserFavourite $favourite): void
    {
        if ($favourite->user_id !== $user->id) {
            throw new NotFoundHttpException('Favourite not found.');
        }

        $favourite->delete();
    }

    /**
     * @return Collection<int, UserCitizenship>
     */
    public function listCitizenships(User $user): Collection
    {
        return $user->citizenships()->orderByDesc('is_primary')->orderBy('country_code')->get();
    }

    /**
     * @return Collection<int, UserFavourite>
     */
    public function listFavourites(User $user): Collection
    {
        return $user->favourites()->latest('created_at')->get();
    }

    /**
     * @return Collection<int, UserConsent>
     */
    public function listConsents(User $user): Collection
    {
        return $user->consents()->orderBy('consent_type')->get();
    }
}
