<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ItineraryItem extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'itinerary_id',
        'listing_id',
        'source_trip_listing_id',
        'scheduled_date',
        'start_time',
        'end_time',
        'end_day_offset',
        'sort_order',
        'is_optional',
        'notes',
        'created_by',
        'updated_by',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'scheduled_date' => 'date',
            'end_day_offset' => 'integer',
            'sort_order' => 'integer',
            'is_optional' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<Itinerary, $this>
     */
    public function itinerary(): BelongsTo
    {
        return $this->belongsTo(Itinerary::class);
    }

    /**
     * @return BelongsTo<Listing, $this>
     */
    public function listing(): BelongsTo
    {
        return $this->belongsTo(Listing::class);
    }

    /**
     * @return BelongsTo<TripListing, $this>
     */
    public function sourceTripListing(): BelongsTo
    {
        return $this->belongsTo(TripListing::class, 'source_trip_listing_id');
    }
}
