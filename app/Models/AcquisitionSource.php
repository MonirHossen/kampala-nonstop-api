<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Database\Factories\AcquisitionSourceFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AcquisitionSource extends Model
{
    /** @use HasFactory<AcquisitionSourceFactory> */
    use HasFactory, HasUuidPrimaryKey;

    /**
     * Permitted values for the `type` column.
     */
    public const TYPES = [
        'social',
        'event',
        'campaign',
        'partner',
        'organic',
        'direct',
        'other',
    ];

    /**
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'code',
        'type',
        'active',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'active' => 'boolean',
        ];
    }

    /**
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('active', true);
    }

    /**
     * @return HasMany<WaitlistSignup, $this>
     */
    public function waitlistSignups(): HasMany
    {
        return $this->hasMany(WaitlistSignup::class);
    }
}
