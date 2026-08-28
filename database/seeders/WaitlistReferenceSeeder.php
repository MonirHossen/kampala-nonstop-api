<?php

namespace Database\Seeders;

use App\Models\AcquisitionSource;
use App\Models\InterestType;
use Illuminate\Database\Seeder;

/**
 * Starter reference data for FR-001 Waitlist & Acquisition.
 *
 * Idempotent: re-running matches on `code` and updates in place.
 */
class WaitlistReferenceSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedAcquisitionSources();
        $this->seedInterestTypes();
    }

    private function seedAcquisitionSources(): void
    {
        $sources = [
            ['code' => 'INSTAGRAM', 'name' => 'Instagram', 'type' => 'social'],
            ['code' => 'FACEBOOK', 'name' => 'Facebook', 'type' => 'social'],
            ['code' => 'GOOGLE_SEARCH', 'name' => 'Google Search', 'type' => 'organic'],
            ['code' => 'REFERRAL', 'name' => 'Referral from a friend', 'type' => 'other'],
            ['code' => 'EVENT', 'name' => 'Event', 'type' => 'event'],
            ['code' => 'PARTNER', 'name' => 'Partner', 'type' => 'partner'],
            ['code' => 'DIRECT', 'name' => 'Direct', 'type' => 'direct'],
            ['code' => 'OTHER', 'name' => 'Other', 'type' => 'other'],
        ];

        foreach ($sources as $source) {
            AcquisitionSource::query()->updateOrCreate(
                ['code' => $source['code']],
                [
                    'name' => $source['name'],
                    'type' => $source['type'],
                    'active' => true,
                ],
            );
        }
    }

    private function seedInterestTypes(): void
    {
        $interests = [
            ['code' => 'NIGHTLIFE', 'name' => 'Nightlife'],
            ['code' => 'FOOD', 'name' => 'Food & Drink'],
            ['code' => 'MUSIC', 'name' => 'Music'],
            ['code' => 'CULTURE', 'name' => 'Culture & Heritage'],
            ['code' => 'ADVENTURE', 'name' => 'Adventure'],
            ['code' => 'NATURE', 'name' => 'Nature & Wildlife'],
            ['code' => 'SHOPPING', 'name' => 'Shopping'],
            ['code' => 'LUXURY', 'name' => 'Luxury'],
            ['code' => 'SPORTS', 'name' => 'Sports'],
            ['code' => 'FAMILY', 'name' => 'Family'],
        ];

        foreach ($interests as $index => $interest) {
            InterestType::query()->updateOrCreate(
                ['code' => $interest['code']],
                [
                    'name' => $interest['name'],
                    'display_order' => ($index + 1) * 10,
                    'active' => true,
                ],
            );
        }
    }
}
