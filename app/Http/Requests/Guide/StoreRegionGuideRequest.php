<?php

namespace App\Http\Requests\Guide;

use Illuminate\Validation\Rule;

class StoreRegionGuideRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'geographic_area_id' => [
                'required',
                'uuid',
                'exists:geographic_areas,id',
                Rule::unique('country_region_guides', 'geographic_area_id')
                    ->where(fn ($query) => $query->where('country_code', $this->input('country_code'))),
            ],
            'title' => ['required', 'string', 'max:255'],
            'summary' => ['required', 'string'],
            'image_link' => ['nullable', 'string', 'max:2048'],
            'is_featured' => ['sometimes', 'boolean'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
