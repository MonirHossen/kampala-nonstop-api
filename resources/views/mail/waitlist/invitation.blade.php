@extends('mail.layouts.brand')

@section('title', 'You are invited to Kampala Nonstop')

@section('content')
    <p style="margin:0 0 18px;font-size:15px;color:#57534e;">
        Hello,
    </p>

    <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#1c1917;font-weight:700;">
        {{ $inviterName }} invited you to Kampala Nonstop
    </h1>

    <p style="margin:0 0 16px;">
        <strong>{{ $inviterName }}</strong> thought you would enjoy discovering Kampala through
        <strong>Kampala Nonstop</strong> — personalised trip planning, local insights and
        unforgettable experiences across Uganda.
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 22px;background:#fff7ed;border:1px solid #ffedd5;border-radius:12px;">
        <tr>
            <td style="padding:16px 18px;font-size:14px;line-height:1.55;color:#9a3412;">
                <strong style="display:block;margin-bottom:4px;color:#c2410c;">Join to win a return flight to Uganda</strong>
                Register on the waitlist for early access and your chance to win a return flight —
                and be first in line when we open.
            </td>
        </tr>
    </table>

    <p style="margin:0 0 22px;">
        It only takes a minute to join. Tell us what you love, and we will build experiences
        around it.
    </p>

    <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 8px;">
        <tr>
            <td align="center" style="border-radius:8px;background:#f97316;">
                <a href="{{ $joinUrl }}"
                   style="display:inline-block;padding:14px 28px;font-size:14px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;color:#ffffff;text-decoration:none;">
                    Join the waitlist
                </a>
            </td>
        </tr>
    </table>

    <p style="margin:18px 0 0;font-size:13px;line-height:1.5;color:#a8a29e;">
        If the button does not work, copy and paste this link into your browser:<br>
        <a href="{{ $joinUrl }}" style="color:#ea580c;word-break:break-all;">{{ $joinUrl }}</a>
    </p>
@endsection
