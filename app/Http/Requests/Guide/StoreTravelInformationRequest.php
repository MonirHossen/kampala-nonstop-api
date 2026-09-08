<?php

namespace App\Http\Requests\Guide;

use Illuminate\Validation\Rule;

class StoreTravelInformationRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'info_type_id' => [
                'required',
                'uuid',
                'exists:travel_information_types,id',
                Rule::unique('country_travel_information', 'info_type_id')
                    ->where(fn ($query) => $query->where('country_code', $this->input('country_code'))),
            ],
            'value_text' => ['required', 'string'],
            'value_data' => ['nullable', 'array'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
