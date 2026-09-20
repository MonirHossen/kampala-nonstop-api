<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreGeographicAreaRequest;
use App\Http\Requests\Guide\UpdateGeographicAreaRequest;
use App\Models\GeographicArea;
use App\Models\GeographicAreaType;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GeographicAreaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = GeographicArea::query()->with('type');

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        $areas = $query->orderBy('code')->get();

        return response()->json(['data' => $areas]);
    }

    public function types(): JsonResponse
    {
        $types = GeographicAreaType::query()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $types]);
    }

    public function store(StoreGeographicAreaRequest $request): JsonResponse
    {
        $area = GeographicArea::query()->create($request->validated());

        return response()->json(['data' => $area->load('type')], 201);
    }

    public function update(UpdateGeographicAreaRequest $request, GeographicArea $geographicArea): JsonResponse
    {
        $geographicArea->fill($request->validated());
        $geographicArea->save();

        return response()->json(['data' => $geographicArea->refresh()->load('type')]);
    }
}
