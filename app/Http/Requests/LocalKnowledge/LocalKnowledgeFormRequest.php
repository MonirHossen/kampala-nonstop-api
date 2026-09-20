<?php

namespace App\Http\Requests\LocalKnowledge;

use Illuminate\Foundation\Http\FormRequest;

abstract class LocalKnowledgeFormRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        foreach (['country_code', 'code', 'page_context', 'type', 'geographic_area_code'] as $field) {
            if ($this->has($field) && is_string($this->input($field))) {
                $this->merge([
                    $field => strtoupper(trim($this->input($field))),
                ]);
            }
        }
    }
}
