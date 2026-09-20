<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\ResetPassword as ResetPasswordNotification;
use Illuminate\Notifications\Messages\MailMessage;

class ResetPassword extends ResetPasswordNotification
{
    protected function resetUrl($notifiable): string
    {
        $frontendUrl = rtrim((string) config('app.frontend_url'), '/');

        return $frontendUrl.'/reset-password?'
            .http_build_query([
                'token' => $this->token,
                'email' => $notifiable->getEmailForPasswordReset(),
            ]);
    }

    public function toMail($notifiable): MailMessage
    {
        $expire = (int) config(
            'auth.passwords.'.config('auth.defaults.passwords').'.expire',
            60
        );

        $data = [
            'url' => $this->resetUrl($notifiable),
            'email' => $notifiable->getEmailForPasswordReset(),
            'expire' => $expire,
        ];

        return (new MailMessage)
            ->subject('Reset your Kampala Nonstop password')
            ->view('mail.auth.reset-password', $data)
            ->text('mail.auth.reset-password-text', $data);
    }
}
