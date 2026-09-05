<?php

namespace App\Http\Resources;

use App\Models\UserFavourite;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin UserFavourite
 */
class UserFavouriteResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'favouritable_type' => $this->favouritable_type,
            'favouritable_id' => $this->favouritable_id,
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
