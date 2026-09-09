<?php

namespace Tests\Feature;

use App\Models\CountryGuideEssentialType;
use App\Models\CountryGuideEssentialValue;
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

    public function test_guide_composition_returns_uganda_essentials_in_type_order(): void
    {
        $this->seedGuide();

        $response = $this->getJson('/api/v1/guide/ug');

        $response->assertOk()
            ->assertJsonPath('data.country_code', 'UG')
            ->assertJsonPath('data.essentials.0.code', 'ABOUT')
            ->assertJsonPath('data.essentials.0.value_data.heading', 'About Uganda')
            ->assertJsonPath('data.essentials.1.code', 'HISTORY');

        $codes = collect($response->json('data.essentials'))->pluck('code')->all();
        $this->assertContains('CULTURE_TRADITIONS', $codes);
        $this->assertContains('LOCAL_ETIQUETTE', $codes);
        $this->assertContains('CAPITAL', $codes);
        $this->assertSame('Kampala', collect($response->json('data.essentials'))->firstWhere('code', 'CAPITAL')['value_text']);

        $payload = $response->json('data');
        $this->assertArrayNotHasKey('travel_guide', $payload);
        $this->assertArrayNotHasKey('travel_information', $payload);
        $this->assertArrayNotHasKey('regions', $payload);

        $this->assertGreaterThanOrEqual(20, count($response->json('data.essentials')));
    }

    public function test_essentials_endpoint_returns_live_content(): void
    {
        $this->seedGuide();

        $response = $this->getJson('/api/v1/guide/UG/essentials');

        $response->assertOk()
            ->assertJsonPath('data.0.code', 'ABOUT')
            ->assertJsonPath('data.0.value_data.heading', 'About Uganda')
            ->assertJsonPath('data.1.code', 'HISTORY')
            ->assertJsonPath('data.1.value_data.heading', 'History of Uganda')
            ->assertJsonPath('data.2.code', 'CULTURE_TRADITIONS');

        $codes = collect($response->json('data'))->pluck('code')->all();
        $this->assertContains('FOOD_DRINK_SOCIAL', $codes);
        $this->assertContains('CAPITAL', $codes);

        $aboutParagraphs = $response->json('data.0.value_data.paragraphs');
        $this->assertIsArray($aboutParagraphs);
        $this->assertNotEmpty($aboutParagraphs);
        $this->assertStringStartsWith('Uganda sits in the heart of East Africa', $aboutParagraphs[0]);
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

        $response = $this->getJson('/api/v1/guide/UG');

        $response->assertOk();
        $essentialCodes = collect($response->json('data.essentials'))->pluck('code')->all();

        $this->assertNotContains('CAPITAL', $essentialCodes);
        $this->assertNotContains('CURRENCY', $essentialCodes);
        $this->assertContains('LANGUAGES', $essentialCodes);
    }

    public function test_guide_returns_not_found_for_unknown_or_invalid_country(): void
    {
        $this->seedGuide();

        $this->getJson('/api/v1/guide/XX')->assertNotFound();
        $this->getJson('/api/v1/guide/uganda')->assertNotFound();
    }

    public function test_admin_can_create_and_update_essential_value(): void
    {
        $this->seedGuide();

        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $type = CountryGuideEssentialType::query()->create([
            'code' => 'POPULATION',
            'name' => 'Population',
            'sort_order' => 200,
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

    public function test_retired_travel_and_region_endpoints_are_gone(): void
    {
        $this->seedGuide();

        $this->getJson('/api/v1/guide/UG/travel-guide')->assertNotFound();
        $this->getJson('/api/v1/guide/UG/travel-information')->assertNotFound();
        $this->getJson('/api/v1/guide/UG/regions')->assertNotFound();
    }
}
