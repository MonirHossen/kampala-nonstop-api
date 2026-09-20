<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\UpdateNotificationPreferencesRequest;
use App\Http\Resources\UserNotificationPreferenceResource;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationPreferenceController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function show(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'notification_preferences' => $user->notificationPreferences
                ? new UserNotificationPreferenceResource($user->notificationPreferences)
                : null,
        ]);
    }

    public function update(UpdateNotificationPreferencesRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $preferences = $this->userProfileService->updateNotificationPreferences(
            $user,
            $request->validated()
        );

        return response()->json([
            'notification_preferences' => new UserNotificationPreferenceResource($preferences),
        ]);
    }
}
