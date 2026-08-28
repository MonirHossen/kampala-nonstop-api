<?php

namespace Database\Factories;

use App\Models\AcquisitionSource;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<AcquisitionSource>
 */
class AcquisitionSourceFactory extends Factory
{
    protected $model = AcquisitionSource::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = fake()->unique()->words(2, true);

        return [
            'name' => Str::title($name),
            'code' => Str::upper(Str::slug($name, '_')),
            'type' => fake()->randomElement(AcquisitionSource::TYPES),
            'active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes): array => ['active' => false]);
    }
}
