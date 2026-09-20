<?php

namespace App\Http\Requests\LocalKnowledge;

use App\Http\Requests\LocalKnowledge\Concerns\ValidatesReferenceData;

class UpdateLocalKnowledgeTagRequest extends LocalKnowledgeFormRequest
{
    use ValidatesReferenceData;

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return $this->referenceRules(
            'local_knowledge_tags',
            required: false,
            ignoreId: $this->route('tag')?->getKey(),
        );
    }
}
