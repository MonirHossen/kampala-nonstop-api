<?php

namespace App\Services\Discover;

use App\Models\Listing;
use App\Models\ListingMedia;
use App\Support\DiscoverCatalogueMap;
use Illuminate\Database\Eloquent\Builder;

class PublicListingCatalogue
{
    public const DEFAULT_PER_PAGE = 12;

    public const MAX_PER_PAGE = 24;

    /**
     * @param  array<string, mixed>  $filters
     * @return array{data: list<array<string, mixed>>, meta: array{current_page: int, per_page: int, total: int, last_page: int}}
     */
    public function page(array $filters): array
    {
        $perPage = min(
            self::MAX_PER_PAGE,
            max(1, (int) ($filters['per_page'] ?? self::DEFAULT_PER_PAGE))
        );

        $paginator = $this->query($filters)
            ->paginate($perPage)
            ->withQueryString();

        return [
            'data' => $paginator->getCollection()
                ->map(fn (Listing $listing): array => $this->presentCard($listing))
                ->values()
                ->all(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ],
        ];
    }

    public function findLiveBySlug(string $slug, string $countryCode = 'UG'): ?Listing
    {
        return $this->baseQuery($countryCode)
            ->where('slug', $slug)
            ->first();
    }

    /**
     * @return array<string, mixed>
     */
    public function presentCard(Listing $listing): array
    {
        $cover = $this->cover($listing);

        return [
            'id' => $listing->id,
            'slug' => $listing->slug,
            'name' => $listing->name,
            'summary' => $listing->summary,
            'listing_type_code' => $listing->listingType?->code,
            'listing_type_name' => $listing->listingType?->name,
            'category_name' => $listing->subcategory?->category?->name,
            'subcategory_name' => $listing->subcategory?->name,
            'geographic_area_name' => $listing->geographicArea?->name,
            'cover' => $cover,
            'is_hot_pick' => $listing->is_hot_pick,
            'is_local_gem' => $listing->is_local_gem,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function presentDetail(Listing $listing): array
    {
        return [
            ...$this->presentCard($listing),
            'description' => $listing->description,
            'inclusions' => $listing->inclusions,
            'exclusions' => $listing->exclusions,
            'what_to_bring' => $listing->what_to_bring,
            'important_information' => $listing->important_information,
            'booking_instructions' => $listing->booking_instructions,
            'gallery' => $listing->media
                ->map(fn (ListingMedia $media): array => [
                    'url' => $media->media_url,
                    'alt_text' => $media->alt_text,
                    'caption' => $media->caption,
                ])
                ->values()
                ->all(),
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<Listing>
     */
    private function query(array $filters): Builder
    {
        $query = $this->baseQuery((string) ($filters['country_code'] ?? 'UG'));

        $typeCode = DiscoverCatalogueMap::listingTypeCode(
            isset($filters['type']) ? (string) $filters['type'] : null
        );

        if ($typeCode !== null) {
            $query->whereHas('listingType', fn (Builder $type) => $type->where('code', $typeCode));
        }

        $interest = isset($filters['interest']) ? trim((string) $filters['interest']) : '';

        if ($interest !== '') {
            $this->applyInterest($query, $interest);
        }

        $location = isset($filters['location']) ? trim((string) $filters['location']) : '';

        if ($location !== '') {
            $query->whereHas('geographicArea', function (Builder $area) use ($location): void {
                $area->where('name', 'ilike', $location)
                    ->orWhereHas('parent', fn (Builder $parent) => $parent->where('name', 'ilike', $location));
            });
        }

        if (! empty($filters['hot_pick'])) {
            $query->where('is_hot_pick', true);
        }

        return $query
            ->orderByDesc('is_hot_pick')
            ->orderByDesc('is_local_gem')
            ->orderBy('name');
    }

    /**
     * @return Builder<Listing>
     */
    private function baseQuery(string $countryCode): Builder
    {
        return Listing::query()
            ->live()
            ->where('country_code', strtoupper($countryCode))
            ->with([
                'listingType',
                'subcategory.category',
                'geographicArea',
                'media',
            ]);
    }

    /**
     * @param  Builder<Listing>  $query
     */
    private function applyInterest(Builder $query, string $interest): void
    {
        if (isset(DiscoverCatalogueMap::INTEREST_LISTING_TYPES[$interest])) {
            $code = DiscoverCatalogueMap::INTEREST_LISTING_TYPES[$interest];
            $query->whereHas('listingType', fn (Builder $type) => $type->where('code', $code));

            return;
        }

        if (isset(DiscoverCatalogueMap::SUBCATEGORY_CODES[$interest])) {
            $codes = DiscoverCatalogueMap::SUBCATEGORY_CODES[$interest];
            $query->whereHas('subcategory', fn (Builder $subcategory) => $subcategory->whereIn('code', $codes));

            return;
        }

        if (isset(DiscoverCatalogueMap::CATEGORY_CODES[$interest])) {
            $codes = DiscoverCatalogueMap::CATEGORY_CODES[$interest];
            $query->whereHas(
                'subcategory.category',
                fn (Builder $category) => $category->whereIn('code', $codes)
            );
        }
    }

    /**
     * @return array{url: string, alt_text: string|null}|null
     */
    private function cover(Listing $listing): ?array
    {
        $cover = $listing->media->firstWhere('is_cover', true) ?? $listing->media->first();

        if ($cover === null) {
            return null;
        }

        return [
            'url' => $cover->media_url,
            'alt_text' => $cover->alt_text,
        ];
    }
}
