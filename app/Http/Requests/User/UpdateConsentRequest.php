<?php

namespace App\Http\Requests\User;

use App\Models\UserConsent;
use Illuminate\Foundation\Http\FormRequest;

class UpdateConsentRequest extends FormRequest
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
            'is_granted' => ['required', 'boolean'],
            'policy_version' => ['sometimes', 'nullable', 'string', 'max:20'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $type = (string) $this->route('type');

            if (! in_array($type, UserConsent::TYPES, true)) {
                $validator->errors()->add('type', 'The consent type is invalid.');
            }
        });
    }
}
