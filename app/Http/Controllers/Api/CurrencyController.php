<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use Illuminate\Http\JsonResponse;

class CurrencyController extends Controller
{
    /**
     * Public catalogue of active currencies for profile preferences UI.
     */
    public function index(): JsonResponse
    {
        $currencies = Currency::query()
            ->active()
            ->orderBy('display_order')
            ->orderBy('name')
            ->get(['code', 'name', 'display_order']);

        return response()->json([
            'data' => $currencies->map(static fn (Currency $currency): array => [
                'code' => $currency->code,
                'name' => $currency->name,
                'display_order' => $currency->display_order,
            ])->values(),
        ]);
    }
}
