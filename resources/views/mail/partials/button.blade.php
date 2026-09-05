{{-- Shared CTA button for branded Kampala Nonstop emails --}}
@php
    $label = $label ?? 'Continue';
    $url = $url ?? '#';
@endphp
<table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 8px;">
    <tr>
        <td align="center" style="border-radius:8px;background:#f97316;">
            <a href="{{ $url }}"
               style="display:inline-block;padding:14px 28px;font-size:14px;font-weight:700;letter-spacing:0.04em;text-transform:uppercase;color:#ffffff;text-decoration:none;">
                {{ $label }}
            </a>
        </td>
    </tr>
</table>
<p style="margin:18px 0 0;font-size:13px;line-height:1.5;color:#a8a29e;">
    If the button does not work, copy and paste this link into your browser:<br>
    <a href="{{ $url }}" style="color:#ea580c;word-break:break-all;">{{ $url }}</a>
</p>
