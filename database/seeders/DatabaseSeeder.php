<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::query()->firstOrCreate(
            ['email' => 'test@example.com'],
            ['password' => 'password', 'status' => 'active'],
        );

        $this->call([
            WaitlistReferenceSeeder::class,
            ListingReferenceSeeder::class,
            GeographicAreaSeeder::class,
            CountryGuideReferenceSeeder::class,
            CountryGuideUgandaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
            LocalKnowledgeUgandaSeeder::class,
        ]);
    }
}
