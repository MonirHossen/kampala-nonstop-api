<?php

namespace App\Http\Requests\User;

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
            'listing_id' => [
                'required',
                'uuid',
                'exists:listings,id',
                Rule::unique('user_favourites', 'listing_id')
                    ->where(fn ($query) => $query->where('user_id', $this->user()->id)),
            ],
            'notes' => ['sometimes', 'nullable', 'string', 'max:500'],
        ];
    }
}
