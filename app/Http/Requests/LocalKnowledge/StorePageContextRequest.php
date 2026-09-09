<?php

namespace App\Http\Requests\LocalKnowledge;

use App\Http\Requests\LocalKnowledge\Concerns\ValidatesReferenceData;

class StorePageContextRequest extends LocalKnowledgeFormRequest
{
    use ValidatesReferenceData;

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return $this->referenceRules('page_contexts', required: true);
    }
}
