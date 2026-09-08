<?php

namespace App\Http\Requests\Guide;

use Illuminate\Foundation\Http\FormRequest;

abstract class GuideFormRequest extends FormRequest
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

        if ($this->has('code') && is_string($this->input('code'))) {
            $this->merge([
                'code' => strtoupper(trim($this->input('code'))),
            ]);
        }
    }
}
