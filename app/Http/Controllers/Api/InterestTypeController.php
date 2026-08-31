<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InterestType;
use Illuminate\Http\JsonResponse;

class InterestTypeController extends Controller
{
    /**
     * Public catalogue of active interest types for waitlist UI.
     */
    public function index(): JsonResponse
    {
        $interests = InterestType::query()
            ->active()
            ->orderBy('display_order')
            ->orderBy('name')
            ->get(['code', 'name', 'description', 'display_order']);

        return response()->json([
            'data' => $interests->map(static fn (InterestType $interest): array => [
                'code' => $interest->code,
                'name' => $interest->name,
                'description' => $interest->description,
                'display_order' => $interest->display_order,
            ])->values(),
        ]);
    }
}
