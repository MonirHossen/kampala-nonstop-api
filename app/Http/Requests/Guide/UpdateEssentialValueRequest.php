<?php

namespace App\Http\Requests\Guide;

use App\Models\CountryGuideEssentialValue;
use Illuminate\Validation\Rule;

class UpdateEssentialValueRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var CountryGuideEssentialValue $value */
        $value = $this->route('essentialValue');
        $countryCode = $this->input('country_code', $value->country_code);

        return [
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'essential_type_id' => [
                'sometimes',
                'uuid',
                'exists:country_guide_essential_types,id',
                Rule::unique('country_guide_essential_values', 'essential_type_id')
                    ->where(fn ($query) => $query->where('country_code', $countryCode))
                    ->ignore($value->id),
            ],
            'value_text' => ['sometimes', 'string'],
            'value_data' => ['nullable', 'array'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
