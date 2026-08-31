<?php

namespace App\Support;

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

        return $base.'/?source='.rawurlencode($source).'#waitlist';
    }
}
