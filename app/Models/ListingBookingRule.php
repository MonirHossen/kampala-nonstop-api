<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ListingBookingRule extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'listing_id',
        'listing_option_id',
        'minimum_notice_minutes',
        'maximum_advance_days',
        'buffer_before_minutes',
        'buffer_after_minutes',
        'earliest_arrival_time',
        'latest_arrival_time',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'minimum_notice_minutes' => 'integer',
            'maximum_advance_days' => 'integer',
            'buffer_before_minutes' => 'integer',
            'buffer_after_minutes' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<Listing, $this>
     */
    public function listing(): BelongsTo
    {
        return $this->belongsTo(Listing::class);
    }
}
