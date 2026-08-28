<?php

namespace Database\Factories;

use App\Models\AcquisitionSource;
use App\Models\WaitlistSignup;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WaitlistSignup>
 */
class WaitlistSignupFactory extends Factory
{
    protected $model = WaitlistSignup::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'first_name' => fake()->firstName(),
            'surname' => fake()->lastName(),
            'email' => fake()->unique()->safeEmail(),
            'country_code' => 'UG',
            'acquisition_source_id' => AcquisitionSource::factory(),
            'marketing_consent' => true,
            'marketing_consent_at' => now(),
            'unsubscribed' => false,
            'countries_of_interest' => ['UG'],
            'source_details' => null,
        ];
    }

    public function unsubscribed(): static
    {
        return $this->state(fn (array $attributes): array => ['unsubscribed' => true]);
    }

    public function withoutConsent(): static
    {
        return $this->state(fn (array $attributes): array => [
            'marketing_consent' => false,
            'marketing_consent_at' => null,
        ]);
    }
}
