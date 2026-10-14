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
            'listing_id' => $this->listing_id,
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'listing' => $this->whenLoaded('listing', function () {
                return [
                    'id' => $this->listing->id,
                    'name' => $this->listing->name,
                    'slug' => $this->listing->slug,
                    'summary' => $this->listing->summary,
                    'is_live' => (bool) $this->listing->is_live,
                ];
            }),
        ];
    }
}
