<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Model;

/**
 * Generic listing reference row (tags, attributes, amenities tables share the same shape).
 */
class ListingReference extends Model
{
    use HasUuidPrimaryKey;

    /**
     * @param  non-empty-string  $table
     */
    public function __construct(array $attributes = [], string $table = 'tags')
    {
        $this->table = $table;
        parent::__construct($attributes);
    }

    /**
     * @var list<string>
     */
    protected $fillable = [
        'code',
        'name',
        'description',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_live' => 'boolean',
        ];
    }
}
