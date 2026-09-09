<?php

namespace App\Http\Requests\LocalKnowledge\Concerns;

use Illuminate\Validation\Rule;

/**
 * Shared rules for the code/name/description reference tables:
 * local_knowledge_types, local_knowledge_tags and page_contexts.
 */
trait ValidatesReferenceData
{
    /**
     * @return array<string, mixed>
     */
    protected function referenceRules(string $table, bool $required, ?string $ignoreId = null): array
    {
        $presence = $required ? 'required' : 'sometimes';

        $unique = Rule::unique($table, 'code');

        if ($ignoreId !== null) {
            $unique->ignore($ignoreId);
        }

        return [
            'code' => [$presence, 'string', 'max:50', 'regex:/^[A-Z0-9_]+$/', $unique],
            'name' => [$presence, 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
