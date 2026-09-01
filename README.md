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

## Docker setup (recommended)

Use Docker when setting up the project for the first time. Everything runs inside this repository — no root-level Docker config is required.

### Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) 24+
- [Docker Compose](https://docs.docker.com/compose/) v2
- `make` (optional but recommended — all commands below have a plain `docker compose` equivalent)

### First-time setup

```bash
cd kampala-nonstop-api

# 1. Create env files and build images
make init

# 2. Edit Laravel env for Docker (if .env was copied from .env.example)
#    Set these values in .env:
#      DB_HOST=postgres
#      DB_PASSWORD=postgres
#      APP_URL=http://localhost:8000

# 3. Start the stack
make up
```

On first start the entrypoint will:

- wait for PostgreSQL to become healthy
- install Composer dependencies (into a Docker volume)
- generate `APP_KEY` if missing
- run database migrations

### Services and URLs

| Service    | URL / Port              |
| ---------- | ----------------------- |
| API (Nginx)| http://localhost:8000   |
| PostgreSQL | localhost:5432          |
| **DB Admin (Adminer)** | http://localhost:8082 |

### Web database access (Adminer)

Adminer is a web UI similar to phpMyAdmin, for **PostgreSQL**.

1. Start the stack: `make up`
2. Open **http://localhost:8082**
3. Log in with:

| Field    | Value              |
| -------- | ------------------ |
| System   | **PostgreSQL**     |
| Server   | `postgres`         |
| Username | `postgres`         |
| Password | `postgres`         |
| Database | `kampala_nonstop`  |

Change the Adminer port in `.env.docker` if needed:

```dotenv
ADMINER_PORT=8082
```

Adminer is **development only** (not started in production).

Health check:

```bash
curl http://localhost:8000/api/v1/health
# {"status":"ok","version":"v1"}
```

### Environment files

| File                 | Purpose                                      |
| -------------------- | -------------------------------------------- |
| `.env`               | Laravel application config                   |
| `.env.docker`        | Docker Compose ports and Postgres credentials |
| `.env.example`       | Laravel template (local/non-Docker)          |
| `.env.docker.example`| Docker Compose template                      |

Copy templates:

```bash
cp .env.example .env
cp .env.docker.example .env.docker
```

For Docker, set at minimum in `.env`:

```dotenv
DB_HOST=postgres
DB_PASSWORD=postgres
APP_URL=http://localhost:8000
```

Port overrides go in `.env.docker`:

```dotenv
APP_PORT=8000
POSTGRES_PORT=5432
```

### Make commands

Run `make help` to list all targets.

| Command | Description |
| ------- | ----------- |
| `make init` | Create env files and build images |
| `make up` | Start dev stack (app + nginx + postgres) |
| `make down` | Stop containers |
| `make logs` | Tail logs |
| `make ps` | Show container status |
| `make shell` | Bash into the app container |
| `make migrate` | Run migrations |
| `make fresh` | Reset DB and re-run migrations |
| `make test` | Run PHPUnit inside Docker |
| `make artisan cmd="route:list"` | Run any Artisan command |
| `make composer cmd="install"` | Run Composer inside the container |
| `make clean` | Stop stack and remove volumes |
| `make prod-build` | Build production images |
| `make prod-up` | Start production stack |

### Plain Docker Compose (without Make)

```bash
docker compose --env-file .env.docker -f docker-compose.yml up -d
docker compose --env-file .env.docker -f docker-compose.yml ps
docker compose --env-file .env.docker -f docker-compose.yml logs -f
docker compose --env-file .env.docker -f docker-compose.yml down
```

Production:

```bash
docker compose --env-file .env.docker -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Troubleshooting

**Port already in use.** Change `APP_PORT` or `POSTGRES_PORT` in `.env.docker`, then run `make down && make up`.

**502 / 500 on first request.** Wait for Composer install and migrations to finish: `make logs`.

**Reset everything (including database):**

```bash
make clean
make init
make up
```

---

## Local setup (without Docker)

Use this if you prefer PHP and PostgreSQL installed directly on your machine.

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

Built from the client's Waitlist ERD, including friend **invitations**.

**Tables**

| Table | Purpose |
|---|---|
| `acquisition_sources` | Reference: how someone heard about the platform |
| `interest_types` | Reference: travel interests |
| `waitlist_signups` | Signup records, keyed by email |
| `waitlist_signup_interests` | Junction, unique on `(waitlist_signup_id, interest_type_id)` |
| `waitlist_invitations` | Friend invites sent by a registrant |

There is **no stored status column** — by client design, status is always derived from `unsubscribed`. Use the `active()` and `unsubscribed()` scopes on `WaitlistSignup`; do not add a status column.

**Endpoints**

| Method | Path | Notes |
|---|---|---|
| `POST` | `/api/v1/waitlist` | Public signup (sends welcome email on first join) |
| `GET` | `/api/v1/waitlist/unsubscribe/{signup}` | Signed one-click unsubscribe (redirects to frontend) |
| `POST` | `/api/v1/waitlist/invitations` | Public friend invite (sends invitation email) |
| `GET` | `/api/v1/interest-types` | Public active interests (form + discover section) |
| `GET` | `/api/v1/acquisition-sources` | Public active acquisition sources |
| `GET` | `/api/v1/admin/waitlist` | Paginated, filterable |
| `GET` | `/api/v1/admin/waitlist/export` | CSV, same filters |

**Signup payload**

```json
{
  "first_name": "Amina",
  "surname": "Okello",
  "email": "amina@example.com",
  "country_code": "UG",
  "acquisition_source_code": "UNAA_DENVER_2026",
  "interest_codes": ["food_local_life", "culture_heritage"],
  "marketing_consent": true,
  "countries_of_interest": ["UG"],
  "source_details": "utm_source=newsletter"
}
```

The frontend sends human-readable **codes**, never raw UUIDs; the service resolves them. Unknown acquisition source codes fall back to `OTHER` (with the requested code recorded in `source_details`). `countries_of_interest` defaults to `["UG"]`. The 201 response returns `id`, `first_name`, `surname`, `email` and `created_at` — consent and acquisition internals are never exposed publicly.

Set `FRONTEND_URL` in `.env` so welcome and invitation emails link back to `/waitlist/join`, and so unsubscribe redirects land on `/waitlist/unsubscribe`.

**Unsubscribe.** When a signup opts into marketing updates (`marketing_consent = true`), the welcome email includes a signed link to `GET /api/v1/waitlist/unsubscribe/{signup}`. The link is validated by Laravel's `signed` middleware (HMAC tied to `APP_KEY`; no expiry so old emails keep working). A valid click sets `unsubscribed = true` without changing `marketing_consent`, then redirects to `{FRONTEND_URL}/waitlist/unsubscribe?status=success|already|invalid`. Re-joining the waitlist clears `unsubscribed` back to `false`.

**Email delivery** is asynchronous. Welcome and invitation mailables implement `ShouldQueue`, are dispatched with `Mail::queue()`, and retry up to 3 times. Run a queue worker (the Compose `queue` service) with `QUEUE_CONNECTION=database`:

```bash
make up            # includes the queue worker
make queue-logs    # tail worker output
```

Without a running worker, API responses stay fast but emails stay in the `jobs` table until processed.

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
- Authentication, user roles and the rest of the V0 scope (discovery, Nonstop Engine, concierge operations, banner advertising, knowledge base) are not started.

## Conventions for contributors

- Run `./vendor/bin/pint` before committing.
- Add a Form Request for every new endpoint that accepts input.
- New reference tables follow rule 4 and 5 above — `is_active` + `visibility`, not `active`.
- When a feature is implemented or materially changed, update this README and `.cursor/rules/project.md` in the same change.
