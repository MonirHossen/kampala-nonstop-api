<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserConsent extends Model
{
    use HasUuidPrimaryKey;

    public const TYPE_MARKETING = 'marketing';

    public const TYPE_TERMS_OF_SERVICE = 'terms_of_service';

    public const TYPE_PRIVACY_POLICY = 'privacy_policy';

    /**
     * @var list<string>
     */
    public const TYPES = [
        self::TYPE_MARKETING,
        self::TYPE_TERMS_OF_SERVICE,
        self::TYPE_PRIVACY_POLICY,
    ];

    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'consent_type',
        'is_granted',
        'granted_at',
        'withdrawn_at',
        'policy_version',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_granted' => 'boolean',
            'granted_at' => 'datetime',
            'withdrawn_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
