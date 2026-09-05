<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreCitizenshipRequest;
use App\Http\Requests\User\UpdateCitizenshipRequest;
use App\Http\Resources\UserCitizenshipResource;
use App\Models\UserCitizenship;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CitizenshipController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'citizenships' => UserCitizenshipResource::collection(
                $this->userProfileService->listCitizenships($user)
            ),
        ]);
    }

    public function store(StoreCitizenshipRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $citizenship = $this->userProfileService->addCitizenship($user, $request->validated());

        return response()->json([
            'citizenship' => new UserCitizenshipResource($citizenship),
        ], 201);
    }

    public function update(UpdateCitizenshipRequest $request, UserCitizenship $citizenship): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $citizenship = $this->userProfileService->updateCitizenship(
            $user,
            $citizenship,
            $request->validated()
        );

        return response()->json([
            'citizenship' => new UserCitizenshipResource($citizenship),
        ]);
    }

    public function destroy(Request $request, UserCitizenship $citizenship): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $this->userProfileService->deleteCitizenship($user, $citizenship);

        return response()->json([
            'message' => 'Citizenship removed.',
        ]);
    }
}
