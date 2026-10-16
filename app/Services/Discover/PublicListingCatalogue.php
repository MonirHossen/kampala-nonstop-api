<?php

namespace App\Services\Discover;

use App\Models\GeographicArea;
use App\Models\Listing;
use App\Models\ListingBookingHour;
use App\Models\ListingBookingRule;
use App\Models\ListingMedia;
use App\Models\ListingOption;
use App\Models\ListingType;
use App\Models\Tag;
use App\Support\DiscoverCatalogueMap;
use Illuminate\Database\Eloquent\Builder;

class PublicListingCatalogue
{
    public const DEFAULT_PER_PAGE = 12;

    public const MAX_PER_PAGE = 48;

    private const DAY_NAMES = [
        0 => 'Sunday',
        1 => 'Monday',
        2 => 'Tuesday',
        3 => 'Wednesday',
        4 => 'Thursday',
        5 => 'Friday',
        6 => 'Saturday',
    ];

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
            ->with(['options', 'tags', 'bookingHours', 'bookingRule'])
            ->where('slug', $slug)
            ->first();
    }

    /**
     * Filter option lists for the Discover catalogue dropdowns.
     *
     * @return array{
     *     locations: list<array{name: string, code: string}>,
     *     types: list<array{label: string, code: string}>,
     *     interests: list<array{label: string}>
     * }
     */
    public function filters(string $countryCode = 'UG'): array
    {
        $country = strtoupper($countryCode);

        $locations = GeographicArea::query()
            ->live()
            ->where('country_code', $country)
            ->whereHas('type', fn (Builder $type) => $type->where('code', 'CITY')->where('is_live', true))
            ->orderBy('name')
            ->get(['code', 'name'])
            ->map(static fn (GeographicArea $area): array => [
                'name' => $area->name,
                'code' => $area->code,
            ])
            ->values()
            ->all();

        $liveTypeCodes = ListingType::query()
            ->where('is_live', true)
            ->pluck('code')
            ->all();

        $types = [];
        foreach (DiscoverCatalogueMap::TYPE_LABELS as $code => $label) {
            if (in_array($code, $liveTypeCodes, true)) {
                $types[] = [
                    'label' => $label,
                    'code' => $code,
                ];
            }
        }

        $interests = array_map(
            static fn (string $label): array => ['label' => $label],
            DiscoverCatalogueMap::interests()
        );

        return [
            'locations' => $locations,
            'types' => $types,
            'interests' => $interests,
        ];
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
                    'is_cover' => $media->is_cover,
                ])
                ->values()
                ->all(),
            'tags' => $listing->tags
                ->map(fn (Tag $tag): array => [
                    'code' => $tag->code,
                    'name' => $tag->name,
                ])
                ->values()
                ->all(),
            'options' => $listing->options
                ->map(fn (ListingOption $option): array => [
                    'name' => $option->name,
                    'description' => $option->description,
                    'duration_minutes' => $option->duration_minutes,
                    'min_participants' => $option->min_participants,
                    'max_participants' => $option->max_participants,
                    'is_default' => $option->is_default,
                ])
                ->values()
                ->all(),
            'booking_hours' => $listing->bookingHours
                ->map(fn (ListingBookingHour $hour): array => [
                    'day_of_week' => $hour->day_of_week,
                    'day_name' => self::DAY_NAMES[$hour->day_of_week] ?? null,
                    'start_time' => $this->formatTime($hour->start_time),
                    'end_time' => $this->formatTime($hour->end_time),
                    'end_day_offset' => $hour->end_day_offset,
                ])
                ->values()
                ->all(),
            'booking_rule' => $this->presentBookingRule($listing->bookingRule),
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

        $tag = isset($filters['tag']) ? strtoupper(trim((string) $filters['tag'])) : '';

        if ($tag !== '') {
            $query->whereHas('tags', fn (Builder $tags) => $tags->where('code', $tag));
        }

        $typeRank = [];
        foreach (array_keys(DiscoverCatalogueMap::TYPE_LABELS) as $index => $code) {
            $typeRank[] = "WHEN '{$code}' THEN {$index}";
        }
        $typeOrderSql = 'CASE (SELECT code FROM listing_types WHERE listing_types.id = listings.listing_type_id) '
            .implode(' ', $typeRank)
            .' ELSE 99 END';

        return $query
            ->orderByRaw($typeOrderSql)
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

    /**
     * @return array<string, mixed>|null
     */
    private function presentBookingRule(?ListingBookingRule $rule): ?array
    {
        if ($rule === null) {
            return null;
        }

        return [
            'minimum_notice_minutes' => $rule->minimum_notice_minutes,
            'maximum_advance_days' => $rule->maximum_advance_days,
            'buffer_before_minutes' => $rule->buffer_before_minutes,
            'buffer_after_minutes' => $rule->buffer_after_minutes,
            'earliest_arrival_time' => $this->formatTime($rule->earliest_arrival_time),
            'latest_arrival_time' => $this->formatTime($rule->latest_arrival_time),
        ];
    }

    private function formatTime(mixed $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        if ($value instanceof \DateTimeInterface) {
            return $value->format('H:i');
        }

        $raw = (string) $value;

        return strlen($raw) >= 5 ? substr($raw, 0, 5) : $raw;
    }
}
