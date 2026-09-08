<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreRegionGuideRequest;
use App\Http\Requests\Guide\UpdateRegionGuideRequest;
use App\Models\CountryRegionGuide;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegionGuideController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = CountryRegionGuide::query()->with('geographicArea');

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        $regions = $query
            ->orderByDesc('is_featured')
            ->orderBy('title')
            ->get();

        return response()->json(['data' => $regions]);
    }

    public function store(StoreRegionGuideRequest $request): JsonResponse
    {
        $region = CountryRegionGuide::query()->create($request->validated());

        return response()->json(['data' => $region->load('geographicArea')], 201);
    }

    public function update(UpdateRegionGuideRequest $request, CountryRegionGuide $regionGuide): JsonResponse
    {
        $regionGuide->fill($request->validated());
        $regionGuide->save();

        return response()->json(['data' => $regionGuide->refresh()->load('geographicArea')]);
    }

    public function destroy(CountryRegionGuide $regionGuide): JsonResponse
    {
        $regionGuide->delete();

        return response()->json(['message' => 'Region guide deleted.']);
    }
}
