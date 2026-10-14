<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreTripCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'user_id' => ['sometimes', 'nullable', 'uuid', 'exists:users,id'],
            'first_name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'middle_name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'last_name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'date_of_birth' => ['sometimes', 'nullable', 'date'],
            'country_of_residence' => ['sometimes', 'nullable', 'string', 'size:2'],
            'is_primary_customer' => ['sometimes', 'boolean'],
            'notes' => ['sometimes', 'nullable', 'string'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            $hasUser = filled($this->input('user_id'));
            $hasNames = filled($this->input('first_name')) && filled($this->input('last_name'));

            if (! $hasUser && ! $hasNames) {
                $validator->errors()->add(
                    'first_name',
                    'Provide a registered user_id or both first_name and last_name.'
                );
            }
        });
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('country_of_residence') && $this->input('country_of_residence') !== null) {
            $this->merge([
                'country_of_residence' => strtoupper((string) $this->input('country_of_residence')),
            ]);
        }
    }
}
