<?php

namespace App\Mail;

use App\Models\WaitlistInvitation;
use App\Models\WaitlistSignup;
use App\Support\WaitlistUrls;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WaitlistInvitationMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public int $tries = 3;

    /** @var list<int> */
    public array $backoff = [10, 30, 60];

    public int $timeout = 60;

    public function __construct(
        public readonly WaitlistInvitation $invitation,
        public readonly WaitlistSignup $inviter,
    ) {
        $this->afterCommit();
    }

    public function envelope(): Envelope
    {
        $name = trim($this->inviter->first_name.' '.$this->inviter->surname);

        return new Envelope(
            subject: $name.' invited you to join Kampala Nonstop',
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'mail.waitlist.invitation',
            text: 'mail.waitlist.invitation-text',
            with: [
                'inviterName' => trim($this->inviter->first_name.' '.$this->inviter->surname),
                'joinUrl' => WaitlistUrls::join('referral'),
            ],
        );
    }
}
