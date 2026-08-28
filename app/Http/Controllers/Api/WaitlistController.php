<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\IndexWaitlistSignupRequest;
use App\Http\Requests\StoreWaitlistSignupRequest;
use App\Models\WaitlistSignup;
use App\Services\WaitlistService;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class WaitlistController extends Controller
{
    public function __construct(private readonly WaitlistService $waitlistService) {}

    /**
     * Public waitlist signup.
     *
     * The response deliberately excludes consent and acquisition internals.
     */
    public function store(StoreWaitlistSignupRequest $request): JsonResponse
    {
        $signup = $this->waitlistService->join($request->validated());

        return response()->json([
            'id' => $signup->id,
            'first_name' => $signup->first_name,
            'email' => $signup->email,
            'created_at' => $signup->created_at,
        ], 201);
    }

    /**
     * Admin listing of waitlist signups.
     */
    public function index(IndexWaitlistSignupRequest $request): JsonResponse
    {
        /** @var LengthAwarePaginator<int, WaitlistSignup> $signups */
        $signups = $this->filteredQuery($request->filters())
            ->with(['acquisitionSource', 'interestTypes'])
            ->latest('created_at')
            ->paginate((int) $request->validated('per_page', 25))
            ->withQueryString();

        $signups->getCollection()->transform(static fn (WaitlistSignup $signup): array => [
            'id' => $signup->id,
            'first_name' => $signup->first_name,
            'surname' => $signup->surname,
            'email' => $signup->email,
            'country_code' => $signup->country_code,
            'acquisition_source' => [
                'code' => $signup->acquisitionSource?->code,
                'name' => $signup->acquisitionSource?->name,
            ],
            'interests' => $signup->interestTypes->pluck('code')->all(),
            'marketing_consent' => $signup->marketing_consent,
            'marketing_consent_at' => $signup->marketing_consent_at,
            'unsubscribed' => $signup->unsubscribed,
            'countries_of_interest' => $signup->countries_of_interest,
            'source_details' => $signup->source_details,
            'created_at' => $signup->created_at,
        ]);

        return response()->json($signups);
    }

    /**
     * CSV export honouring the same filters as index().
     */
    public function export(IndexWaitlistSignupRequest $request): StreamedResponse
    {
        $query = $this->filteredQuery($request->filters())
            ->with(['acquisitionSource', 'interestTypes']);

        $filename = 'waitlist-'.now()->format('Y-m-d-His').'.csv';

        return response()->streamDownload(function () use ($query): void {
            $handle = fopen('php://output', 'wb');

            fputcsv($handle, [
                'id',
                'first_name',
                'surname',
                'email',
                'country_code',
                'acquisition_source_name',
                'interests',
                'marketing_consent',
                'unsubscribed',
                'countries_of_interest',
                'created_at',
            ]);

            $query->orderBy('created_at')->chunk(500, function ($signups) use ($handle): void {
                foreach ($signups as $signup) {
                    fputcsv($handle, [
                        $signup->id,
                        $signup->first_name,
                        $signup->surname,
                        $signup->email,
                        $signup->country_code,
                        $signup->acquisitionSource?->name,
                        $signup->interestTypes->pluck('name')->implode(', '),
                        $signup->marketing_consent ? 'true' : 'false',
                        $signup->unsubscribed ? 'true' : 'false',
                        implode(', ', $signup->countries_of_interest ?? []),
                        $signup->created_at?->toIso8601String(),
                    ]);
                }
            });

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return Builder<WaitlistSignup>
     */
    private function filteredQuery(array $filters): Builder
    {
        return WaitlistSignup::query()
            ->when(
                filled($filters['acquisition_source_code'] ?? null),
                fn (Builder $query): Builder => $query->whereHas(
                    'acquisitionSource',
                    fn (Builder $source): Builder => $source->where('code', $filters['acquisition_source_code'])
                )
            )
            ->when(
                filled($filters['interest_code'] ?? null),
                fn (Builder $query): Builder => $query->whereHas(
                    'interestTypes',
                    fn (Builder $interest): Builder => $interest->where('code', $filters['interest_code'])
                )
            )
            ->when(
                array_key_exists('unsubscribed', $filters) && $filters['unsubscribed'] !== null,
                fn (Builder $query): Builder => $query->where('unsubscribed', (bool) $filters['unsubscribed'])
            )
            ->when(
                filled($filters['country_code'] ?? null),
                fn (Builder $query): Builder => $query->where('country_code', $filters['country_code'])
            )
            ->when(
                filled($filters['created_from'] ?? null),
                fn (Builder $query): Builder => $query->where('created_at', '>=', $filters['created_from'])
            )
            ->when(
                filled($filters['created_to'] ?? null),
                fn (Builder $query): Builder => $query->where('created_at', '<=', $filters['created_to'])
            );
    }
}
