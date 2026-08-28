<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreWaitlistSignupRequest extends FormRequest
{
    /**
     * Default countries of interest when the caller omits the field.
     *
     * @var list<string>
     */
    public const DEFAULT_COUNTRIES_OF_INTEREST = ['UG'];

    public function authorize(): bool
    {
        return true;
    }

    /**
     * Normalise casing and apply the default country list before validation.
     */
    protected function prepareForValidation(): void
    {
        $normalised = [];

        if ($this->has('country_code') && is_string($this->input('country_code'))) {
            $normalised['country_code'] = strtoupper(trim($this->input('country_code')));
        }

        if ($this->has('email') && is_string($this->input('email'))) {
            $normalised['email'] = strtolower(trim($this->input('email')));
        }

        $countries = $this->input('countries_of_interest');

        if (is_array($countries) && $countries !== []) {
            $normalised['countries_of_interest'] = array_values(array_unique(array_map(
                static fn (mixed $code): mixed => is_string($code) ? strtoupper(trim($code)) : $code,
                $countries
            )));
        } else {
            $normalised['countries_of_interest'] = self::DEFAULT_COUNTRIES_OF_INTEREST;
        }

        $this->merge($normalised);
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'max:100'],
            'surname' => ['required', 'string', 'max:100'],
            'email' => ['required', 'string', 'email:rfc', 'max:254'],
            'country_code' => ['required', 'string', 'size:2', 'alpha', 'uppercase'],

            'acquisition_source_code' => [
                'required',
                'string',
                'max:100',
                Rule::exists('acquisition_sources', 'code')->where('active', true),
            ],

            'interest_codes' => ['nullable', 'array'],
            'interest_codes.*' => [
                'string',
                'max:100',
                Rule::exists('interest_types', 'code')->where('active', true),
            ],

            'marketing_consent' => ['required', 'boolean'],

            'countries_of_interest' => ['nullable', 'array'],
            'countries_of_interest.*' => ['string', 'size:2', 'alpha', 'uppercase'],

            'source_details' => ['nullable', 'string'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'acquisition_source_code.exists' => 'The selected acquisition source is not recognised.',
            'interest_codes.*.exists' => 'One or more selected interests are not recognised.',
        ];
    }
}
