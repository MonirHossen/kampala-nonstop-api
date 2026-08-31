<?php

namespace App\Mail;

use App\Models\WaitlistSignup;
use App\Support\WaitlistUrls;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WaitlistWelcomeMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public int $tries = 3;

    /** @var list<int> */
    public array $backoff = [10, 30, 60];

    public int $timeout = 60;

    public function __construct(public readonly WaitlistSignup $signup)
    {
        $this->afterCommit();
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: "Welcome to Kampala Nonstop — you're on the waitlist",
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'mail.waitlist.welcome',
            text: 'mail.waitlist.welcome-text',
            with: [
                'firstName' => $this->signup->first_name,
                'joinUrl' => WaitlistUrls::join(),
            ],
        );
    }
}
