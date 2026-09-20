<?php

namespace App\Http\Controllers\Api\Guide;

use App\Http\Controllers\Controller;
use App\Services\GuideService;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class GuideController extends Controller
{
    public function __construct(private readonly GuideService $guideService) {}

    public function show(string $countryCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->compose($countryCode),
        ]);
    }

    public function essentials(string $countryCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->essentials($countryCode),
        ]);
    }

    private function assertValidCountryCode(string $countryCode): void
    {
        $normalised = $this->guideService->normaliseCountryCode($countryCode);

        if (! preg_match('/^[A-Z]{2}$/', $normalised)) {
            throw new NotFoundHttpException('Country guide not found.');
        }
    }
}
