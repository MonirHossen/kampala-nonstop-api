<?php

namespace App\Http\Controllers\Api\Guide\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Guide\StoreEssentialValueRequest;
use App\Http\Requests\Guide\UpdateEssentialValueRequest;
use App\Models\CountryGuideEssentialValue;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EssentialValueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = CountryGuideEssentialValue::query()->with('type');

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        $values = $query
            ->get()
            ->sortBy(fn (CountryGuideEssentialValue $value) => $value->type?->sort_order ?? 0)
            ->values();

        return response()->json(['data' => $values]);
    }

    public function store(StoreEssentialValueRequest $request): JsonResponse
    {
        $value = CountryGuideEssentialValue::query()->create($request->validated());

        return response()->json(['data' => $value->load('type')], 201);
    }

    public function update(UpdateEssentialValueRequest $request, CountryGuideEssentialValue $essentialValue): JsonResponse
    {
        $essentialValue->fill($request->validated());
        $essentialValue->save();

        return response()->json(['data' => $essentialValue->refresh()->load('type')]);
    }

    public function destroy(CountryGuideEssentialValue $essentialValue): JsonResponse
    {
        $essentialValue->delete();

        return response()->json(['message' => 'Essential value deleted.']);
    }
}
