<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserPreference extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'preferred_language',
        'preferred_currency',
        'distance_unit',
        'temperature_unit',
    ];

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
