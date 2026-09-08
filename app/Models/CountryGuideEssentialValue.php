<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CountryGuideEssentialValue extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'country_code',
        'essential_type_id',
        'value_text',
        'value_data',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'value_data' => 'array',
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
     * @return BelongsTo<CountryGuideEssentialType, $this>
     */
    public function type(): BelongsTo
    {
        return $this->belongsTo(CountryGuideEssentialType::class, 'essential_type_id');
    }
}
