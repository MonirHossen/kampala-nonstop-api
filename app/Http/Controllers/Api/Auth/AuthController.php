<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $authService) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register($request->validated());

        return response()->json([
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => new UserResource($result['user']),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->validated());

        return response()->json([
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => new UserResource($result['user']),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request);

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        $user->load(['profile', 'preferences', 'notificationPreferences', 'consents']);

        return response()->json([
            'user' => new UserResource($user),
        ]);
    }
}
