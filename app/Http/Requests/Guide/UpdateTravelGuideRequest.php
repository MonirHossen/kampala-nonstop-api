<?php

namespace App\Http\Requests\Guide;

use App\Models\CountryTravelGuide;
use Illuminate\Validation\Rule;

class UpdateTravelGuideRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var CountryTravelGuide $travelGuide */
        $travelGuide = $this->route('travelGuide');
        $countryCode = $this->input('country_code', $travelGuide->country_code);

        return [
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'topic_id' => [
                'sometimes',
                'uuid',
                'exists:travel_guide_topics,id',
                Rule::unique('country_travel_guides', 'topic_id')
                    ->where(fn ($query) => $query->where('country_code', $countryCode))
                    ->ignore($travelGuide->id),
            ],
            'content' => ['sometimes', 'string'],
            'image_link' => ['nullable', 'string', 'max:2048'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
