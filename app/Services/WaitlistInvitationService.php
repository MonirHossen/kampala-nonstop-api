<?php

namespace App\Services;

use App\Mail\WaitlistInvitationMail;
use App\Models\WaitlistInvitation;
use App\Models\WaitlistSignup;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class WaitlistInvitationService
{
    /**
     * Record an invitation and email the invitee.
     *
     * @param  array{inviter_id: string, invitee_email: string}  $data
     */
    public function invite(array $data): WaitlistInvitation
    {
        $inviter = WaitlistSignup::query()->find($data['inviter_id']);

        if (! $inviter instanceof WaitlistSignup) {
            throw ValidationException::withMessages([
                'inviter_id' => 'The inviter could not be found.',
            ]);
        }

        $inviteeEmail = strtolower(trim($data['invitee_email']));

        if ($inviteeEmail === $inviter->email) {
            throw ValidationException::withMessages([
                'invitee_email' => 'You cannot invite yourself.',
            ]);
        }

        try {
            $invitation = DB::transaction(function () use ($inviter, $inviteeEmail): WaitlistInvitation {
                $existing = WaitlistInvitation::query()
                    ->where('inviter_waitlist_signup_id', $inviter->id)
                    ->where('invitee_email', $inviteeEmail)
                    ->lockForUpdate()
                    ->first();

                if ($existing instanceof WaitlistInvitation) {
                    $existing->sent_at = now();
                    $existing->save();

                    return $existing->load('inviter');
                }

                return WaitlistInvitation::query()->create([
                    'inviter_waitlist_signup_id' => $inviter->id,
                    'invitee_email' => $inviteeEmail,
                    'sent_at' => now(),
                ])->load('inviter');
            });
        } catch (UniqueConstraintViolationException) {
            $invitation = WaitlistInvitation::query()
                ->where('inviter_waitlist_signup_id', $inviter->id)
                ->where('invitee_email', $inviteeEmail)
                ->firstOrFail();

            $invitation->sent_at = now();
            $invitation->save();
            $invitation->load('inviter');
        }

        Mail::to($invitation->invitee_email)->queue(
            new WaitlistInvitationMail($invitation, $inviter)
        );

        return $invitation;
    }
}
