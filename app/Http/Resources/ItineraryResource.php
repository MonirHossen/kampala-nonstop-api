<?php

namespace App\Http\Resources;

use App\Models\Itinerary;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Itinerary
 */
class ItineraryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'trip_id' => $this->trip_id,
            'version_number' => $this->version_number,
            'status_code' => $this->status_code,
            'is_current' => (bool) $this->is_current,
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'items' => ItineraryItemResource::collection($this->whenLoaded('items')),
        ];
    }
}
