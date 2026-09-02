<?php

namespace App\Support;

use App\Models\WaitlistSignup;
use Illuminate\Support\Facades\URL;

final class WaitlistUrls
{
    public const DEFAULT_SOURCE = 'unaa_denver_2026';

    public static function join(string $source = self::DEFAULT_SOURCE): string
    {
        $base = rtrim((string) config('app.frontend_url'), '/');
        $source = trim($source);

        if ($source === '') {
            $source = self::DEFAULT_SOURCE;
        }

        return $base.'/waitlist/join?source='.rawurlencode($source);
    }

    public static function unsubscribe(WaitlistSignup $signup): string
    {
        return URL::signedRoute('waitlist.unsubscribe', ['signup' => $signup->id]);
    }
}
