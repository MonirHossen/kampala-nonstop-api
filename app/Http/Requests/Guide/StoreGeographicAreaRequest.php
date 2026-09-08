<?php

namespace App\Http\Requests\Guide;

class StoreGeographicAreaRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'parent_geographic_area_id' => ['nullable', 'uuid', 'exists:geographic_areas,id'],
            'geographic_area_type_id' => ['required', 'uuid', 'exists:geographic_area_types,id'],
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'code' => ['required', 'string', 'max:50', 'regex:/^[A-Z0-9_-]+$/', 'unique:geographic_areas,code'],
            'name' => ['required', 'string', 'max:255'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
