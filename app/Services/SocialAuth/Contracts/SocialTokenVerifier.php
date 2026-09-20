<?php

namespace App\Services\SocialAuth\Contracts;

use App\Services\SocialAuth\VerifiedSocialIdentity;

interface SocialTokenVerifier
{
    public function verify(string $token): VerifiedSocialIdentity;
}
