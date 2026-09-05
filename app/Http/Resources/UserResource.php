<?php

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $profile = $this->whenLoaded('profile');

        return [
            'id' => $this->id,
            'email' => $this->email,
            'status' => $this->status,
            'email_verified_at' => $this->email_verified_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'profile' => $this->when($this->relationLoaded('profile'), function () use ($profile) {
                if ($profile === null) {
                    return null;
                }

                return [
                    'id' => $profile->id,
                    'title' => $profile->title,
                    'first_name' => $profile->first_name,
                    'middle_name' => $profile->middle_name,
                    'last_name' => $profile->last_name,
                    'gender' => $profile->gender,
                    'date_of_birth' => $profile->date_of_birth?->toDateString(),
                    'phone_number' => $profile->phone_number,
                    'city_of_residence' => $profile->city_of_residence,
                    'country_of_residence' => $profile->country_of_residence,
                    'profile_photo_url' => $profile->profile_photo_url,
                ];
            }),
            'preferences' => $this->when($this->relationLoaded('preferences'), function () {
                $preferences = $this->preferences;

                if ($preferences === null) {
                    return null;
                }

                return [
                    'preferred_language' => $preferences->preferred_language,
                    'preferred_currency' => $preferences->preferred_currency,
                    'distance_unit' => $preferences->distance_unit,
                    'temperature_unit' => $preferences->temperature_unit,
                ];
            }),
            'notification_preferences' => $this->when(
                $this->relationLoaded('notificationPreferences'),
                function () {
                    $prefs = $this->notificationPreferences;

                    if ($prefs === null) {
                        return null;
                    }

                    return [
                        'email_enabled' => $prefs->email_enabled,
                        'sms_enabled' => $prefs->sms_enabled,
                        'push_enabled' => $prefs->push_enabled,
                    ];
                }
            ),
            'consents' => $this->when($this->relationLoaded('consents'), function () {
                return $this->consents->map(static fn ($consent): array => [
                    'consent_type' => $consent->consent_type,
                    'is_granted' => $consent->is_granted,
                    'granted_at' => $consent->granted_at,
                    'withdrawn_at' => $consent->withdrawn_at,
                    'policy_version' => $consent->policy_version,
                ])->values();
            }),
        ];
    }
}
