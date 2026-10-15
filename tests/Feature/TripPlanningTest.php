<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\ListingType;
use App\Models\Trip;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TripPlanningTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        if (! Schema::hasTable('trips') || ! Schema::hasTable('listings')) {
            $this->markTestSkipped('Trip planning and listings schema are required.');
        }
    }

    public function test_user_can_create_trip_and_add_listing(): void
    {
        $user = $this->registerUser();
        Sanctum::actingAs($user);
        $listing = $this->createListing('Trip Walk', 'trip-walk');

        $trip = $this->postJson('/api/v1/user/trips', [
            'name' => 'Kampala Weekend',
            'start_date' => '2026-11-01',
            'end_date' => '2026-11-03',
        ])
            ->assertCreated()
            ->assertJsonPath('trip.name', 'Kampala Weekend')
            ->assertJsonPath('trip.status_code', 'DRAFT')
            ->json('trip');

        $this->assertDatabaseHas('trip_customers', [
            'trip_id' => $trip['id'],
            'user_id' => $user->id,
            'is_primary_customer' => true,
        ]);

        $this->postJson('/api/v1/user/trips/listings', [
            'listing_id' => $listing->id,
            'trip_id' => $trip['id'],
        ])
            ->assertCreated()
            ->assertJsonPath('trip_listing.listing_id', $listing->id)
            ->assertJsonPath('created', true);

        $this->postJson('/api/v1/user/trips/listings', [
            'listing_id' => $listing->id,
            'trip_id' => $trip['id'],
        ])
            ->assertOk()
            ->assertJsonPath('created', false);

        $this->getJson('/api/v1/user/trips/'.$trip['id'])
            ->assertOk()
            ->assertJsonCount(1, 'trip.listings')
            ->assertJsonPath('trip.listings.0.listing.slug', 'trip-walk');
    }

    public function test_quick_add_creates_draft_trip_when_missing(): void
    {
        $user = $this->registerUser(['email' => 'planner@example.com']);
        Sanctum::actingAs($user);
        $listing = $this->createListing('Quick Add Spot', 'quick-add-spot');

        $response = $this->postJson('/api/v1/user/trips/listings', [
            'listing_id' => $listing->id,
        ])->assertCreated();

        $tripId = $response->json('trip.id');
        $this->assertNotEmpty($tripId);
        $this->assertDatabaseHas('trips', [
            'id' => $tripId,
            'owner_user_id' => $user->id,
            'status_code' => Trip::STATUS_DRAFT,
        ]);
    }

    public function test_user_cannot_view_another_users_trip(): void
    {
        $owner = $this->registerUser(['email' => 'owner@example.com']);
        Sanctum::actingAs($owner);

        $tripId = $this->postJson('/api/v1/user/trips', [
            'name' => 'Private Trip',
        ])->assertCreated()->json('trip.id');

        $other = $this->registerUser(['email' => 'other-trip@example.com']);
        Sanctum::actingAs($other);

        $this->getJson('/api/v1/user/trips/'.$tripId)->assertNotFound();
    }

    private function registerUser(array $overrides = []): User
    {
        $payload = array_merge([
            'first_name' => 'Amina',
            'last_name' => 'Okello',
            'email' => 'amina-trip@example.com',
            'password' => 'Password1!',
            'password_confirmation' => 'Password1!',
            'accept_terms' => true,
            'marketing_consent' => true,
        ], $overrides);

        $this->postJson('/api/v1/auth/register', $payload)->assertCreated();

        return User::query()->where('email', $payload['email'])->firstOrFail();
    }

    private function createListing(string $name, string $slug): Listing
    {
        $listingType = ListingType::query()->firstOrCreate(
            ['code' => 'ACTIVITY'],
            ['name' => 'Activity', 'is_live' => true],
        );

        return Listing::query()->create([
            'listing_type_id' => $listingType->id,
            'name' => $name,
            'slug' => $slug,
            'summary' => 'For trip planning tests.',
            'country_code' => 'UG',
            'is_live' => true,
        ]);
    }
}
