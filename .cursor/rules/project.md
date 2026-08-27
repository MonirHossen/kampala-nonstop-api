# Kampala Nonstop API — Project Architecture Rules

These rules apply to the entire `kampala-nonstop-api` codebase. Follow them in every session unless explicitly overridden by the user.

## Stack

- **Framework:** Laravel 11
- **Database:** PostgreSQL (not MySQL)
- **API versioning:** `/api/v1/` prefix

## Application Architecture

1. **Keep the codebase simple:** Model → Controller → Form Request for validation.
2. **Services only when needed:** Add a Service class only when a controller action involves real business logic (e.g. merging duplicate records, multi-step coordination across models).
3. **Do NOT use:** Repositories, Actions, DTOs, Interface-per-class patterns, or CQRS.

## Database Conventions

1. **Primary keys:** Every table has a UUID primary key named `id`, using PostgreSQL's native `uuid` type (not `varchar`). Prefer UUIDv7 generation for new IDs where the app can control it.
2. **Table names:** Plural `snake_case` (e.g. `waitlist_leads`, `activity_types`).
3. **Foreign keys:** `singular_entity_name_id` (e.g. `destination_id`, `activity_type_id`).
4. **Reference/controlled tables** include:
   - `id` (uuid)
   - `code` (unique, stable, machine-readable, e.g. `SPORTS`)
   - `name`
   - `created_at` (timestamptz)
   - `updated_at` (timestamptz)
   - `is_active` (boolean)
   - `visibility` (string/enum: `PUBLIC` or `INTERNAL`)
5. **Public availability rule:** Effective public availability for reference data is always `is_active = true AND visibility = 'PUBLIC'`. Never replace this with two independent booleans.
6. **Junction/pivot tables:** Only for genuine many-to-many relationships, named descriptively in plural `snake_case` (e.g. `activity_tags`, `experience_activities`). One-to-many relationships use a foreign key column, not a pivot table.

## Validation & Code Style

1. **Form Requests:** Use Laravel Form Requests for all validation — no inline `$request->validate()` in controllers.
2. **Conventions:** Follow Laravel naming conventions everywhere else (PSR-12, standard Eloquent conventions).

## Folder Structure

```
app/
  Models/
  Http/
    Controllers/
      Api/
    Requests/
  Services/          # empty until first real business-logic need
routes/
  api.php            # mounts /api/v1/ versioned routes
  api/
    v1.php
```

## Domain Context

Kampala Nonstop is a travel discovery, trip planning, and concierge platform. Key data domains include geography/destinations, taxonomy (activity types, categories, tags), discovery listings (places, activities, events, tours, experiences), trip planning (Nonstop Engine), concierge/booking operations, and waitlist/acquisition. See the SRS and Conceptual Data Model documents for full domain terminology.
