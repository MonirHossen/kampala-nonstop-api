<?php

namespace App\Http\Requests\Guide;

use App\Models\CountryGuideEssentialType;
use Illuminate\Validation\Rule;

class UpdateEssentialTypeRequest extends GuideFormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var CountryGuideEssentialType $type */
        $type = $this->route('essentialType');

        return [
            'code' => [
                'sometimes',
                'string',
                'max:50',
                'regex:/^[A-Z0-9_]+$/',
                Rule::unique('country_guide_essential_types', 'code')->ignore($type->id),
            ],
            'name' => ['sometimes', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'sort_order' => ['sometimes', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
