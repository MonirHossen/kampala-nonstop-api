<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Publishes the project’s existing Kampala catalogue demo listings for Discover.
 * Safe to re-run; does not invent new offering types or taxonomy.
 */
class DiscoverLiveListingsSeeder extends Seeder
{
    public function run(): void
    {
        if (! Schema::hasTable('listings') || ! Schema::hasTable('listing_media')) {
            $this->command?->warn('listings schema missing.');

            return;
        }

        $areaId = DB::table('geographic_areas')->where('name', 'ilike', '%Kampala%')->value('id')
            ?? DB::table('geographic_areas')->orderBy('name')->value('id');

        $types = DB::table('listing_types')->pluck('id', 'code');
        $sub = fn (string $code) => DB::table('subcategories')->where('code', $code)->value('id')
            ?? DB::table('subcategories')->orderBy('name')->value('id');

        if (! $areaId || $types->isEmpty() || ! $sub('WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS')) {
            $this->command?->warn('Missing listing types, subcategories, or Kampala area.');

            return;
        }

        $now = now();
        $demos = [
            [
                'slug' => 'sunset-nile-boat-cruise',
                'listing_type_id' => $types['ACTIVITY'],
                'subcategory_id' => $sub('WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS'),
                'name' => 'Sunset Nile Boat Cruise',
                'summary' => 'Two-hour cruise with drinks and live commentary on Lake Victoria.',
                'description' => 'Watch Kampala’s shoreline soften as the sun drops over Lake Victoria. The crew share local stories while you move between quiet coves and open water.',
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => 'Welcome drink, life jacket, guide commentary.',
                'exclusions' => 'Meals and hotel transfers.',
                'what_to_bring' => 'Light jacket, camera, sun hat.',
                'important_information' => 'Departs from the Ggaba jetty. Arrive 20 minutes early.',
                'booking_instructions' => 'Request preferred dates through Plan My Trip and a host will confirm availability.',
                'media' => [
                    [
                        'url' => 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1400',
                        'caption' => 'Sunset on the water',
                        'alt' => 'Boat on lake at sunset',
                        'is_cover' => true,
                    ],
                ],
            ],
            [
                'slug' => 'kampala-nightlife-pub-crawl',
                'listing_type_id' => $types['EXPERIENCE'],
                'subcategory_id' => $sub('NIGHTLIFE_ENTERTAINMENT_BARS_AND_LOUNGES'),
                'name' => 'Kampala Nightlife Pub Crawl',
                'summary' => 'Guided evening visiting three signature bars in Kololo and Nakasero.',
                'description' => 'A host leads a short evening across three Kampala bars, with a first round at each stop and safe transport between venues.',
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => 'Host, first round at each stop, venue transfers.',
                'what_to_bring' => 'ID, comfortable shoes, cash or card for extras.',
                'important_information' => 'Starts in Kololo. Guests must be 18+.',
                'booking_instructions' => 'Request a Friday or Saturday start time through Plan My Trip.',
                'media' => [
                    [
                        'url' => 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=1400',
                        'caption' => 'Evening social',
                        'alt' => 'Friends at a Kampala bar',
                        'is_cover' => true,
                    ],
                ],
            ],
            [
                'slug' => 'ndere-cultural-centre-show',
                'listing_type_id' => $types['EVENT'],
                'subcategory_id' => $sub('CULTURE_HERITAGE_CULTURAL_CENTRES'),
                'name' => 'Ndere Cultural Centre Show',
                'summary' => 'Weekly dance, music, and storytelling performance.',
                'description' => 'An evening of Ugandan dance, drumming and storytelling at Ndere Cultural Centre, with reserved seating and an optional dinner package.',
                'is_local_gem' => true,
                'is_hot_pick' => false,
                'inclusions' => 'Reserved seating for the show.',
                'exclusions' => 'Dinner package unless selected.',
                'what_to_bring' => 'Camera without flash, light jacket for the evening.',
                'important_information' => 'Saturday performances are the most popular; arrive early for parking.',
                'booking_instructions' => 'Request seats or the dinner package through Plan My Trip.',
                'media' => [
                    [
                        'url' => 'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?w=1400',
                        'caption' => 'Traditional performance',
                        'alt' => 'Dancers on stage',
                        'is_cover' => true,
                    ],
                ],
            ],
            [
                'slug' => 'entebbe-airport-transfer',
                'listing_type_id' => $types['SERVICE'],
                'subcategory_id' => $sub('TRANSPORT_MOBILITY_AIRPORT_TRANSFERS'),
                'name' => 'Entebbe Airport Transfer',
                'summary' => 'Private meet-and-greet transfer between Entebbe International Airport and Kampala hotels.',
                'description' => 'A private driver meets you in arrivals with a name board and takes you between Entebbe International Airport and your Kampala hotel.',
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => 'Meet-and-greet, private vehicle, bottled water.',
                'what_to_bring' => 'Flight number and hotel address.',
                'important_information' => 'Share flight details at least 24 hours before landing.',
                'booking_instructions' => 'Request pickup or drop-off times through Plan My Trip.',
                'media' => [
                    [
                        'url' => 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=1400',
                        'caption' => 'Airport transfer',
                        'alt' => 'Driver assisting a traveller with luggage',
                        'is_cover' => true,
                    ],
                ],
            ],
            [
                'slug' => 'kampala-city-cultural-tour',
                'listing_type_id' => $types['TOUR'],
                'subcategory_id' => $sub('CULTURE_HERITAGE_HISTORICAL_SITES'),
                'name' => 'Kampala City Cultural Tour',
                'summary' => 'A guided half-day through Kampala’s hills, markets and heritage landmarks.',
                'description' => 'Walk and drive across Kampala’s seven hills with a local guide, stopping at markets, viewpoints and cultural landmarks that rarely make the standard itinerary.',
                'is_local_gem' => true,
                'is_hot_pick' => false,
                'inclusions' => 'Guide, hotel pickup in central Kampala, bottled water.',
                'exclusions' => 'Entrance fees and lunch.',
                'what_to_bring' => 'Walking shoes, sun protection, small cash for markets.',
                'important_information' => 'Best started in the morning before the city heats up.',
                'booking_instructions' => 'Request a morning or afternoon departure through Plan My Trip.',
                'media' => [
                    [
                        'url' => 'https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=1400',
                        'caption' => 'City overlook',
                        'alt' => 'Guide with travellers overlooking a green landscape',
                        'is_cover' => true,
                    ],
                ],
            ],
        ];

        foreach ($demos as $demo) {
            $listingId = DB::table('listings')
                ->where('country_code', 'UG')
                ->where('slug', $demo['slug'])
                ->value('id');

            $row = [
                'listing_type_id' => $demo['listing_type_id'],
                'subcategory_id' => $demo['subcategory_id'],
                'name' => $demo['name'],
                'slug' => $demo['slug'],
                'summary' => $demo['summary'],
                'description' => $demo['description'],
                'country_code' => 'UG',
                'geographic_area_id' => $areaId,
                'inclusions' => $demo['inclusions'] ?? null,
                'exclusions' => $demo['exclusions'] ?? null,
                'what_to_bring' => $demo['what_to_bring'] ?? null,
                'important_information' => $demo['important_information'] ?? null,
                'booking_instructions' => $demo['booking_instructions'] ?? null,
                'is_local_gem' => $demo['is_local_gem'],
                'is_hot_pick' => $demo['is_hot_pick'],
                'is_live' => true,
                'updated_at' => $now,
            ];

            if (! $listingId) {
                $listingId = (string) Str::uuid();
                DB::table('listings')->insert([
                    'id' => $listingId,
                    ...$row,
                    'created_at' => $now,
                ]);
            } else {
                DB::table('listings')->where('id', $listingId)->update($row);
            }

            DB::table('listing_media')->where('listing_id', $listingId)->delete();

            foreach ($demo['media'] as $index => $media) {
                DB::table('listing_media')->insert([
                    'id' => (string) Str::uuid(),
                    'listing_id' => $listingId,
                    'media_url' => $media['url'],
                    'media_type' => 'IMAGE',
                    'caption' => $media['caption'] ?? null,
                    'alt_text' => $media['alt'] ?? null,
                    'sort_order' => $index,
                    'is_cover' => (bool) ($media['is_cover'] ?? false),
                    'is_live' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        }

        $this->command?->info('DiscoverLiveListingsSeeder: published '.count($demos).' live listings.');
    }
}
