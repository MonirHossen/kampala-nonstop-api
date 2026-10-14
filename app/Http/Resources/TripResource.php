<?php

namespace App\Http\Resources;

use App\Models\Trip;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Trip
 */
class TripResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'owner_user_id' => $this->owner_user_id,
            'name' => $this->name,
            'country_code' => $this->country_code,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'status_code' => $this->status_code,
            'notes' => $this->notes,
            'listings_count' => $this->when(
                isset($this->trip_listings_count),
                fn () => (int) $this->trip_listings_count,
            ),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'listings' => TripListingResource::collection($this->whenLoaded('tripListings')),
            'customers' => TripCustomerResource::collection($this->whenLoaded('customers')),
            'requirements' => $this->whenLoaded('requirements', function () {
                return $this->requirements->map(fn ($requirement) => [
                    'id' => $requirement->id,
                    'trip_customer_id' => $requirement->trip_customer_id,
                    'requirement_code' => $requirement->requirement_code,
                    'value_json' => $requirement->value_json,
                    'notes' => $requirement->notes,
                ]);
            }),
            'current_itinerary' => $this->when(
                $this->relationLoaded('currentItinerary'),
                fn () => $this->currentItinerary
                    ? new ItineraryResource($this->currentItinerary)
                    : null,
            ),
        ];
    }
}
