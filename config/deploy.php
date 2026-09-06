<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Deploy pull API
    |--------------------------------------------------------------------------
    |
    | Each server sets DEPLOY_BRANCH so POST /api/v1/deploy/pull pulls the
    | correct git branch:
    |   - main server → main
    |   - dev server  → dev
    |
    | DEPLOY_HOOK_URL points at scripts/deploy-pull-api.py on the host
    | (Docker bridge gateway is usually http://172.17.0.1:PORT/pull).
    |
    */

    'branch' => env('DEPLOY_BRANCH', 'main'),
    'token' => env('DEPLOY_TOKEN'),
    'hook_url' => env('DEPLOY_HOOK_URL'),
];
