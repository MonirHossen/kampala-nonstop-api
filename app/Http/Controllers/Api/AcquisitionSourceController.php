<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcquisitionSource;
use Illuminate\Http\JsonResponse;

class AcquisitionSourceController extends Controller
{
    /**
     * Public catalogue of active acquisition sources.
     */
    public function index(): JsonResponse
    {
        $sources = AcquisitionSource::query()
            ->active()
            ->orderBy('name')
            ->get(['code', 'name', 'type']);

        return response()->json([
            'data' => $sources->map(static fn (AcquisitionSource $source): array => [
                'code' => $source->code,
                'name' => $source->name,
                'type' => $source->type,
            ])->values(),
        ]);
    }
}
