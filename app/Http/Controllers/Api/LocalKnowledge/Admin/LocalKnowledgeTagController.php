<?php

namespace App\Http\Controllers\Api\LocalKnowledge\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\StoreLocalKnowledgeTagRequest;
use App\Http\Requests\LocalKnowledge\UpdateLocalKnowledgeTagRequest;
use App\Models\LocalKnowledgeTag;
use Illuminate\Http\JsonResponse;

class LocalKnowledgeTagController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => LocalKnowledgeTag::query()->orderBy('name')->get(),
        ]);
    }

    public function store(StoreLocalKnowledgeTagRequest $request): JsonResponse
    {
        $tag = LocalKnowledgeTag::query()->create($request->validated());

        return response()->json(['data' => $tag], 201);
    }

    public function update(UpdateLocalKnowledgeTagRequest $request, LocalKnowledgeTag $tag): JsonResponse
    {
        $tag->fill($request->validated());
        $tag->save();

        return response()->json(['data' => $tag->refresh()]);
    }
}
