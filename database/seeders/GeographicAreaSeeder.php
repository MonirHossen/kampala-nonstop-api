<?php

namespace Database\Seeders;

use App\Models\GeographicArea;
use App\Models\GeographicAreaType;
use Illuminate\Database\Seeder;

/**
 * Uganda geographic hierarchy from the 2026-09-09 spreadsheet snapshot.
 *
 * Mirrors sql/6_1_kampala_nonstop_geography_tables_data.sql.
 * Idempotent: types match on `code`; areas match on `country_code` + `code`.
 */
class GeographicAreaSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedTypes();
        $this->seedAreas();
    }

    private function seedTypes(): void
    {
        $types = [
            ['code' => 'REGION', 'name' => 'Region', 'description' => 'Primary destination region.'],
            ['code' => 'SUBREGION', 'name' => 'Subregion', 'description' => 'Recognised subdivision within a region.'],
            ['code' => 'CULTURAL_REGION', 'name' => 'Cultural Region', 'description' => 'Area associated with a cultural or historical community.'],
            ['code' => 'CITY', 'name' => 'City', 'description' => 'Recognised city or urban authority.'],
            ['code' => 'NEIGHBOURHOOD', 'name' => 'Neighbourhood', 'description' => 'Named neighbourhood within a city or town.'],
            ['code' => 'LOCALITY', 'name' => 'Locality', 'description' => 'Named local area that is not represented as a city or neighbourhood.'],
            ['code' => 'LAKE', 'name' => 'Lake', 'description' => 'Named lake or country-specific portion of a lake.'],
            ['code' => 'CHANNEL', 'name' => 'Channel', 'description' => 'Named natural water channel.'],
            ['code' => 'MOUNTAIN_RANGE', 'name' => 'Mountain Range', 'description' => 'Named mountain range or country-specific portion of one.'],
            ['code' => 'NATIONAL_PARK', 'name' => 'National Park', 'description' => 'Protected area designated as a national park.'],
            ['code' => 'WATERFALL', 'name' => 'Waterfall', 'description' => 'Named waterfall or falls.'],
            ['code' => 'ARCHIPELAGO', 'name' => 'Archipelago', 'description' => 'Named group of islands.'],
            ['code' => 'GEOGRAPHIC_FEATURE', 'name' => 'Geographic Feature', 'description' => 'Other named geographic feature.'],
            ['code' => 'NATURAL_AREA', 'name' => 'Natural Area', 'description' => 'Named natural landscape or collection of related natural features.'],
        ];

        foreach ($types as $index => $type) {
            GeographicAreaType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'sort_order' => $index,
                    'is_live' => true,
                ],
            );
        }
    }

    private function seedAreas(): void
    {
        // Parent must appear before children. Format: [code, name, typeCode, parentCode|null]
        $areas = [
            ['CENTRAL', 'Central', 'REGION', null],
            ['EAST', 'East', 'REGION', null],
            ['NORTH', 'North', 'REGION', null],
            ['WEST', 'West', 'REGION', null],
            ['SOUTH_WEST', 'South West', 'SUBREGION', 'WEST'],
            ['BUGANDA', 'Buganda', 'CULTURAL_REGION', 'CENTRAL'],
            ['BUSOGA', 'Busoga', 'CULTURAL_REGION', 'EAST'],
            ['TESO', 'Teso', 'CULTURAL_REGION', 'EAST'],
            ['ACHOLILAND', 'Acholiland', 'CULTURAL_REGION', 'NORTH'],
            ['ANKOLE', 'Ankole', 'CULTURAL_REGION', 'SOUTH_WEST'],
            ['KIGEZI', 'Kigezi', 'CULTURAL_REGION', 'SOUTH_WEST'],
            ['KAMPALA', 'Kampala', 'CITY', 'CENTRAL'],
            ['KATWE', 'Katwe', 'NEIGHBOURHOOD', 'KAMPALA'],
            ['WAKALIGA', 'Wakaliga', 'NEIGHBOURHOOD', 'KAMPALA'],
            ['LAKE_VICTORIA', 'Lake Victoria', 'LAKE', null],
            ['SSESE_ISLANDS', 'Ssese Islands', 'ARCHIPELAGO', 'LAKE_VICTORIA'],
            ['LAKE_ALBERT', 'Lake Albert', 'LAKE', 'WEST'],
            ['LAKE_EDWARD', 'Lake Edward', 'LAKE', 'WEST'],
            ['LAKE_GEORGE', 'Lake George', 'LAKE', 'WEST'],
            ['LAKE_BUNYONYI', 'Lake Bunyonyi', 'LAKE', 'SOUTH_WEST'],
            ['LAKE_MUTANDA', 'Lake Mutanda', 'LAKE', 'SOUTH_WEST'],
            ['RWENZORI_MOUNTAINS', 'Rwenzori Mountains', 'MOUNTAIN_RANGE', 'WEST'],
            ['VIRUNGA_MOUNTAINS', 'Virunga Mountains', 'MOUNTAIN_RANGE', 'SOUTH_WEST'],
            ['QUEEN_ELIZABETH_NATIONAL_PARK', 'Queen Elizabeth National Park', 'NATIONAL_PARK', 'WEST'],
            ['BWINDI', 'Bwindi Impenetrable National Park', 'NATIONAL_PARK', 'SOUTH_WEST'],
            ['MGAHINGA', 'Mgahinga Gorilla National Park', 'NATIONAL_PARK', 'SOUTH_WEST'],
            ['MURCHISON_FALLS_NATIONAL_PARK', 'Murchison Falls National Park', 'NATIONAL_PARK', null],
            ['ISHASHA', 'Ishasha', 'LOCALITY', 'QUEEN_ELIZABETH_NATIONAL_PARK'],
            ['KAZINGA_CHANNEL', 'Kazinga Channel', 'CHANNEL', 'QUEEN_ELIZABETH_NATIONAL_PARK'],
            ['MURCHISON_FALLS', 'Murchison Falls', 'WATERFALL', 'MURCHISON_FALLS_NATIONAL_PARK'],
            ['EQUATOR', 'Equator', 'GEOGRAPHIC_FEATURE', null],
            ['CRATER_LAKES', 'Crater Lakes', 'NATURAL_AREA', 'WEST'],
        ];

        $typeIds = GeographicAreaType::query()->pluck('id', 'code');
        $areaIds = [];

        foreach ($areas as [$code, $name, $typeCode, $parentCode]) {
            $parentId = $parentCode === null ? null : ($areaIds[$parentCode] ?? null);

            $saved = GeographicArea::query()->updateOrCreate(
                ['country_code' => 'UG', 'code' => $code],
                [
                    'parent_geographic_area_id' => $parentId,
                    'geographic_area_type_id' => $typeIds[$typeCode],
                    'name' => $name,
                    'is_live' => true,
                ],
            );

            $areaIds[$code] = $saved->id;
        }
    }
}
