<?php

namespace App\Http\Requests;

use App\Support\DiscoverCatalogueMap;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ListPublicListingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalised = [];

        foreach (['type', 'interest', 'location'] as $field) {
            if (! $this->has($field) || ! is_string($this->input($field))) {
                continue;
            }

            $value = trim($this->input($field));
            $normalised[$field] = $value === '' ? null : $value;
        }

        if ($this->has('country_code') && is_string($this->input('country_code'))) {
            $normalised['country_code'] = strtoupper(trim($this->input('country_code')));
        }

        if ($this->has('hot_pick')) {
            $hotPick = filter_var(
                $this->input('hot_pick'),
                FILTER_VALIDATE_BOOLEAN,
                FILTER_NULL_ON_FAILURE
            );

            if ($hotPick !== null) {
                $normalised['hot_pick'] = $hotPick;
            }
        }

        if ($normalised !== []) {
            $this->merge($normalised);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'type' => ['sometimes', 'nullable', 'string', Rule::in(DiscoverCatalogueMap::acceptedTypes())],
            'interest' => ['sometimes', 'nullable', 'string', Rule::in(DiscoverCatalogueMap::interests())],
            'location' => ['sometimes', 'nullable', 'string', 'max:100'],
            'hot_pick' => ['sometimes', 'boolean'],
            'page' => ['sometimes', 'integer', 'min:1'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:24'],
            'country_code' => ['sometimes', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
        ];
    }
}
