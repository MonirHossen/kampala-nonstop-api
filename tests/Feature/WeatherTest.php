<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class WeatherTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Cache::flush();
    }

    public function test_kampala_weather_returns_current_conditions(): void
    {
        Http::fake([
            'api.open-meteo.com/*' => Http::response([
                'current' => [
                    'temperature_2m' => 24.3,
                    'weather_code' => 2,
                ],
            ]),
        ]);

        $this->getJson('/api/v1/weather/kampala')
            ->assertOk()
            ->assertJsonPath('data.temperature_c', 24.3)
            ->assertJsonPath('data.condition', 'Partly cloudy')
            ->assertJsonPath('data.location', 'Kampala')
            ->assertJsonPath('data.timezone', 'Africa/Kampala')
            ->assertJsonStructure([
                'data' => [
                    'temperature_c',
                    'condition',
                    'location',
                    'timezone',
                    'fetched_at',
                ],
            ]);
    }

    public function test_kampala_weather_is_cached_across_requests(): void
    {
        Http::fake([
            'api.open-meteo.com/*' => Http::response([
                'current' => [
                    'temperature_2m' => 22.0,
                    'weather_code' => 0,
                ],
            ]),
        ]);

        $this->getJson('/api/v1/weather/kampala')
            ->assertOk()
            ->assertJsonPath('data.condition', 'Clear sky');

        $this->getJson('/api/v1/weather/kampala')
            ->assertOk()
            ->assertJsonPath('data.temperature_c', 22);

        Http::assertSentCount(1);
    }

    public function test_kampala_weather_returns_bad_gateway_when_provider_fails(): void
    {
        Http::fake([
            'api.open-meteo.com/*' => Http::response(['error' => true], 503),
        ]);

        $this->getJson('/api/v1/weather/kampala')
            ->assertStatus(502)
            ->assertJsonPath('message', 'Unable to load Kampala weather right now.');
    }
}
