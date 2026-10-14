<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreTripRequest;
use App\Http\Requests\User\UpdateTripRequest;
use App\Http\Resources\TripResource;
use App\Models\Trip;
use App\Services\TripPlanningService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TripController extends Controller
{
    public function __construct(private readonly TripPlanningService $tripPlanningService) {}

    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'trips' => TripResource::collection(
                $this->tripPlanningService->listTrips($user)
            ),
        ]);
    }

    public function store(StoreTripRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $user->loadMissing('profile');

        $trip = $this->tripPlanningService->createTrip($user, $request->validated());

        return response()->json([
            'trip' => new TripResource($trip),
        ], 201);
    }

    public function show(Request $request, string $trip): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        return response()->json([
            'trip' => new TripResource(
                $this->tripPlanningService->findOwnedTrip($user, $trip)
            ),
        ]);
    }

    public function update(UpdateTripRequest $request, string $trip): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $owned = $this->tripPlanningService->findOwnedTrip($user, $trip);
        $updated = $this->tripPlanningService->updateTrip($user, $owned, $request->validated());

        return response()->json([
            'trip' => new TripResource($updated),
        ]);
    }

    public function destroy(Request $request, string $trip): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $owned = $this->tripPlanningService->findOwnedTrip($user, $trip);
        $this->tripPlanningService->deleteTrip($user, $owned);

        return response()->json([
            'message' => 'Trip deleted.',
        ]);
    }
}
