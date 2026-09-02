@extends('mail.layouts.brand')

@section('title', 'Welcome to the Kampala Nonstop Early Access')

@section('content')
    <p style="margin:0 0 18px;font-size:15px;color:#57534e;">
        Dear <strong>{{ $firstName }}</strong>,
    </p>

    <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#1c1917;font-weight:700;">
        Thanks for joining the <strong>Kampala Nonstop</strong> early access list.
    </h1>

    <p style="margin:0 0 16px;">
        Your sign up is confirmed. You have also been entered into our draw to win a <strong style="color:#ea580c;">return flight to Uganda</strong>.
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 22px;background:#fff7ed;border:1px solid #ffedd5;border-radius:12px;">
        <tr>
            <td style="padding:16px 18px;font-size:14px;line-height:1.55;color:#9a3412;">
                <strong style="display:block;margin-bottom:4px;color:#c2410c;">What happens next</strong>
                We will be in touch as we approach launch. No spam — only meaningful updates about
                experiences, travel inspiration and offers.
                @if ($unsubscribeUrl)
                    <br>
                    <a href="{{ $unsubscribeUrl }}" style="color:#c2410c;text-decoration:underline;">Unsubscribe from updates</a>
                @else
                    <br>
                    You can unsubscribe at any time.
                @endif
            </td>
        </tr>
    </table>

    <p style="margin:0 0 22px;">
        Know someone who would love Kampala Nonstop? Share the early access:
    </p>

    <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 8px;">
        <tr>
            <td align="center" style="border-radius:8px;background:#f97316;">
                <a href="{{ $joinUrl }}"
                   style="display:inline-block;padding:14px 28px;font-size:14px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;color:#ffffff;text-decoration:none;">
                    Share the early access
                </a>
            </td>
        </tr>
    </table>

    <p style="margin:18px 0 0;font-size:13px;line-height:1.5;color:#a8a29e;">
        If the button does not work, copy and paste this link into your browser:<br>
        <a href="{{ $joinUrl }}" style="color:#ea580c;word-break:break-all;">{{ $joinUrl }}</a>
    </p>
@endsection
