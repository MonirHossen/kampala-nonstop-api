<?php

namespace App\Services;

use App\Mail\WaitlistWelcomeMail;
use App\Models\AcquisitionSource;
use App\Models\InterestType;
use App\Models\WaitlistSignup;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class WaitlistService
{
    /**
     * Add someone to the waitlist, or merge into their existing signup.
     *
     * Email is the identity of a signup: a repeat submission never creates a
     * second row.
     *
     * @param  array<string, mixed>  $data
     */
    public function join(array $data): WaitlistSignup
    {
        $requestedSource = strtoupper(trim((string) $data['acquisition_source_code']));
        $acquisitionSourceId = $this->resolveAcquisitionSourceId($requestedSource);
        $interestTypeIds = $this->resolveInterestTypeIds($data['interest_codes'] ?? []);

        $resolvedCode = AcquisitionSource::query()->where('id', $acquisitionSourceId)->value('code');
        if (is_string($resolvedCode) && $resolvedCode !== $requestedSource) {
            $detail = trim((string) ($data['source_details'] ?? ''));
            $note = 'requested_source='.$requestedSource;
            $data['source_details'] = $detail === '' ? $note : $detail.' | '.$note;
        }

        try {
            [$signup, $isNew] = DB::transaction(
                function () use ($data, $acquisitionSourceId, $interestTypeIds): array {
                    return $this->createOrMerge($data, $acquisitionSourceId, $interestTypeIds);
                }
            );
        } catch (UniqueConstraintViolationException) {
            // A concurrent request (typically a double-clicked form) inserted the
            // same email first. The row exists now, so merge into it instead.
            [$signup, $isNew] = DB::transaction(
                function () use ($data, $acquisitionSourceId, $interestTypeIds): array {
                    return $this->createOrMerge($data, $acquisitionSourceId, $interestTypeIds);
                }
            );
        }

        if ($isNew) {
            Mail::to($signup->email)->queue(new WaitlistWelcomeMail($signup));
        }

        return $signup;
    }

    /**
     * @param  array<string, mixed>  $data
     * @param  list<string>  $interestTypeIds
     * @return array{0: WaitlistSignup, 1: bool}
     */
    private function createOrMerge(array $data, string $acquisitionSourceId, array $interestTypeIds): array
    {
        $existing = WaitlistSignup::query()
            ->where('email', $data['email'])
            ->lockForUpdate()
            ->first();

        if ($existing instanceof WaitlistSignup) {
            return [$this->mergeIntoExisting($existing, $data, $interestTypeIds), false];
        }

        return [$this->createSignup($data, $acquisitionSourceId, $interestTypeIds), true];
    }

    /**
     * @param  array<string, mixed>  $data
     * @param  list<string>  $interestTypeIds
     */
    private function createSignup(array $data, string $acquisitionSourceId, array $interestTypeIds): WaitlistSignup
    {
        $marketingConsent = (bool) ($data['marketing_consent'] ?? false);

        $signup = WaitlistSignup::create([
            'first_name' => $data['first_name'],
            'surname' => $data['surname'],
            'email' => $data['email'],
            'country_code' => $data['country_code'],
            'acquisition_source_id' => $acquisitionSourceId,
            'marketing_consent' => $marketingConsent,
            'marketing_consent_at' => $marketingConsent ? now() : null,
            'unsubscribed' => false,
            'countries_of_interest' => $this->countriesOfInterest($data),
            'source_details' => $data['source_details'] ?? null,
        ]);

        $signup->interestTypes()->sync($interestTypeIds);

        return $signup->load(['acquisitionSource', 'interestTypes']);
    }

    /**
     * Merge a repeat submission into the signup that already owns this email.
     *
     * Deliberate rules:
     *  - Names, country and source details are only overwritten when newly supplied.
     *  - Consent is only ever upgraded; a repeat submission never silently revokes it.
     *  - `marketing_consent_at` is stamped only on the transition from false to true,
     *    so the original consent timestamp is preserved.
     *  - Interests are merged, never removed.
     *  - Countries of interest are unioned with what is already stored.
     *  - The original acquisition source is preserved (first-touch attribution).
     *  - Re-joining implies re-subscribing, so `unsubscribed` is cleared.
     *
     * @param  array<string, mixed>  $data
     * @param  list<string>  $interestTypeIds
     */
    private function mergeIntoExisting(WaitlistSignup $signup, array $data, array $interestTypeIds): WaitlistSignup
    {
        foreach (['first_name', 'surname', 'country_code', 'source_details'] as $field) {
            if (isset($data[$field]) && $data[$field] !== '') {
                $signup->{$field} = $data[$field];
            }
        }

        if ((bool) ($data['marketing_consent'] ?? false) && ! $signup->marketing_consent) {
            $signup->marketing_consent = true;
            $signup->marketing_consent_at = now();
        }

        if (isset($data['countries_of_interest']) && is_array($data['countries_of_interest'])) {
            $signup->countries_of_interest = array_values(array_unique(array_merge(
                $signup->countries_of_interest ?? [],
                $data['countries_of_interest'],
            )));
        }

        $signup->unsubscribed = false;

        $signup->save();

        // Attaches only the links that do not exist yet, and removes nothing.
        $signup->interestTypes()->syncWithoutDetaching($interestTypeIds);

        return $signup->load(['acquisitionSource', 'interestTypes']);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return list<string>
     */
    private function countriesOfInterest(array $data): array
    {
        $countries = $data['countries_of_interest'] ?? null;

        if (! is_array($countries) || $countries === []) {
            return ['UG'];
        }

        return array_values(array_unique($countries));
    }

    private function resolveAcquisitionSourceId(string $code): string
    {
        $id = AcquisitionSource::query()
            ->active()
            ->where('code', $code)
            ->value('id');

        if ($id !== null) {
            return (string) $id;
        }

        $fallbackId = AcquisitionSource::query()
            ->active()
            ->whereIn('code', ['OTHER', 'DIRECT'])
            ->orderByRaw("CASE code WHEN 'OTHER' THEN 0 WHEN 'DIRECT' THEN 1 ELSE 2 END")
            ->value('id');

        if ($fallbackId === null) {
            throw ValidationException::withMessages([
                'acquisition_source_code' => 'The selected acquisition source is not recognised.',
            ]);
        }

        return (string) $fallbackId;
    }

    /**
     * @param  array<int, mixed>  $codes
     * @return list<string>
     */
    private function resolveInterestTypeIds(array $codes): array
    {
        $codes = array_values(array_unique(array_filter(
            $codes,
            static fn (mixed $code): bool => is_string($code) && $code !== ''
        )));

        if ($codes === []) {
            return [];
        }

        $found = InterestType::query()
            ->active()
            ->whereIn('code', $codes)
            ->pluck('id', 'code');

        $missing = array_diff($codes, $found->keys()->all());

        if ($missing !== []) {
            throw ValidationException::withMessages([
                'interest_codes' => 'One or more selected interests are not recognised.',
            ]);
        }

        return array_map('strval', $found->values()->all());
    }
}
