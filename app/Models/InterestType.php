<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Database\Factories\InterestTypeFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class InterestType extends Model
{
    /** @use HasFactory<InterestTypeFactory> */
    use HasFactory, HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'code',
        'description',
        'display_order',
        'active',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'display_order' => 'integer',
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
     * @return BelongsToMany<WaitlistSignup, $this>
     */
    public function waitlistSignups(): BelongsToMany
    {
        return $this->belongsToMany(
            WaitlistSignup::class,
            'waitlist_signup_interests',
            'interest_type_id',
            'waitlist_signup_id',
        )->using(WaitlistSignupInterest::class);
    }
}
