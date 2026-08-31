<?php

use App\Support\WaitlistUrls;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

/*
|--------------------------------------------------------------------------
| Waitlist deep-link fallback
|--------------------------------------------------------------------------
|
| Invitation / welcome emails must open the Angular frontend. If someone
| hits the API host by mistake (FRONTEND_URL misconfigured), bounce them.
|
*/

Route::get('/waitlist/join', function () {
    $source = trim((string) request()->query('source')) ?: 'referral';
    $target = WaitlistUrls::join($source);

    // The frontend now serves this same path, so a misconfigured FRONTEND_URL
    // pointing back at this host would loop forever.
    $origin = parse_url($target, PHP_URL_SCHEME).'://'.parse_url($target, PHP_URL_HOST)
        .(($port = parse_url($target, PHP_URL_PORT)) ? ':'.$port : '');

    abort_if($origin === request()->getSchemeAndHttpHost(), 404);

    return redirect()->away($target);
});
