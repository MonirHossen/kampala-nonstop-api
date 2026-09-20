<?php

namespace App\Http\Controllers\Api\LocalKnowledge;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\RandomLocalKnowledgeRequest;
use App\Services\LocalKnowledgeService;
use Illuminate\Http\JsonResponse;

class LocalKnowledgeController extends Controller
{
    public function __construct(private readonly LocalKnowledgeService $localKnowledgeService) {}

    public function random(RandomLocalKnowledgeRequest $request): JsonResponse
    {
        return response()->json([
            'data' => $this->localKnowledgeService->random($request->validated()),
        ]);
    }

    public function index(RandomLocalKnowledgeRequest $request): JsonResponse
    {
        return response()->json([
            'data' => $this->localKnowledgeService->list($request->validated()),
        ]);
    }
}
