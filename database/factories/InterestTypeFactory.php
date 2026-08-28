<?php

namespace Database\Factories;

use App\Models\InterestType;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<InterestType>
 */
class InterestTypeFactory extends Factory
{
    protected $model = InterestType::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = fake()->unique()->words(2, true);

        return [
            'name' => Str::title($name),
            'code' => Str::upper(Str::slug($name, '_')),
            'description' => fake()->optional()->sentence(),
            'display_order' => fake()->numberBetween(0, 100),
            'active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes): array => ['active' => false]);
    }
}
