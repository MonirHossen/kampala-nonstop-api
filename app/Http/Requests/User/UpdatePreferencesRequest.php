<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePreferencesRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('preferred_currency') && is_string($this->input('preferred_currency'))) {
            $value = strtoupper(trim($this->input('preferred_currency')));
            $this->merge([
                'preferred_currency' => $value === '' ? null : $value,
            ]);
        }

        if ($this->has('preferred_language') && is_string($this->input('preferred_language'))) {
            $this->merge([
                'preferred_language' => strtolower(trim($this->input('preferred_language'))),
            ]);
        }

        if ($this->has('distance_unit') && is_string($this->input('distance_unit'))) {
            $this->merge([
                'distance_unit' => strtolower(trim($this->input('distance_unit'))),
            ]);
        }

        if ($this->has('temperature_unit') && is_string($this->input('temperature_unit'))) {
            $this->merge([
                'temperature_unit' => strtolower(trim($this->input('temperature_unit'))),
            ]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'preferred_language' => ['sometimes', 'required', 'string', 'max:10'],
            'preferred_currency' => ['sometimes', 'nullable', 'string', 'size:3', 'regex:/^[A-Z]{3}$/'],
            'distance_unit' => ['sometimes', 'required', Rule::in(['km', 'mi'])],
            'temperature_unit' => ['sometimes', 'required', Rule::in(['c', 'f'])],
        ];
    }
}
