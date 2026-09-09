<?php

use App\Http\Controllers\Api\AcquisitionSourceController;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Auth\PasswordController;
use App\Http\Controllers\Api\Auth\SocialiteAuthController;
use App\Http\Controllers\Api\DeployController;
use App\Http\Controllers\Api\Guide\Admin\EssentialTypeController as AdminEssentialTypeController;
use App\Http\Controllers\Api\Guide\Admin\EssentialValueController as AdminEssentialValueController;
use App\Http\Controllers\Api\Guide\Admin\GeographicAreaController as AdminGeographicAreaController;
use App\Http\Controllers\Api\Guide\GuideController;
use App\Http\Controllers\Api\InterestTypeController;
use App\Http\Controllers\Api\LocalKnowledge\Admin\LocalKnowledgeItemController as AdminLocalKnowledgeItemController;
use App\Http\Controllers\Api\LocalKnowledge\Admin\LocalKnowledgeTagController as AdminLocalKnowledgeTagController;
use App\Http\Controllers\Api\LocalKnowledge\Admin\LocalKnowledgeTypeController as AdminLocalKnowledgeTypeController;
use App\Http\Controllers\Api\LocalKnowledge\Admin\LocalLanguageController as AdminLocalLanguageController;
use App\Http\Controllers\Api\LocalKnowledge\Admin\PageContextController as AdminPageContextController;
use App\Http\Controllers\Api\LocalKnowledge\LocalKnowledgeController;
use App\Http\Controllers\Api\User\CitizenshipController;
use App\Http\Controllers\Api\User\ConsentController;
use App\Http\Controllers\Api\User\FavouriteController;
use App\Http\Controllers\Api\User\NotificationPreferenceController;
use App\Http\Controllers\Api\User\PreferenceController;
use App\Http\Controllers\Api\User\ProfileController;
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
        'deploy_branch' => config('deploy.branch', 'main'),
    ]);
});

/*
|--------------------------------------------------------------------------
| Deploy — pull latest code for this server's branch
|--------------------------------------------------------------------------
|
| Main server (DEPLOY_BRANCH=main) → git pull origin/main
| Dev server  (DEPLOY_BRANCH=dev)  → git pull origin/dev
|
| Auth: Authorization: Bearer <DEPLOY_TOKEN>
|
*/

Route::prefix('deploy')->group(function () {
    Route::get('/status', [DeployController::class, 'status']);
    Route::post('/pull', [DeployController::class, 'pull']);
});

/*
|--------------------------------------------------------------------------
| Auth — public
|--------------------------------------------------------------------------
*/

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/social', [AuthController::class, 'social']);
    Route::post('/social/exchange', [SocialiteAuthController::class, 'exchange']);
    Route::get('/social/{provider}/redirect', [SocialiteAuthController::class, 'redirect']);
    Route::get('/social/{provider}/callback', [SocialiteAuthController::class, 'callback']);
    Route::post('/forgot-password', [PasswordController::class, 'forgot']);
    Route::post('/reset-password', [PasswordController::class, 'reset']);
});

/*
|--------------------------------------------------------------------------
| Auth — authenticated
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->prefix('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/password', [PasswordController::class, 'update']);
});

/*
|--------------------------------------------------------------------------
| Authenticated user profile domain
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->prefix('user')->group(function () {
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);

    Route::get('/preferences', [PreferenceController::class, 'show']);
    Route::put('/preferences', [PreferenceController::class, 'update']);

    Route::get('/notification-preferences', [NotificationPreferenceController::class, 'show']);
    Route::put('/notification-preferences', [NotificationPreferenceController::class, 'update']);

    Route::get('/citizenships', [CitizenshipController::class, 'index']);
    Route::post('/citizenships', [CitizenshipController::class, 'store']);
    Route::put('/citizenships/{citizenship}', [CitizenshipController::class, 'update']);
    Route::delete('/citizenships/{citizenship}', [CitizenshipController::class, 'destroy']);

    Route::get('/consents', [ConsentController::class, 'index']);
    Route::put('/consents/{type}', [ConsentController::class, 'update']);

    Route::get('/favourites', [FavouriteController::class, 'index']);
    Route::post('/favourites', [FavouriteController::class, 'store']);
    Route::delete('/favourites/{favourite}', [FavouriteController::class, 'destroy']);
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
| Authenticated for now. Admin/concierge role middleware remains TODO.
|
*/

Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    Route::get('/waitlist/export', [WaitlistController::class, 'export']);
    Route::get('/waitlist', [WaitlistController::class, 'index']);

    /*
    |--------------------------------------------------------------------------
    | Country Guide — admin
    |--------------------------------------------------------------------------
    |
    | Authenticated for now. Admin/concierge role middleware remains TODO.
    |
    */
    Route::prefix('guide')->group(function () {
        Route::get('/geographic-area-types', [AdminGeographicAreaController::class, 'types']);
        Route::get('/geographic-areas', [AdminGeographicAreaController::class, 'index']);
        Route::post('/geographic-areas', [AdminGeographicAreaController::class, 'store']);
        Route::put('/geographic-areas/{geographicArea}', [AdminGeographicAreaController::class, 'update']);

        Route::get('/essential-types', [AdminEssentialTypeController::class, 'index']);
        Route::post('/essential-types', [AdminEssentialTypeController::class, 'store']);
        Route::put('/essential-types/{essentialType}', [AdminEssentialTypeController::class, 'update']);

        Route::get('/essential-values', [AdminEssentialValueController::class, 'index']);
        Route::post('/essential-values', [AdminEssentialValueController::class, 'store']);
        Route::put('/essential-values/{essentialValue}', [AdminEssentialValueController::class, 'update']);
        Route::delete('/essential-values/{essentialValue}', [AdminEssentialValueController::class, 'destroy']);
    });

    /*
    |--------------------------------------------------------------------------
    | Local Knowledge — admin
    |--------------------------------------------------------------------------
    |
    | Authenticated for now. Admin/concierge role middleware remains TODO.
    |
    */
    Route::prefix('local-knowledge')->group(function () {
        Route::get('/types', [AdminLocalKnowledgeTypeController::class, 'index']);
        Route::post('/types', [AdminLocalKnowledgeTypeController::class, 'store']);
        Route::put('/types/{knowledgeType}', [AdminLocalKnowledgeTypeController::class, 'update']);

        Route::get('/tags', [AdminLocalKnowledgeTagController::class, 'index']);
        Route::post('/tags', [AdminLocalKnowledgeTagController::class, 'store']);
        Route::put('/tags/{tag}', [AdminLocalKnowledgeTagController::class, 'update']);

        Route::get('/page-contexts', [AdminPageContextController::class, 'index']);
        Route::post('/page-contexts', [AdminPageContextController::class, 'store']);
        Route::put('/page-contexts/{pageContext}', [AdminPageContextController::class, 'update']);

        Route::get('/languages', [AdminLocalLanguageController::class, 'index']);
        Route::post('/languages', [AdminLocalLanguageController::class, 'store']);
        Route::put('/languages/{language}', [AdminLocalLanguageController::class, 'update']);

        Route::get('/items', [AdminLocalKnowledgeItemController::class, 'index']);
        Route::post('/items', [AdminLocalKnowledgeItemController::class, 'store']);
        Route::get('/items/{localKnowledge}', [AdminLocalKnowledgeItemController::class, 'show']);
        Route::put('/items/{localKnowledge}', [AdminLocalKnowledgeItemController::class, 'update']);
        Route::delete('/items/{localKnowledge}', [AdminLocalKnowledgeItemController::class, 'destroy']);
    });
});

/*
|--------------------------------------------------------------------------
| Country Guide — public
|--------------------------------------------------------------------------
*/

Route::prefix('guide')->group(function () {
    Route::get('/{countryCode}', [GuideController::class, 'show']);
    Route::get('/{countryCode}/essentials', [GuideController::class, 'essentials']);
});

/*
|--------------------------------------------------------------------------
| Local Knowledge — public
|--------------------------------------------------------------------------
*/

Route::prefix('local-knowledge')->group(function () {
    Route::get('/random', [LocalKnowledgeController::class, 'random']);
});
