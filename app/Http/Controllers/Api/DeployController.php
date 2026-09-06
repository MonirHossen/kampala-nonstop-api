<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Symfony\Component\HttpFoundation\Response;

/**
 * Triggers a git pull + stack rebuild on this server.
 *
 * Branch is chosen by the server's configured DEPLOY_BRANCH:
 *   - main / production server → pulls origin/main
 *   - dev / testing server     → pulls origin/dev
 *
 * Auth: Authorization: Bearer <DEPLOY_TOKEN>  or  X-Deploy-Token header
 */
class DeployController extends Controller
{
    public function pull(Request $request): JsonResponse
    {
        $token = (string) config('deploy.token', '');
        if ($token === '' || str_starts_with($token, 'CHANGE_ME')) {
            return response()->json([
                'error' => 'deploy_not_configured',
                'message' => 'Set DEPLOY_TOKEN in the API environment.',
            ], Response::HTTP_SERVICE_UNAVAILABLE);
        }

        $provided = $request->bearerToken()
            ?: (string) $request->header('X-Deploy-Token', '');

        if (! hash_equals($token, $provided)) {
            return response()->json(['error' => 'unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $defaultBranch = (string) config('deploy.branch', 'main');
        $envName = $this->resolveEnv($request, $defaultBranch);
        $branch = $envName === 'dev' ? 'dev' : 'main';

        $hookUrl = (string) config('deploy.hook_url', '');
        if ($hookUrl === '') {
            return response()->json([
                'error' => 'deploy_hook_missing',
                'message' => 'Set DEPLOY_HOOK_URL to the host pull API (e.g. http://172.17.0.1:9091/pull).',
                'branch' => $branch,
                'env' => $envName,
            ], Response::HTTP_SERVICE_UNAVAILABLE);
        }

        try {
            $response = Http::timeout(10)
                ->withToken($token)
                ->acceptJson()
                ->post($hookUrl, [
                    'env' => $envName,
                    'branch' => $branch,
                ]);
        } catch (ConnectionException $e) {
            return response()->json([
                'error' => 'deploy_hook_unreachable',
                'message' => 'Could not reach the host deploy pull API. Is deploy-pull-api.py running?',
                'hook_url' => $hookUrl,
                'detail' => $e->getMessage(),
            ], Response::HTTP_BAD_GATEWAY);
        }

        return response()->json([
            'status' => $response->successful() ? 'accepted' : 'hook_error',
            'env' => $envName,
            'branch' => $branch,
            'hook_status' => $response->status(),
            'hook' => $response->json() ?? $response->body(),
        ], $response->successful() ? Response::HTTP_ACCEPTED : Response::HTTP_BAD_GATEWAY);
    }

    public function status(): JsonResponse
    {
        return response()->json([
            'status' => 'ok',
            'deploy_branch' => config('deploy.branch', 'main'),
            'deploy_configured' => filled(config('deploy.token'))
                && ! str_starts_with((string) config('deploy.token'), 'CHANGE_ME')
                && filled(config('deploy.hook_url')),
        ]);
    }

    private function resolveEnv(Request $request, string $defaultBranch): string
    {
        $requested = strtolower((string) $request->input('env', $request->input('branch', '')));

        if (in_array($requested, ['main', 'master', 'production', 'prod'], true)) {
            return 'main';
        }

        if (in_array($requested, ['dev', 'development', 'staging'], true)) {
            return 'dev';
        }

        return $defaultBranch === 'dev' ? 'dev' : 'main';
    }
}
