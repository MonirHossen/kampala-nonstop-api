<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\UpdatePreferencesRequest;
use App\Http\Resources\UserPreferenceResource;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PreferenceController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function show(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'preferences' => $user->preferences
                ? new UserPreferenceResource($user->preferences)
                : null,
        ]);
    }

    public function update(UpdatePreferencesRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $preferences = $this->userProfileService->updatePreferences($user, $request->validated());

        return response()->json([
            'preferences' => new UserPreferenceResource($preferences),
        ]);
    }
}
