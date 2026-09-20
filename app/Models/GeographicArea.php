<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GeographicArea extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'parent_geographic_area_id',
        'geographic_area_type_id',
        'country_code',
        'code',
        'name',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
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
     * @return BelongsTo<GeographicArea, $this>
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(GeographicArea::class, 'parent_geographic_area_id');
    }

    /**
     * @return HasMany<GeographicArea, $this>
     */
    public function children(): HasMany
    {
        return $this->hasMany(GeographicArea::class, 'parent_geographic_area_id');
    }

    /**
     * @return BelongsTo<GeographicAreaType, $this>
     */
    public function type(): BelongsTo
    {
        return $this->belongsTo(GeographicAreaType::class, 'geographic_area_type_id');
    }

    /**
     * @return HasMany<LocalKnowledge, $this>
     */
    public function localKnowledge(): HasMany
    {
        return $this->hasMany(LocalKnowledge::class, 'geographic_area_id');
    }
}
