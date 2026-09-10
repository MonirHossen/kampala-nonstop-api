<?php

namespace App\Services;

use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class WeatherService
{
    private const CACHE_KEY = 'weather:kampala';

    /**
     * Current Kampala weather from Open-Meteo (cached).
     *
     * @return array{
     *     temperature_c: float,
     *     condition: string,
     *     location: string,
     *     timezone: string,
     *     fetched_at: string
     * }
     */
    public function kampala(): array
    {
        $ttl = (int) config('services.open_meteo.cache_seconds', 900);

        return Cache::remember(self::CACHE_KEY, $ttl, fn (): array => $this->fetchKampala());
    }

    /**
     * @return array{
     *     temperature_c: float,
     *     condition: string,
     *     location: string,
     *     timezone: string,
     *     fetched_at: string
     * }
     */
    private function fetchKampala(): array
    {
        $baseUrl = (string) config('services.open_meteo.base_url');
        $latitude = (float) config('services.open_meteo.kampala.latitude');
        $longitude = (float) config('services.open_meteo.kampala.longitude');

        try {
            $response = Http::timeout(10)
                ->acceptJson()
                ->get($baseUrl, [
                    'latitude' => $latitude,
                    'longitude' => $longitude,
                    'current' => 'temperature_2m,weather_code',
                    'timezone' => 'Africa/Kampala',
                ])
                ->throw();
        } catch (RequestException $exception) {
            throw new RuntimeException('Unable to fetch Kampala weather.', 0, $exception);
        }

        /** @var array<string, mixed> $payload */
        $payload = $response->json() ?? [];
        /** @var array<string, mixed> $current */
        $current = is_array($payload['current'] ?? null) ? $payload['current'] : [];

        if (! array_key_exists('temperature_2m', $current) || ! array_key_exists('weather_code', $current)) {
            throw new RuntimeException('Kampala weather response was incomplete.');
        }

        $temperature = round((float) $current['temperature_2m'], 1);
        $weatherCode = (int) $current['weather_code'];

        return [
            'temperature_c' => $temperature,
            'condition' => $this->conditionLabel($weatherCode),
            'location' => 'Kampala',
            'timezone' => 'Africa/Kampala',
            'fetched_at' => now()->toIso8601String(),
        ];
    }

    private function conditionLabel(int $weatherCode): string
    {
        return match (true) {
            $weatherCode === 0 => 'Clear sky',
            $weatherCode === 1 => 'Mainly clear',
            $weatherCode === 2 => 'Partly cloudy',
            $weatherCode === 3 => 'Overcast',
            in_array($weatherCode, [45, 48], true) => 'Fog',
            in_array($weatherCode, [51, 53, 55], true) => 'Drizzle',
            in_array($weatherCode, [56, 57], true) => 'Freezing drizzle',
            in_array($weatherCode, [61, 63, 65], true) => 'Rain',
            in_array($weatherCode, [66, 67], true) => 'Freezing rain',
            in_array($weatherCode, [71, 73, 75], true) => 'Snow',
            $weatherCode === 77 => 'Snow grains',
            in_array($weatherCode, [80, 81, 82], true) => 'Rain showers',
            in_array($weatherCode, [85, 86], true) => 'Snow showers',
            $weatherCode === 95 => 'Thunderstorm',
            in_array($weatherCode, [96, 99], true) => 'Thunderstorm with hail',
            default => 'Unknown',
        };
    }
}
