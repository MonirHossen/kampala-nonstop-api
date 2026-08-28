<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validates the admin waitlist filters shared by the index and export endpoints.
 */
class IndexWaitlistSignupRequest extends FormRequest
{
    public function authorize(): bool
    {
        // TODO: replace with auth + admin role authorisation once authentication is implemented.
        return true;
    }

    protected function prepareForValidation(): void
    {
        $normalised = [];

        if ($this->has('country_code') && is_string($this->input('country_code'))) {
            $normalised['country_code'] = strtoupper(trim($this->input('country_code')));
        }

        // Query strings carry booleans as "true"/"false", which the boolean rule
        // rejects. Unrecognised values are left untouched so validation fails.
        if ($this->has('unsubscribed')) {
            $unsubscribed = filter_var(
                $this->input('unsubscribed'),
                FILTER_VALIDATE_BOOLEAN,
                FILTER_NULL_ON_FAILURE
            );

            if ($unsubscribed !== null) {
                $normalised['unsubscribed'] = $unsubscribed;
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
            'acquisition_source_code' => ['nullable', 'string', 'max:100'],
            'interest_code' => ['nullable', 'string', 'max:100'],
            'unsubscribed' => ['nullable', 'boolean'],
            'country_code' => ['nullable', 'string', 'size:2', 'alpha', 'uppercase'],
            'created_from' => ['nullable', 'date'],
            'created_to' => ['nullable', 'date', 'after_or_equal:created_from'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:200'],
        ];
    }

    /**
     * The filter values actually supplied by the caller.
     *
     * @return array<string, mixed>
     */
    public function filters(): array
    {
        return $this->safe()->only([
            'acquisition_source_code',
            'interest_code',
            'unsubscribed',
            'country_code',
            'created_from',
            'created_to',
        ]);
    }
}
