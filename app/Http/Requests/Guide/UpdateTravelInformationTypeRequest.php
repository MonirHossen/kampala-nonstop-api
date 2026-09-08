<?php

namespace App\Http\Requests\Guide;

use App\Models\TravelInformationType;
use Illuminate\Validation\Rule;

class UpdateTravelInformationTypeRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var TravelInformationType $infoType */
        $infoType = $this->route('infoType');

        return [
            'code' => [
                'sometimes',
                'string',
                'max:50',
                'regex:/^[A-Z0-9_]+$/',
                Rule::unique('travel_information_types', 'code')->ignore($infoType->id),
            ],
            'name' => ['sometimes', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'sort_order' => ['sometimes', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
