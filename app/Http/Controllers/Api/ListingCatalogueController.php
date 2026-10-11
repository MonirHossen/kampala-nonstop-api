<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ListPublicListingsRequest;
use App\Services\Discover\PublicListingCatalogue;
use Illuminate\Http\JsonResponse;

class ListingCatalogueController extends Controller
{
    public function __construct(private readonly PublicListingCatalogue $catalogue) {}

    public function index(ListPublicListingsRequest $request): JsonResponse
    {
        return response()->json($this->catalogue->page($request->validated()));
    }

    public function show(string $slug): JsonResponse
    {
        $country = strtoupper((string) request()->query('country_code', 'UG'));

        if (! preg_match('/^[A-Z]{2}$/', $country)) {
            return response()->json([
                'message' => 'The country code must be two letters.',
            ], 422);
        }

        $listing = $this->catalogue->findLiveBySlug($slug, $country);

        if ($listing === null) {
            return response()->json([
                'message' => 'Listing not found.',
            ], 404);
        }

        return response()->json([
            'data' => $this->catalogue->presentDetail($listing),
        ]);
    }
}
