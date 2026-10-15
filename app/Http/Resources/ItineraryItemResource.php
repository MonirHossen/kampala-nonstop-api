<?php

namespace App\Http\Resources;

use App\Models\ItineraryItem;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ItineraryItem
 */
class ItineraryItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'listing_id' => $this->listing_id,
            'source_trip_listing_id' => $this->source_trip_listing_id,
            'scheduled_date' => $this->scheduled_date?->toDateString(),
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'end_day_offset' => $this->end_day_offset,
            'sort_order' => $this->sort_order,
            'is_optional' => (bool) $this->is_optional,
            'notes' => $this->notes,
            'listing' => $this->whenLoaded('listing', function () {
                return [
                    'id' => $this->listing->id,
                    'name' => $this->listing->name,
                    'slug' => $this->listing->slug,
                    'summary' => $this->listing->summary,
                ];
            }),
        ];
    }
}
