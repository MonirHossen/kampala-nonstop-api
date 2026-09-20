<?php

namespace App\Services;

use App\Models\CountryGuideEssentialValue;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class GuideService
{
    /**
     * @return array{
     *     country_code: string,
     *     essentials: list<array<string, mixed>>
     * }
     */
    public function compose(string $countryCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);

        if (! $this->hasAnyLiveContent($countryCode)) {
            throw new NotFoundHttpException('Country guide not found.');
        }

        return [
            'country_code' => $countryCode,
            'essentials' => $this->essentials($countryCode),
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function essentials(string $countryCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);

        return CountryGuideEssentialValue::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('type', fn ($query) => $query->active())
            ->with('type')
            ->get()
            ->sortBy(fn (CountryGuideEssentialValue $value) => $value->type?->sort_order ?? 0)
            ->values()
            ->map(static fn (CountryGuideEssentialValue $value): array => [
                'id' => $value->id,
                'code' => $value->type?->code,
                'name' => $value->type?->name,
                'value_text' => $value->value_text,
                'value_data' => $value->value_data,
                'sort_order' => $value->type?->sort_order,
            ])
            ->all();
    }

    public function normaliseCountryCode(string $countryCode): string
    {
        return strtoupper(trim($countryCode));
    }

    private function hasAnyLiveContent(string $countryCode): bool
    {
        return CountryGuideEssentialValue::query()
            ->live()
            ->where('country_code', $countryCode)
            ->exists();
    }
}
