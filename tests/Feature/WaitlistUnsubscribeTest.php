<?php

namespace Tests\Feature;

use App\Mail\WaitlistWelcomeMail;
use App\Models\AcquisitionSource;
use App\Models\WaitlistSignup;
use App\Support\WaitlistUrls;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Str;
use Tests\TestCase;

class WaitlistUnsubscribeTest extends TestCase
{
    use RefreshDatabase;

    private WaitlistSignup $signup;

    protected function setUp(): void
    {
        parent::setUp();

        config(['app.frontend_url' => 'http://frontend.test']);

        $source = AcquisitionSource::factory()->create([
            'code' => 'INSTAGRAM',
            'name' => 'Instagram',
            'type' => 'social',
        ]);

        $this->signup = WaitlistSignup::factory()->create([
            'email' => 'amina@example.com',
            'acquisition_source_id' => $source->id,
            'marketing_consent' => true,
            'unsubscribed' => false,
        ]);
    }

    public function test_valid_signed_url_unsubscribes_and_redirects_to_frontend_success_page(): void
    {
        $url = WaitlistUrls::unsubscribe($this->signup);

        $response = $this->get($url);

        $response->assertRedirect('http://frontend.test/waitlist/unsubscribe?status=success');

        $this->signup->refresh();
        $this->assertTrue($this->signup->unsubscribed);
        $this->assertTrue($this->signup->marketing_consent);
    }

    public function test_already_unsubscribed_is_idempotent_and_redirects_with_already_status(): void
    {
        $this->signup->update(['unsubscribed' => true]);

        $response = $this->get(WaitlistUrls::unsubscribe($this->signup));

        $response->assertRedirect('http://frontend.test/waitlist/unsubscribe?status=already');
        $this->assertTrue($this->signup->fresh()->unsubscribed);
    }

    public function test_missing_signature_is_rejected(): void
    {
        $response = $this->get('/api/v1/waitlist/unsubscribe/'.$this->signup->id);

        $response->assertForbidden();
        $this->assertFalse($this->signup->fresh()->unsubscribed);
    }

    public function test_invalid_signature_is_rejected(): void
    {
        $url = WaitlistUrls::unsubscribe($this->signup).'&signature=invalid';

        $response = $this->get($url);

        $response->assertForbidden();
        $this->assertFalse($this->signup->fresh()->unsubscribed);
    }

    public function test_unknown_signup_redirects_with_invalid_status(): void
    {
        $unknownId = (string) Str::uuid();
        $url = URL::signedRoute('waitlist.unsubscribe', ['signup' => $unknownId]);

        $response = $this->get($url);

        $response->assertRedirect('http://frontend.test/waitlist/unsubscribe?status=invalid');
    }

    public function test_welcome_mail_with_marketing_consent_includes_unsubscribe_url(): void
    {
        $html = (new WaitlistWelcomeMail($this->signup))->render();

        $this->assertStringContainsString('Unsubscribe from updates', $html);
        $this->assertStringContainsString(
            '/api/v1/waitlist/unsubscribe/'.$this->signup->id,
            $html,
        );
        $this->assertStringContainsString('signature=', $html);
    }

    public function test_welcome_mail_without_marketing_consent_omits_unsubscribe_url(): void
    {
        $signup = WaitlistSignup::factory()->create([
            'marketing_consent' => false,
            'marketing_consent_at' => null,
        ]);

        $html = (new WaitlistWelcomeMail($signup))->render();

        $this->assertStringContainsString('You can unsubscribe at any time.', $html);
        $this->assertStringNotContainsString('/waitlist/unsubscribe/', $html);
        $this->assertStringNotContainsString('signature=', $html);
    }
}
