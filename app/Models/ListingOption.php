<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ListingOption extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'listing_id',
        'name',
        'description',
        'duration_minutes',
        'min_participants',
        'max_participants',
        'is_default',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'duration_minutes' => 'integer',
            'min_participants' => 'integer',
            'max_participants' => 'integer',
            'is_default' => 'boolean',
            'is_live' => 'boolean',
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
