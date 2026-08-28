<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;

/**
 * Casts a PostgreSQL text[] column to and from a PHP list of strings.
 *
 * @implements CastsAttributes<array<int, string>, array<int, string>>
 */
class PostgresTextArray implements CastsAttributes
{
    /**
     * @return array<int, string>
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): array
    {
        if (is_array($value)) {
            return array_values($value);
        }

        if (! is_string($value)) {
            return [];
        }

        $inner = trim($value, '{}');

        if ($inner === '') {
            return [];
        }

        return array_map(
            static fn (string $item): string => stripcslashes(trim($item, '"')),
            str_getcsv($inner)
        );
    }

    /**
     * @return array<string, string|null>
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): array
    {
        if ($value === null) {
            return [$key => null];
        }

        $quoted = array_map(
            static fn (mixed $item): string => '"'.addcslashes((string) $item, '"\\').'"',
            array_values((array) $value)
        );

        return [$key => '{'.implode(',', $quoted).'}'];
    }
}
