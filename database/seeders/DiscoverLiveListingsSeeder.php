<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Publishes Kampala catalogue demo listings for Discover.
 * Safe to re-run. Includes options, gallery, tags, and booking windows.
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

        $this->ensureListingTypes();
        $types = DB::table('listing_types')->pluck('id', 'code');
        $sub = fn (string $code) => DB::table('subcategories')->where('code', $code)->value('id')
            ?? DB::table('subcategories')->orderBy('name')->value('id');

        if (! $areaId || $types->isEmpty() || ! $sub('WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS')) {
            $this->command?->warn('Missing listing types, subcategories, or Kampala area.');

            return;
        }

        $tagIds = Schema::hasTable('tags')
            ? DB::table('tags')->where('is_live', true)->pluck('id', 'code')
            : collect();

        $now = now();
        $demos = $this->demos($types, $sub);

        $hotPicks = 0;

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

            if ($demo['is_hot_pick']) {
                $hotPicks++;
            }

            $this->syncRelated($listingId, $demo, $tagIds, $now);
        }

        $this->command?->info(
            'DiscoverLiveListingsSeeder: published '.count($demos)." live listings ({$hotPicks} hot picks)."
        );
    }

    private function ensureListingTypes(): void
    {
        if (! Schema::hasTable('listing_types')) {
            return;
        }

        $now = now();
        $types = [
            ['code' => 'ACTIVITY', 'name' => 'Activity', 'description' => 'A specific thing a traveller can do.'],
            ['code' => 'EVENT', 'name' => 'Event', 'description' => 'A scheduled happening that travellers can attend or book.'],
            ['code' => 'TOUR', 'name' => 'Tour', 'description' => 'A structured journey or route offered to travellers.'],
            ['code' => 'SERVICE', 'name' => 'Service', 'description' => 'A bookable service delivered for a traveller.'],
            ['code' => 'EXPERIENCE', 'name' => 'Experience', 'description' => 'A curated combination or sequence of activities.'],
        ];

        foreach ($types as $type) {
            $exists = DB::table('listing_types')->where('code', $type['code'])->exists();
            if ($exists) {
                DB::table('listing_types')->where('code', $type['code'])->update([
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'is_live' => true,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('listing_types')->insert([
                    'id' => (string) Str::uuid(),
                    'code' => $type['code'],
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'is_live' => true,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        }
    }

    /**
     * @param  \Illuminate\Support\Collection<string, string>  $types
     * @param  callable(string): ?string  $sub
     * @return list<array<string, mixed>>
     */
    private function demos($types, callable $sub): array
    {
        return [
            [
                'slug' => 'sunset-nile-boat-cruise',
                'listing_type_id' => $types['ACTIVITY'],
                'subcategory_id' => $sub('WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS'),
                'name' => 'Sunset Nile Boat Cruise',
                'summary' => 'Two-hour cruise with drinks and live commentary on Lake Victoria.',
                'description' => "Watch Kampala’s shoreline soften as the sun drops over Lake Victoria.\n\nThe crew share local stories while you move between quiet coves and open water. Expect golden light, soft lake air, and a pace that suits first-time visitors and returning travellers alike.",
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => "Welcome drink\nLife jacket\nGuide commentary",
                'exclusions' => "Meals\nHotel transfers",
                'what_to_bring' => "Light jacket\nCamera\nSun hat",
                'important_information' => 'Departs from the Ggaba jetty. Arrive 20 minutes early.',
                'booking_instructions' => 'Request preferred dates through Plan My Trip and a host will confirm availability.',
                'tag_codes' => ['FAMILY_FRIENDLY', 'OUTDOOR_SEATING', 'LOCAL_FAVOURITE'],
                'options' => [
                    ['name' => 'Standard cruise', 'description' => 'Shared boat with welcome drink.', 'duration_minutes' => 120, 'min_participants' => 2, 'max_participants' => 20, 'is_default' => true],
                    ['name' => 'Private charter', 'description' => 'Private boat for your group.', 'duration_minutes' => 180, 'min_participants' => 4, 'max_participants' => 12, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 4, 'start' => '16:00', 'end' => '18:30'],
                    ['day_of_week' => 5, 'start' => '16:00', 'end' => '18:30'],
                    ['day_of_week' => 6, 'start' => '16:00', 'end' => '18:30'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 240,
                    'maximum_advance_days' => 90,
                    'buffer_before_minutes' => 30,
                    'buffer_after_minutes' => 15,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1600', 'caption' => 'Sunset on the water', 'alt' => 'Boat on lake at sunset', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1400', 'caption' => 'Open water', 'alt' => 'Lake shoreline at dusk'],
                    ['url' => 'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=1400', 'caption' => 'Golden hour', 'alt' => 'Sunset reflections on water'],
                ],
            ],
            [
                'slug' => 'kampala-nightlife-pub-crawl',
                'listing_type_id' => $types['EXPERIENCE'],
                'subcategory_id' => $sub('NIGHTLIFE_ENTERTAINMENT_BARS_AND_LOUNGES'),
                'name' => 'Kampala Nightlife Pub Crawl',
                'summary' => 'Guided evening visiting three signature bars in Kololo and Nakasero.',
                'description' => "A host leads a short evening across three Kampala bars, with a first round at each stop and safe transport between venues.\n\nExpect a mix of outdoor terraces, live playlists, and neighbourhood spots that locals actually use on a Friday.",
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => "Host\nFirst round at each stop\nVenue transfers",
                'exclusions' => "Extra drinks\nFood",
                'what_to_bring' => "ID\nComfortable shoes\nCash or card for extras",
                'important_information' => 'Starts in Kololo. Guests must be 18+.',
                'booking_instructions' => 'Request a Friday or Saturday start time through Plan My Trip.',
                'tag_codes' => ['LIVE_MUSIC', 'LGBTQ_FRIENDLY'],
                'options' => [
                    ['name' => 'Classic crawl', 'description' => 'Three venues with a host.', 'duration_minutes' => 240, 'min_participants' => 2, 'max_participants' => 12, 'is_default' => true],
                ],
                'booking_hours' => [
                    ['day_of_week' => 4, 'start' => '19:00', 'end' => '23:30'],
                    ['day_of_week' => 5, 'start' => '19:00', 'end' => '01:00', 'end_day_offset' => 1],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 1440,
                    'maximum_advance_days' => 60,
                    'earliest_arrival_time' => '19:00',
                    'latest_arrival_time' => '20:30',
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=1600', 'caption' => 'Evening social', 'alt' => 'Friends at a Kampala bar', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=1400', 'caption' => 'Bar lights', 'alt' => 'Drinks on a bar counter'],
                ],
            ],
            [
                'slug' => 'ndere-cultural-centre-show',
                'listing_type_id' => $types['EVENT'],
                'subcategory_id' => $sub('CULTURE_HERITAGE_CULTURAL_CENTRES'),
                'name' => 'Ndere Cultural Centre Show',
                'summary' => 'Weekly dance, music, and storytelling performance.',
                'description' => "An evening of Ugandan dance, drumming and storytelling at Ndere Cultural Centre, with reserved seating and an optional dinner package.\n\nThe programme moves through regions and rhythms, so first-timers leave with a clearer sense of Uganda’s cultural map.",
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => "Reserved seating for the show",
                'exclusions' => "Dinner package unless selected",
                'what_to_bring' => "Camera without flash\nLight jacket for the evening",
                'important_information' => 'Saturday performances are the most popular; arrive early for parking.',
                'booking_instructions' => 'Request seats or the dinner package through Plan My Trip.',
                'tag_codes' => ['FAMILY_FRIENDLY', 'LIVE_MUSIC', 'LOCAL_FAVOURITE'],
                'options' => [
                    ['name' => 'Show only', 'description' => 'Reserved seating for the performance.', 'duration_minutes' => 150, 'min_participants' => 1, 'max_participants' => 8, 'is_default' => true],
                    ['name' => 'Show and dinner', 'description' => 'Performance plus dinner package.', 'duration_minutes' => 210, 'min_participants' => 1, 'max_participants' => 8, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 6, 'start' => '18:00', 'end' => '21:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 720,
                    'maximum_advance_days' => 120,
                    'buffer_before_minutes' => 15,
                    'buffer_after_minutes' => 15,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?w=1600', 'caption' => 'Traditional performance', 'alt' => 'Dancers on stage', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1400', 'caption' => 'Live energy', 'alt' => 'Crowd enjoying a live show'],
                ],
            ],
            [
                'slug' => 'entebbe-airport-transfer',
                'listing_type_id' => $types['SERVICE'],
                'subcategory_id' => $sub('TRANSPORT_MOBILITY_AIRPORT_TRANSFERS'),
                'name' => 'Entebbe Airport Transfer',
                'summary' => 'Private meet-and-greet transfer between Entebbe International Airport and Kampala hotels.',
                'description' => "A private driver meets you in arrivals with a name board and takes you between Entebbe International Airport and your Kampala hotel.\n\nUseful after long-haul flights when you want a calm start and a vehicle that already knows the route.",
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => "Meet-and-greet\nPrivate vehicle\nBottled water",
                'exclusions' => "Tips\nExtra stops outside the route",
                'what_to_bring' => "Flight number\nHotel address",
                'important_information' => 'Share flight details at least 24 hours before landing.',
                'booking_instructions' => 'Request pickup or drop-off times through Plan My Trip.',
                'tag_codes' => ['WHEELCHAIR_ACCESSIBLE', 'FAMILY_FRIENDLY'],
                'options' => [
                    ['name' => 'Arrival transfer', 'description' => 'Airport to Kampala hotel.', 'duration_minutes' => 90, 'min_participants' => 1, 'max_participants' => 4, 'is_default' => true],
                    ['name' => 'Departure transfer', 'description' => 'Kampala hotel to airport.', 'duration_minutes' => 90, 'min_participants' => 1, 'max_participants' => 4, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 0, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 1, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 2, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 3, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 4, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 5, 'start' => '05:00', 'end' => '23:00'],
                    ['day_of_week' => 6, 'start' => '05:00', 'end' => '23:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 1440,
                    'maximum_advance_days' => 180,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=1600', 'caption' => 'Airport transfer', 'alt' => 'Driver assisting a traveller with luggage', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1544620341-1adc1baa1ad4?w=1400', 'caption' => 'Road ready', 'alt' => 'Vehicle on an open road'],
                ],
            ],
            [
                'slug' => 'kampala-city-cultural-tour',
                'listing_type_id' => $types['TOUR'],
                'subcategory_id' => $sub('CULTURE_HERITAGE_HISTORICAL_SITES'),
                'name' => 'Kampala City Cultural Tour',
                'summary' => 'A guided half-day through Kampala’s hills, markets and heritage landmarks.',
                'description' => "Walk and drive across Kampala’s seven hills with a local guide, stopping at markets, viewpoints and cultural landmarks that rarely make the standard itinerary.\n\nThe route flexes with traffic and energy levels, but always keeps the story of the city in focus.",
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => "Guide\nHotel pickup in central Kampala\nBottled water",
                'exclusions' => "Entrance fees\nLunch",
                'what_to_bring' => "Walking shoes\nSun protection\nSmall cash for markets",
                'important_information' => 'Best started in the morning before the city heats up.',
                'booking_instructions' => 'Request a morning or afternoon departure through Plan My Trip.',
                'tag_codes' => ['LOCAL_FAVOURITE', 'HIDDEN_GEM', 'FAMILY_FRIENDLY'],
                'options' => [
                    ['name' => 'Morning half-day', 'description' => 'Cooler start with market stops.', 'duration_minutes' => 240, 'min_participants' => 2, 'max_participants' => 8, 'is_default' => true],
                    ['name' => 'Afternoon half-day', 'description' => 'Later start with viewpoint emphasis.', 'duration_minutes' => 240, 'min_participants' => 2, 'max_participants' => 8, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '08:00', 'end' => '16:00'],
                    ['day_of_week' => 2, 'start' => '08:00', 'end' => '16:00'],
                    ['day_of_week' => 3, 'start' => '08:00', 'end' => '16:00'],
                    ['day_of_week' => 4, 'start' => '08:00', 'end' => '16:00'],
                    ['day_of_week' => 5, 'start' => '08:00', 'end' => '16:00'],
                    ['day_of_week' => 6, 'start' => '08:00', 'end' => '14:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 720,
                    'maximum_advance_days' => 90,
                    'buffer_before_minutes' => 15,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=1600', 'caption' => 'City overlook', 'alt' => 'Guide with travellers overlooking a green landscape', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=1400', 'caption' => 'Street life', 'alt' => 'Busy city street scene'],
                    ['url' => 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1400', 'caption' => 'Hills and sky', 'alt' => 'Green hills under open sky'],
                ],
            ],
            [
                'slug' => 'owino-street-food-walk',
                'listing_type_id' => $types['ACTIVITY'],
                'subcategory_id' => $sub('RESTAURANTS_FOOD_STREET_FOOD'),
                'name' => 'Owino Street Food Walk',
                'summary' => 'Taste chapati, rolex and grilled meats with a local food host in downtown Kampala.',
                'description' => "A paced walk through Owino and nearby stalls, sampling everyday Kampala food with stories about how the city eats after work.\n\nPortions are tasting-sized so you can try more without filling up too early.",
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => "Host\nTasting portions at three stops",
                'exclusions' => "Full meals\nSoft drinks beyond tastings",
                'what_to_bring' => "Appetite\nSmall notes for extras\nComfortable shoes",
                'important_information' => 'Runs late afternoon when the stalls are busiest.',
                'booking_instructions' => 'Request a weekday or weekend slot through Plan My Trip.',
                'tag_codes' => ['LOCAL_FAVOURITE', 'HALAL_OPTIONS', 'VEGETARIAN_OPTIONS'],
                'options' => [
                    ['name' => 'Classic tasting walk', 'description' => 'Three tasting stops with a host.', 'duration_minutes' => 150, 'min_participants' => 2, 'max_participants' => 10, 'is_default' => true],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '16:00', 'end' => '19:00'],
                    ['day_of_week' => 3, 'start' => '16:00', 'end' => '19:00'],
                    ['day_of_week' => 5, 'start' => '16:00', 'end' => '19:30'],
                    ['day_of_week' => 6, 'start' => '15:00', 'end' => '18:30'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 480,
                    'maximum_advance_days' => 45,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1600', 'caption' => 'Street food', 'alt' => 'Assorted street food dishes', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=1400', 'caption' => 'Grill stop', 'alt' => 'Food cooking on an open grill'],
                ],
            ],
            [
                'slug' => 'kololo-spa-afternoon',
                'listing_type_id' => $types['SERVICE'],
                'subcategory_id' => $sub('WELLNESS_BEAUTY_SPAS'),
                'name' => 'Kololo Spa Afternoon',
                'summary' => 'Massage and recovery time in a quiet Kololo wellness studio.',
                'description' => "Book a calming afternoon of massage and rest in Kololo, ideal after a long arrival day or before evening plans.\n\nThe studio keeps the schedule unhurried so you can settle in without rushing back out.",
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => "90-minute treatment\nHerbal tea",
                'exclusions' => "Additional treatments\nTransport",
                'what_to_bring' => 'Comfortable clothes for after the session.',
                'important_information' => 'Arrive 10 minutes early to check in.',
                'booking_instructions' => 'Request preferred treatment times through Plan My Trip.',
                'tag_codes' => ['LOCAL_FAVOURITE'],
                'options' => [
                    ['name' => 'Recovery massage', 'description' => '90-minute full-body session.', 'duration_minutes' => 90, 'min_participants' => 1, 'max_participants' => 2, 'is_default' => true],
                    ['name' => 'Couple session', 'description' => 'Side-by-side treatments.', 'duration_minutes' => 90, 'min_participants' => 2, 'max_participants' => 2, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '10:00', 'end' => '18:00'],
                    ['day_of_week' => 2, 'start' => '10:00', 'end' => '18:00'],
                    ['day_of_week' => 3, 'start' => '10:00', 'end' => '18:00'],
                    ['day_of_week' => 4, 'start' => '10:00', 'end' => '18:00'],
                    ['day_of_week' => 5, 'start' => '10:00', 'end' => '18:00'],
                    ['day_of_week' => 6, 'start' => '10:00', 'end' => '16:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 360,
                    'maximum_advance_days' => 60,
                    'buffer_before_minutes' => 10,
                    'buffer_after_minutes' => 20,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1600', 'caption' => 'Spa treatment', 'alt' => 'Spa massage room', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=1400', 'caption' => 'Quiet recovery', 'alt' => 'Calm spa interior'],
                ],
            ],
            [
                'slug' => 'jinja-day-rafting-transfer',
                'listing_type_id' => $types['EXPERIENCE'],
                'subcategory_id' => $sub('SPORTS_RECREATION_ADVENTURE_AND_OUTDOOR_CENTRES'),
                'name' => 'Jinja Day Rafting Escape',
                'summary' => 'Round-trip from Kampala with a full day of Nile rafting near Jinja.',
                'description' => "Leave Kampala early, raft a classic Nile stretch near Jinja, then return the same evening with lunch and transfers included.\n\nGuides brief every rapid, and the day is paced for travellers who want adventure without overnight logistics.",
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => "Kampala transfers\nRafting\nLunch\nSafety briefing",
                'exclusions' => "Photos\nPersonal insurance",
                'what_to_bring' => "Swimwear\nTowel\nChange of clothes\nSunscreen",
                'important_information' => 'Minimum age and swimming confidence apply.',
                'booking_instructions' => 'Request a departure date through Plan My Trip.',
                'tag_codes' => ['FAMILY_FRIENDLY', 'OUTDOOR_SEATING'],
                'options' => [
                    ['name' => 'Full-day rafting', 'description' => 'Transfers, rafting and lunch.', 'duration_minutes' => 600, 'min_participants' => 2, 'max_participants' => 12, 'is_default' => true],
                ],
                'booking_hours' => [
                    ['day_of_week' => 2, 'start' => '06:00', 'end' => '18:00'],
                    ['day_of_week' => 4, 'start' => '06:00', 'end' => '18:00'],
                    ['day_of_week' => 6, 'start' => '06:00', 'end' => '18:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 2880,
                    'maximum_advance_days' => 120,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1530866495561-507c9faab2ed?w=1600', 'caption' => 'River rafting', 'alt' => 'People rafting on a river', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=1400', 'caption' => 'White water', 'alt' => 'Raft in white water rapids'],
                ],
            ],
            [
                'slug' => 'craft-market-morning-tour',
                'listing_type_id' => $types['TOUR'],
                'subcategory_id' => $sub('SHOPPING_MARKETS'),
                'name' => 'Craft Market Morning Tour',
                'summary' => 'Browse Kampala craft markets with a guide who knows the makers.',
                'description' => "A morning among craft stalls and workshops, with tips on fair pricing, textiles, woodwork and gifts worth bringing home.\n\nYour guide introduces trusted makers, helps you compare quality, and keeps the route efficient so you leave with pieces you actually want—not impulse buys from the first stall.\n\nExpect bark cloth, baskets, jewellery, carved wood and contemporary design from Kampala’s creative scene. The pace is unhurried, with time to watch artisans at work and ask questions before you buy.",
                'is_local_gem' => true,
                'is_hot_pick' => true,
                'inclusions' => "Local guide\nMarket introductions to trusted makers\nBargaining and quality tips\nBottled water",
                'exclusions' => "Purchases\nLunch\nHotel pickup outside central Kampala",
                'what_to_bring' => "Cash for shopping\nA tote or soft bag\nComfortable walking shoes\nSun hat",
                'important_information' => "Best on weekday mornings before the crowds build.\nSome workshops prefer cash; ATMs can be busy nearby.\nPhotography is welcome at most stalls—ask before close-ups of makers at work.",
                'booking_instructions' => 'Request a morning start through Plan My Trip. Tell us if you want textiles, jewellery, homeware or a mixed browse so we can shape the route.',
                'tag_codes' => ['LOCAL_FAVOURITE', 'HIDDEN_GEM', 'FAMILY_FRIENDLY', 'WHEELCHAIR_ACCESSIBLE'],
                'options' => [
                    [
                        'name' => 'Classic morning browse',
                        'description' => 'Two markets and a workshop stop with guided introductions.',
                        'duration_minutes' => 180,
                        'min_participants' => 1,
                        'max_participants' => 8,
                        'is_default' => true,
                    ],
                    [
                        'name' => 'Extended maker morning',
                        'description' => 'Adds a second workshop visit and more time for commissions.',
                        'duration_minutes' => 270,
                        'min_participants' => 1,
                        'max_participants' => 6,
                        'is_default' => false,
                    ],
                    [
                        'name' => 'Private shopping host',
                        'description' => 'Private guide focused on your gift list and shipping-friendly pieces.',
                        'duration_minutes' => 210,
                        'min_participants' => 1,
                        'max_participants' => 4,
                        'is_default' => false,
                    ],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '08:30', 'end' => '13:00'],
                    ['day_of_week' => 2, 'start' => '08:30', 'end' => '13:00'],
                    ['day_of_week' => 3, 'start' => '08:30', 'end' => '13:00'],
                    ['day_of_week' => 4, 'start' => '08:30', 'end' => '13:00'],
                    ['day_of_week' => 5, 'start' => '08:30', 'end' => '13:00'],
                    ['day_of_week' => 6, 'start' => '09:00', 'end' => '13:30'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 720,
                    'maximum_advance_days' => 90,
                    'buffer_before_minutes' => 15,
                    'buffer_after_minutes' => 30,
                    'earliest_arrival_time' => '08:15',
                    'latest_arrival_time' => '09:30',
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1555529902-5261145633bf?w=1600', 'caption' => 'Craft market colour', 'alt' => 'Colourful market stall with handmade goods', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1400', 'caption' => 'Textile finds', 'alt' => 'Folded textiles on a shop display'],
                    ['url' => 'https://images.unsplash.com/photo-1461896836934-ffe607ba6851?w=1400', 'caption' => 'Workshop details', 'alt' => 'Hands working on a craft piece'],
                    ['url' => 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=1400', 'caption' => 'Jewellery and finishes', 'alt' => 'Handmade jewellery on a display'],
                ],
            ],
            [
                'slug' => 'live-jazz-on-the-terrace',
                'listing_type_id' => $types['EVENT'],
                'subcategory_id' => $sub('NIGHTLIFE_ENTERTAINMENT_LIVE_MUSIC_VENUES'),
                'name' => 'Live Jazz on the Terrace',
                'summary' => 'An evening of live jazz above the city lights.',
                'description' => "Reserved terrace seating for a rotating jazz night with city views, drinks service and a late start for travellers who want an easy evening out.\n\nTables are held for two hours so you can settle in without queueing for space.",
                'is_local_gem' => false,
                'is_hot_pick' => true,
                'inclusions' => "Reserved seating for two hours",
                'exclusions' => "Food and drinks",
                'what_to_bring' => 'Smart-casual dress.',
                'important_information' => 'Doors open at 7pm; music starts at 8pm.',
                'booking_instructions' => 'Request a table for the next available Friday through Plan My Trip.',
                'tag_codes' => ['LIVE_MUSIC', 'OUTDOOR_SEATING'],
                'options' => [
                    ['name' => 'Terrace table for two', 'description' => 'Reserved seating with city views.', 'duration_minutes' => 120, 'min_participants' => 2, 'max_participants' => 2, 'is_default' => true],
                    ['name' => 'Terrace table for four', 'description' => 'Larger reserved table.', 'duration_minutes' => 120, 'min_participants' => 3, 'max_participants' => 4, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 5, 'start' => '19:00', 'end' => '23:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 1440,
                    'maximum_advance_days' => 45,
                    'earliest_arrival_time' => '19:00',
                    'latest_arrival_time' => '20:00',
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1511192336575-5a79af67a586?w=1600', 'caption' => 'Live jazz', 'alt' => 'Musician playing saxophone on stage', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1415201364774-f6f0bb35beb0?w=1400', 'caption' => 'Night atmosphere', 'alt' => 'Audience at a live music venue'],
                ],
            ],
            [
                'slug' => 'uganda-museum-guided-visit',
                'listing_type_id' => $types['ACTIVITY'],
                'subcategory_id' => $sub('CULTURE_HERITAGE_MUSEUMS'),
                'name' => 'Uganda Museum Guided Visit',
                'summary' => 'A focused guided hour through Uganda Museum highlights.',
                'description' => "Meet a guide at Uganda Museum for a clear walkthrough of key collections, instruments and stories that help frame the rest of your trip.\n\nIdeal if you want context before heading out to markets, parks or cultural centres.",
                'is_local_gem' => true,
                'is_hot_pick' => false,
                'inclusions' => "Guide\nMuseum orientation",
                'exclusions' => "Entrance fees unless requested",
                'what_to_bring' => 'Curiosity and a notebook if you like notes.',
                'important_information' => 'Allow time for traffic around Kitante.',
                'booking_instructions' => 'Request a morning or afternoon slot through Plan My Trip.',
                'tag_codes' => ['FAMILY_FRIENDLY', 'KID_FRIENDLY', 'LOCAL_FAVOURITE'],
                'options' => [
                    ['name' => 'Highlights hour', 'description' => 'Focused guided visit.', 'duration_minutes' => 60, 'min_participants' => 1, 'max_participants' => 10, 'is_default' => true],
                    ['name' => 'Extended collection walk', 'description' => 'Deeper stop with instruments and history.', 'duration_minutes' => 90, 'min_participants' => 1, 'max_participants' => 8, 'is_default' => false],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '09:00', 'end' => '16:00'],
                    ['day_of_week' => 2, 'start' => '09:00', 'end' => '16:00'],
                    ['day_of_week' => 3, 'start' => '09:00', 'end' => '16:00'],
                    ['day_of_week' => 4, 'start' => '09:00', 'end' => '16:00'],
                    ['day_of_week' => 5, 'start' => '09:00', 'end' => '16:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 360,
                    'maximum_advance_days' => 60,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=1600', 'caption' => 'Museum visit', 'alt' => 'Museum interior with exhibits', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1400', 'caption' => 'Collections', 'alt' => 'Museum gallery hallway'],
                ],
            ],
            [
                'slug' => 'mabamba-shoebill-morning',
                'listing_type_id' => $types['TOUR'],
                'subcategory_id' => $sub('WILDLIFE_NATURE_NATIONAL_PARKS_AND_RESERVES'),
                'name' => 'Mabamba Shoebill Morning',
                'summary' => 'Early start from Kampala for a canoe search for the shoebill.',
                'description' => "Leave before dawn for Mabamba Wetland, paddle quiet channels with a bird guide, and return to Kampala by early afternoon.\n\nSightings are likely but never guaranteed—the guide reads the wetland carefully and keeps the morning unhurried.",
                'is_local_gem' => true,
                'is_hot_pick' => false,
                'inclusions' => "Return transfer\nCanoe\nBird guide",
                'exclusions' => "Breakfast\nBinocular hire",
                'what_to_bring' => "Binoculars if you have them\nInsect repellent\nWarm layer",
                'important_information' => 'Sightings are likely but never guaranteed.',
                'booking_instructions' => 'Request an early departure date through Plan My Trip.',
                'tag_codes' => ['HIDDEN_GEM', 'FAMILY_FRIENDLY', 'OUTDOOR_SEATING'],
                'options' => [
                    ['name' => 'Shoebill morning', 'description' => 'Transfer, canoe and bird guide.', 'duration_minutes' => 420, 'min_participants' => 2, 'max_participants' => 6, 'is_default' => true],
                ],
                'booking_hours' => [
                    ['day_of_week' => 1, 'start' => '05:00', 'end' => '13:00'],
                    ['day_of_week' => 3, 'start' => '05:00', 'end' => '13:00'],
                    ['day_of_week' => 5, 'start' => '05:00', 'end' => '13:00'],
                    ['day_of_week' => 6, 'start' => '05:00', 'end' => '13:00'],
                ],
                'booking_rule' => [
                    'minimum_notice_minutes' => 1440,
                    'maximum_advance_days' => 90,
                ],
                'media' => [
                    ['url' => 'https://images.unsplash.com/photo-1551244072-5d12893278ab?w=1600', 'caption' => 'Wetland canoe', 'alt' => 'Canoe on calm wetland water', 'is_cover' => true],
                    ['url' => 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=1400', 'caption' => 'Birding light', 'alt' => 'Bird silhouette against morning sky'],
                ],
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $demo
     * @param  \Illuminate\Support\Collection<string, string>  $tagIds
     */
    private function syncRelated(string $listingId, array $demo, $tagIds, $now): void
    {
        $this->syncBookingHours($listingId, []);
        $this->syncBookingRule($listingId, []);
        $this->syncOptions($listingId, $demo['options'] ?? [], $now);
        $this->syncMedia($listingId, $demo['media'] ?? [], $now);
        $this->syncTags($listingId, $demo['tag_codes'] ?? [], $tagIds, $now);
        $this->syncBookingHours($listingId, $demo['booking_hours'] ?? [], $now);
        $this->syncBookingRule($listingId, $demo['booking_rule'] ?? [], $now);
    }

    /** @param  list<array<string, mixed>>  $options */
    private function syncOptions(string $listingId, array $options, $now): void
    {
        if (! Schema::hasTable('listing_options')) {
            return;
        }

        DB::table('listing_options')->where('listing_id', $listingId)->delete();

        foreach ($options as $opt) {
            DB::table('listing_options')->insert($this->withAudit([
                'id' => (string) Str::uuid(),
                'listing_id' => $listingId,
                'name' => $opt['name'],
                'description' => $opt['description'] ?? null,
                'duration_minutes' => $opt['duration_minutes'] ?? null,
                'min_participants' => $opt['min_participants'] ?? null,
                'max_participants' => $opt['max_participants'] ?? null,
                'is_default' => (bool) ($opt['is_default'] ?? false),
                'is_live' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ], 'listing_options'));
        }
    }

    /** @param  list<array<string, mixed>>  $mediaRows */
    private function syncMedia(string $listingId, array $mediaRows, $now): void
    {
        DB::table('listing_media')->where('listing_id', $listingId)->delete();

        foreach ($mediaRows as $index => $media) {
            DB::table('listing_media')->insert($this->withAudit([
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
            ], 'listing_media'));
        }
    }

    /**
     * @param  list<string>  $tagCodes
     * @param  \Illuminate\Support\Collection<string, string>  $tagIds
     */
    private function syncTags(string $listingId, array $tagCodes, $tagIds, $now): void
    {
        if (! Schema::hasTable('listing_tags')) {
            return;
        }

        DB::table('listing_tags')->where('listing_id', $listingId)->delete();

        foreach ($tagCodes as $code) {
            $tagId = $tagIds[$code] ?? null;
            if (! $tagId) {
                continue;
            }

            DB::table('listing_tags')->insert($this->withAudit([
                'listing_id' => $listingId,
                'tag_id' => $tagId,
                'created_at' => $now,
                'updated_at' => $now,
            ], 'listing_tags'));
        }
    }

    /** @param  list<array<string, mixed>>  $hours */
    private function syncBookingHours(string $listingId, array $hours, $now = null): void
    {
        if (! Schema::hasTable('listing_booking_hours')) {
            return;
        }

        DB::table('listing_booking_hours')->where('listing_id', $listingId)->delete();

        if ($hours === [] || $now === null) {
            return;
        }

        foreach ($hours as $hour) {
            DB::table('listing_booking_hours')->insert($this->withAudit([
                'id' => (string) Str::uuid(),
                'listing_id' => $listingId,
                'listing_option_id' => null,
                'day_of_week' => (int) $hour['day_of_week'],
                'start_time' => $hour['start'],
                'end_time' => $hour['end'],
                'end_day_offset' => (int) ($hour['end_day_offset'] ?? 0),
                'is_live' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ], 'listing_booking_hours'));
        }
    }

    /** @param  array<string, mixed>  $rule */
    private function syncBookingRule(string $listingId, array $rule, $now = null): void
    {
        if (! Schema::hasTable('listing_booking_rules')) {
            return;
        }

        DB::table('listing_booking_rules')->where('listing_id', $listingId)->delete();

        if ($rule === [] || $now === null) {
            return;
        }

        DB::table('listing_booking_rules')->insert($this->withAudit([
            'id' => (string) Str::uuid(),
            'listing_id' => $listingId,
            'listing_option_id' => null,
            'minimum_notice_minutes' => $rule['minimum_notice_minutes'] ?? null,
            'maximum_advance_days' => $rule['maximum_advance_days'] ?? null,
            'buffer_before_minutes' => (int) ($rule['buffer_before_minutes'] ?? 0),
            'buffer_after_minutes' => (int) ($rule['buffer_after_minutes'] ?? 0),
            'earliest_arrival_time' => $rule['earliest_arrival_time'] ?? null,
            'latest_arrival_time' => $rule['latest_arrival_time'] ?? null,
            'created_at' => $now,
            'updated_at' => $now,
        ], 'listing_booking_rules'));
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    private function withAudit(array $row, string $table): array
    {
        if (Schema::hasColumn($table, 'created_by')) {
            $row['created_by'] = 'discover-seeder';
        }
        if (Schema::hasColumn($table, 'updated_by')) {
            $row['updated_by'] = 'discover-seeder';
        }

        return $row;
    }
}
