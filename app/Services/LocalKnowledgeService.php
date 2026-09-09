<?php

namespace App\Services;

use App\Models\LocalKnowledge;
use App\Models\PageContext;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class LocalKnowledgeService
{
    public const MAX_LIMIT = 10;

    /**
     * Pick random live Local Knowledge for a page.
     *
     * @param  array<string, mixed>  $filters
     * @return list<array<string, mixed>>
     */
    public function random(array $filters): array
    {
        $limit = min(max((int) ($filters['limit'] ?? 1), 1), self::MAX_LIMIT);

        return $this->query($filters)
            ->inRandomOrder()
            ->limit($limit)
            ->get()
            ->map(fn (LocalKnowledge $item): array => $this->present($item))
            ->all();
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return list<array<string, mixed>>
     */
    public function list(array $filters): array
    {
        $limit = min(max((int) ($filters['limit'] ?? 20), 1), 100);

        return $this->query($filters)
            ->orderBy('created_at')
            ->limit($limit)
            ->get()
            ->map(fn (LocalKnowledge $item): array => $this->present($item))
            ->all();
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<LocalKnowledge>
     */
    private function query(array $filters): Builder
    {
        $countryCode = $this->normaliseCode((string) ($filters['country_code'] ?? ''));

        $query = LocalKnowledge::query()
            ->live()
            ->where('country_code', $countryCode)
            ->whereHas('type', fn ($type) => $type->active())
            ->with(['type', 'geographicArea', 'language', 'tags']);

        $this->applyGeographicFilter($query, $countryCode, $filters['geographic_area_code'] ?? null);
        $this->applyPageContextFilter($query, $filters['page_context'] ?? null);
        $this->applyTagFilter($query, $filters['tags'] ?? null);

        if (! empty($filters['type'])) {
            $typeCode = $this->normaliseCode((string) $filters['type']);
            $query->whereHas('type', fn ($type) => $type->where('code', $typeCode));
        }

        if (! empty($filters['language'])) {
            $query->where('local_language_code', trim((string) $filters['language']));
        }

        $excludeIds = $this->normaliseIdList($filters['exclude_ids'] ?? null);

        if ($excludeIds !== []) {
            $query->whereNotIn('id', $excludeIds);
        }

        return $query;
    }

    /**
     * An item anchored to an ancestor area still applies further down the
     * hierarchy. A NULL anchor means the item is country-wide.
     *
     * @param  Builder<LocalKnowledge>  $query
     */
    private function applyGeographicFilter(Builder $query, string $countryCode, mixed $areaCode): void
    {
        if (blank($areaCode)) {
            return;
        }

        $areaIds = $this->resolveAreaAncestry($countryCode, $this->normaliseCode((string) $areaCode));

        $query->where(function (Builder $scoped) use ($areaIds) {
            $scoped->whereNull('geographic_area_id');

            if ($areaIds !== []) {
                $scoped->orWhereIn('geographic_area_id', $areaIds);
            }
        });
    }

    /**
     * Items with no page-context links are treated as eligible everywhere, so
     * authors only tag the items that need narrowing.
     *
     * @param  Builder<LocalKnowledge>  $query
     */
    private function applyPageContextFilter(Builder $query, mixed $pageContext): void
    {
        if (blank($pageContext)) {
            return;
        }

        $contextId = PageContext::query()
            ->active()
            ->where('code', $this->normaliseCode((string) $pageContext))
            ->value('id');

        $query->where(function (Builder $scoped) use ($contextId) {
            $scoped->whereDoesntHave('pageContexts');

            if ($contextId !== null) {
                $scoped->orWhereHas(
                    'pageContexts',
                    fn ($context) => $context->where('page_contexts.id', $contextId)
                );
            }
        });
    }

    /**
     * @param  Builder<LocalKnowledge>  $query
     */
    private function applyTagFilter(Builder $query, mixed $tags): void
    {
        $tagCodes = $this->normaliseCodeList($tags);

        if ($tagCodes === []) {
            return;
        }

        $query->whereHas(
            'tags',
            fn ($tag) => $tag->whereIn('local_knowledge_tags.code', $tagCodes)
        );
    }

    /**
     * Walks up the geographic_areas parent chain from the given area.
     *
     * @return list<string>
     */
    private function resolveAreaAncestry(string $countryCode, string $areaCode): array
    {
        $rows = DB::select(
            <<<'SQL'
            WITH RECURSIVE area_chain AS (
                SELECT id, parent_geographic_area_id
                FROM geographic_areas
                WHERE code = ?
                  AND country_code = ?
                  AND is_live = TRUE

                UNION ALL

                SELECT parent.id, parent.parent_geographic_area_id
                FROM geographic_areas parent
                JOIN area_chain child ON parent.id = child.parent_geographic_area_id
                WHERE parent.is_live = TRUE
            )
            SELECT id FROM area_chain
            SQL,
            [$areaCode, $countryCode]
        );

        return array_map(static fn (object $row): string => (string) $row->id, $rows);
    }

    /**
     * @return array<string, mixed>
     */
    private function present(LocalKnowledge $item): array
    {
        return [
            'id' => $item->id,
            'country_code' => $item->country_code,
            'title' => $item->title,
            'content' => $item->content,
            'explanation' => $item->explanation,
            'image_link' => $item->image_link,
            'source_url' => $item->source_url,
            'type' => $item->type === null ? null : [
                'code' => $item->type->code,
                'name' => $item->type->name,
            ],
            'language' => $item->language === null ? null : [
                'code' => $item->language->code,
                'name' => $item->language->name,
                'native_name' => $item->language->native_name,
            ],
            'geographic_area' => $item->geographicArea === null ? null : [
                'code' => $item->geographicArea->code,
                'name' => $item->geographicArea->name,
            ],
            'tags' => $item->tags
                ->map(static fn ($tag): array => [
                    'code' => $tag->code,
                    'name' => $tag->name,
                ])
                ->values()
                ->all(),
        ];
    }

    public function normaliseCode(string $value): string
    {
        return strtoupper(trim($value));
    }

    /**
     * Accepts either an array or a comma-separated string.
     *
     * @return list<string>
     */
    private function normaliseCodeList(mixed $value): array
    {
        return array_values(array_unique(array_filter(
            array_map(
                fn (string $item): string => $this->normaliseCode($item),
                $this->toArray($value)
            ),
            static fn (string $item): bool => $item !== ''
        )));
    }

    /**
     * @return list<string>
     */
    private function normaliseIdList(mixed $value): array
    {
        return array_values(array_unique(array_filter(
            array_map(static fn (string $item): string => trim($item), $this->toArray($value)),
            static fn (string $item): bool => $item !== ''
        )));
    }

    /**
     * @return list<string>
     */
    private function toArray(mixed $value): array
    {
        if (is_array($value)) {
            return array_map(static fn (mixed $item): string => (string) $item, array_values($value));
        }

        if (is_string($value) && trim($value) !== '') {
            return explode(',', $value);
        }

        return [];
    }
}
