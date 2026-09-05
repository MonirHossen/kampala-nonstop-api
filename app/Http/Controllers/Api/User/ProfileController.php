<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\UpdateProfileRequest;
use App\Http\Resources\UserProfileResource;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function show(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'profile' => $user->profile
                ? new UserProfileResource($user->profile)
                : null,
        ]);
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $profile = $this->userProfileService->updateProfile($user, $request->validated());

        return response()->json([
            'profile' => new UserProfileResource($profile),
        ]);
    }
}
