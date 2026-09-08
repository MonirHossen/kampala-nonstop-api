<?php

namespace App\Services;

use App\Models\CountryGuideEssentialValue;
use App\Models\CountryRegionGuide;
use App\Models\CountryTravelGuide;
use App\Models\CountryTravelInformation;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class GuideService
{
    /**
     * @return array{
     *     country_code: string,
     *     essentials: list<array<string, mixed>>,
     *     travel_guide: list<array<string, mixed>>,
     *     travel_information: list<array<string, mixed>>,
     *     regions: list<array<string, mixed>>
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
            'travel_guide' => $this->travelGuide($countryCode),
            'travel_information' => $this->travelInformation($countryCode),
            'regions' => $this->regions($countryCode),
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

    /**
     * @return list<array<string, mixed>>
     */
    public function travelGuide(string $countryCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);

        return CountryTravelGuide::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('topic', fn ($query) => $query->active())
            ->with('topic')
            ->get()
            ->sortBy(fn (CountryTravelGuide $guide) => $guide->topic?->sort_order ?? 0)
            ->values()
            ->map(static fn (CountryTravelGuide $guide): array => [
                'id' => $guide->id,
                'code' => $guide->topic?->code,
                'name' => $guide->topic?->name,
                'description' => $guide->topic?->description,
                'content' => $guide->content,
                'image_link' => $guide->image_link,
                'sort_order' => $guide->topic?->sort_order,
            ])
            ->all();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function travelInformation(string $countryCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);

        return CountryTravelInformation::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('type', fn ($query) => $query->active())
            ->with('type')
            ->get()
            ->sortBy(fn (CountryTravelInformation $item) => $item->type?->sort_order ?? 0)
            ->values()
            ->map(static fn (CountryTravelInformation $item): array => [
                'id' => $item->id,
                'code' => $item->type?->code,
                'name' => $item->type?->name,
                'value_text' => $item->value_text,
                'value_data' => $item->value_data,
                'sort_order' => $item->type?->sort_order,
            ])
            ->all();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function regions(string $countryCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);

        return CountryRegionGuide::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('geographicArea', fn ($query) => $query->live())
            ->with('geographicArea')
            ->orderByDesc('is_featured')
            ->orderBy('title')
            ->get()
            ->map(static fn (CountryRegionGuide $region): array => [
                'id' => $region->id,
                'code' => $region->geographicArea?->code,
                'title' => $region->title,
                'summary' => $region->summary,
                'image_link' => $region->image_link,
                'is_featured' => $region->is_featured,
            ])
            ->all();
    }

    /**
     * @return array<string, mixed>
     */
    public function region(string $countryCode, string $areaCode): array
    {
        $countryCode = $this->normaliseCountryCode($countryCode);
        $areaCode = strtoupper(trim($areaCode));

        $region = CountryRegionGuide::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('geographicArea', function ($query) use ($areaCode) {
                $query->live()->where('code', $areaCode);
            })
            ->with('geographicArea')
            ->first();

        if ($region === null) {
            throw new NotFoundHttpException('Region guide not found.');
        }

        return [
            'id' => $region->id,
            'code' => $region->geographicArea?->code,
            'title' => $region->title,
            'summary' => $region->summary,
            'image_link' => $region->image_link,
            'is_featured' => $region->is_featured,
        ];
    }

    public function normaliseCountryCode(string $countryCode): string
    {
        return strtoupper(trim($countryCode));
    }

    private function hasAnyLiveContent(string $countryCode): bool
    {
        return CountryGuideEssentialValue::query()->live()->where('country_code', $countryCode)->exists()
            || CountryTravelGuide::query()->live()->where('country_code', $countryCode)->exists()
            || CountryTravelInformation::query()->live()->where('country_code', $countryCode)->exists()
            || CountryRegionGuide::query()->live()->where('country_code', $countryCode)->exists();
    }
}
