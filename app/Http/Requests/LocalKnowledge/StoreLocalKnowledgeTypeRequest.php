<?php

namespace App\Http\Requests\LocalKnowledge;

use App\Http\Requests\LocalKnowledge\Concerns\ValidatesReferenceData;

class StoreLocalKnowledgeTypeRequest extends LocalKnowledgeFormRequest
{
    use ValidatesReferenceData;

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return $this->referenceRules('local_knowledge_types', required: true);
    }
}
