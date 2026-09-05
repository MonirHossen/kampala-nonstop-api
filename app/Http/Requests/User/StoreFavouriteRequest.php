<?php

namespace App\Http\Requests\User;

use App\Models\UserFavourite;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreFavouriteRequest extends FormRequest
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
            'favouritable_type' => ['required', 'string', Rule::in(UserFavourite::TYPES)],
            'favouritable_id' => [
                'required',
                'uuid',
                Rule::unique('user_favourites', 'favouritable_id')
                    ->where(fn ($query) => $query
                        ->where('user_id', $this->user()->id)
                        ->where('favouritable_type', $this->input('favouritable_type'))),
            ],
            'notes' => ['sometimes', 'nullable', 'string', 'max:500'],
        ];
    }
}
