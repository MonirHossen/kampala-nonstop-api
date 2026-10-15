<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Trip extends Model
{
    use HasUuidPrimaryKey;

    public const STATUS_DRAFT = 'DRAFT';

    public const STATUS_PLANNING = 'PLANNING';

    public const STATUS_SUBMITTED = 'SUBMITTED';

    public const STATUS_IN_PROGRESS = 'IN_PROGRESS';

    public const STATUS_COMPLETED = 'COMPLETED';

    public const STATUS_CANCELLED = 'CANCELLED';

    /**
     * @var list<string>
     */
    public const STATUSES = [
        self::STATUS_DRAFT,
        self::STATUS_PLANNING,
        self::STATUS_SUBMITTED,
        self::STATUS_IN_PROGRESS,
        self::STATUS_COMPLETED,
        self::STATUS_CANCELLED,
    ];

    /**
     * Statuses a trip owner may set themselves.
     *
     * @var list<string>
     */
    public const OWNER_SETTABLE_STATUSES = [
        self::STATUS_DRAFT,
        self::STATUS_PLANNING,
        self::STATUS_SUBMITTED,
        self::STATUS_CANCELLED,
    ];

    /**
     * @var list<string>
     */
    protected $fillable = [
        'owner_user_id',
        'name',
        'country_code',
        'start_date',
        'end_date',
        'status_code',
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
            'start_date' => 'date',
            'end_date' => 'date',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    /**
     * @return HasMany<TripCustomer, $this>
     */
    public function customers(): HasMany
    {
        return $this->hasMany(TripCustomer::class);
    }

    /**
     * @return HasMany<TripRequirement, $this>
     */
    public function requirements(): HasMany
    {
        return $this->hasMany(TripRequirement::class);
    }

    /**
     * @return HasMany<TripListing, $this>
     */
    public function tripListings(): HasMany
    {
        return $this->hasMany(TripListing::class);
    }

    /**
     * @return HasMany<Itinerary, $this>
     */
    public function itineraries(): HasMany
    {
        return $this->hasMany(Itinerary::class);
    }

    /**
     * @return HasOne<Itinerary, $this>
     */
    public function currentItinerary(): HasOne
    {
        return $this->hasOne(Itinerary::class)->where('is_current', true);
    }
}
