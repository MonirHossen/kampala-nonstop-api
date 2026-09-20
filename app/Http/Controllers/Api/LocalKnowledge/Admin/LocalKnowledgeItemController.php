<?php

namespace App\Http\Controllers\Api\LocalKnowledge\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\StoreLocalKnowledgeRequest;
use App\Http\Requests\LocalKnowledge\UpdateLocalKnowledgeRequest;
use App\Models\LocalKnowledge;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LocalKnowledgeItemController extends Controller
{
    private const RELATIONS = ['type', 'geographicArea', 'language', 'tags', 'pageContexts'];

    public function index(Request $request): JsonResponse
    {
        $query = LocalKnowledge::query()->with(self::RELATIONS);

        if ($request->filled('country_code')) {
            $query->where('country_code', strtoupper((string) $request->query('country_code')));
        }

        if ($request->filled('type')) {
            $typeCode = strtoupper((string) $request->query('type'));
            $query->whereHas('type', fn ($type) => $type->where('code', $typeCode));
        }

        if ($request->filled('page_context')) {
            $contextCode = strtoupper((string) $request->query('page_context'));
            $query->whereHas('pageContexts', fn ($context) => $context->where('code', $contextCode));
        }

        if ($request->filled('search')) {
            $term = '%'.$request->query('search').'%';
            $query->where(function ($scoped) use ($term) {
                $scoped->where('title', 'ilike', $term)
                    ->orWhere('content', 'ilike', $term);
            });
        }

        return response()->json([
            'data' => $query->orderByDesc('created_at')->paginate(
                perPage: min(max((int) $request->query('per_page', 25), 1), 100)
            ),
        ]);
    }

    public function show(LocalKnowledge $localKnowledge): JsonResponse
    {
        return response()->json(['data' => $localKnowledge->load(self::RELATIONS)]);
    }

    public function store(StoreLocalKnowledgeRequest $request): JsonResponse
    {
        $data = $request->validated();

        $item = DB::transaction(function () use ($data) {
            $item = LocalKnowledge::query()->create($data);
            $this->syncLinks($item, $data);

            return $item;
        });

        return response()->json(['data' => $item->load(self::RELATIONS)], 201);
    }

    public function update(UpdateLocalKnowledgeRequest $request, LocalKnowledge $localKnowledge): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($localKnowledge, $data) {
            $localKnowledge->fill($data);
            $localKnowledge->save();
            $this->syncLinks($localKnowledge, $data);
        });

        return response()->json(['data' => $localKnowledge->refresh()->load(self::RELATIONS)]);
    }

    public function destroy(LocalKnowledge $localKnowledge): JsonResponse
    {
        $localKnowledge->delete();

        return response()->json(['message' => 'Local Knowledge item deleted.']);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function syncLinks(LocalKnowledge $item, array $data): void
    {
        if (array_key_exists('tag_ids', $data)) {
            $item->tags()->sync($data['tag_ids']);
        }

        if (array_key_exists('page_context_ids', $data)) {
            $item->pageContexts()->sync($data['page_context_ids']);
        }
    }
}
