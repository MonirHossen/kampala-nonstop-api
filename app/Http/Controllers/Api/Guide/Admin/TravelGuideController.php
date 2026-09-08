<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreTravelGuideRequest;
use App\Http\Requests\Guide\UpdateTravelGuideRequest;
use App\Models\CountryTravelGuide;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TravelGuideController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = CountryTravelGuide::query()->with('topic');

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        $guides = $query
            ->get()
            ->sortBy(fn (CountryTravelGuide $guide) => $guide->topic?->sort_order ?? 0)
            ->values();

        return response()->json(['data' => $guides]);
    }

    public function store(StoreTravelGuideRequest $request): JsonResponse
    {
        $guide = CountryTravelGuide::query()->create($request->validated());

        return response()->json(['data' => $guide->load('topic')], 201);
    }

    public function update(UpdateTravelGuideRequest $request, CountryTravelGuide $travelGuide): JsonResponse
    {
        $travelGuide->fill($request->validated());
        $travelGuide->save();

        return response()->json(['data' => $travelGuide->refresh()->load('topic')]);
    }

    public function destroy(CountryTravelGuide $travelGuide): JsonResponse
    {
        $travelGuide->delete();

        return response()->json(['message' => 'Travel guide entry deleted.']);
    }
}
