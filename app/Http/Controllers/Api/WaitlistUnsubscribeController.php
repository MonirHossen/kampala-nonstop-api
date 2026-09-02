<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WaitlistSignup;
use App\Services\WaitlistService;
use Illuminate\Http\RedirectResponse;

class WaitlistUnsubscribeController extends Controller
{
    public function __construct(private readonly WaitlistService $waitlistService) {}

    /**
     * One-click unsubscribe from marketing updates via a signed email link.
     */
    public function store(string $signup): RedirectResponse
    {
        $record = WaitlistSignup::query()->find($signup);

        if (! $record instanceof WaitlistSignup) {
            return redirect()->away($this->frontendRedirectUrl('invalid'));
        }

        $status = $this->waitlistService->unsubscribe($record) ? 'success' : 'already';

        return redirect()->away($this->frontendRedirectUrl($status));
    }

    private function frontendRedirectUrl(string $status): string
    {
        $frontend = rtrim((string) config('app.frontend_url'), '/');

        return "{$frontend}/waitlist/unsubscribe?status={$status}";
    }
}
