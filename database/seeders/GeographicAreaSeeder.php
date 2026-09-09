<?php

namespace Database\Seeders;

use App\Models\GeographicArea;
use App\Models\GeographicAreaType;
use Illuminate\Database\Seeder;

/**
 * Uganda geographic hierarchy used by Local Knowledge and listings.
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
            ['code' => 'CITY', 'name' => 'City', 'description' => 'City or major urban settlement'],
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
        $cityTypeId = GeographicAreaType::query()->where('code', 'CITY')->value('id');

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

        $regionIds = [];

        foreach ($regions as $region) {
            $saved = GeographicArea::query()->updateOrCreate(
                ['code' => $region['code']],
                [
                    'parent_geographic_area_id' => $uganda->id,
                    'geographic_area_type_id' => $regionTypeId,
                    'country_code' => 'UG',
                    'name' => $region['name'],
                    'is_live' => true,
                ],
            );

            $regionIds[$region['code']] = $saved->id;
        }

        GeographicArea::query()->updateOrCreate(
            ['code' => 'UG-KAMPALA'],
            [
                'parent_geographic_area_id' => $regionIds['UG-CENTRAL'],
                'geographic_area_type_id' => $cityTypeId,
                'country_code' => 'UG',
                'name' => 'Kampala',
                'is_live' => true,
            ],
        );
    }
}
