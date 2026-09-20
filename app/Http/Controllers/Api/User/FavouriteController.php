<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreFavouriteRequest;
use App\Http\Resources\UserFavouriteResource;
use App\Models\UserFavourite;
use App\Services\UserProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavouriteController extends Controller
{
    public function __construct(private readonly UserProfileService $userProfileService) {}

    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'favourites' => UserFavouriteResource::collection(
                $this->userProfileService->listFavourites($user)
            ),
        ]);
    }

    public function store(StoreFavouriteRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $favourite = $this->userProfileService->addFavourite($user, $request->validated());

        return response()->json([
            'favourite' => new UserFavouriteResource($favourite),
        ], 201);
    }

    public function destroy(Request $request, UserFavourite $favourite): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $this->userProfileService->deleteFavourite($user, $favourite);

        return response()->json([
            'message' => 'Favourite removed.',
        ]);
    }
}
