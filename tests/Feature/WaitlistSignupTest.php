<?php

namespace Tests\Feature;

use App\Models\AcquisitionSource;
use App\Models\InterestType;
use App\Models\WaitlistSignup;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class WaitlistSignupTest extends TestCase
{
    use RefreshDatabase;

    private AcquisitionSource $instagram;

    private AcquisitionSource $referral;

    private InterestType $nightlife;

    private InterestType $food;

    private InterestType $music;

    protected function setUp(): void
    {
        parent::setUp();

        Mail::fake();

        $this->instagram = AcquisitionSource::factory()->create([
            'code' => 'INSTAGRAM',
            'name' => 'Instagram',
            'type' => 'social',
        ]);

        $this->referral = AcquisitionSource::factory()->create([
            'code' => 'REFERRAL',
            'name' => 'Referral from a friend',
            'type' => 'other',
        ]);

        $this->nightlife = InterestType::factory()->create([
            'code' => 'music_nightlife_entertainment',
            'name' => 'Music, Nightlife & Entertainment',
        ]);
        $this->food = InterestType::factory()->create([
            'code' => 'food_local_life',
            'name' => 'Food & Local Life',
        ]);
        $this->music = InterestType::factory()->create([
            'code' => 'events_festivals',
            'name' => 'Events & Festivals',
        ]);
    }

    /**
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function payload(array $overrides = []): array
    {
        return array_merge([
            'first_name' => 'Amina',
            'surname' => 'Okello',
            'email' => 'amina@example.com',
            'country_code' => 'UG',
            'acquisition_source_code' => 'INSTAGRAM',
            'interest_codes' => ['music_nightlife_entertainment', 'food_local_life'],
            'marketing_consent' => true,
            'countries_of_interest' => ['UG'],
        ], $overrides);
    }

    public function test_valid_signup_creates_a_record_and_links_the_correct_interests(): void
    {
        $response = $this->postJson('/api/v1/waitlist', $this->payload());

        $response->assertCreated()
            ->assertJsonStructure(['id', 'first_name', 'surname', 'email', 'created_at']);

        // The public response must not leak consent or acquisition internals.
        $response->assertJsonMissingPath('marketing_consent')
            ->assertJsonMissingPath('acquisition_source_id')
            ->assertJsonMissingPath('source_details');

        $signup = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();

        $this->assertSame('Amina', $signup->first_name);
        $this->assertSame($this->instagram->id, $signup->acquisition_source_id);
        $this->assertTrue($signup->marketing_consent);
        $this->assertNotNull($signup->marketing_consent_at);
        $this->assertFalse($signup->unsubscribed);
        $this->assertSame(['UG'], $signup->countries_of_interest);

        $this->assertEqualsCanonicalizing(
            ['music_nightlife_entertainment', 'food_local_life'],
            $signup->interestTypes->pluck('code')->all()
        );

        $this->assertDatabaseCount('waitlist_signup_interests', 2);
    }

    public function test_signup_succeeds_when_marketing_consent_is_declined(): void
    {
        $this->postJson('/api/v1/waitlist', $this->payload([
            'email' => 'noconsent@example.com',
            'marketing_consent' => false,
        ]))->assertCreated();

        $signup = WaitlistSignup::query()->where('email', 'noconsent@example.com')->sole();

        $this->assertFalse($signup->marketing_consent);
        $this->assertNull($signup->marketing_consent_at);
    }

    public function test_signup_defaults_countries_of_interest_to_uganda(): void
    {
        $payload = $this->payload(['email' => 'defaults@example.com']);
        unset($payload['countries_of_interest']);

        $this->postJson('/api/v1/waitlist', $payload)->assertCreated();

        $signup = WaitlistSignup::query()->where('email', 'defaults@example.com')->sole();

        $this->assertSame(['UG'], $signup->countries_of_interest);
    }

    public function test_signup_with_an_invalid_acquisition_source_code_falls_back_to_other(): void
    {
        AcquisitionSource::factory()->create([
            'code' => 'OTHER',
            'name' => 'Other',
            'type' => 'other',
        ]);

        $this->postJson('/api/v1/waitlist', $this->payload([
            'email' => 'fallback@example.com',
            'acquisition_source_code' => 'NOT_A_REAL_SOURCE',
        ]))->assertCreated();

        $signup = WaitlistSignup::query()->where('email', 'fallback@example.com')->sole();
        $this->assertSame('OTHER', $signup->acquisitionSource?->code);
        $this->assertStringContainsString('requested_source=NOT_A_REAL_SOURCE', (string) $signup->source_details);
    }

    public function test_signup_with_an_inactive_acquisition_source_falls_back_to_other(): void
    {
        AcquisitionSource::factory()->inactive()->create(['code' => 'RETIRED']);
        AcquisitionSource::factory()->create([
            'code' => 'OTHER',
            'name' => 'Other',
            'type' => 'other',
        ]);

        $this->postJson('/api/v1/waitlist', $this->payload([
            'email' => 'inactive-source@example.com',
            'acquisition_source_code' => 'RETIRED',
        ]))->assertCreated();

        $signup = WaitlistSignup::query()->where('email', 'inactive-source@example.com')->sole();
        $this->assertSame('OTHER', $signup->acquisitionSource?->code);
    }

    public function test_signing_up_twice_updates_the_existing_record_and_merges_interests(): void
    {
        $this->postJson('/api/v1/waitlist', $this->payload([
            'interest_codes' => ['music_nightlife_entertainment'],
        ]))->assertCreated();

        $original = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();
        $originalConsentAt = $original->marketing_consent_at;

        $this->postJson('/api/v1/waitlist', $this->payload([
            'first_name' => 'Aminah',
            'surname' => 'Okello-Ssemakula',
            'acquisition_source_code' => 'REFERRAL',
            'interest_codes' => ['food_local_life', 'events_festivals'],
            'countries_of_interest' => ['KE'],
            'source_details' => 'utm_source=newsletter',
        ]))->assertCreated();

        $this->assertDatabaseCount('waitlist_signups', 1);

        $updated = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();

        $this->assertSame('Aminah', $updated->first_name);
        $this->assertSame('Okello-Ssemakula', $updated->surname);
        $this->assertSame('utm_source=newsletter', $updated->source_details);

        // Interests are merged, never replaced.
        $this->assertEqualsCanonicalizing(
            ['music_nightlife_entertainment', 'food_local_life', 'events_festivals'],
            $updated->interestTypes->pluck('code')->all()
        );

        // Countries of interest are unioned with what was already stored.
        $this->assertEqualsCanonicalizing(['UG', 'KE'], $updated->countries_of_interest);

        // First-touch attribution and the original consent timestamp are preserved.
        $this->assertSame($this->instagram->id, $updated->acquisition_source_id);
        $this->assertNotSame($this->referral->id, $updated->acquisition_source_id);
        $this->assertTrue($originalConsentAt->equalTo($updated->marketing_consent_at));
    }

    public function test_repeat_signup_does_not_duplicate_an_existing_interest_link(): void
    {
        $this->postJson('/api/v1/waitlist', $this->payload([
            'interest_codes' => ['music_nightlife_entertainment', 'food_local_life'],
        ]))->assertCreated();

        $this->postJson('/api/v1/waitlist', $this->payload([
            'interest_codes' => ['music_nightlife_entertainment', 'food_local_life'],
        ]))->assertCreated();

        $this->assertDatabaseCount('waitlist_signup_interests', 2);
    }

    public function test_signing_up_again_after_unsubscribing_resets_unsubscribed_to_false(): void
    {
        $this->postJson('/api/v1/waitlist', $this->payload())->assertCreated();

        WaitlistSignup::query()->where('email', 'amina@example.com')->update(['unsubscribed' => true]);

        $this->postJson('/api/v1/waitlist', $this->payload())->assertCreated();

        $signup = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();

        $this->assertFalse($signup->unsubscribed);
        $this->assertDatabaseCount('waitlist_signups', 1);
    }

    public function test_repeat_signup_upgrades_consent_but_never_revokes_it(): void
    {
        $this->postJson('/api/v1/waitlist', $this->payload([
            'marketing_consent' => false,
        ]))->assertCreated();

        $this->assertNull(
            WaitlistSignup::query()->where('email', 'amina@example.com')->sole()->marketing_consent_at
        );

        $this->postJson('/api/v1/waitlist', $this->payload([
            'marketing_consent' => true,
        ]))->assertCreated();

        $upgraded = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();
        $this->assertTrue($upgraded->marketing_consent);
        $this->assertNotNull($upgraded->marketing_consent_at);

        $this->postJson('/api/v1/waitlist', $this->payload([
            'marketing_consent' => false,
        ]))->assertCreated();

        $stillConsented = WaitlistSignup::query()->where('email', 'amina@example.com')->sole();
        $this->assertTrue($stillConsented->marketing_consent);
    }

    public function test_active_and_unsubscribed_scopes_derive_status_from_the_unsubscribed_column(): void
    {
        WaitlistSignup::factory()->count(2)->create();
        WaitlistSignup::factory()->unsubscribed()->create();

        $this->assertSame(2, WaitlistSignup::query()->active()->count());
        $this->assertSame(1, WaitlistSignup::query()->unsubscribed()->count());
    }

    public function test_admin_index_filters_by_acquisition_source_code_and_unsubscribed_status(): void
    {
        WaitlistSignup::factory()->count(2)->create(['acquisition_source_id' => $this->instagram->id]);
        WaitlistSignup::factory()->create(['acquisition_source_id' => $this->referral->id]);
        WaitlistSignup::factory()->unsubscribed()->create(['acquisition_source_id' => $this->instagram->id]);

        $this->getJson('/api/v1/admin/waitlist?acquisition_source_code=INSTAGRAM')
            ->assertOk()
            ->assertJsonPath('total', 3);

        $this->getJson('/api/v1/admin/waitlist?acquisition_source_code=REFERRAL')
            ->assertOk()
            ->assertJsonPath('total', 1);

        $this->getJson('/api/v1/admin/waitlist?unsubscribed=false')
            ->assertOk()
            ->assertJsonPath('total', 3);

        $this->getJson('/api/v1/admin/waitlist?unsubscribed=true')
            ->assertOk()
            ->assertJsonPath('total', 1);

        $this->getJson('/api/v1/admin/waitlist?acquisition_source_code=INSTAGRAM&unsubscribed=true')
            ->assertOk()
            ->assertJsonPath('total', 1);
    }

    public function test_admin_index_filters_by_interest_code_and_country_code(): void
    {
        $withNightlife = WaitlistSignup::factory()->create(['country_code' => 'UG']);
        $withNightlife->interestTypes()->sync([$this->nightlife->id]);

        $withFood = WaitlistSignup::factory()->create(['country_code' => 'KE']);
        $withFood->interestTypes()->sync([$this->food->id]);

        $this->getJson('/api/v1/admin/waitlist?interest_code=music_nightlife_entertainment')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('data.0.email', $withNightlife->email);

        $this->getJson('/api/v1/admin/waitlist?country_code=KE')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('data.0.email', $withFood->email);
    }

    public function test_csv_export_returns_expected_headers_and_rows_for_a_filtered_set(): void
    {
        $included = WaitlistSignup::factory()->create([
            'acquisition_source_id' => $this->instagram->id,
            'email' => 'included@example.com',
        ]);
        $included->interestTypes()->sync([$this->nightlife->id, $this->food->id]);

        WaitlistSignup::factory()->create([
            'acquisition_source_id' => $this->referral->id,
            'email' => 'excluded@example.com',
        ]);

        $response = $this->get('/api/v1/admin/waitlist/export?acquisition_source_code=INSTAGRAM');

        $response->assertOk();
        $this->assertStringContainsString('text/csv', (string) $response->headers->get('content-type'));

        $rows = array_values(array_filter(
            explode("\n", str_replace("\r\n", "\n", $response->streamedContent()))
        ));

        $this->assertSame(
            'id,first_name,surname,email,country_code,acquisition_source_name,interests,'
                .'marketing_consent,unsubscribed,countries_of_interest,created_at',
            $rows[0]
        );

        // Header plus exactly one matching signup.
        $this->assertCount(2, $rows);
        $this->assertStringContainsString('included@example.com', $rows[1]);
        $this->assertStringContainsString('Instagram', $rows[1]);
        $this->assertStringContainsString('Music, Nightlife & Entertainment', $rows[1]);
        $this->assertStringNotContainsString('excluded@example.com', implode("\n", $rows));
    }
}
