<?php

namespace App\Http\Requests\Guide;

use App\Models\TravelGuideTopic;
use Illuminate\Validation\Rule;

class UpdateTravelGuideTopicRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var TravelGuideTopic $topic */
        $topic = $this->route('topic');

        return [
            'code' => [
                'sometimes',
                'string',
                'max:50',
                'regex:/^[A-Z0-9_]+$/',
                Rule::unique('travel_guide_topics', 'code')->ignore($topic->id),
            ],
            'name' => ['sometimes', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'sort_order' => ['sometimes', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
