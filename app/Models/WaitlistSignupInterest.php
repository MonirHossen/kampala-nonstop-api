<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Relations\Pivot;

/**
 * Junction record linking a waitlist signup to an interest type.
 *
 * Extending Pivot (rather than relying on the default pivot handling) lets
 * Eloquent generate the UUIDv7 primary key that this table requires.
 */
class WaitlistSignupInterest extends Pivot
{
    use HasUuidPrimaryKey;

    protected $table = 'waitlist_signup_interests';

    public $timestamps = true;

    /**
     * The table stores `created_at` only.
     *
     * AsPivot resolves this column from the parent model instead of the pivot's
     * own UPDATED_AT constant, so it has to be disabled here.
     */
    public function getUpdatedAtColumn(): ?string
    {
        return null;
    }
}
