<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserConsent;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthService
{
    /**
     * @param  array{
     *     first_name: string,
     *     last_name: string,
     *     email: string,
     *     password: string,
     *     middle_name?: string|null,
     *     accept_terms: bool,
     *     marketing_consent?: bool
     * }  $data
     * @return array{user: User, token: string}
     */
    public function register(array $data): array
    {
        $user = DB::transaction(function () use ($data): User {
            /** @var User $user */
            $user = User::query()->create([
                'email' => strtolower(trim($data['email'])),
                'password' => $data['password'],
                'status' => 'active',
            ]);

            $user->profile()->create([
                'first_name' => $data['first_name'],
                'middle_name' => $data['middle_name'] ?? null,
                'last_name' => $data['last_name'],
            ]);

            $user->preferences()->create([]);
            $user->notificationPreferences()->create([]);

            $now = now();

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_TERMS_OF_SERVICE,
                'is_granted' => true,
                'granted_at' => $now,
                'policy_version' => 'v0',
            ]);

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_PRIVACY_POLICY,
                'is_granted' => true,
                'granted_at' => $now,
                'policy_version' => 'v0',
            ]);

            $marketingGranted = (bool) ($data['marketing_consent'] ?? false);

            $user->consents()->create([
                'consent_type' => UserConsent::TYPE_MARKETING,
                'is_granted' => $marketingGranted,
                'granted_at' => $marketingGranted ? $now : null,
            ]);

            return $user;
        });

        $user->load(['profile', 'preferences', 'notificationPreferences', 'consents']);

        return [
            'user' => $user,
            'token' => $user->createToken('api')->plainTextToken,
        ];
    }

    /**
     * @param  array{email: string, password: string, device_name?: string}  $credentials
     * @return array{user: User, token: string}
     */
    public function login(array $credentials): array
    {
        /** @var User|null $user */
        $user = User::query()
            ->whereRaw('LOWER(email) = ?', [strtolower(trim($credentials['email']))])
            ->first();

        if ($user === null || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'email' => ['This account is inactive.'],
            ]);
        }

        $user->load(['profile', 'preferences', 'notificationPreferences', 'consents']);

        $deviceName = $credentials['device_name'] ?? 'api';

        return [
            'user' => $user,
            'token' => $user->createToken($deviceName)->plainTextToken,
        ];
    }

    public function logout(Request $request): void
    {
        $bearer = $request->bearerToken();

        if ($bearer !== null && $bearer !== '') {
            PersonalAccessToken::findToken($bearer)?->delete();
        } else {
            $token = $request->user()?->currentAccessToken();

            if ($token instanceof PersonalAccessToken) {
                $token->delete();
            }
        }

        Auth::forgetGuards();
    }

    /**
     * @param  array{email: string}  $data
     */
    public function sendPasswordResetLink(array $data): string
    {
        $status = Password::broker()->sendResetLink([
            'email' => strtolower(trim($data['email'])),
        ]);

        if ($status === Password::RESET_THROTTLED) {
            throw ValidationException::withMessages([
                'email' => [__($status)],
            ]);
        }

        // Always succeed for unknown emails to avoid account enumeration.
        return Password::RESET_LINK_SENT;
    }

    /**
     * @param  array{email: string, password: string, token: string, password_confirmation?: string}  $data
     */
    public function resetPassword(array $data): string
    {
        $status = Password::broker()->reset(
            [
                'email' => strtolower(trim($data['email'])),
                'password' => $data['password'],
                'password_confirmation' => $data['password_confirmation'] ?? $data['password'],
                'token' => $data['token'],
            ],
            function (User $user, string $password): void {
                $user->forceFill([
                    'password' => $password,
                    'remember_token' => Str::random(60),
                ])->save();

                $user->tokens()->delete();

                event(new PasswordReset($user));
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            throw ValidationException::withMessages([
                'email' => [__($status)],
            ]);
        }

        return $status;
    }

    /**
     * @param  array{current_password: string, password: string}  $data
     */
    public function changePassword(User $user, array $data): void
    {
        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->forceFill([
            'password' => $data['password'],
        ])->save();

        $user->tokens()
            ->where('id', '!=', $user->currentAccessToken()?->id)
            ->delete();
    }
}
