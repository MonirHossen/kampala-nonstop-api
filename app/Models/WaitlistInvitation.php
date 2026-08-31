<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Database\Factories\WaitlistInvitationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WaitlistInvitation extends Model
{
    /** @use HasFactory<WaitlistInvitationFactory> */
    use HasFactory, HasUuidPrimaryKey;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'inviter_waitlist_signup_id',
        'invitee_email',
        'sent_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sent_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<WaitlistSignup, $this>
     */
    public function inviter(): BelongsTo
    {
        return $this->belongsTo(WaitlistSignup::class, 'inviter_waitlist_signup_id');
    }
}
