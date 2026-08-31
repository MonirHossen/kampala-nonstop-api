@extends('mail.layouts.brand')

@section('title', 'Welcome to the Kampala Nonstop waitlist')

@section('content')
    <p style="margin:0 0 18px;font-size:15px;color:#57534e;">
        Dear {{ $firstName }},
    </p>

    <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#1c1917;font-weight:700;">
        Thank you for joining the waitlist
    </h1>

    <p style="margin:0 0 16px;">
        Your registration with <strong>Kampala Nonstop</strong> is confirmed. You are now among
        the first travellers who will experience personalised trip planning, trusted local insights,
        and unforgettable moments across Kampala and Uganda.
    </p>

    <p style="margin:0 0 16px;">
        As a waitlist member, you will receive carefully curated updates on new experiences,
        launch news, and exclusive opportunities — including our draw for a
        <strong style="color:#ea580c;">return flight to Uganda</strong>.
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 22px;background:#fff7ed;border:1px solid #ffedd5;border-radius:12px;">
        <tr>
            <td style="padding:16px 18px;font-size:14px;line-height:1.55;color:#9a3412;">
                <strong style="display:block;margin-bottom:4px;color:#c2410c;">What happens next</strong>
                We will be in touch as we approach launch. No spam — only meaningful updates about
                experiences, travel inspiration and offers you can unsubscribe from at any time.
            </td>
        </tr>
    </table>

    <p style="margin:0 0 22px;">
        Know someone who would love Kampala? Share the waitlist and help shape the experiences
        we build together.
    </p>

    <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 8px;">
        <tr>
            <td align="center" style="border-radius:8px;background:#f97316;">
                <a href="{{ $joinUrl }}"
                   style="display:inline-block;padding:14px 28px;font-size:14px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;color:#ffffff;text-decoration:none;">
                    Share the waitlist
                </a>
            </td>
        </tr>
    </table>

    <p style="margin:18px 0 0;font-size:13px;line-height:1.5;color:#a8a29e;">
        If the button does not work, copy and paste this link into your browser:<br>
        <a href="{{ $joinUrl }}" style="color:#ea580c;word-break:break-all;">{{ $joinUrl }}</a>
    </p>
@endsection
