<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\GeographicArea;
use App\Models\GeographicAreaType;
use App\Models\Listing;
use App\Models\ListingBookingHour;
use App\Models\ListingBookingRule;
use App\Models\ListingMedia;
use App\Models\ListingOption;
use App\Models\ListingType;
use App\Models\Subcategory;
use App\Models\Tag;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class PublicListingCatalogueTest extends TestCase
{
    use RefreshDatabase;

    private Listing $liveActivity;

    private Listing $draftActivity;

    private Listing $liveEvent;

    protected function setUp(): void
    {
        parent::setUp();

        $this->ensureListingTables();
        $this->seedCatalogue();
    }

    public function test_index_returns_only_live_listings_and_hides_drafts(): void
    {
        $response = $this->getJson('/api/v1/listings');

        $response->assertOk()
            ->assertJsonPath('meta.total', 2)
            ->assertJsonMissing(['slug' => 'draft-food-walk']);

        $slugs = collect($response->json('data'))->pluck('slug')->all();
        $this->assertEqualsCanonicalizing(
            ['nile-street-food-walk', 'ndere-cultural-night'],
            $slugs
        );

        $food = collect($response->json('data'))->firstWhere('slug', 'nile-street-food-walk');
        $this->assertSame('ACTIVITY', $food['listing_type_code']);
        $this->assertSame('Activity', $food['listing_type_name']);
        $this->assertSame('Restaurants & Food', $food['category_name']);
        $this->assertSame('Kololo', $food['geographic_area_name']);
        $this->assertTrue($food['is_hot_pick']);
        $this->assertTrue($food['is_local_gem']);
        $this->assertSame('https://cdn.example.test/food-cover.jpg', $food['cover']['url']);
        $this->assertSame('Chapati on the grill', $food['cover']['alt_text']);
    }

    public function test_type_interest_location_and_hot_pick_filters(): void
    {
        $this->getJson('/api/v1/listings?type=Activities')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'nile-street-food-walk');

        $this->getJson('/api/v1/listings?type=EVENT')
            ->assertOk()
            ->assertJsonPath('data.0.slug', 'ndere-cultural-night');

        $this->getJson('/api/v1/listings?interest='.urlencode('Food & Local Life'))
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'nile-street-food-walk');

        $this->getJson('/api/v1/listings?interest='.urlencode('Events & Festivals'))
            ->assertOk()
            ->assertJsonPath('data.0.slug', 'ndere-cultural-night');

        $this->getJson('/api/v1/listings?interest='.urlencode('Adventure & Outdoors'))
            ->assertOk()
            ->assertJsonPath('meta.total', 0);

        $this->getJson('/api/v1/listings?location=Kampala')
            ->assertOk()
            ->assertJsonPath('meta.total', 2);

        $this->getJson('/api/v1/listings?location=Kololo')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'nile-street-food-walk');

        $this->getJson('/api/v1/listings?hot_pick=1')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'nile-street-food-walk');

        $this->getJson('/api/v1/listings?type=Tours&interest='.urlencode('Events & Festivals'))
            ->assertOk()
            ->assertJsonPath('meta.total', 0);
    }

    public function test_tag_filter_returns_only_matching_listings(): void
    {
        $nyenge = Tag::query()->create([
            'code' => 'NYENGE_NYEGE',
            'name' => 'Nyenge Nyenge',
            'is_live' => true,
        ]);

        DB::table('listing_tags')->insert([
            'listing_id' => $this->liveEvent->id,
            'tag_id' => $nyenge->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->getJson('/api/v1/listings?tag=NYENGE_NYEGE')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'ndere-cultural-night');

        $this->getJson('/api/v1/listings?tag=LOCAL_FAVOURITE')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.slug', 'nile-street-food-walk');

        $this->getJson('/api/v1/listings?tag=MISSING_TAG')
            ->assertOk()
            ->assertJsonPath('meta.total', 0);
    }

    public function test_show_returns_live_detail_and_hides_drafts_and_offline_media(): void
    {
        $this->getJson('/api/v1/listings/nile-street-food-walk')
            ->assertOk()
            ->assertJsonPath('data.slug', 'nile-street-food-walk')
            ->assertJsonPath('data.description', 'A walk through evening chapati stalls.')
            ->assertJsonPath('data.inclusions', 'Guide and water')
            ->assertJsonPath('data.gallery.0.url', 'https://cdn.example.test/food-cover.jpg')
            ->assertJsonPath('data.gallery.1.url', 'https://cdn.example.test/food-stall.jpg')
            ->assertJsonPath('data.options.0.name', 'Evening walk')
            ->assertJsonPath('data.options.0.duration_minutes', 120)
            ->assertJsonPath('data.options.0.is_default', true)
            ->assertJsonPath('data.tags.0.code', 'LOCAL_FAVOURITE')
            ->assertJsonPath('data.tags.0.name', 'Local favourite')
            ->assertJsonPath('data.booking_hours.0.day_of_week', 5)
            ->assertJsonPath('data.booking_hours.0.day_name', 'Friday')
            ->assertJsonPath('data.booking_hours.0.start_time', '17:00')
            ->assertJsonPath('data.booking_rule.minimum_notice_minutes', 360)
            ->assertJsonMissing(['url' => 'https://cdn.example.test/hidden.jpg']);

        $this->assertCount(2, $this->getJson('/api/v1/listings/nile-street-food-walk')->json('data.gallery'));

        $this->getJson('/api/v1/listings/draft-food-walk')
            ->assertNotFound();

        $this->getJson('/api/v1/listings/missing-listing')
            ->assertNotFound();
    }

    private function ensureListingTables(): void
    {
        if (Schema::hasTable('listings')) {
            return;
        }

        $sql = (string) file_get_contents(
            base_path('sql/implemented/8_kampala_nonstop_listings_schema.sql')
        );
        $sql = preg_replace('/^\xEF\xBB\xBF/', '', $sql) ?? $sql;
        $sql = preg_replace('/^--.*$/m', '', $sql) ?? $sql;
        $sql = preg_replace('/\b(BEGIN|COMMIT)\s*;/i', '', $sql) ?? $sql;
        $sql = preg_replace("/COMMENT ON COLUMN[\\s\\S]*?';/i", '', $sql) ?? $sql;

        foreach (array_filter(array_map('trim', explode(';', $sql))) as $statement) {
            DB::unprepared($statement);
        }
    }

    private function seedCatalogue(): void
    {
        $food = Category::query()->create([
            'code' => 'RESTAURANTS_FOOD',
            'name' => 'Restaurants & Food',
            'is_live' => true,
        ]);

        $streetFood = Subcategory::query()->create([
            'category_id' => $food->id,
            'code' => 'RESTAURANTS_FOOD_STREET_FOOD',
            'name' => 'Street Food',
            'is_live' => true,
        ]);

        $sports = Category::query()->create([
            'code' => 'SPORTS_RECREATION',
            'name' => 'Sports & Recreation',
            'is_live' => true,
        ]);

        Subcategory::query()->create([
            'category_id' => $sports->id,
            'code' => 'SPORTS_RECREATION_ADVENTURE_AND_OUTDOOR_CENTRES',
            'name' => 'Adventure & Outdoor Centres',
            'is_live' => true,
        ]);

        $culture = Category::query()->create([
            'code' => 'CULTURE_HERITAGE',
            'name' => 'Culture & Heritage',
            'is_live' => true,
        ]);

        $culturalCentres = Subcategory::query()->create([
            'category_id' => $culture->id,
            'code' => 'CULTURE_HERITAGE_CULTURAL_CENTRES',
            'name' => 'Cultural Centres',
            'is_live' => true,
        ]);

        $city = GeographicAreaType::query()->create([
            'code' => 'CITY',
            'name' => 'City',
            'sort_order' => 1,
            'is_live' => true,
        ]);

        $neighbourhood = GeographicAreaType::query()->create([
            'code' => 'NEIGHBOURHOOD',
            'name' => 'Neighbourhood',
            'sort_order' => 2,
            'is_live' => true,
        ]);

        $kampala = GeographicArea::query()->create([
            'geographic_area_type_id' => $city->id,
            'country_code' => 'UG',
            'code' => 'KAMPALA',
            'name' => 'Kampala',
            'is_live' => true,
        ]);

        $kololo = GeographicArea::query()->create([
            'parent_geographic_area_id' => $kampala->id,
            'geographic_area_type_id' => $neighbourhood->id,
            'country_code' => 'UG',
            'code' => 'KOLOLO',
            'name' => 'Kololo',
            'is_live' => true,
        ]);

        $activity = ListingType::query()->create([
            'code' => 'ACTIVITY',
            'name' => 'Activity',
            'is_live' => true,
        ]);

        $event = ListingType::query()->create([
            'code' => 'EVENT',
            'name' => 'Event',
            'is_live' => true,
        ]);

        $this->liveActivity = Listing::query()->create([
            'listing_type_id' => $activity->id,
            'subcategory_id' => $streetFood->id,
            'name' => 'Nile Street Food Walk',
            'slug' => 'nile-street-food-walk',
            'summary' => 'Evening stalls along the ridge.',
            'description' => 'A walk through evening chapati stalls.',
            'country_code' => 'UG',
            'geographic_area_id' => $kololo->id,
            'inclusions' => 'Guide and water',
            'exclusions' => 'Dinner',
            'what_to_bring' => 'Comfortable shoes',
            'important_information' => 'Starts at dusk',
            'booking_instructions' => 'Request a time with the concierge.',
            'is_local_gem' => true,
            'is_hot_pick' => true,
            'is_live' => true,
        ]);

        ListingMedia::query()->create([
            'listing_id' => $this->liveActivity->id,
            'media_url' => 'https://cdn.example.test/hidden.jpg',
            'media_type' => 'IMAGE',
            'alt_text' => 'Hidden frame',
            'sort_order' => 0,
            'is_cover' => false,
            'is_live' => false,
        ]);

        ListingMedia::query()->create([
            'listing_id' => $this->liveActivity->id,
            'media_url' => 'https://cdn.example.test/food-cover.jpg',
            'media_type' => 'IMAGE',
            'alt_text' => 'Chapati on the grill',
            'sort_order' => 1,
            'is_cover' => true,
            'is_live' => true,
        ]);

        ListingMedia::query()->create([
            'listing_id' => $this->liveActivity->id,
            'media_url' => 'https://cdn.example.test/food-stall.jpg',
            'media_type' => 'IMAGE',
            'alt_text' => 'Street stall',
            'caption' => 'Kololo stall',
            'sort_order' => 2,
            'is_cover' => false,
            'is_live' => true,
        ]);

        ListingOption::query()->create([
            'listing_id' => $this->liveActivity->id,
            'name' => 'Evening walk',
            'description' => 'Three tasting stops.',
            'duration_minutes' => 120,
            'min_participants' => 2,
            'max_participants' => 8,
            'is_default' => true,
            'is_live' => true,
        ]);

        $localFavourite = Tag::query()->create([
            'code' => 'LOCAL_FAVOURITE',
            'name' => 'Local favourite',
            'is_live' => true,
        ]);

        DB::table('listing_tags')->insert([
            'listing_id' => $this->liveActivity->id,
            'tag_id' => $localFavourite->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        ListingBookingHour::query()->create([
            'listing_id' => $this->liveActivity->id,
            'day_of_week' => 5,
            'start_time' => '17:00',
            'end_time' => '20:00',
            'end_day_offset' => 0,
            'is_live' => true,
        ]);

        ListingBookingRule::query()->create([
            'listing_id' => $this->liveActivity->id,
            'minimum_notice_minutes' => 360,
            'maximum_advance_days' => 45,
            'buffer_before_minutes' => 0,
            'buffer_after_minutes' => 0,
        ]);

        $this->draftActivity = Listing::query()->create([
            'listing_type_id' => $activity->id,
            'subcategory_id' => $streetFood->id,
            'name' => 'Draft Food Walk',
            'slug' => 'draft-food-walk',
            'summary' => 'Not published.',
            'country_code' => 'UG',
            'geographic_area_id' => $kololo->id,
            'is_live' => false,
        ]);

        $this->liveEvent = Listing::query()->create([
            'listing_type_id' => $event->id,
            'subcategory_id' => $culturalCentres->id,
            'name' => 'Ndere Cultural Night',
            'slug' => 'ndere-cultural-night',
            'summary' => 'Dance and drumming in the city.',
            'country_code' => 'UG',
            'geographic_area_id' => $kampala->id,
            'is_hot_pick' => false,
            'is_local_gem' => false,
            'is_live' => true,
        ]);
    }
}
