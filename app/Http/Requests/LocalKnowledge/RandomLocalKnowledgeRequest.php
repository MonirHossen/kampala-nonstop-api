<?php

namespace App\Http\Requests\LocalKnowledge;

class RandomLocalKnowledgeRequest extends LocalKnowledgeFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'page_context' => ['sometimes', 'nullable', 'string', 'max:50'],
            'geographic_area_code' => ['sometimes', 'nullable', 'string', 'max:50'],
            'type' => ['sometimes', 'nullable', 'string', 'max:50'],
            'language' => ['sometimes', 'nullable', 'string', 'max:10'],
            'tags' => ['sometimes', 'nullable', 'string', 'max:500'],
            'exclude_ids' => ['sometimes', 'nullable', 'string', 'max:2000'],
            // The service clamps further: 10 for random picks, 100 for listings.
            'limit' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ];
    }
}
