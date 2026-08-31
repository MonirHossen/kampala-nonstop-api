{{-- Shared branded shell for Kampala Nonstop transactional emails --}}
@php
    $frontend = rtrim((string) config('app.frontend_url'), '/');
    $logoPath = public_path('images/kampala-nonstop-logo.png');
    $logoSrc = isset($message) && is_file($logoPath)
        ? $message->embed($logoPath)
        : $frontend.'/img/kampala_nonstop_logo.png';
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light">
    <title>@yield('title', 'Kampala Nonstop')</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background-color:#f5f2ed;font-family:'Plus Jakarta Sans',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#44403c;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f2ed;padding:32px 12px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e7e5e4;box-shadow:0 18px 40px -28px rgba(28,25,23,0.35);">
                    <tr>
                        <td align="center" style="padding:28px 32px 20px;background:#ffffff;border-bottom:1px solid #f5f5f4;">
                            <a href="{{ $frontend }}" style="text-decoration:none;">
                                <img src="{{ $logoSrc }}" alt="Kampala Nonstop" width="190" style="display:block;width:190px;max-width:70%;height:auto;border:0;">
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td style="height:4px;background:#f97316;font-size:0;line-height:0;">&nbsp;</td>
                    </tr>
                    <tr>
                        <td style="padding:32px 36px 8px;color:#44403c;font-size:16px;line-height:1.65;">
                            @yield('content')
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:12px 36px 36px;">
                            <p style="margin:0;font-size:15px;line-height:1.6;color:#57534e;">
                                Warm regards,<br>
                                <strong style="color:#1c1917;">The Kampala Nonstop team</strong>
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:20px 36px 28px;background:#fafaf9;border-top:1px solid #f5f5f4;text-align:center;">
                            <p style="margin:0 0 6px;font-size:12px;line-height:1.5;color:#a8a29e;">
                                &copy; {{ date('Y') }} Kampala Nonstop. All rights reserved.
                            </p>
                            <p style="margin:0;font-size:12px;line-height:1.5;color:#a8a29e;">
                                Discover Kampala differently ·
                                <a href="{{ $frontend }}" style="color:#ea580c;text-decoration:none;">Visit our website</a>
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
