<?php

namespace App\Http\Requests\Guide;

use App\Models\GeographicArea;
use Illuminate\Validation\Rule;

class UpdateGeographicAreaRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var GeographicArea $geographicArea */
        $geographicArea = $this->route('geographicArea');
        $countryCode = strtoupper((string) $this->input(
            'country_code',
            $geographicArea->country_code
        ));

        return [
            'parent_geographic_area_id' => ['nullable', 'uuid', 'exists:geographic_areas,id'],
            'geographic_area_type_id' => ['sometimes', 'uuid', 'exists:geographic_area_types,id'],
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'code' => [
                'sometimes',
                'string',
                'max:50',
                'regex:/^[A-Z0-9_-]+$/',
                Rule::unique('geographic_areas', 'code')
                    ->where(fn ($query) => $query->where('country_code', $countryCode))
                    ->ignore($geographicArea->id),
            ],
            'name' => ['sometimes', 'string', 'max:255'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
