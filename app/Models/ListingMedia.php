<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ListingMedia extends Model
{
    use HasUuidPrimaryKey;

    protected $table = 'listing_media';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'listing_id',
        'media_url',
        'media_type',
        'caption',
        'alt_text',
        'sort_order',
        'is_cover',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'is_cover' => 'boolean',
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
