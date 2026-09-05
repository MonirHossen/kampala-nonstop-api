<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\UpdateConsentRequest;
use App\Http\Resources\UserConsentResource;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConsentController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'consents' => UserConsentResource::collection(
                $this->userProfileService->listConsents($user)
            ),
        ]);
    }

    public function update(UpdateConsentRequest $request, string $type): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $consent = $this->userProfileService->updateConsent(
            $user,
            $type,
            $request->validated()
        );

        return response()->json([
            'consent' => new UserConsentResource($consent),
        ]);
    }
}
