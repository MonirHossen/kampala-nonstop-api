<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreTripListingRequest;
use App\Http\Resources\TripListingResource;
use App\Http\Resources\TripResource;
use App\Models\TripListing;
use App\Services\TripPlanningService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TripListingController extends Controller
{
    public function __construct(private readonly TripPlanningService $tripPlanningService) {}

    /**
     * Add a listing to a trip. When trip_id is omitted, uses (or creates) the latest DRAFT trip.
     */
    public function store(StoreTripListingRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $user->loadMissing('profile');

        $validated = $request->validated();
        $result = $this->tripPlanningService->addListingToTrip(
            $user,
            $validated['listing_id'],
            $validated['trip_id'] ?? null,
        );

        return response()->json([
            'trip' => new TripResource($result['trip']),
            'trip_listing' => new TripListingResource($result['trip_listing']),
            'created' => $result['created'],
            'message' => $result['created']
                ? 'Listing added to trip.'
                : 'Listing was already on this trip.',
        ], $result['created'] ? 201 : 200);
    }

    public function destroy(Request $request, string $trip, string $tripListing): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $ownedTrip = $this->tripPlanningService->findOwnedTrip($user, $trip);
        $listing = TripListing::query()->whereKey($tripListing)->firstOrFail();

        $this->tripPlanningService->removeListingFromTrip($user, $ownedTrip, $listing);

        return response()->json([
            'message' => 'Listing removed from trip.',
        ]);
    }
}
