<?php

namespace Database\Seeders;

use App\Models\AcquisitionSource;
use App\Models\InterestType;
use Illuminate\Database\Seeder;

/**
 * Starter reference data for FR-001 Waitlist & Acquisition.
 *
 * Idempotent: re-running matches on `code` and updates in place.
 * Legacy interest codes not in the active list are deactivated.
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
            ['code' => 'UNAA_DENVER_2026', 'name' => 'UNAA Denver 2026', 'type' => 'event'],
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
            [
                'code' => 'culture_heritage',
                'name' => 'Culture & Heritage',
                'description' => 'Buganda drums, barkcloth, palaces and the stories behind them.',
            ],
            [
                'code' => 'food_local_life',
                'name' => 'Food & Local Life',
                'description' => 'Rolex stands, fish at the landing site, kitchens with no signage.',
            ],
            [
                'code' => 'music_nightlife_entertainment',
                'name' => 'Music, Nightlife & Entertainment',
                'description' => "From live band nights to the city's loudest, longest weekends.",
            ],
            [
                'code' => 'nature_wildlife',
                'name' => 'Nature & Wildlife',
                'description' => 'Crested cranes, misty hills and mornings on Lake Victoria.',
            ],
            [
                'code' => 'adventure_outdoors',
                'name' => 'Adventure & Outdoors',
                'description' => 'The Nile at Jinja, hikes, quad trails and long weekends out.',
            ],
            [
                'code' => 'events_festivals',
                'name' => 'Events & Festivals',
                'description' => 'Concerts, street festivals and the nights the city plans around.',
            ],
            [
                'code' => 'wellness_relaxation',
                'name' => 'Wellness & Relaxation',
                'description' => 'Slow lakeside afternoons, gardens and quiet corners of the city.',
            ],
            [
                'code' => 'sports_recreation',
                'name' => 'Sports & Recreation',
                'description' => 'Match days, five-a-side, padel, boxing gyms and rugby afternoons.',
            ],
            [
                'code' => 'other',
                'name' => 'Other',
                'description' => 'Something else entirely — tell us on the waitlist and we will shape it with you.',
            ],
        ];

        $activeCodes = [];

        foreach ($interests as $index => $interest) {
            $activeCodes[] = $interest['code'];

            InterestType::query()->updateOrCreate(
                ['code' => $interest['code']],
                [
                    'name' => $interest['name'],
                    'description' => $interest['description'],
                    'display_order' => ($index + 1) * 10,
                    'active' => true,
                ],
            );
        }

        InterestType::query()
            ->whereNotIn('code', $activeCodes)
            ->update(['active' => false]);
    }
}
