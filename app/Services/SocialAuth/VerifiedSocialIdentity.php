<?php

namespace App\Services\SocialAuth;

final readonly class VerifiedSocialIdentity
{
    public function __construct(
        public string $provider,
        public string $providerUserId,
        public string $email,
        public bool $emailVerified,
        public string $firstName,
        public string $lastName,
        public ?string $avatarUrl = null,
    ) {}
}
