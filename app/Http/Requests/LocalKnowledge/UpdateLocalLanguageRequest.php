<?php

namespace App\Http\Requests\LocalKnowledge;

class UpdateLocalLanguageRequest extends LocalKnowledgeFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:100'],
            'native_name' => ['nullable', 'string', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
            'country_codes' => ['sometimes', 'array'],
            'country_codes.*' => ['string', 'size:2', 'regex:/^[A-Z]{2}$/'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if (is_array($this->input('country_codes'))) {
            $this->merge([
                'country_codes' => array_map(
                    static fn (mixed $code): string => strtoupper(trim((string) $code)),
                    $this->input('country_codes')
                ),
            ]);
        }
    }
}
