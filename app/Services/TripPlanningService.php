<?php

namespace App\Services;

use App\Models\Listing;
use App\Models\Trip;
use App\Models\TripCustomer;
use App\Models\TripListing;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class TripPlanningService
{
    /**
     * @return Collection<int, Trip>
     */
    public function listTrips(User $user): Collection
    {
        return Trip::query()
            ->where('owner_user_id', $user->id)
            ->withCount('tripListings')
            ->with(['tripListings.listing'])
            ->latest('updated_at')
            ->get();
    }

    public function findOwnedTrip(User $user, string $tripId): Trip
    {
        $trip = Trip::query()
            ->where('owner_user_id', $user->id)
            ->whereKey($tripId)
            ->with($this->detailRelations())
            ->first();

        if ($trip === null) {
            throw new NotFoundHttpException('Trip not found.');
        }

        return $trip;
    }

    /**
     * @param  array{
     *     name?: string|null,
     *     country_code?: string,
     *     start_date?: string|null,
     *     end_date?: string|null,
     *     status_code?: string,
     *     notes?: string|null
     * }  $data
     */
    public function createTrip(User $user, array $data): Trip
    {
        return DB::transaction(function () use ($user, $data) {
            $trip = Trip::query()->create([
                'owner_user_id' => $user->id,
                'name' => $data['name'] ?? 'My Trip',
                'country_code' => strtoupper($data['country_code'] ?? 'UG'),
                'start_date' => $data['start_date'] ?? null,
                'end_date' => $data['end_date'] ?? null,
                'status_code' => $data['status_code'] ?? Trip::STATUS_DRAFT,
                'notes' => $data['notes'] ?? null,
                'created_by' => $user->email,
                'updated_by' => $user->email,
            ]);

            $this->ensurePrimaryCustomer($trip, $user);

            return $this->findOwnedTrip($user, $trip->id);
        });
    }

    /**
     * @param  array{
     *     name?: string|null,
     *     country_code?: string,
     *     start_date?: string|null,
     *     end_date?: string|null,
     *     status_code?: string,
     *     notes?: string|null
     * }  $data
     */
    public function updateTrip(User $user, Trip $trip, array $data): Trip
    {
        $this->assertOwned($user, $trip);

        $trip->fill([
            'name' => array_key_exists('name', $data) ? $data['name'] : $trip->name,
            'country_code' => array_key_exists('country_code', $data)
                ? strtoupper((string) $data['country_code'])
                : $trip->country_code,
            'start_date' => array_key_exists('start_date', $data) ? $data['start_date'] : $trip->start_date,
            'end_date' => array_key_exists('end_date', $data) ? $data['end_date'] : $trip->end_date,
            'status_code' => array_key_exists('status_code', $data) ? $data['status_code'] : $trip->status_code,
            'notes' => array_key_exists('notes', $data) ? $data['notes'] : $trip->notes,
            'updated_by' => $user->email,
        ]);
        $trip->save();

        return $this->findOwnedTrip($user, $trip->id);
    }

    public function deleteTrip(User $user, Trip $trip): void
    {
        $this->assertOwned($user, $trip);
        $trip->delete();
    }

    /**
     * Add a listing to a specific trip, or to the user's latest draft (creating one if needed).
     *
     * @return array{trip: Trip, trip_listing: TripListing, created: bool}
     */
    public function addListingToTrip(User $user, string $listingId, ?string $tripId = null): array
    {
        if (! Listing::query()->whereKey($listingId)->exists()) {
            throw new NotFoundHttpException('Listing not found.');
        }

        return DB::transaction(function () use ($user, $listingId, $tripId) {
            $trip = $tripId !== null
                ? $this->findOwnedTrip($user, $tripId)
                : $this->resolveDraftTrip($user);

            $existing = TripListing::query()
                ->where('trip_id', $trip->id)
                ->where('listing_id', $listingId)
                ->first();

            if ($existing !== null) {
                return [
                    'trip' => $this->findOwnedTrip($user, $trip->id),
                    'trip_listing' => $existing->load('listing'),
                    'created' => false,
                ];
            }

            $tripListing = TripListing::query()->create([
                'trip_id' => $trip->id,
                'listing_id' => $listingId,
            ]);

            $trip->forceFill([
                'updated_by' => $user->email,
            ])->save();

            return [
                'trip' => $this->findOwnedTrip($user, $trip->id),
                'trip_listing' => $tripListing->load('listing'),
                'created' => true,
            ];
        });
    }

    public function removeListingFromTrip(User $user, Trip $trip, TripListing $tripListing): void
    {
        $this->assertOwned($user, $trip);

        if ($tripListing->trip_id !== $trip->id) {
            throw new NotFoundHttpException('Trip listing not found.');
        }

        $tripListing->delete();

        $trip->forceFill([
            'updated_by' => $user->email,
        ])->save();
    }

    /**
     * @param  array{
     *     user_id?: string|null,
     *     first_name?: string|null,
     *     middle_name?: string|null,
     *     last_name?: string|null,
     *     date_of_birth?: string|null,
     *     country_of_residence?: string|null,
     *     is_primary_customer?: bool,
     *     notes?: string|null
     * }  $data
     */
    public function addCustomer(User $user, Trip $trip, array $data): TripCustomer
    {
        $this->assertOwned($user, $trip);

        return DB::transaction(function () use ($user, $trip, $data) {
            $isPrimary = (bool) ($data['is_primary_customer'] ?? false);

            if ($isPrimary) {
                TripCustomer::query()
                    ->where('trip_id', $trip->id)
                    ->where('is_primary_customer', true)
                    ->update(['is_primary_customer' => false, 'updated_by' => $user->email]);
            }

            return TripCustomer::query()->create([
                'trip_id' => $trip->id,
                'user_id' => $data['user_id'] ?? null,
                'first_name' => $data['first_name'] ?? null,
                'middle_name' => $data['middle_name'] ?? null,
                'last_name' => $data['last_name'] ?? null,
                'date_of_birth' => $data['date_of_birth'] ?? null,
                'country_of_residence' => isset($data['country_of_residence'])
                    ? strtoupper((string) $data['country_of_residence'])
                    : null,
                'is_primary_customer' => $isPrimary,
                'notes' => $data['notes'] ?? null,
                'created_by' => $user->email,
                'updated_by' => $user->email,
            ])->fresh();
        });
    }

    public function removeCustomer(User $user, Trip $trip, TripCustomer $customer): void
    {
        $this->assertOwned($user, $trip);

        if ($customer->trip_id !== $trip->id) {
            throw new NotFoundHttpException('Trip customer not found.');
        }

        if ($customer->is_primary_customer) {
            throw new ConflictHttpException('Cannot remove the primary customer.');
        }

        $customer->delete();
    }

    private function resolveDraftTrip(User $user): Trip
    {
        $draft = Trip::query()
            ->where('owner_user_id', $user->id)
            ->where('status_code', Trip::STATUS_DRAFT)
            ->latest('updated_at')
            ->first();

        if ($draft !== null) {
            return $draft;
        }

        return $this->createTrip($user, [
            'name' => 'My Trip',
            'status_code' => Trip::STATUS_DRAFT,
        ]);
    }

    private function ensurePrimaryCustomer(Trip $trip, User $user): void
    {
        $profile = $user->profile;

        TripCustomer::query()->create([
            'trip_id' => $trip->id,
            'user_id' => $user->id,
            'first_name' => $profile?->first_name,
            'middle_name' => $profile?->middle_name,
            'last_name' => $profile?->last_name,
            'date_of_birth' => $profile?->date_of_birth,
            'country_of_residence' => $profile?->country_of_residence,
            'is_primary_customer' => true,
            'created_by' => $user->email,
            'updated_by' => $user->email,
        ]);
    }

    private function assertOwned(User $user, Trip $trip): void
    {
        if ($trip->owner_user_id !== $user->id) {
            throw new NotFoundHttpException('Trip not found.');
        }
    }

    /**
     * @return list<string|array<string, mixed>>
     */
    private function detailRelations(): array
    {
        return [
            'tripListings.listing',
            'customers',
            'requirements',
            'currentItinerary.items.listing',
        ];
    }
}
