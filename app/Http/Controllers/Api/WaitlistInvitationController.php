<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWaitlistInvitationRequest;
use App\Services\WaitlistInvitationService;
use Illuminate\Http\JsonResponse;

class WaitlistInvitationController extends Controller
{
    public function __construct(private readonly WaitlistInvitationService $invitationService) {}

    /**
     * Public friend-invite from a confirmed waitlist registrant.
     */
    public function store(StoreWaitlistInvitationRequest $request): JsonResponse
    {
        $invitation = $this->invitationService->invite($request->validated());

        return response()->json([
            'id' => $invitation->id,
            'invitee_email' => $invitation->invitee_email,
            'sent_at' => $invitation->sent_at,
        ], 201);
    }
}
