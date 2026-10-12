<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Listing extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'listing_type_id',
        'subcategory_id',
        'name',
        'slug',
        'summary',
        'description',
        'country_code',
        'geographic_area_id',
        'inclusions',
        'exclusions',
        'what_to_bring',
        'important_information',
        'booking_instructions',
        'is_local_gem',
        'is_hot_pick',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_local_gem' => 'boolean',
            'is_hot_pick' => 'boolean',
            'is_live' => 'boolean',
        ];
    }

    /**
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeLive(Builder $query): Builder
    {
        return $query->where('is_live', true);
    }

    /**
     * @return BelongsTo<ListingType, $this>
     */
    public function listingType(): BelongsTo
    {
        return $this->belongsTo(ListingType::class);
    }

    /**
     * @return BelongsTo<Subcategory, $this>
     */
    public function subcategory(): BelongsTo
    {
        return $this->belongsTo(Subcategory::class);
    }

    /**
     * @return BelongsTo<GeographicArea, $this>
     */
    public function geographicArea(): BelongsTo
    {
        return $this->belongsTo(GeographicArea::class);
    }

    /**
     * Live images only, cover first in presentation rather than in this order.
     *
     * @return HasMany<ListingMedia, $this>
     */
    public function media(): HasMany
    {
        return $this->hasMany(ListingMedia::class)
            ->where('is_live', true)
            ->orderBy('sort_order')
            ->orderBy('id');
    }

    /**
     * @return HasMany<ListingOption, $this>
     */
    public function options(): HasMany
    {
        return $this->hasMany(ListingOption::class)
            ->where('is_live', true)
            ->orderByDesc('is_default')
            ->orderBy('name');
    }

    /**
     * @return HasMany<ListingBookingHour, $this>
     */
    public function bookingHours(): HasMany
    {
        return $this->hasMany(ListingBookingHour::class)
            ->where('is_live', true)
            ->orderBy('day_of_week')
            ->orderBy('start_time');
    }

    /**
     * @return HasOne<ListingBookingRule, $this>
     */
    public function bookingRule(): HasOne
    {
        return $this->hasOne(ListingBookingRule::class)
            ->whereNull('listing_option_id');
    }

    /**
     * @return BelongsToMany<Tag, $this>
     */
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'listing_tags')
            ->where('tags.is_live', true)
            ->orderBy('tags.name');
    }
}
