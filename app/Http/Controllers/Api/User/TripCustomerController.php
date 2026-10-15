<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreTripCustomerRequest;
use App\Http\Resources\TripCustomerResource;
use App\Models\TripCustomer;
use App\Services\TripPlanningService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TripCustomerController extends Controller
{
    public function __construct(private readonly TripPlanningService $tripPlanningService) {}

    public function store(StoreTripCustomerRequest $request, string $trip): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $ownedTrip = $this->tripPlanningService->findOwnedTrip($user, $trip);
        $customer = $this->tripPlanningService->addCustomer($user, $ownedTrip, $request->validated());

        return response()->json([
            'customer' => new TripCustomerResource($customer),
        ], 201);
    }

    public function destroy(Request $request, string $trip, string $customer): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $ownedTrip = $this->tripPlanningService->findOwnedTrip($user, $trip);
        $tripCustomer = TripCustomer::query()->whereKey($customer)->firstOrFail();

        $this->tripPlanningService->removeCustomer($user, $ownedTrip, $tripCustomer);

        return response()->json([
            'message' => 'Customer removed from trip.',
        ]);
    }
}
