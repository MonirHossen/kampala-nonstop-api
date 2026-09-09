<?php

namespace App\Http\Controllers\Api\LocalKnowledge\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\LocalKnowledge\StoreLocalLanguageRequest;
use App\Http\Requests\LocalKnowledge\UpdateLocalLanguageRequest;
use App\Models\LocalLanguage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LocalLanguageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $languages = LocalLanguage::query()->orderBy('name')->get();

        if ($request->filled('country_code')) {
            $countryCode = strtoupper((string) $request->query('country_code'));
            $codes = DB::table('local_language_countries')
                ->where('country_code', $countryCode)
                ->pluck('language_code');

            $languages = $languages->whereIn('code', $codes)->values();
        }

        return response()->json(['data' => $languages]);
    }

    public function store(StoreLocalLanguageRequest $request): JsonResponse
    {
        $data = $request->validated();

        $language = DB::transaction(function () use ($data) {
            $language = LocalLanguage::query()->create($data);
            $this->syncCountries($language, $data);

            return $language;
        });

        return response()->json([
            'data' => $language,
            'country_codes' => $this->countryCodes($language),
        ], 201);
    }

    public function update(UpdateLocalLanguageRequest $request, LocalLanguage $language): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($language, $data) {
            $language->fill($data);
            $language->save();
            $this->syncCountries($language, $data);
        });

        return response()->json([
            'data' => $language->refresh(),
            'country_codes' => $this->countryCodes($language),
        ]);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function syncCountries(LocalLanguage $language, array $data): void
    {
        if (! array_key_exists('country_codes', $data)) {
            return;
        }

        DB::table('local_language_countries')
            ->where('language_code', $language->code)
            ->delete();

        $rows = array_map(
            static fn (string $countryCode): array => [
                'language_code' => $language->code,
                'country_code' => $countryCode,
            ],
            array_values(array_unique($data['country_codes']))
        );

        if ($rows !== []) {
            DB::table('local_language_countries')->insert($rows);
        }
    }

    /**
     * @return list<string>
     */
    private function countryCodes(LocalLanguage $language): array
    {
        return DB::table('local_language_countries')
            ->where('language_code', $language->code)
            ->orderBy('country_code')
            ->pluck('country_code')
            ->all();
    }
}
