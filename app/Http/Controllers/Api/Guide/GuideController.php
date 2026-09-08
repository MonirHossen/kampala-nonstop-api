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

    public function travelGuide(string $countryCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->travelGuide($countryCode),
        ]);
    }

    public function travelInformation(string $countryCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->travelInformation($countryCode),
        ]);
    }

    public function regions(string $countryCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->regions($countryCode),
        ]);
    }

    public function region(string $countryCode, string $areaCode): JsonResponse
    {
        $this->assertValidCountryCode($countryCode);

        return response()->json([
            'data' => $this->guideService->region($countryCode, $areaCode),
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
