<?php

namespace App\Http\Requests\Guide;

use App\Models\CountryRegionGuide;
use Illuminate\Validation\Rule;

class UpdateRegionGuideRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var CountryRegionGuide $regionGuide */
        $regionGuide = $this->route('regionGuide');
        $countryCode = $this->input('country_code', $regionGuide->country_code);

        return [
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'geographic_area_id' => [
                'sometimes',
                'uuid',
                'exists:geographic_areas,id',
                Rule::unique('country_region_guides', 'geographic_area_id')
                    ->where(fn ($query) => $query->where('country_code', $countryCode))
                    ->ignore($regionGuide->id),
            ],
            'title' => ['sometimes', 'string', 'max:255'],
            'summary' => ['sometimes', 'string'],
            'image_link' => ['nullable', 'string', 'max:2048'],
            'is_featured' => ['sometimes', 'boolean'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
