@extends('mail.layouts.brand')

@section('title', 'Reset your Kampala Nonstop password')

@section('content')
    <p style="margin:0 0 18px;font-size:15px;color:#57534e;">
        Hello,
    </p>

    <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#1c1917;font-weight:700;">
        Reset your password
    </h1>

    <p style="margin:0 0 16px;">
        You are receiving this email because we received a password reset request for your
        <strong>Kampala Nonstop</strong> account.
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 22px;background:#fff7ed;border:1px solid #ffedd5;border-radius:12px;">
        <tr>
            <td style="padding:16px 18px;font-size:14px;line-height:1.55;color:#9a3412;">
                <strong style="display:block;margin-bottom:4px;color:#c2410c;">Link expiry</strong>
                This password reset link will expire in {{ $expire }} minutes.
                If you did not request a password reset, no further action is required.
            </td>
        </tr>
    </table>

    @include('mail.partials.button', [
        'url' => $url,
        'label' => 'Reset Password',
    ])
@endsection
