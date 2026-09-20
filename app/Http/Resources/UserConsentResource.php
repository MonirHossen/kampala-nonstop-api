<?php

namespace App\Http\Resources;

use App\Models\UserConsent;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin UserConsent
 */
class UserConsentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'consent_type' => $this->consent_type,
            'is_granted' => $this->is_granted,
            'granted_at' => $this->granted_at,
            'withdrawn_at' => $this->withdrawn_at,
            'policy_version' => $this->policy_version,
            'updated_at' => $this->updated_at,
        ];
    }
}
