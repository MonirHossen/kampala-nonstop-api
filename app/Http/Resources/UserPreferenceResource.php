<?php

namespace App\Http\Resources;

use App\Models\UserPreference;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin UserPreference
 */
class UserPreferenceResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'preferred_language' => $this->preferred_language,
            'preferred_currency' => $this->preferred_currency,
            'distance_unit' => $this->distance_unit,
            'temperature_unit' => $this->temperature_unit,
            'updated_at' => $this->updated_at,
        ];
    }
}
