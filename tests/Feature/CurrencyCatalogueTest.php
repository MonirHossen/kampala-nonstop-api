<?php

namespace Tests\Feature;

use App\Models\Currency;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CurrencyCatalogueTest extends TestCase
{
    use RefreshDatabase;

    public function test_currencies_endpoint_returns_active_currencies_in_display_order(): void
    {
        Currency::factory()->create([
            'code' => 'USD',
            'name' => 'USD',
            'display_order' => 20,
        ]);
        Currency::factory()->create([
            'code' => 'GBP',
            'name' => 'GBP',
            'display_order' => 10,
        ]);
        Currency::factory()->create([
            'code' => 'EUR',
            'name' => 'Euros',
            'display_order' => 30,
        ]);
        Currency::factory()->inactive()->create([
            'code' => 'XYZ',
            'name' => 'Retired',
            'display_order' => 5,
        ]);

        $this->getJson('/api/v1/currencies')
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.code', 'GBP')
            ->assertJsonPath('data.1.code', 'USD')
            ->assertJsonPath('data.2.code', 'EUR')
            ->assertJsonPath('data.2.name', 'Euros')
            ->assertJsonMissing(['code' => 'XYZ']);
    }

    public function test_preferences_reject_unknown_currency(): void
    {
        Currency::factory()->create([
            'code' => 'UGX',
            'name' => 'UGX',
            'display_order' => 40,
        ]);

        $this->postJson('/api/v1/auth/register', [
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'currency-reject@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
        ])->assertCreated();

        $user = User::query()->where('email', 'currency-reject@example.com')->firstOrFail();
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/user/preferences', [
            'preferred_currency' => 'ZZZ',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['preferred_currency']);

        $this->putJson('/api/v1/user/preferences', [
            'preferred_currency' => 'ugx',
        ])->assertOk()
            ->assertJsonPath('preferences.preferred_currency', 'UGX');
    }
}
