<?php

namespace Tests\Feature;

use App\Models\CountryGuideEssentialType;
use App\Models\CountryGuideEssentialValue;
use App\Models\CountryRegionGuide;
use App\Models\CountryTravelGuide;
use App\Models\GeographicArea;
use App\Models\TravelGuideTopic;
use App\Models\User;
use Database\Seeders\CountryGuideReferenceSeeder;
use Database\Seeders\CountryGuideUgandaSeeder;
use Database\Seeders\GeographicAreaSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CountryGuideTest extends TestCase
{
    use RefreshDatabase;

    private function seedGuide(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            CountryGuideReferenceSeeder::class,
            CountryGuideUgandaSeeder::class,
        ]);
    }

    public function test_guide_composition_returns_uganda_sections_in_type_order(): void
    {
        $this->seedGuide();

        $response = $this->getJson('/api/v1/guide/ug');

        $response->assertOk()
            ->assertJsonPath('data.country_code', 'UG')
            ->assertJsonPath('data.essentials.0.code', 'CAPITAL')
            ->assertJsonPath('data.essentials.0.value_text', 'Kampala')
            ->assertJsonPath('data.travel_guide.0.code', 'ENTRY_VISAS')
            ->assertJsonPath('data.travel_guide.0.description', 'Long-form guidance on entry requirements, visas and related visitor considerations.')
            ->assertJsonPath('data.travel_guide.1.code', 'ARRIVAL')
            ->assertJsonPath('data.travel_guide.9.code', 'WHAT_TO_PACK')
            ->assertJsonPath('data.travel_information.0.code', 'EXCHANGE_RATE')
            ->assertJsonPath('data.regions.0.code', 'UG-CENTRAL');

        $this->assertGreaterThanOrEqual(4, count($response->json('data.regions')));
        $this->assertCount(10, $response->json('data.travel_guide'));
        $this->assertNotNull($response->json('data.travel_guide.0.description'));
    }

    public function test_guide_section_endpoints_return_live_content(): void
    {
        $this->seedGuide();

        $this->getJson('/api/v1/guide/UG/essentials')
            ->assertOk()
            ->assertJsonPath('data.0.code', 'CAPITAL');

        $this->getJson('/api/v1/guide/UG/travel-guide')
            ->assertOk()
            ->assertJsonPath('data.0.code', 'ENTRY_VISAS');

        $this->getJson('/api/v1/guide/UG/travel-information')
            ->assertOk()
            ->assertJsonPath('data.0.code', 'EXCHANGE_RATE');

        $this->getJson('/api/v1/guide/UG/regions')
            ->assertOk()
            ->assertJsonFragment(['code' => 'UG-WEST']);

        $this->getJson('/api/v1/guide/UG/regions/UG-EAST')
            ->assertOk()
            ->assertJsonPath('data.code', 'UG-EAST')
            ->assertJsonPath('data.title', 'East');
    }

    public function test_guide_excludes_inactive_types_and_unpublished_values(): void
    {
        $this->seedGuide();

        $capitalType = CountryGuideEssentialType::query()->where('code', 'CAPITAL')->firstOrFail();
        $capitalType->update(['is_active' => false]);

        $currencyType = CountryGuideEssentialType::query()->where('code', 'CURRENCY')->firstOrFail();
        CountryGuideEssentialValue::query()
            ->where('country_code', 'UG')
            ->where('essential_type_id', $currencyType->id)
            ->update(['is_live' => false]);

        $entryTopic = TravelGuideTopic::query()->where('code', 'ENTRY_VISAS')->firstOrFail();
        CountryTravelGuide::query()
            ->where('country_code', 'UG')
            ->where('topic_id', $entryTopic->id)
            ->update(['is_live' => false]);

        $central = GeographicArea::query()->where('code', 'UG-CENTRAL')->firstOrFail();
        CountryRegionGuide::query()
            ->where('geographic_area_id', $central->id)
            ->update(['is_live' => false]);

        $response = $this->getJson('/api/v1/guide/UG');

        $response->assertOk();
        $essentialCodes = collect($response->json('data.essentials'))->pluck('code')->all();
        $travelCodes = collect($response->json('data.travel_guide'))->pluck('code')->all();
        $regionCodes = collect($response->json('data.regions'))->pluck('code')->all();

        $this->assertNotContains('CAPITAL', $essentialCodes);
        $this->assertNotContains('CURRENCY', $essentialCodes);
        $this->assertNotContains('ENTRY_VISAS', $travelCodes);
        $this->assertNotContains('UG-CENTRAL', $regionCodes);
        $this->assertContains('LANGUAGES', $essentialCodes);
    }

    public function test_guide_returns_not_found_for_unknown_or_invalid_country(): void
    {
        $this->seedGuide();

        $this->getJson('/api/v1/guide/XX')->assertNotFound();
        $this->getJson('/api/v1/guide/uganda')->assertNotFound();
        $this->getJson('/api/v1/guide/UG/regions/MISSING')->assertNotFound();
    }

    public function test_admin_can_create_and_update_essential_value(): void
    {
        $this->seedGuide();

        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $type = CountryGuideEssentialType::query()->create([
            'code' => 'POPULATION',
            'name' => 'Population',
            'sort_order' => 110,
            'is_active' => true,
        ]);

        $create = $this->withToken($token)->postJson('/api/v1/admin/guide/essential-values', [
            'country_code' => 'ug',
            'essential_type_id' => $type->id,
            'value_text' => 'About 45 million',
            'value_data' => ['approx' => 45_000_000],
        ]);

        $create->assertCreated()
            ->assertJsonPath('data.country_code', 'UG')
            ->assertJsonPath('data.value_text', 'About 45 million');

        $id = $create->json('data.id');

        $this->withToken($token)->putJson("/api/v1/admin/guide/essential-values/{$id}", [
            'value_text' => 'About 46 million',
            'is_live' => false,
        ])->assertOk()
            ->assertJsonPath('data.value_text', 'About 46 million')
            ->assertJsonPath('data.is_live', false);

        $this->getJson('/api/v1/guide/UG/essentials')
            ->assertOk()
            ->assertJsonMissing(['code' => 'POPULATION']);
    }

    public function test_admin_guide_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/admin/guide/essential-types')->assertUnauthorized();
        $this->postJson('/api/v1/admin/guide/essential-types', [
            'code' => 'TEST',
            'name' => 'Test',
        ])->assertUnauthorized();
    }
}
