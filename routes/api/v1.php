<?php

use App\Http\Controllers\Api\AcquisitionSourceController;
use App\Http\Controllers\Api\InterestTypeController;
use App\Http\Controllers\Api\WaitlistController;
use App\Http\Controllers\Api\WaitlistInvitationController;
use App\Http\Controllers\Api\WaitlistUnsubscribeController;
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

/*
|--------------------------------------------------------------------------
| FR-001 Waitlist & Acquisition — public
|--------------------------------------------------------------------------
*/

Route::post('/waitlist', [WaitlistController::class, 'store']);
Route::get('/waitlist/unsubscribe/{signup}', [WaitlistUnsubscribeController::class, 'store'])
    ->middleware('signed')
    ->name('waitlist.unsubscribe');
Route::post('/waitlist/invitations', [WaitlistInvitationController::class, 'store']);
Route::get('/interest-types', [InterestTypeController::class, 'index']);
Route::get('/acquisition-sources', [AcquisitionSourceController::class, 'index']);

/*
|--------------------------------------------------------------------------
| FR-001 Waitlist & Acquisition — admin
|--------------------------------------------------------------------------
|
| TODO: apply auth + admin/concierge role middleware to this group once
| authentication is implemented. These endpoints are currently unprotected
| and must not be deployed beyond local development as-is.
|
*/

Route::prefix('admin')->group(function () {
    Route::get('/waitlist/export', [WaitlistController::class, 'export']);
    Route::get('/waitlist', [WaitlistController::class, 'index']);
});
