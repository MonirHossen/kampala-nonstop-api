<?php

namespace App\Models\Concerns;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Support\Str;

trait HasUuidPrimaryKey
{
    use HasUuids;

    /**
     * Generate a new UUIDv7 for the model.
     */
    public function newUniqueId(): string
    {
        return (string) Str::uuid7();
    }
}
