<?php

namespace App\Http\Requests\Guide;

use Illuminate\Validation\Rule;

class StoreTravelGuideRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'country_code' => ['required', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'topic_id' => [
                'required',
                'uuid',
                'exists:travel_guide_topics,id',
                Rule::unique('country_travel_guides', 'topic_id')
                    ->where(fn ($query) => $query->where('country_code', $this->input('country_code'))),
            ],
            'content' => ['required', 'string'],
            'image_link' => ['nullable', 'string', 'max:2048'],
            'is_live' => ['sometimes', 'boolean'],
        ];
    }
}
