<?php

namespace App\Http\Requests\LocalKnowledge;

use Illuminate\Validation\Rule;

class StoreLocalLanguageRequest extends LocalKnowledgeFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'code' => [
                'required',
                'string',
                'max:10',
                Rule::unique('local_languages', 'code'),
            ],
            'name' => ['required', 'string', 'max:100'],
            'native_name' => ['nullable', 'string', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
            'country_codes' => ['sometimes', 'array'],
            'country_codes.*' => ['string', 'size:2', 'regex:/^[A-Z]{2}$/'],
        ];
    }

    /**
     * Language codes are BCP 47-style and stay lowercase, unlike the
     * uppercase reference codes normalised by the parent request.
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('code') && is_string($this->input('code'))) {
            $this->merge(['code' => strtolower(trim($this->input('code')))]);
        }

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
