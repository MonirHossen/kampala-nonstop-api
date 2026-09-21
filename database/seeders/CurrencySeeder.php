<?php

namespace Database\Seeders;

use App\Models\Currency;
use Illuminate\Database\Seeder;

/**
 * Preferred-currency catalogue for traveller preferences.
 *
 * Idempotent: re-running matches on `code` and updates in place.
 */
class CurrencySeeder extends Seeder
{
    public function run(): void
    {
        $currencies = [
            ['code' => 'GBP', 'name' => 'GBP', 'display_order' => 10],
            ['code' => 'USD', 'name' => 'USD', 'display_order' => 20],
            ['code' => 'EUR', 'name' => 'Euros', 'display_order' => 30],
            ['code' => 'UGX', 'name' => 'UGX', 'display_order' => 40],
        ];

        foreach ($currencies as $currency) {
            Currency::query()->updateOrCreate(
                ['code' => $currency['code']],
                [
                    'name' => $currency['name'],
                    'display_order' => $currency['display_order'],
                    'active' => true,
                ],
            );
        }
    }
}
