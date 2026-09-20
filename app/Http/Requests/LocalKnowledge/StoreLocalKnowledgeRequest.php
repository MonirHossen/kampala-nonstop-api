<?php

namespace App\Http\Requests\LocalKnowledge;

class StoreLocalKnowledgeRequest extends LocalKnowledgeFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'local_knowledge_type_id' => ['required', 'uuid', 'exists:local_knowledge_types,id'],
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'geographic_area_id' => ['nullable', 'uuid', 'exists:geographic_areas,id'],
            'local_language_code' => ['nullable', 'string', 'max:10', 'exists:local_languages,code'],
            'title' => ['nullable', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'explanation' => ['nullable', 'string'],
            'image_link' => ['nullable', 'string', 'url', 'max:2048'],
            'source_url' => ['nullable', 'string', 'url', 'max:2048'],
            'is_live' => ['sometimes', 'boolean'],
            'tag_ids' => ['sometimes', 'array'],
            'tag_ids.*' => ['uuid', 'exists:local_knowledge_tags,id'],
            'page_context_ids' => ['sometimes', 'array'],
            'page_context_ids.*' => ['uuid', 'exists:page_contexts,id'],
        ];
    }
}
