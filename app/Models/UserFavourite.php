<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserFavourite extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    public const TYPES = [
        'place',
        'activity',
        'event',
        'tour',
        'service',
        'organisation',
        'experience',
    ];

    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'favouritable_type',
        'favouritable_id',
        'notes',
    ];

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
