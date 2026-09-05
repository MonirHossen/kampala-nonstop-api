<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCitizenshipRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('country_code') && is_string($this->input('country_code'))) {
            $this->merge([
                'country_code' => strtoupper(trim($this->input('country_code'))),
            ]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var \App\Models\UserCitizenship $citizenship */
        $citizenship = $this->route('citizenship');

        return [
            'country_code' => [
                'sometimes',
                'required',
                'string',
                'size:2',
                'regex:/^[A-Z]{2}$/',
                Rule::unique('user_citizenships', 'country_code')
                    ->where(fn ($query) => $query->where('user_id', $this->user()->id))
                    ->ignore($citizenship->id),
            ],
            'is_primary' => ['sometimes', 'boolean'],
        ];
    }
}
