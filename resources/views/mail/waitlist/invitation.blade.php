@extends('mail.layouts.brand')

@section('title', 'You are invited to Kampala Nonstop Early Access List')

@section('content')
    <p style="margin:0 0 18px;font-size:15px;color:#57534e;">
        Hello,
    </p>

    <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#1c1917;font-weight:700;">
        {{ $inviterName }} invited you to Kampala Nonstop Early Access
    </h1>

    <p style="margin:0 0 16px;">
        <strong>{{ $inviterName }}</strong> thought you would enjoy discovering Uganda through
        <strong>Kampala Nonstop</strong> — Kampala Nonstop is the first destination of our Africa Nonstop platform to help travellers better experience the continent. We are launching with Uganda around Nyenge Nyenge (Jinja) in November, and want to use the Nyenge World Belgium as a mailing list registration campaign.
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 22px;background:#fff7ed;border:1px solid #ffedd5;border-radius:12px;">
        <tr>
            <td style="padding:16px 18px;font-size:14px;line-height:1.55;color:#9a3412;">
                <strong style="display:block;margin-bottom:4px;color:#c2410c;">Join to win a return flight to Uganda</strong>
                Register for early access and your chance to win a return flight —
                and be first in line when we launch.
                <br>You can unsubscribe at any time.
            </td>
        </tr>
    </table>

    @include('mail.partials.button', [
        'url' => $joinUrl,
        'label' => 'Join Early Access',
    ])
@endsection
