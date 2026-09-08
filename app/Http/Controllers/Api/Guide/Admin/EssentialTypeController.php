<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreEssentialTypeRequest;
use App\Http\Requests\Guide\UpdateEssentialTypeRequest;
use App\Models\CountryGuideEssentialType;
use Illuminate\Http\JsonResponse;

class EssentialTypeController extends Controller
{
    public function index(): JsonResponse
    {
        $types = CountryGuideEssentialType::query()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $types]);
    }

    public function store(StoreEssentialTypeRequest $request): JsonResponse
    {
        $type = CountryGuideEssentialType::query()->create($request->validated());

        return response()->json(['data' => $type], 201);
    }

    public function update(UpdateEssentialTypeRequest $request, CountryGuideEssentialType $essentialType): JsonResponse
    {
        $essentialType->fill($request->validated());
        $essentialType->save();

        return response()->json(['data' => $essentialType->refresh()]);
    }
}
