<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SocialAccount extends Model
{
    use HasUuidPrimaryKey;

    public const PROVIDER_GOOGLE = 'google';

    public const PROVIDER_FACEBOOK = 'facebook';

    /**
     * @var list<string>
     */
    public const PROVIDERS = [
        self::PROVIDER_GOOGLE,
        self::PROVIDER_FACEBOOK,
    ];

    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'provider',
        'provider_user_id',
        'avatar_url',
    ];

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
