<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreTravelInformationTypeRequest;
use App\Http\Requests\Guide\UpdateTravelInformationTypeRequest;
use App\Models\TravelInformationType;
use Illuminate\Http\JsonResponse;

class TravelInformationTypeController extends Controller
{
    public function index(): JsonResponse
    {
        $types = TravelInformationType::query()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $types]);
    }

    public function store(StoreTravelInformationTypeRequest $request): JsonResponse
    {
        $type = TravelInformationType::query()->create($request->validated());

        return response()->json(['data' => $type], 201);
    }

    public function update(UpdateTravelInformationTypeRequest $request, TravelInformationType $infoType): JsonResponse
    {
        $infoType->fill($request->validated());
        $infoType->save();

        return response()->json(['data' => $infoType->refresh()]);
    }
}
