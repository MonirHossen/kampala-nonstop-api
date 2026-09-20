<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;

class UpdateNotificationPreferencesRequest extends FormRequest
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
            'email_enabled' => ['sometimes', 'required', 'boolean'],
            'sms_enabled' => ['sometimes', 'required', 'boolean'],
            'push_enabled' => ['sometimes', 'required', 'boolean'],
        ];
    }
}
