<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalised = [];

        if ($this->has('country_of_residence') && is_string($this->input('country_of_residence'))) {
            $value = strtoupper(trim($this->input('country_of_residence')));
            $normalised['country_of_residence'] = $value === '' ? null : $value;
        }

        $this->merge($normalised);
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'nullable', 'string', 'max:20'],
            'first_name' => ['sometimes', 'required', 'string', 'max:100'],
            'middle_name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'last_name' => ['sometimes', 'required', 'string', 'max:100'],
            'gender' => ['sometimes', 'nullable', 'string', 'max:30'],
            'date_of_birth' => ['sometimes', 'nullable', 'date', 'before:today'],
            'phone_number' => ['sometimes', 'nullable', 'string', 'max:32'],
            'city_of_residence' => ['sometimes', 'nullable', 'string', 'max:100'],
            'country_of_residence' => ['sometimes', 'nullable', 'string', 'size:2', 'regex:/^[A-Z]{2}$/'],
            'profile_photo_url' => ['sometimes', 'nullable', 'string', 'max:500', 'url'],
        ];
    }
}
