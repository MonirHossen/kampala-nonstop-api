<?php

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
    $frontend = rtrim((string) config('app.frontend_url'), '/');
    $query = request()->getQueryString();

    $target = $frontend.'/waitlist/join'.($query ? '?'.$query : '?source=referral');

    return redirect()->away($target);
});
