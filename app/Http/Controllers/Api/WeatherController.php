<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\WeatherService;
use Illuminate\Http\JsonResponse;
use RuntimeException;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class WeatherController extends Controller
{
    public function __construct(private readonly WeatherService $weatherService) {}

    public function kampala(): JsonResponse
    {
        try {
            return response()->json([
                'data' => $this->weatherService->kampala(),
            ]);
        } catch (RuntimeException|Throwable) {
            return response()->json([
                'message' => 'Unable to load Kampala weather right now.',
            ], Response::HTTP_BAD_GATEWAY);
        }
    }
}
