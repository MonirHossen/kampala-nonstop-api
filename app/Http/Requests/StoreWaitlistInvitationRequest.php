<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreWaitlistInvitationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('invitee_email') && is_string($this->input('invitee_email'))) {
            $this->merge([
                'invitee_email' => strtolower(trim($this->input('invitee_email'))),
            ]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'inviter_id' => [
                'required',
                'uuid',
                Rule::exists('waitlist_signups', 'id'),
            ],
            'invitee_email' => ['required', 'string', 'email:rfc', 'max:254'],
        ];
    }
}
