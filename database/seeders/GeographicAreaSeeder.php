<?php

namespace Database\Seeders;

use App\Models\GeographicArea;
use App\Models\GeographicAreaType;
use Illuminate\Database\Seeder;

/**
 * Minimal geographic hierarchy for Country Guide Region pages.
 *
 * Idempotent: matches on `code`.
 */
class GeographicAreaSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            ['code' => 'COUNTRY', 'name' => 'Country', 'description' => 'National root geography node'],
            ['code' => 'REGION', 'name' => 'Region', 'description' => 'Primary sub-national region'],
        ];

        foreach ($types as $type) {
            GeographicAreaType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'is_active' => true,
                ],
            );
        }

        $countryTypeId = GeographicAreaType::query()->where('code', 'COUNTRY')->value('id');
        $regionTypeId = GeographicAreaType::query()->where('code', 'REGION')->value('id');

        $uganda = GeographicArea::query()->updateOrCreate(
            ['code' => 'UG'],
            [
                'parent_geographic_area_id' => null,
                'geographic_area_type_id' => $countryTypeId,
                'country_code' => 'UG',
                'name' => 'Uganda',
                'is_live' => true,
            ],
        );

        $regions = [
            ['code' => 'UG-CENTRAL', 'name' => 'Central'],
            ['code' => 'UG-WEST', 'name' => 'West'],
            ['code' => 'UG-EAST', 'name' => 'East'],
            ['code' => 'UG-NORTH', 'name' => 'North'],
        ];

        foreach ($regions as $region) {
            GeographicArea::query()->updateOrCreate(
                ['code' => $region['code']],
                [
                    'parent_geographic_area_id' => $uganda->id,
                    'geographic_area_type_id' => $regionTypeId,
                    'country_code' => 'UG',
                    'name' => $region['name'],
                    'is_live' => true,
                ],
            );
        }
    }
}
