<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreTravelInformationRequest;
use App\Http\Requests\Guide\UpdateTravelInformationRequest;
use App\Models\CountryTravelInformation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TravelInformationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = CountryTravelInformation::query()->with('type');

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        $items = $query
            ->get()
            ->sortBy(fn (CountryTravelInformation $item) => $item->type?->sort_order ?? 0)
            ->values();

        return response()->json(['data' => $items]);
    }

    public function store(StoreTravelInformationRequest $request): JsonResponse
    {
        $item = CountryTravelInformation::query()->create($request->validated());

        return response()->json(['data' => $item->load('type')], 201);
    }

    public function update(
        UpdateTravelInformationRequest $request,
        CountryTravelInformation $travelInformation
    ): JsonResponse {
        $travelInformation->fill($request->validated());
        $travelInformation->save();

        return response()->json(['data' => $travelInformation->refresh()->load('type')]);
    }

    public function destroy(CountryTravelInformation $travelInformation): JsonResponse
    {
        $travelInformation->delete();

        return response()->json(['message' => 'Travel information entry deleted.']);
    }
}
