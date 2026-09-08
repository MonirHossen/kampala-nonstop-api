<?php

namespace App\Http\Requests\Guide;

use App\Models\CountryTravelInformation;
use Illuminate\Validation\Rule;

class UpdateTravelInformationRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var CountryTravelInformation $travelInformation */
        $travelInformation = $this->route('travelInformation');
        $countryCode = $this->input('country_code', $travelInformation->country_code);

        return [
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'info_type_id' => [
                'sometimes',
                'uuid',
                'exists:travel_information_types,id',
                Rule::unique('country_travel_information', 'info_type_id')
                    ->where(fn ($query) => $query->where('country_code', $countryCode))
                    ->ignore($travelInformation->id),
            ],
            'value_text' => ['sometimes', 'string'],
            'value_data' => ['nullable', 'array'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
