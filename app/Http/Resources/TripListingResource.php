<?php

namespace App\Http\Resources;

use App\Models\TripListing;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin TripListing
 */
class TripListingResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'trip_id' => $this->trip_id,
            'listing_id' => $this->listing_id,
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
