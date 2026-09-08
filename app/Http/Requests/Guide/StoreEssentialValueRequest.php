<?php

namespace App\Http\Requests\Guide;

use Illuminate\Validation\Rule;

class StoreEssentialValueRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'essential_type_id' => [
                'required',
                'uuid',
                'exists:country_guide_essential_types,id',
                Rule::unique('country_guide_essential_values', 'essential_type_id')
                    ->where(fn ($query) => $query->where('country_code', $this->input('country_code'))),
            ],
            'value_text' => ['required', 'string'],
            'value_data' => ['nullable', 'array'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
