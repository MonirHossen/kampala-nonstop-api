<?php

namespace App\Http\Controllers\Api\LocalKnowledge\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\StoreLocalKnowledgeTypeRequest;
use App\Http\Requests\LocalKnowledge\UpdateLocalKnowledgeTypeRequest;
use App\Models\LocalKnowledgeType;
use Illuminate\Http\JsonResponse;

class LocalKnowledgeTypeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => LocalKnowledgeType::query()->orderBy('name')->get(),
        ]);
    }

    public function store(StoreLocalKnowledgeTypeRequest $request): JsonResponse
    {
        $type = LocalKnowledgeType::query()->create($request->validated());

        return response()->json(['data' => $type], 201);
    }

    public function update(UpdateLocalKnowledgeTypeRequest $request, LocalKnowledgeType $knowledgeType): JsonResponse
    {
        $knowledgeType->fill($request->validated());
        $knowledgeType->save();

        return response()->json(['data' => $knowledgeType->refresh()]);
    }
}
