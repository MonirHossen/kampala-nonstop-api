<?php

namespace App\Models;

use App\Casts\PostgresTextArray;
use App\Models\Concerns\HasUuidPrimaryKey;
use Database\Factories\WaitlistSignupFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class WaitlistSignup extends Model
{
    /** @use HasFactory<WaitlistSignupFactory> */
    use HasFactory, HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'first_name',
        'surname',
        'email',
        'country_code',
        'acquisition_source_id',
        'marketing_consent',
        'marketing_consent_at',
        'unsubscribed',
        'countries_of_interest',
        'source_details',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'marketing_consent' => 'boolean',
            'marketing_consent_at' => 'datetime',
            'unsubscribed' => 'boolean',
            'countries_of_interest' => PostgresTextArray::class,
        ];
    }

    /**
     * Signups still subscribed to communications.
     *
     * This project has no stored status column by design; status is always
     * derived from `unsubscribed`.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('unsubscribed', false);
    }

    /**
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeUnsubscribed(Builder $query): Builder
    {
        return $query->where('unsubscribed', true);
    }

    /**
     * @return BelongsTo<AcquisitionSource, $this>
     */
    public function acquisitionSource(): BelongsTo
    {
        return $this->belongsTo(AcquisitionSource::class);
    }

    /**
     * @return BelongsToMany<InterestType, $this>
     */
    public function interestTypes(): BelongsToMany
    {
        return $this->belongsToMany(
            InterestType::class,
            'waitlist_signup_interests',
            'waitlist_signup_id',
            'interest_type_id',
        )
            ->using(WaitlistSignupInterest::class)
            ->withPivot(['id', 'created_at']);
    }
}
