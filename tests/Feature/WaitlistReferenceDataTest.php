<?php

namespace Tests\Feature;

use App\Models\AcquisitionSource;
use App\Models\InterestType;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WaitlistReferenceDataTest extends TestCase
{
    use RefreshDatabase;

    public function test_interest_types_endpoint_returns_active_interests_in_display_order(): void
    {
        InterestType::factory()->create([
            'code' => 'food_local_life',
            'name' => 'Food & Local Life',
            'description' => 'Rolex stands',
            'display_order' => 20,
        ]);
        InterestType::factory()->create([
            'code' => 'culture_heritage',
            'name' => 'Culture & Heritage',
            'description' => 'Buganda drums',
            'display_order' => 10,
        ]);
        InterestType::factory()->inactive()->create([
            'code' => 'retired',
            'name' => 'Retired',
            'display_order' => 5,
        ]);

        $response = $this->getJson('/api/v1/interest-types');

        $response->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.code', 'culture_heritage')
            ->assertJsonPath('data.1.code', 'food_local_life')
            ->assertJsonMissing(['code' => 'retired']);
    }

    public function test_acquisition_sources_endpoint_returns_active_sources(): void
    {
        AcquisitionSource::factory()->create([
            'code' => 'UNAA_DENVER_2026',
            'name' => 'UNAA Denver 2026',
            'type' => 'event',
        ]);
        AcquisitionSource::factory()->inactive()->create([
            'code' => 'RETIRED',
            'name' => 'Retired',
        ]);

        $this->getJson('/api/v1/acquisition-sources')
            ->assertOk()
            ->assertJsonFragment(['code' => 'UNAA_DENVER_2026'])
            ->assertJsonMissing(['code' => 'RETIRED']);
    }
}
