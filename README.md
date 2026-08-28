# Kampala Nonstop API

Backend API for **Kampala Nonstop** — a travel discovery, trip planning and concierge platform. Uganda is the launch Destination; Kampala is the initial geographic inventory scope within it.

The platform lets travellers explore Places, Organisations, Services, Activities, Events, Experiences and Tours, save items of interest, and work with the *Nonstop Engine* to build a personalised Trip that is fulfilled through a **Request Booking and Human Confirmation** model — not automated online booking.

> **V0 flow:** Discover → Save → Plan/Orchestrate → Request Booking → Human Confirmation/Fulfilment → Manage Trip → Concierge.
>
> Automation progressively replaces human operations as the platform matures. Payment is **not** a V0 launch gate.

## Reference documents

| Document | Role |
|---|---|
| Kampala Nonstop SRS v2.0 | Functional requirements (supersedes v1.0) |
| Africa Nonstop — Conceptual Data Model & Database Conventions | Terminology and modelling rules |
| Kampala Nonstop Waitlist ERD | Client-provided schema for FR-001 |

SRS v1.0 described a conventional OTA/marketplace flow and **must not** be used as the basis for schema or API design.

## Stack

| Component | Version / Notes |
|---|---|
| PHP | 8.4 (requires `pdo_pgsql` and `pgsql` extensions) |
| Laravel | 11.x |
| Database | **PostgreSQL 18** — not MySQL |
| Frontend | Angular (separate repository, locked) |
| API style | REST, versioned under `/api/v1/` |

PostgreSQL is a hard requirement, not a preference. The schema uses native `uuid` primary keys, `timestamptz` columns and `text[]` arrays, so SQLite and MySQL are not viable substitutes — including for tests.

## Getting started

### 1. Install dependencies

```bash
composer install
```

### 2. Enable the PostgreSQL PHP extensions

In your `php.ini`, uncomment both:

```ini
extension=pdo_pgsql
extension=pgsql
```

Verify with `php -m | grep pgsql` (or `php -m | Select-String pgsql` on Windows).

### 3. Configure the environment

```bash
cp .env.example .env
php artisan key:generate
```

Then set your PostgreSQL credentials in `.env`:

```dotenv
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=kampala_nonstop
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

### 4. Create the databases

Two are needed — the test suite runs against its own database and truncates between tests:

```sql
CREATE DATABASE kampala_nonstop;
CREATE DATABASE kampala_nonstop_testing;
```

### 5. Migrate and seed

```bash
php artisan migrate
php artisan db:seed
```

### 6. Verify

```bash
php artisan serve
curl http://127.0.0.1:8000/api/v1/health
# {"status":"ok","version":"v1"}
```

## Testing

```bash
php artisan test
php artisan test --filter=WaitlistSignupTest
```

Tests target `kampala_nonstop_testing` (configured in `phpunit.xml`) and use `RefreshDatabase`, so your development data is never touched.

## Architecture rules

These are enforced project-wide and mirrored in `.cursor/rules/project.md`, which persists them across AI-assisted sessions.

### Application layers

Keep it simple: **Model → Controller → Form Request**.

- Add a **Service** class only when a controller action involves real business logic — merging duplicate records, multi-step coordination across models. `WaitlistService` qualifies; most controllers will not need one.
- Do **not** introduce Repositories, Actions, DTOs, Interface-per-class patterns, or CQRS.
- All validation goes through Form Requests. No inline `$request->validate()` in controllers.
- PSR-12 and standard Eloquent conventions everywhere else. Format with `./vendor/bin/pint`.

### Database conventions

1. Every table has a UUID primary key named `id`, using PostgreSQL's native `uuid` type. Prefer UUIDv7 — see the `HasUuidPrimaryKey` trait.
2. Table names are plural `snake_case` (`waitlist_signups`, `activity_types`).
3. Foreign keys are `singular_entity_name_id` (`destination_id`, `activity_type_id`).
4. Reference/controlled tables carry `id`, `code`, `name`, `created_at`, `updated_at`, `is_active` and `visibility` (`PUBLIC` | `INTERNAL`).
5. Effective public availability for reference data is always `is_active = true AND visibility = 'PUBLIC'`. Never split this into two independent booleans.
6. Junction tables exist only for genuine many-to-many relationships, named descriptively in plural `snake_case` (`waitlist_signup_interests`). One-to-many gets a foreign key, not a pivot.

> **Documented exception:** the FR-001 reference tables `acquisition_sources` and `interest_types` follow the client's Waitlist ERD instead — a single `active` boolean, no `visibility` column. Availability for those two tables is `active = true`. This is client-driven and approved; do not copy it into new reference tables.

### Domain vocabulary

Terminology drift is the main modelling risk. The short version:

- **`activity_types`** = *what a thing is* (Kayaking, Bird Watching)
- **`tags`** = *what it relates to* (Romantic, Family-Friendly)
- **`attributes`** = *what properties it has* (duration, difficulty)
- **Activity** is a business/directory entity; **Activity Type** is its classification. Category, Entity Type and Subcategory are distinct concepts.
- **Destination** is a product/business scope, not pure administrative geography.
- **Experience** is a curated/composite construct — `experience_groups` does not exist.

## Project structure

```
app/
  Casts/            PostgresTextArray (text[] <-> PHP array)
  Http/
    Controllers/Api/
    Requests/       All validation lives here
  Models/
    Concerns/       HasUuidPrimaryKey (UUIDv7)
  Services/         Only where real business logic exists
database/
  factories/
  migrations/
  seeders/
routes/
  api.php           Mounts the versioned prefix
  api/v1.php        All v1 endpoints
```

## Implemented features

### FR-001 — Waitlist & Acquisition

Built from the client's Waitlist ERD. The referral **`invitations`** table on that ERD is deliberately **not** built; it remains out of scope pending client confirmation that it moves into V0.

**Tables**

| Table | Purpose |
|---|---|
| `acquisition_sources` | Reference: how someone heard about the platform |
| `interest_types` | Reference: travel interests |
| `waitlist_signups` | Signup records, keyed by email |
| `waitlist_signup_interests` | Junction, unique on `(waitlist_signup_id, interest_type_id)` |

There is **no stored status column** — by client design, status is always derived from `unsubscribed`. Use the `active()` and `unsubscribed()` scopes on `WaitlistSignup`; do not add a status column.

**Endpoints**

| Method | Path | Notes |
|---|---|---|
| `POST` | `/api/v1/waitlist` | Public signup |
| `GET` | `/api/v1/admin/waitlist` | Paginated, filterable |
| `GET` | `/api/v1/admin/waitlist/export` | CSV, same filters |

**Signup payload**

```json
{
  "first_name": "Amina",
  "surname": "Okello",
  "email": "amina@example.com",
  "country_code": "UG",
  "acquisition_source_code": "INSTAGRAM",
  "interest_codes": ["NIGHTLIFE", "FOOD"],
  "marketing_consent": true,
  "countries_of_interest": ["UG"],
  "source_details": "utm_source=newsletter"
}
```

The frontend sends human-readable **codes**, never raw UUIDs; the service resolves them. `countries_of_interest` defaults to `["UG"]`. The 201 response returns only `id`, `first_name`, `email` and `created_at` — consent and acquisition internals are never exposed publicly.

**Admin filters:** `acquisition_source_code`, `interest_code`, `unsubscribed`, `country_code`, `created_from`, `created_to`, `per_page`.

**Duplicate handling.** Email is the identity of a signup, so a repeat submission never creates a second row. `WaitlistService::join()` merges instead, inside a transaction with a row lock:

- Names, country and source details are overwritten only when newly supplied.
- Consent is only ever **upgraded**; a repeat submission never silently revokes it. `marketing_consent_at` is stamped only on the false → true transition, preserving the original timestamp.
- Interests are **merged**, never removed.
- `countries_of_interest` is unioned with what is already stored.
- The original acquisition source is preserved (first-touch attribution).
- Re-joining implies re-subscribing, so `unsubscribed` is cleared.

The last three are judgement calls where the specification was silent. All are covered by tests, so changing them will surface clearly.

**Seeded reference data**

```bash
php artisan db:seed --class=WaitlistReferenceSeeder
```

Idempotent — matches on `code` and updates in place.

- **Sources:** `INSTAGRAM`, `FACEBOOK`, `GOOGLE_SEARCH`, `REFERRAL`, `EVENT`, `PARTNER`, `DIRECT`, `OTHER`
- **Interests:** `NIGHTLIFE`, `FOOD`, `MUSIC`, `CULTURE`, `ADVENTURE`, `NATURE`, `SHOPPING`, `LUXURY`, `SPORTS`, `FAMILY`

## Known gaps

- **The admin endpoints are unauthenticated.** `IndexWaitlistSignupRequest::authorize()` returns `true` and the route group carries a TODO. Anyone who can reach the app can list and export the full waitlist, including email addresses and consent state. **Do not deploy beyond local development until auth and role middleware are in place.**
- There is no unsubscribe endpoint yet. `unsubscribed` can currently only be set directly in the database.
- Authentication, user roles and the rest of the V0 scope (discovery, Nonstop Engine, concierge operations, banner advertising, knowledge base) are not started.

## Conventions for contributors

- Run `./vendor/bin/pint` before committing.
- Add a Form Request for every new endpoint that accepts input.
- New reference tables follow rule 4 and 5 above — `is_active` + `visibility`, not `active`.
- When a feature is implemented or materially changed, update this README and `.cursor/rules/project.md` in the same change.
