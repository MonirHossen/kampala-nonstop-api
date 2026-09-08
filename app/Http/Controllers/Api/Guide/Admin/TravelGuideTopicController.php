<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreTravelGuideTopicRequest;
use App\Http\Requests\Guide\UpdateTravelGuideTopicRequest;
use App\Models\TravelGuideTopic;
use Illuminate\Http\JsonResponse;

class TravelGuideTopicController extends Controller
{
    public function index(): JsonResponse
    {
        $topics = TravelGuideTopic::query()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $topics]);
    }

    public function store(StoreTravelGuideTopicRequest $request): JsonResponse
    {
        $topic = TravelGuideTopic::query()->create($request->validated());

        return response()->json(['data' => $topic], 201);
    }

    public function update(UpdateTravelGuideTopicRequest $request, TravelGuideTopic $topic): JsonResponse
    {
        $topic->fill($request->validated());
        $topic->save();

        return response()->json(['data' => $topic->refresh()]);
    }
}
