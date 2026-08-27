<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API v1 Routes
|--------------------------------------------------------------------------
|
| All Kampala Nonstop API endpoints are versioned under /api/v1/.
| Register feature routes here as they are built.
|
*/

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'version' => 'v1',
    ]);
});
