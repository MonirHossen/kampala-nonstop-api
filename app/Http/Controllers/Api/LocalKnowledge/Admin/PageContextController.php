<?php

namespace App\Http\Controllers\Api\LocalKnowledge\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\StorePageContextRequest;
use App\Http\Requests\LocalKnowledge\UpdatePageContextRequest;
use App\Models\PageContext;
use Illuminate\Http\JsonResponse;

class PageContextController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => PageContext::query()->orderBy('name')->get(),
        ]);
    }

    public function store(StorePageContextRequest $request): JsonResponse
    {
        $context = PageContext::query()->create($request->validated());

        return response()->json(['data' => $context], 201);
    }

    public function update(UpdatePageContextRequest $request, PageContext $pageContext): JsonResponse
    {
        $pageContext->fill($request->validated());
        $pageContext->save();

        return response()->json(['data' => $pageContext->refresh()]);
    }
}
