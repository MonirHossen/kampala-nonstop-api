-- Kampala Nonstop - Magma Tours Nyege Nyege 2026
-- PostgreSQL 13+ insert script. Source: Kampala_Nonstop_Magma_2026_Data_Capture.xlsx.
-- AUDIT ACTOR: UPLOAD. No UPDATE/DELETE of existing business records.
-- Run with psql -v ON_ERROR_STOP=1 -f 16_magma_nyege_nyege_2026_insert.sql
-- Apply schemas/reference seeds 9 through 13 and the agreed places rename first.
-- Then apply pricing 14, pricing enhancements 15 AND service_dates 15.
-- Existing core Listing/Option DDL is checked at runtime, not silently assumed.
--
-- IMPORTANT: this capture workbook was NOT a fully validated database seed.
-- Fill the mapping section below before running. Missing required values make
-- the entire business insert roll back. No guessed subcategory, quantity basis,
-- tour operating mode, check-in time, company registration or venue address.
-- Jinja is the primary discovery area; it does not establish every physical
-- endpoint/venue location. R05 uses the supplier's Kalagala Falls/Jinja claim.
-- R02 and R03 physical geographic areas still need confirmation.
-- All records remain unpublished. Tent/banda/cottage units are unverified drafts.
-- Raw catalogue prices are inserted into listing_pricing_profiles/listing_price_offers.
-- All amounts are the ORIGINAL source UGX prices, not doubled occupancy totals.
-- Original supplier group-of-five per-person prices are retained without another discount.
-- Price-validity dates are NULL; no sales windows are needed for this offer.
-- Approximate USD is informational, not a separately payable currency rate.
-- Unknown price bases stay NULL and inactive. Inventory remains source claims, not stock.
-- Extra nights have no amount and remain request-only; C15 is an extra-person supplement.
--
-- Service date migration 15 permits DATE_ONLY service/Experience occurrences.
-- Event 19-22 Nov is INCLUSIVE; P01/P02/P03 check-in 19 Nov, checkout 23 Nov
-- is EXCLUSIVE (four nights). Time zone Africa/Kampala; no fictional clock times.
-- P01-P04 expire at the exclusive cutoff 24 Nov 00:00 Uganda time.
-- Catalogue AND booking-request code must enforce expires_at; schema alone does not.
-- Per-person pricing and two-guest unit occupancy are independent. Group rates
-- use qualifying party size >=5; planner allocates suitable shared/solo units.
-- Missing source details/required mappings still make the entire import fail.
--
-- Reruns are deliberately rejected on duplicate keys; there is no overwrite or
-- ON CONFLICT DO NOTHING that could hide mismatched or incomplete existing data.
BEGIN;
SET LOCAL search_path = public, pg_catalog;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '120s';
SET LOCAL timezone = 'Africa/Kampala';
SET LOCAL standard_conforming_strings = on;
SELECT pg_advisory_xact_lock(hashtext('KNS_MAGMA_NYEGE_NYEGE_2026'));
CREATE TEMP TABLE magma_source_snapshot (data jsonb NOT NULL) ON COMMIT DROP;
INSERT INTO magma_source_snapshot VALUES ($magma_json${
  "offer_map": [
    [
      "P01",
      "Budget: Camp Crew",
      "EXPERIENCE",
      "listings",
      "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "Experience",
      "Four nights camping at Eden Rocks, shared return festival shuttle, breakfast boxes, rain kit, locker and charging access."
    ],
    [
      "P02",
      "Comfort: Shared Stay",
      "EXPERIENCE",
      "listings",
      "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "Experience",
      "Four nights in a twin banda at Eden Rocks, breakfast, shared return festival shuttle, two dinner vouchers, locker and charging access."
    ],
    [
      "P03",
      "Premium: Riverside Escape",
      "EXPERIENCE",
      "listings",
      "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "Experience",
      "Four nights in a container cottage at Jinja Jungle, breakfast, private return festival shuttle, four dinner vouchers, one rafting day with Bungee Uganda, locker and charging access."
    ],
    [
      "P04",
      "Recovery Day bundle",
      "EXPERIENCE",
      "listings",
      "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "Experience",
      "Tubing plus one dinner voucher."
    ],
    [
      "C01",
      "Camping accommodation",
      "SERVICE",
      "listings",
      "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "Component",
      "Waterproof rented tent at Eden Rocks. Tent occupancy is not stated."
    ],
    [
      "C02",
      "Banda accommodation",
      "SERVICE",
      "listings",
      "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "Component",
      "Twin banda at Eden Rocks. Advertised for two sharing, with sole-occupancy pricing."
    ],
    [
      "C03",
      "Cottage accommodation",
      "SERVICE",
      "listings",
      "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "Component",
      "Container cottage at Jinja Jungle with one bed and one day bed. Two cottages advertised."
    ],
    [
      "C04",
      "Shared festival shuttle",
      "SERVICE",
      "listings",
      "99f6d231-4551-5858-9edf-91a62a08adfe",
      "Component",
      "Return shared festival transport. Included package service provides after-midnight pickup every festival night."
    ],
    [
      "C05",
      "Private festival shuttle",
      "SERVICE",
      "listings",
      "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "Component",
      "Premium includes private transport to and from the festival every festival night. Standalone private arrangements need confirmation."
    ],
    [
      "C06",
      "Breakfast provision",
      "SERVICE",
      "listings",
      "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "Component",
      "Breakfast at the accommodation. Budget includes a breakfast box each morning; a late breakfast box is separately purchasable."
    ],
    [
      "C07",
      "Dinner entitlement",
      "SERVICE",
      "listings",
      "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "Component",
      "Voucher redeemable for dinner. Comfort specifies the lodge; other redeeming venues and meal terms are unconfirmed."
    ],
    [
      "C08",
      "Rain-kit provision",
      "SERVICE",
      "listings",
      "07a162a6-4b89-52ac-9047-66f561432546",
      "Component",
      "Physical kit. Budget specifies a poncho and dry bag; confirm separately sold kit contents."
    ],
    [
      "C09",
      "Locker and charging access",
      "SERVICE",
      "listings",
      "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "Component",
      "Secure locker and phone charging pass, sold per stay and included in the festival packages."
    ],
    [
      "C10",
      "Recovery Day: tubing",
      "ACTIVITY",
      "listings",
      "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "Component",
      "Tubing; activity date and participant pricing basis to confirm."
    ],
    [
      "C11",
      "Recovery Day: rafting",
      "ACTIVITY",
      "listings",
      "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "Component",
      "White-water rafting. Premium names Bungee Uganda for one day; the standalone provider is not confirmed."
    ],
    [
      "C12",
      "Quad biking",
      "ACTIVITY",
      "listings",
      "6c1250e9-f87b-5430-8768-843518060f35",
      "Component",
      "Quad biking sold per hour; participant or vehicle basis not stated."
    ],
    [
      "C13",
      "Guided Jinja tour",
      "TOUR",
      "listings",
      "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "Component",
      "Guided tour of Jinja, priced per person. Route, duration and departure details are not supplied."
    ],
    [
      "C14",
      "Airport transfer: Entebbe-Jinja return",
      "SERVICE",
      "listings",
      "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "Component",
      "Entebbe-Jinja return transfer: whole vehicle for up to five people or per person in a full vehicle."
    ],
    [
      "E01",
      "Nyege Nyege 2026",
      "EVENT",
      "listings",
      "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "Event association",
      "Festival at Kalagala Falls, Jinja, 19-22 November 2026. Festival tickets are excluded from Magma packages."
    ],
    [
      "C15",
      "Extra person at Jinja Jungle",
      "ADJUSTMENT",
      "listing_adjustment_rules",
      null,
      "EXTRA_PARTICIPANT",
      "One extra guest per night at Jinja Jungle; capacity and benefits to confirm."
    ],
    [
      "C16",
      "Extra accommodation nights",
      "ADJUSTMENT",
      "listing_adjustment_rules",
      null,
      "PERIOD_EXTENSION",
      "Extra nights on 18 or 23 November, on request."
    ]
  ],
  "rates": [
    {
      "rate_ref": "P01-R1",
      "listing_ref": "P01",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Standard",
      "source_price_ugx": 455000,
      "source_approx_usd": 110,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P01-R2",
      "listing_ref": "P01",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Group 5+",
      "source_price_ugx": 430000,
      "source_approx_usd": 104,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Four-night package total",
      "minimum_group_size": 5,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P01-R3",
      "listing_ref": "P01",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Solo",
      "source_price_ugx": 455000,
      "source_approx_usd": 110,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P02-R1",
      "listing_ref": "P02",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "option_ref": "P02-SHARED",
      "listing_option_id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "variant": "Standard shared",
      "source_price_ugx": 660000,
      "source_approx_usd": 160,
      "priced_guest_count": 2,
      "occupancy_multiplier": 2,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P02-R2",
      "listing_ref": "P02",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "option_ref": "P02-SHARED",
      "listing_option_id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "variant": "Group 5+ shared",
      "source_price_ugx": 625000,
      "source_approx_usd": 152,
      "priced_guest_count": 2,
      "occupancy_multiplier": 2,
      "price_basis": "Four-night package total",
      "minimum_group_size": 5,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P02-R3",
      "listing_ref": "P02",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "option_ref": "P02-SOLO",
      "listing_option_id": "3573c8c5-dde0-5137-92fb-f461fc3878cb",
      "variant": "Solo",
      "source_price_ugx": 1090000,
      "source_approx_usd": 265,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P03-R1",
      "listing_ref": "P03",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "option_ref": "P03-SHARED",
      "listing_option_id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "variant": "Standard shared",
      "source_price_ugx": 2250000,
      "source_approx_usd": 546,
      "priced_guest_count": 2,
      "occupancy_multiplier": 2,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P03-R2",
      "listing_ref": "P03",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "option_ref": "P03-SHARED",
      "listing_option_id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "variant": "Group 5+ shared",
      "source_price_ugx": 2140000,
      "source_approx_usd": 519,
      "priced_guest_count": 2,
      "occupancy_multiplier": 2,
      "price_basis": "Four-night package total",
      "minimum_group_size": 5,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "P03-R3",
      "listing_ref": "P03",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "option_ref": "P03-SOLO",
      "listing_option_id": "a259a2b3-58d3-53b0-8b72-83d21b3b9e76",
      "variant": "Solo",
      "source_price_ugx": 3735000,
      "source_approx_usd": 907,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Four-night package total",
      "minimum_group_size": null,
      "detail": "Original price per person; derived total uses stated occupancy. Discount discrepancy unresolved."
    },
    {
      "rate_ref": "C04-R10",
      "listing_ref": "C04",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 30000,
      "source_approx_usd": 7,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Per person per night",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C05-R11",
      "listing_ref": "C05",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 70000,
      "source_approx_usd": 17,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Per person per night",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C06-R12",
      "listing_ref": "C06",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "option_ref": "C06-LATE",
      "listing_option_id": "c21174f3-126a-5737-9cf7-93a1705a47e4",
      "variant": "Add-on / adjustment",
      "source_price_ugx": 20000,
      "source_approx_usd": 5,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Per late breakfast box",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C07-R13",
      "listing_ref": "C07",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 35000,
      "source_approx_usd": 8,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Per dinner voucher",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C08-R14",
      "listing_ref": "C08",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 30000,
      "source_approx_usd": 7,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Per rain kit",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C09-R15",
      "listing_ref": "C09",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 35000,
      "source_approx_usd": 8,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Per stay; guest basis unclear",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C10-R16",
      "listing_ref": "C10",
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 120000,
      "source_approx_usd": 29,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Participant basis not stated",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C11-R17",
      "listing_ref": "C11",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 300000,
      "source_approx_usd": 73,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Participant basis not stated",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "P04-R18",
      "listing_ref": "P04",
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 155000,
      "source_approx_usd": 38,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Tubing plus one dinner voucher",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C12-R19",
      "listing_ref": "C12",
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 255000,
      "source_approx_usd": 62,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Per hour; participant/vehicle basis unclear",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C13-R20",
      "listing_ref": "C13",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 245000,
      "source_approx_usd": 59,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Per person",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C14-R21",
      "listing_ref": "C14",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "option_ref": "C14-VEHICLE",
      "listing_option_id": "a117e2f1-7ee1-5b36-972c-dda97f1a4e1e",
      "variant": "Add-on / adjustment",
      "source_price_ugx": 2470000,
      "source_approx_usd": 600,
      "priced_guest_count": 5,
      "occupancy_multiplier": 1,
      "price_basis": "Per vehicle up to five people",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C14-R22",
      "listing_ref": "C14",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "option_ref": "C14-SEAT",
      "listing_option_id": "0eae2e85-3212-5cbd-97e9-9512b452a5bf",
      "variant": "Add-on / adjustment",
      "source_price_ugx": 495000,
      "source_approx_usd": 120,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Per person in a full vehicle",
      "minimum_group_size": null,
      "detail": ""
    },
    {
      "rate_ref": "C15-R23",
      "listing_ref": "C15",
      "listing_id": null,
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": 245000,
      "source_approx_usd": 59,
      "priced_guest_count": 1,
      "occupancy_multiplier": 1,
      "price_basis": "Per extra person per night",
      "minimum_group_size": null,
      "detail": "Adjustment to C03/P03"
    },
    {
      "rate_ref": "C16-R24",
      "listing_ref": "C16",
      "listing_id": null,
      "option_ref": null,
      "listing_option_id": null,
      "variant": "Add-on / adjustment",
      "source_price_ugx": null,
      "source_approx_usd": null,
      "priced_guest_count": null,
      "occupancy_multiplier": 1,
      "price_basis": "Extra night on 18 or 23 Nov; on request",
      "minimum_group_size": null,
      "detail": "Accommodation extension adjustment"
    }
  ],
  "inventory": [
    [
      "R03",
      "Cottage count",
      2,
      "Cottages advertised, not available stock",
      "Physical Unit identities, capacities and reservations unknown."
    ],
    [
      "R02",
      "Tent count",
      null,
      "Not supplied",
      "No available stock inferred."
    ],
    [
      "R02",
      "Banda count",
      null,
      "Not supplied",
      "No available stock inferred."
    ],
    [
      "C14",
      "Vehicle guest limit",
      5,
      "Advertised offer limit",
      "Actual vehicle identities/capacity must be checked."
    ],
    [
      "R02",
      "Festival drive minutes",
      30,
      "Supplier estimate",
      "Not a verified routing calculation."
    ],
    [
      "R03",
      "Festival drive minutes",
      30,
      "Supplier estimate",
      "Not a verified routing calculation."
    ]
  ],
  "issues": [
    [
      "Q01",
      "U01-U04",
      "Unit identities",
      "Unit rows are unverified capture candidates, not real inventory records. Resolve actual unit codes/capacities before creating resources.",
      "Resources / Units",
      "BLOCKER"
    ],
    [
      "Q02",
      "C06-C09",
      "Entitlement policy defaults",
      "Single/unlimited use, transferability and collection settings are proposed configuration, not confirmed supplier facts. Source meal/pass details remain incomplete.",
      "Entitlements",
      "BLOCKER"
    ],
    [
      "Q03",
      "C07",
      "Dinner redemption venue",
      "Comfort has an Eden Rocks child option and redemption venue. Premium and standalone venues are still unconfirmed.",
      "Entitlement places",
      "REVIEW"
    ],
    [
      "Q04",
      "Components",
      "Unconfirmed quantity basis",
      "Dinner quantities 2/4 may be per person or room; kit/pass/rafting/tubing basis not fully specified. Blank quantity_basis is deliberate and blocks direct import. Do not multiply entitlements silently.",
      "Components",
      "BLOCKER"
    ],
    [
      "Q05",
      "P01-P03",
      "Accommodation quantity",
      "PER_BOOKING is a draft one-stay template. Multi-room/unit quantities must be entered and validated at booking; do not assume one room for every party.",
      "Components / booking design",
      "BLOCKER"
    ],
    [
      "Q06",
      "Fulfilment",
      "Missing venues and operational responsibilities",
      "Venue resources for tubing, rafting, quad biking and other services are not fully named. Do not publish until mandatory venues and operator responsibilities are confirmed. Magma seller status does not prove it delivers every service.",
      "Fulfilment",
      "BLOCKER"
    ],
    [
      "Q07",
      "C13",
      "Tour details",
      "One-day/no-overnight structure is a capture assumption. Shared/private participation, schedule mode, meeting point, route, stops and duration are unknown. Blank required policy fields prevent import.",
      "Tour policies / Tour items",
      "BLOCKER"
    ],
    [
      "Q08",
      "Documents",
      "Waiver and terms readiness",
      "Supplier terms stored in draft document version. No waiver text, published date or signed acceptance is invented. Obtain waiver versions and resolve terms before activation.",
      "Documents / Obligations",
      "BLOCKER"
    ],
    [
      "Q09",
      "Prices",
      "Pricing model absent",
      "All monetary rows are preserved in Rate capture. They are not inserts for listing_rates, which remains a proposal. USD converted at 4,120; retain original rounded USD separately.",
      "Rate capture",
      "SCHEMA GAP"
    ],
    [
      "Q10",
      "P01-P03",
      "Group discount discrepancy",
      "Source states 5%, but listed group prices differ. Preserve advertised rates; do not apply a second automatic 5% deduction.",
      "Rate capture",
      "REVIEW"
    ],
    [
      "Q11",
      "C14",
      "Vehicle price rounding",
      "Five shared seats at UGX 495,000 total UGX 2,475,000 vs UGX 2,470,000 per vehicle. Confirm rounding and full-vehicle guarantee.",
      "Rate capture / Journey policies",
      "REVIEW"
    ],
    [
      "Q12",
      "P01-P03 / C16",
      "Stay dates",
      "Package 19-22 Nov, checkout 23 Nov; minimum 3 nights; extra night 23 Nov implies checkout 24 Nov. Exact check-in/out hours unprovided.",
      "Stay policies",
      "REVIEW"
    ],
    [
      "Q13",
      "All",
      "Missing shared lookup IDs",
      "Resolve listing types, subcategories, geography, resource types/roles and booking information fields against actual DB. Blank FK IDs must not be imported.",
      "Listings / Resources / Fulfilment / Customer inputs",
      "BLOCKER"
    ],
    [
      "Q14",
      "Places / Units",
      "Legacy schema rename",
      "Resource SQL 9 uses locations and resource_units.location_id; Services/Events/Tours use places. Workbook follows agreed places/place_id names. Verify rename migration and live column names before import.",
      "Places / Units",
      "BLOCKER"
    ],
    [
      "Q15",
      "Listings / Options",
      "Core DDL evidence",
      "Core columns mapped from shared form contracts; exact deployed listings and listing_options DDL was not supplied. Verify field names and constraints before import.",
      "Schema dictionary",
      "BLOCKER"
    ],
    [
      "Q16",
      "Activities",
      "Activity subtype",
      "No separate Activity business-table DDL in retrieved schema set. Tubing, rafting and quad biking captured as ACTIVITY Listings, options and obligations; do not invent activities columns.",
      "Listings",
      "SCHEMA GAP"
    ],
    [
      "Q17",
      "Tour items",
      "No itinerary supplied",
      "Tour itinerary item columns included with no fictional stops or timings. Populate when supplier provides itinerary.",
      "Tour items",
      "REVIEW"
    ],
    [
      "Q18",
      "Inventory / booking",
      "Reservation model",
      "Inventory facts are supplier claims, not live stock. No bookings, guests, holds, confirmed allocations or quote records exist in this offer workbook.",
      "Inventory capture",
      "SCHEMA GAP"
    ],
    [
      "Q19",
      "C15 / C16",
      "Adjustment identity",
      "Original PDF labels retained; mapped to EXTRA_PARTICIPANT and PERIOD_EXTENSION rules, not fabricated separate Services. Rates preserve their source references.",
      "Adjustments / Rate capture",
      "REVIEW"
    ]
  ],
  "sources": [
    [
      "Derived mapping",
      "Kampala_Nonstop_Magma_Tours_Nyege_Nyege_2026_Festival_Packages(2).pdf",
      "libfile_4bd06a4753588191b372b691ecca4ea9",
      "Pages 1-4; capture refs and occupancy totals"
    ],
    [
      "Supplier offer",
      "Nyege Nyege 2026 Packages - Magma Tours.pdf",
      "libfile_60e6ee37325c8191b4954dadd92edb0e",
      "Packages, add-ons and booking terms; indicative USD rate 4,120"
    ],
    [
      "Schema",
      "9_kampala_nonstop_resources_schema.sql",
      null,
      "DDL inspected; no live database connection"
    ],
    [
      "Schema",
      "10_kampala_nonstop_experiences_schema.sql",
      null,
      "DDL inspected; no live database connection"
    ],
    [
      "Schema",
      "11_kampala_nonstop_services_schema.sql",
      null,
      "DDL inspected; no live database connection"
    ],
    [
      "Schema",
      "12_kampala_nonstop_events_schema.sql",
      null,
      "DDL inspected; no live database connection"
    ],
    [
      "Schema",
      "13_kampala_nonstop_tours_schema.sql",
      null,
      "DDL inspected; no live database connection"
    ]
  ],
  "guide": [
    [
      "Purpose",
      "Populated capture workbook for Magma festival packages, component listings, add-ons, resources and schema mappings."
    ],
    [
      "State",
      "All business rows are DRAFT. This is a data-capture workbook, not an import-ready seed or proof of confirmed availability."
    ],
    [
      "Identifiers",
      "Deterministic staging UUIDs link sheets; reuse existing database identities after duplicate checks. _capture_ref / _status / _source / *_code helper columns are workbook-only."
    ],
    [
      "Unknowns",
      "Blank means not supplied, unresolved or awaiting confirmation; not zero. Required blanks are highlighted. Review sheet lists blockers."
    ],
    [
      "Audit",
      "created_at / updated_at / created_by / updated_by are included but blank; authenticated API/import process supplies them."
    ],
    [
      "Pricing",
      "Rate capture preserves all source prices and calculates occupancy totals / indicative USD. No monetary table is asserted to exist."
    ],
    [
      "Dates",
      "DATE_ONLY occurrences preserve 19-22 Nov inclusive stay/festival dates. Check-out is separately stated as 23 Nov; do not interpret occurrence end as occupied night 23 Nov."
    ],
    [
      "Occupancy",
      "Comfort/Premium standard/group totals cover 2 guests; solo totals cover 1. Group eligibility 5+ is separate from room occupancy."
    ],
    [
      "Components",
      "Shared components reused by UUID. Solo/shared accommodation uses package-option replacements. Unknown entitlement quantity bases remain blank."
    ],
    [
      "Adjustments",
      "C15/C16 are mapped to existing adjustment rules; no duplicate bookable Service is created solely for occupancy/date changes."
    ],
    [
      "Scope",
      "No fake contacts, organisers, itinerary stops, actual vehicles/drivers, admissions sales or customer bookings. Unit candidates are explicitly unverified."
    ],
    [
      "Sources",
      "Derived package PDF version (2), original Magma PDF and current schema files 9-13; source catalogue below."
    ]
  ],
  "manifest": [
    [
      "Listings",
      "listings",
      19,
      "africa_nonstop_listing_admin_ui_spec.md / save_validation_spec.md",
      "Draft records"
    ],
    [
      "Options",
      "listing_options",
      15,
      "africa_nonstop_listing_admin_ui_spec.md / save_validation_spec.md",
      "Draft records"
    ],
    [
      "Experiences",
      "experiences",
      4,
      "10_kampala_nonstop_experiences_schema.sql",
      "Draft records"
    ],
    [
      "Components",
      "experience_components",
      22,
      "10_kampala_nonstop_experiences_schema.sql",
      "Draft records"
    ],
    [
      "Inclusion rules",
      "experience_component_inclusion_rules",
      6,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Resources",
      "resources",
      9,
      "9_kampala_nonstop_resources_schema.sql",
      "Draft records"
    ],
    [
      "Places",
      "places",
      3,
      "9_kampala_nonstop_resources_schema.sql (legacy locations; agreed rename to places)",
      "Draft records"
    ],
    [
      "Organisations",
      "organisations",
      2,
      "9_kampala_nonstop_resources_schema.sql",
      "Draft records"
    ],
    [
      "Units",
      "resource_units",
      4,
      "9_kampala_nonstop_resources_schema.sql",
      "Draft records"
    ],
    [
      "Services",
      "services",
      10,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Config scopes",
      "listing_configuration_scopes",
      58,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Service schedules",
      "service_schedule_policies",
      10,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Delivery",
      "service_delivery_configurations",
      10,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Stay policies",
      "service_stay_policies",
      7,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Journey policies",
      "service_journey_policies",
      4,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Journey legs",
      "service_journey_legs",
      8,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Entitlements",
      "service_entitlement_policies",
      5,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Entitlement places",
      "service_entitlement_resources",
      1,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Adjustments",
      "listing_adjustment_rules",
      6,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Event links",
      "listing_event_associations",
      18,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Occurrences",
      "listing_occurrences",
      4,
      "10_kampala_nonstop_experiences_schema.sql",
      "Draft records"
    ],
    [
      "Events",
      "events",
      1,
      "12_kampala_nonstop_events_schema.sql",
      "Draft records"
    ],
    [
      "Event details",
      "event_occurrence_details",
      1,
      "12_kampala_nonstop_events_schema.sql",
      "Draft records"
    ],
    [
      "Event venues",
      "event_occurrence_places",
      1,
      "12_kampala_nonstop_events_schema.sql",
      "Draft records"
    ],
    [
      "Fulfilment",
      "listing_fulfilment_requirements",
      29,
      "9_kampala_nonstop_resources_schema.sql",
      "Draft records"
    ],
    [
      "Resource links",
      "listing_resources",
      22,
      "9_kampala_nonstop_resources_schema.sql",
      "Draft records"
    ],
    [
      "Customer inputs",
      "listing_customer_information_requirements",
      27,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Documents",
      "booking_documents",
      1,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Document versions",
      "booking_document_versions",
      1,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Obligations",
      "listing_booking_obligations",
      6,
      "11_kampala_nonstop_services_schema.sql",
      "Draft records"
    ],
    [
      "Tours",
      "tours",
      1,
      "13_kampala_nonstop_tours_schema.sql",
      "Draft records"
    ],
    [
      "Tour policies",
      "tour_policies",
      1,
      "13_kampala_nonstop_tours_schema.sql",
      "Draft records"
    ],
    [
      "Tour days",
      "tour_itinerary_days",
      1,
      "13_kampala_nonstop_tours_schema.sql",
      "Draft records"
    ],
    [
      "Tour items",
      "tour_itinerary_items",
      0,
      "13_kampala_nonstop_tours_schema.sql",
      "Empty template; source not supplied"
    ]
  ],
  "ugx_per_usd": 4120,
  "supplier_source_text": "Nyege Nyege 2026 Packages - Magma Tours\n\n\n\n\nNyege Nyege 2026 Festival Packages\nMagma Tours · Kalagala Falls, Jinja · 19–22 November 2026\n\nStay near the festival without the hassle. Choose from three packages, each with a\nfestival shuttle built in so you get to the grounds and back safely, even after midnight.\nPrices are per person for 4 nights (nights of 19–22 Nov, check-out 23 Nov).\n\n\nPackages at a glance\n\n                                   Budget: Camp Crew         Comfort: Shared    Premium: Riverside\n                                                             Stay               Escape\n\n  Where you stay                   Waterproof rented tent,   Twin banda, Eden   Container cottage,\n                                   Eden Rocks                Rocks              Jinja Jungle\n\n  Drive to festival                30 min                    30 min             30 min\n\n  Price per person                 UGX 455,000 (~$110)       UGX 660,000        UGX 2,250,000\n                                                             (~$160)            (~$546)\n\n  Group of 5+ (per                 UGX 430,000 (~$104)       UGX 625,000        UGX 2,140,000\n  person)                                                    (~$152)            (~$519)\n\n  Solo traveller                   UGX 455,000 (~$110)       UGX 1,090,000      UGX 3,735,000\n                                                             (~$265)            (~$907)\n\n\nPrices based on 1 USD = 4,120 UGX. Comfort and Premium prices assume two people\nsharing; solo prices cover a whole room for one guest.\n\n\nBudget: Camp Crew\nUGX 455,000 (~$110) per person · 4 nights\n\nFor festival-goers who want to spend on the music, not the bed. Camp at Eden Rocks in a\nwaterproof rented tent, 30 minutes from the festival grounds.\n\nIncludes\n\n     4 nights camping in a waterproof rented tent\n     Return festival shuttle every festival night, including after-midnight pickup\n     Breakfast box each morning, ready when you get back at dawn\n     Rain kit (poncho and dry bag)\n     Secure locker and phone charging pass\n\n\n                                                                                                Page 1 of 4\n\fNyege Nyege 2026 Packages - Magma Tours\n\n\n\n\nBest for: young, social campers and solo travellers who will make friends at camp.\n\n\nComfort: Shared Stay\nUGX 660,000 (~$160) per person sharing · 4 nights\n\nA proper bed and a quiet base to recover. Share a twin banda at Eden Rocks, 30 minutes\nfrom the festival grounds.\n\nIncludes\n\n     4 nights in a twin banda, shared by 2 guests\n     Breakfast included\n     Return festival shuttle every festival night, including after-midnight pickup\n     2 dinner vouchers at the lodge\n     Secure locker and phone charging pass\n\nBest for: friends and couples who want comfort without the premium price.\n\n\nPremium: Riverside Escape\nUGX 2,250,000 (~$546) per person sharing · 4 nights\n\nOur top package, in a container cottage at Jinja Jungle with one bed and one day bed, 30\nminutes from the festival grounds. Availability is limited, as Jinja Jungle has only 2\ncottages.\n\nIncludes\n\n     4 nights in a container cottage, shared by 2 guests\n     Breakfast included\n     Private shuttle to and from the festival every festival night\n     4 dinner vouchers\n     1 white-water rafting day with Bungee Uganda\n     Secure locker and phone charging pass\n\nBest for: couples and VIP guests who want comfort, privacy and a daytime adventure.\n\n\n\n\n                                                                                     Page 2 of 4\n\fNyege Nyege 2026 Packages - Magma Tours\n\n\n\n\nAdd-ons\n\n  Add-on                                                Price (UGX)   ~USD\n\n  Festival shuttle pass, shared (per person, per        30,000        $7\n  night)\n\n  Private shuttle (per person, per night)               70,000        $17\n\n  Late breakfast box                                    20,000        $5\n\n  Dinner voucher                                        35,000        $8\n\n  Rain kit                                              30,000        $7\n\n  Locker and charging pass (per stay)                   35,000        $8\n\n  Recovery Day: tubing                                  120,000       $29\n\n  Recovery Day: rafting                                 300,000       $73\n\n  Recovery Day bundle (tubing and a dinner              155,000       $38\n  voucher)\n\n  Quad biking (per hour)                                255,000       $62\n\n  Guided Jinja tour (per person)                        245,000       $59\n\n  Airport transfer, Entebbe to Jinja and back (per      2,470,000     $600\n  vehicle, up to 5 people)\n\n  Airport transfer, round trip, per person in a full    495,000       $120\n  vehicle\n\n  Extra person at Jinja Jungle (per night)              245,000       $59\n\n  Extra nights (18 or 23 Nov)                           On request\n\n\n\n\nBooking terms\n     Deposit: 50% confirms your booking. The balance is due 14 days before arrival.\n     Cancellation: more than 30 days before arrival, your deposit is refunded less an admin\n     fee. Between 14 and 30 days, the deposit is forfeited. Under 14 days, there is no refund,\n     but you can transfer the booking to another guest.\n     Stay dates: arrive from 18 Nov and leave on 23 Nov. Minimum stay is 3 nights.\n     Payment: mobile money, card or bank transfer. The UGX price is locked at the exchange\n     rate on the day you book.\n\n\n\n                                                                                        Page 3 of 4\n\fNyege Nyege 2026 Packages - Magma Tours\n\n\n\n\n     Groups: 5% off per person for groups of 5 or more.\n     Weather: November is rainy season. All rented tents are waterproof. If a camp floods,\n     you can upgrade to a room at the price difference.\n     Safety: activities such as rafting, tubing and quad biking need a signed waiver. We\n     recommend travel insurance.\n     Not included: festival ticket, drinks, personal spending, travel insurance and airport\n     transfers unless added.\n\nBook with Magma Tours to hold your place. Rooms and cottages are limited.\n\n\n\n\n                                                                                        Page 4 of 4\n\f"
}$magma_json$::jsonb);
CREATE TEMP TABLE magma_rows (
 ordinal integer PRIMARY KEY, table_name text NOT NULL,
 capture_ref text NOT NULL, payload jsonb NOT NULL,
 UNIQUE(table_name,capture_ref)
) ON COMMIT DROP;
INSERT INTO magma_rows
SELECT ordinal,table_name,capture_ref,payload
FROM jsonb_to_recordset($magma_json$[
  {
    "ordinal": 1,
    "table_name": "resources",
    "capture_ref": "R01",
    "payload": {
      "id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "resource_type_id": null,
      "name": "Magma Tours",
      "summary": "Package seller and coordinator; not asserted to be the festival organiser.",
      "description": "Package seller and coordinator; not asserted to be the festival organiser.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "ORGANISATION"
    }
  },
  {
    "ordinal": 2,
    "table_name": "resources",
    "capture_ref": "R02",
    "payload": {
      "id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "resource_type_id": null,
      "name": "Eden Rocks",
      "summary": "Camping and twin bandas; advertised 30-minute drive from festival.",
      "description": "Camping and twin bandas; advertised 30-minute drive from festival.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "PLACE"
    }
  },
  {
    "ordinal": 3,
    "table_name": "resources",
    "capture_ref": "R03",
    "payload": {
      "id": "9b625049-d5f0-5637-9a23-d9e5b5d52f1e",
      "resource_type_id": null,
      "name": "Jinja Jungle",
      "summary": "Container cottages; two cottages advertised; 30-minute drive from festival.",
      "description": "Container cottages; two cottages advertised; 30-minute drive from festival.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "PLACE"
    }
  },
  {
    "ordinal": 4,
    "table_name": "resources",
    "capture_ref": "R04",
    "payload": {
      "id": "83b442cf-1530-54b3-b466-15489702949b",
      "resource_type_id": null,
      "name": "Bungee Uganda",
      "summary": "Named provider of Premium package rafting day.",
      "description": "Named provider of Premium package rafting day.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "ORGANISATION"
    }
  },
  {
    "ordinal": 5,
    "table_name": "resources",
    "capture_ref": "R05",
    "payload": {
      "id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "resource_type_id": null,
      "name": "Kalagala Falls festival venue",
      "summary": "Festival venue as described by Magma; exact address and site identity to confirm.",
      "description": "Festival venue as described by Magma; exact address and site identity to confirm.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "PLACE"
    }
  },
  {
    "ordinal": 6,
    "table_name": "resources",
    "capture_ref": "U01",
    "payload": {
      "id": "f74e4d26-ee79-5c73-a264-3f578b8f2259",
      "resource_type_id": null,
      "name": "Unverified U01 accommodation candidate",
      "summary": null,
      "description": "Tent inventory and individual identities unknown.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "UNIT"
    }
  },
  {
    "ordinal": 7,
    "table_name": "resources",
    "capture_ref": "U02",
    "payload": {
      "id": "31d70b6a-a70e-5b1b-a8c8-7137f01ede79",
      "resource_type_id": null,
      "name": "Unverified U02 accommodation candidate",
      "summary": null,
      "description": "Twin banda inventory and individual identities unknown.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "UNIT"
    }
  },
  {
    "ordinal": 8,
    "table_name": "resources",
    "capture_ref": "U03",
    "payload": {
      "id": "ad6d0e74-6645-52d3-bb98-e5b7cce5ef70",
      "resource_type_id": null,
      "name": "Unverified U03 accommodation candidate",
      "summary": null,
      "description": "First of two advertised cottages; identity and physical maximum capacity unverified.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "UNIT"
    }
  },
  {
    "ordinal": 9,
    "table_name": "resources",
    "capture_ref": "U04",
    "payload": {
      "id": "8dab755c-a9d7-530a-bec4-2c30f65e0709",
      "resource_type_id": null,
      "name": "Unverified U04 accommodation candidate",
      "summary": null,
      "description": "Second of two advertised cottages; identity and physical maximum capacity unverified.",
      "operational_status": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_type_code": "UNIT"
    }
  },
  {
    "ordinal": 10,
    "table_name": "places",
    "capture_ref": "R02",
    "payload": {
      "resource_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "geographic_area_id": null,
      "address_line_1": null,
      "address_line_2": null,
      "postcode": null,
      "latitude": null,
      "longitude": null,
      "directions": "Camping and twin bandas; advertised 30-minute drive from festival.",
      "arrival_instructions": null,
      "pickup_dropoff_instructions": null,
      "time_zone": "Africa/Kampala",
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 11,
    "table_name": "places",
    "capture_ref": "R03",
    "payload": {
      "resource_id": "9b625049-d5f0-5637-9a23-d9e5b5d52f1e",
      "geographic_area_id": null,
      "address_line_1": null,
      "address_line_2": null,
      "postcode": null,
      "latitude": null,
      "longitude": null,
      "directions": "Container cottages; two cottages advertised; 30-minute drive from festival.",
      "arrival_instructions": null,
      "pickup_dropoff_instructions": null,
      "time_zone": "Africa/Kampala",
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 12,
    "table_name": "places",
    "capture_ref": "R05",
    "payload": {
      "resource_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "geographic_area_id": null,
      "address_line_1": null,
      "address_line_2": null,
      "postcode": null,
      "latitude": null,
      "longitude": null,
      "directions": "Festival venue as described by Magma; exact address and site identity to confirm.",
      "arrival_instructions": null,
      "pickup_dropoff_instructions": null,
      "time_zone": "Africa/Kampala",
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 13,
    "table_name": "organisations",
    "capture_ref": "R01",
    "payload": {
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "legal_name": null,
      "registration_number": null,
      "registration_country_code": null,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 14,
    "table_name": "organisations",
    "capture_ref": "R04",
    "payload": {
      "resource_id": "83b442cf-1530-54b3-b466-15489702949b",
      "legal_name": null,
      "registration_number": null,
      "registration_country_code": null,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "R04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 15,
    "table_name": "resource_units",
    "capture_ref": "U01",
    "payload": {
      "resource_id": "f74e4d26-ee79-5c73-a264-3f578b8f2259",
      "place_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "unit_code": null,
      "capacity": null,
      "is_individually_assignable": true,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 16,
    "table_name": "resource_units",
    "capture_ref": "U02",
    "payload": {
      "resource_id": "31d70b6a-a70e-5b1b-a8c8-7137f01ede79",
      "place_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "unit_code": null,
      "capacity": null,
      "is_individually_assignable": true,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 17,
    "table_name": "resource_units",
    "capture_ref": "U03",
    "payload": {
      "resource_id": "ad6d0e74-6645-52d3-bb98-e5b7cce5ef70",
      "place_id": "9b625049-d5f0-5637-9a23-d9e5b5d52f1e",
      "unit_code": null,
      "capacity": null,
      "is_individually_assignable": true,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 18,
    "table_name": "resource_units",
    "capture_ref": "U04",
    "payload": {
      "resource_id": "8dab755c-a9d7-530a-bec4-2c30f65e0709",
      "place_id": "9b625049-d5f0-5637-9a23-d9e5b5d52f1e",
      "unit_code": null,
      "capacity": null,
      "is_individually_assignable": true,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "U04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 19,
    "table_name": "listings",
    "capture_ref": "P01",
    "payload": {
      "id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Budget: Camp Crew",
      "slug": "budget-camp-crew",
      "summary": "Four nights camping at Eden Rocks, shared return festival shuttle, breakfast boxes, rain kit, locker and charging access.",
      "description": "Four nights camping at Eden Rocks, shared return festival shuttle, breakfast boxes, rain kit, locker and charging access.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": "Festival ticket; drinks; personal spending; travel insurance; airport transfers unless added.",
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "EXPERIENCE",
      "expires_at": "2026-11-24T00:00:00+03:00"
    }
  },
  {
    "ordinal": 20,
    "table_name": "listings",
    "capture_ref": "P02",
    "payload": {
      "id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Comfort: Shared Stay",
      "slug": "comfort-shared-stay",
      "summary": "Four nights in a twin banda at Eden Rocks, breakfast, shared return festival shuttle, two dinner vouchers, locker and charging access.",
      "description": "Four nights in a twin banda at Eden Rocks, breakfast, shared return festival shuttle, two dinner vouchers, locker and charging access.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": "Festival ticket; drinks; personal spending; travel insurance; airport transfers unless added.",
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "EXPERIENCE",
      "expires_at": "2026-11-24T00:00:00+03:00"
    }
  },
  {
    "ordinal": 21,
    "table_name": "listings",
    "capture_ref": "P03",
    "payload": {
      "id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Premium: Riverside Escape",
      "slug": "premium-riverside-escape",
      "summary": "Four nights in a container cottage at Jinja Jungle, breakfast, private return festival shuttle, four dinner vouchers, one rafting day with Bungee Uganda, locker and charging access.",
      "description": "Four nights in a container cottage at Jinja Jungle, breakfast, private return festival shuttle, four dinner vouchers, one rafting day with Bungee Uganda, locker and charging access.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": "Festival ticket; drinks; personal spending; travel insurance; airport transfers unless added.",
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "EXPERIENCE",
      "expires_at": "2026-11-24T00:00:00+03:00"
    }
  },
  {
    "ordinal": 22,
    "table_name": "listings",
    "capture_ref": "P04",
    "payload": {
      "id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Recovery Day bundle",
      "slug": "recovery-day-bundle",
      "summary": "Tubing plus one dinner voucher.",
      "description": "Tubing plus one dinner voucher.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "EXPERIENCE",
      "expires_at": "2026-11-24T00:00:00+03:00"
    }
  },
  {
    "ordinal": 23,
    "table_name": "listings",
    "capture_ref": "C01",
    "payload": {
      "id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Camping accommodation",
      "slug": "camping-accommodation",
      "summary": "Waterproof rented tent at Eden Rocks. Tent occupancy is not stated.",
      "description": "Waterproof rented tent at Eden Rocks. Tent occupancy is not stated.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 24,
    "table_name": "listings",
    "capture_ref": "C02",
    "payload": {
      "id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Banda accommodation",
      "slug": "banda-accommodation",
      "summary": "Twin banda at Eden Rocks. Advertised for two sharing, with sole-occupancy pricing.",
      "description": "Twin banda at Eden Rocks. Advertised for two sharing, with sole-occupancy pricing.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 25,
    "table_name": "listings",
    "capture_ref": "C03",
    "payload": {
      "id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Cottage accommodation",
      "slug": "cottage-accommodation",
      "summary": "Container cottage at Jinja Jungle with one bed and one day bed. Two cottages advertised.",
      "description": "Container cottage at Jinja Jungle with one bed and one day bed. Two cottages advertised.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 26,
    "table_name": "listings",
    "capture_ref": "C04",
    "payload": {
      "id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Shared festival shuttle",
      "slug": "shared-festival-shuttle",
      "summary": "Return shared festival transport. Included package service provides after-midnight pickup every festival night.",
      "description": "Return shared festival transport. Included package service provides after-midnight pickup every festival night.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 27,
    "table_name": "listings",
    "capture_ref": "C05",
    "payload": {
      "id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Private festival shuttle",
      "slug": "private-festival-shuttle",
      "summary": "Premium includes private transport to and from the festival every festival night. Standalone private arrangements need confirmation.",
      "description": "Premium includes private transport to and from the festival every festival night. Standalone private arrangements need confirmation.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 28,
    "table_name": "listings",
    "capture_ref": "C06",
    "payload": {
      "id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Breakfast provision",
      "slug": "breakfast-provision",
      "summary": "Breakfast at the accommodation. Budget includes a breakfast box each morning; a late breakfast box is separately purchasable.",
      "description": "Breakfast at the accommodation. Budget includes a breakfast box each morning; a late breakfast box is separately purchasable.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 29,
    "table_name": "listings",
    "capture_ref": "C07",
    "payload": {
      "id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Dinner entitlement",
      "slug": "dinner-entitlement",
      "summary": "Voucher redeemable for dinner. Comfort specifies the lodge; other redeeming venues and meal terms are unconfirmed.",
      "description": "Voucher redeemable for dinner. Comfort specifies the lodge; other redeeming venues and meal terms are unconfirmed.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 30,
    "table_name": "listings",
    "capture_ref": "C08",
    "payload": {
      "id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Rain-kit provision",
      "slug": "rain-kit-provision",
      "summary": "Physical kit. Budget specifies a poncho and dry bag; confirm separately sold kit contents.",
      "description": "Physical kit. Budget specifies a poncho and dry bag; confirm separately sold kit contents.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 31,
    "table_name": "listings",
    "capture_ref": "C09",
    "payload": {
      "id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Locker and charging access",
      "slug": "locker-and-charging-access",
      "summary": "Secure locker and phone charging pass, sold per stay and included in the festival packages.",
      "description": "Secure locker and phone charging pass, sold per stay and included in the festival packages.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 32,
    "table_name": "listings",
    "capture_ref": "C10",
    "payload": {
      "id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Recovery Day: tubing",
      "slug": "recovery-day-tubing",
      "summary": "Tubing; activity date and participant pricing basis to confirm.",
      "description": "Tubing; activity date and participant pricing basis to confirm.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C10",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "ACTIVITY"
    }
  },
  {
    "ordinal": 33,
    "table_name": "listings",
    "capture_ref": "C11",
    "payload": {
      "id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Recovery Day: rafting",
      "slug": "recovery-day-rafting",
      "summary": "White-water rafting. Premium names Bungee Uganda for one day; the standalone provider is not confirmed.",
      "description": "White-water rafting. Premium names Bungee Uganda for one day; the standalone provider is not confirmed.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C11",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "ACTIVITY"
    }
  },
  {
    "ordinal": 34,
    "table_name": "listings",
    "capture_ref": "C12",
    "payload": {
      "id": "6c1250e9-f87b-5430-8768-843518060f35",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Quad biking",
      "slug": "quad-biking",
      "summary": "Quad biking sold per hour; participant or vehicle basis not stated.",
      "description": "Quad biking sold per hour; participant or vehicle basis not stated.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C12",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "ACTIVITY"
    }
  },
  {
    "ordinal": 35,
    "table_name": "listings",
    "capture_ref": "C13",
    "payload": {
      "id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Guided Jinja tour",
      "slug": "guided-jinja-tour",
      "summary": "Guided tour of Jinja, priced per person. Route, duration and departure details are not supplied.",
      "description": "Guided tour of Jinja, priced per person. Route, duration and departure details are not supplied.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "TOUR"
    }
  },
  {
    "ordinal": 36,
    "table_name": "listings",
    "capture_ref": "C14",
    "payload": {
      "id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Airport transfer: Entebbe-Jinja return",
      "slug": "airport-transfer-entebbe-jinja-return",
      "summary": "Entebbe-Jinja return transfer: whole vehicle for up to five people or per person in a full vehicle.",
      "description": "Entebbe-Jinja return transfer: whole vehicle for up to five people or per person in a full vehicle.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Dates and exact times subject to provider confirmation.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": true,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "SERVICE"
    }
  },
  {
    "ordinal": 37,
    "table_name": "listings",
    "capture_ref": "E01",
    "payload": {
      "id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "listing_type_id": null,
      "subcategory_id": null,
      "name": "Nyege Nyege 2026",
      "slug": "nyege-nyege-2026",
      "summary": "Festival at Kalagala Falls, Jinja, 19-22 November 2026. Festival tickets are excluded from Magma packages.",
      "description": "Festival at Kalagala Falls, Jinja, 19-22 November 2026. Festival tickets are excluded from Magma packages.",
      "country_code": "UG",
      "geographic_area_id": null,
      "inclusions": null,
      "exclusions": null,
      "what_to_bring": null,
      "important_information": "Festival association does not include admission.",
      "booking_instructions": "Request booking; provider confirmation required.",
      "is_local_gem": false,
      "is_hot_pick": false,
      "is_live": false,
      "is_bookable": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_listing_type_code": "EVENT"
    }
  },
  {
    "ordinal": 38,
    "table_name": "listing_options",
    "capture_ref": "P02-SHARED",
    "payload": {
      "id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "name": "Two guests sharing",
      "description": "Two guests in one accommodation unit; price basis captured separately.",
      "duration_minutes": null,
      "minimum_participants": 2,
      "maximum_participants": 2,
      "is_default": true,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 39,
    "table_name": "listing_options",
    "capture_ref": "P02-SOLO",
    "payload": {
      "id": "3573c8c5-dde0-5137-92fb-f461fc3878cb",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "name": "Sole occupancy",
      "description": "One guest using the whole accommodation unit.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 1,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 40,
    "table_name": "listing_options",
    "capture_ref": "P03-SHARED",
    "payload": {
      "id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "name": "Two guests sharing",
      "description": "Two guests in one accommodation unit; price basis captured separately.",
      "duration_minutes": null,
      "minimum_participants": 2,
      "maximum_participants": 2,
      "is_default": true,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 41,
    "table_name": "listing_options",
    "capture_ref": "P03-SOLO",
    "payload": {
      "id": "a259a2b3-58d3-53b0-8b72-83d21b3b9e76",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "name": "Sole occupancy",
      "description": "One guest using the whole accommodation unit.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 1,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 42,
    "table_name": "listing_options",
    "capture_ref": "C02-SHARED",
    "payload": {
      "id": "84220d96-f0d3-5f22-8f63-9891b01673fb",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "name": "Two guests sharing",
      "description": "Two guests in one accommodation unit; price basis captured separately.",
      "duration_minutes": null,
      "minimum_participants": 2,
      "maximum_participants": 2,
      "is_default": true,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 43,
    "table_name": "listing_options",
    "capture_ref": "C02-SOLO",
    "payload": {
      "id": "3d2f5d92-aa1a-52aa-aa3a-4cd8b203cccd",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "name": "Sole occupancy",
      "description": "One guest using the whole accommodation unit.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 1,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 44,
    "table_name": "listing_options",
    "capture_ref": "C03-SHARED",
    "payload": {
      "id": "8ea7af7b-41c0-5f4d-ac1e-19db432044d9",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "name": "Two guests sharing",
      "description": "Two guests in one accommodation unit; price basis captured separately.",
      "duration_minutes": null,
      "minimum_participants": 2,
      "maximum_participants": 2,
      "is_default": true,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 45,
    "table_name": "listing_options",
    "capture_ref": "C03-SOLO",
    "payload": {
      "id": "6128b3cc-7c90-5c60-b23e-50cf28853e2d",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "name": "Sole occupancy",
      "description": "One guest using the whole accommodation unit.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 1,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 46,
    "table_name": "listing_options",
    "capture_ref": "C06-BOX",
    "payload": {
      "id": "9a57fb6f-e126-5c4d-b4a8-655096d07c6b",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "name": "Breakfast box",
      "description": "Budget package breakfast box.",
      "duration_minutes": null,
      "minimum_participants": null,
      "maximum_participants": null,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-BOX",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 47,
    "table_name": "listing_options",
    "capture_ref": "C06-LODGE",
    "payload": {
      "id": "519cc8a6-2cc1-54c2-b44c-dc6a6159197e",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "name": "Lodge breakfast",
      "description": "Breakfast included in Comfort and Premium.",
      "duration_minutes": null,
      "minimum_participants": null,
      "maximum_participants": null,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-LODGE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 48,
    "table_name": "listing_options",
    "capture_ref": "C06-LATE",
    "payload": {
      "id": "c21174f3-126a-5737-9cf7-93a1705a47e4",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "name": "Late breakfast box",
      "description": "Separately sold late breakfast box; UGX 20,000.",
      "duration_minutes": null,
      "minimum_participants": null,
      "maximum_participants": null,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-LATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 49,
    "table_name": "listing_options",
    "capture_ref": "C11-PREMIUM",
    "payload": {
      "id": "f473fd4f-7a59-5089-8552-d8e0547e4d3e",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "name": "Premium package rafting",
      "description": "One rafting day with Bungee Uganda; standalone operator remains unconfirmed.",
      "duration_minutes": null,
      "minimum_participants": null,
      "maximum_participants": null,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C11-PREMIUM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 50,
    "table_name": "listing_options",
    "capture_ref": "C07-EDEN",
    "payload": {
      "id": "cd0c9dd3-df9e-5067-8105-41deb2c0cb34",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "name": "Eden Rocks lodge dinner",
      "description": "Comfort package dinner voucher redeemable at the lodge. Quantity basis remains unconfirmed.",
      "duration_minutes": null,
      "minimum_participants": null,
      "maximum_participants": null,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07-EDEN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 51,
    "table_name": "listing_options",
    "capture_ref": "C14-VEHICLE",
    "payload": {
      "id": "a117e2f1-7ee1-5b36-972c-dda97f1a4e1e",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "name": "Whole vehicle return transfer",
      "description": "Exclusive vehicle, up to five guests.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 5,
      "is_default": true,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 52,
    "table_name": "listing_options",
    "capture_ref": "C14-SEAT",
    "payload": {
      "id": "0eae2e85-3212-5cbd-97e9-9512b452a5bf",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "name": "Seat in a full vehicle",
      "description": "Shared-capacity return transfer conditional on a full vehicle.",
      "duration_minutes": null,
      "minimum_participants": 1,
      "maximum_participants": 5,
      "is_default": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-SEAT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 53,
    "table_name": "services",
    "capture_ref": "C01",
    "payload": {
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "delivery_instructions": "Waterproof rented tent at Eden Rocks. Tent occupancy is not stated.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 54,
    "table_name": "services",
    "capture_ref": "C02",
    "payload": {
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "delivery_instructions": "Twin banda at Eden Rocks. Advertised for two sharing, with sole-occupancy pricing.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 55,
    "table_name": "services",
    "capture_ref": "C03",
    "payload": {
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "delivery_instructions": "Container cottage at Jinja Jungle with one bed and one day bed. Two cottages advertised.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 56,
    "table_name": "services",
    "capture_ref": "C04",
    "payload": {
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "delivery_instructions": "Return shared festival transport. Included package service provides after-midnight pickup every festival night.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 57,
    "table_name": "services",
    "capture_ref": "C05",
    "payload": {
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "delivery_instructions": "Premium includes private transport to and from the festival every festival night. Standalone private arrangements need confirmation.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 58,
    "table_name": "services",
    "capture_ref": "C06",
    "payload": {
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "delivery_instructions": "Breakfast at the accommodation. Budget includes a breakfast box each morning; a late breakfast box is separately purchasable.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 59,
    "table_name": "services",
    "capture_ref": "C07",
    "payload": {
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "delivery_instructions": "Voucher redeemable for dinner. Comfort specifies the lodge; other redeeming venues and meal terms are unconfirmed.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 60,
    "table_name": "services",
    "capture_ref": "C08",
    "payload": {
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "delivery_instructions": "Physical kit. Budget specifies a poncho and dry bag; confirm separately sold kit contents.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 61,
    "table_name": "services",
    "capture_ref": "C09",
    "payload": {
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "delivery_instructions": "Secure locker and phone charging pass, sold per stay and included in the festival packages.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 62,
    "table_name": "services",
    "capture_ref": "C14",
    "payload": {
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "delivery_instructions": "Entebbe-Jinja return transfer: whole vehicle for up to five people or per person in a full vehicle.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 63,
    "table_name": "experiences",
    "capture_ref": "P01",
    "payload": {
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "schedule_mode": "FIXED_START",
      "is_customisable": false,
      "anchor_component_id": null,
      "estimated_duration_minutes": null,
      "start_place_id": null,
      "end_place_id": null,
      "start_geographic_area_id": null,
      "end_geographic_area_id": null,
      "start_instructions": "Check-in 19 November; final checkout 23 November. Exact times unconfirmed.",
      "end_instructions": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 64,
    "table_name": "experiences",
    "capture_ref": "P02",
    "payload": {
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "schedule_mode": "FIXED_START",
      "is_customisable": false,
      "anchor_component_id": null,
      "estimated_duration_minutes": null,
      "start_place_id": null,
      "end_place_id": null,
      "start_geographic_area_id": null,
      "end_geographic_area_id": null,
      "start_instructions": "Check-in 19 November; final checkout 23 November. Exact times unconfirmed.",
      "end_instructions": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 65,
    "table_name": "experiences",
    "capture_ref": "P03",
    "payload": {
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "schedule_mode": "FIXED_START",
      "is_customisable": false,
      "anchor_component_id": null,
      "estimated_duration_minutes": null,
      "start_place_id": null,
      "end_place_id": null,
      "start_geographic_area_id": null,
      "end_geographic_area_id": null,
      "start_instructions": "Check-in 19 November; final checkout 23 November. Exact times unconfirmed.",
      "end_instructions": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 66,
    "table_name": "experiences",
    "capture_ref": "P04",
    "payload": {
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "schedule_mode": "FLEXIBLE_START",
      "is_customisable": false,
      "anchor_component_id": null,
      "estimated_duration_minutes": null,
      "start_place_id": null,
      "end_place_id": null,
      "start_geographic_area_id": null,
      "end_geographic_area_id": null,
      "start_instructions": "Activity date requested at booking.",
      "end_instructions": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 67,
    "table_name": "events",
    "capture_ref": "E01",
    "payload": {
      "listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_series_id": null,
      "official_website_url": null,
      "admission_requirement": "TICKET_REQUIRED",
      "admission_information": "Festival ticket not included in Magma packages. No KNS admission sales configured.",
      "official_ticket_url": null,
      "attendance_mode": "IN_PERSON",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 68,
    "table_name": "tours",
    "capture_ref": "C13",
    "payload": {
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "operating_instructions": "Guided Jinja tour. Route, stops, guide, departure, duration and group mode not supplied.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 69,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C01:SERVICE_SCHEDULE",
    "payload": {
      "id": "8e310c6c-8be6-569f-b5df-aa69cf93319c",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 70,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C01:SERVICE_DELIVERY",
    "payload": {
      "id": "74c300e5-4253-5c0c-b9bb-6c50cf078848",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 71,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:SERVICE_SCHEDULE",
    "payload": {
      "id": "9864cda6-a987-501d-a2ec-0f4ad47d9ad4",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 72,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:SERVICE_DELIVERY",
    "payload": {
      "id": "178b5a73-190c-58a7-8ed5-e1f2670753b4",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 73,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:SERVICE_SCHEDULE",
    "payload": {
      "id": "a1774fe1-fab5-5bdf-a56a-fca10b9f8380",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 74,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:SERVICE_DELIVERY",
    "payload": {
      "id": "58738d16-1918-56b4-9c20-345d71d47378",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 75,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C04:SERVICE_SCHEDULE",
    "payload": {
      "id": "b0f51035-9d90-58e9-a9fe-519e7002fe88",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 76,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C04:SERVICE_DELIVERY",
    "payload": {
      "id": "52ef026e-15a6-5fb9-b22e-c6a379ff59b2",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 77,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C05:SERVICE_SCHEDULE",
    "payload": {
      "id": "fa68c6c8-2455-5616-9615-b42c248ed0af",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 78,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C05:SERVICE_DELIVERY",
    "payload": {
      "id": "7afabf6f-3491-53de-8a4f-bb4d962a57ef",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 79,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C06:SERVICE_SCHEDULE",
    "payload": {
      "id": "7d913db2-e91f-5fb4-93e9-2694e6aca457",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 80,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C06:SERVICE_DELIVERY",
    "payload": {
      "id": "daa2c190-f327-5ff4-8746-d5d0426a71b7",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 81,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C07:SERVICE_SCHEDULE",
    "payload": {
      "id": "9d763738-0de0-5895-995c-1ca91cae93ea",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 82,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C07:SERVICE_DELIVERY",
    "payload": {
      "id": "ac491060-1b2f-5e70-a0c8-aa4ba7e55123",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 83,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C08:SERVICE_SCHEDULE",
    "payload": {
      "id": "3cf9e232-1448-53b8-b4f9-3836ba523f95",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 84,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C08:SERVICE_DELIVERY",
    "payload": {
      "id": "63ccdbd1-ebaf-5554-8b00-38e4ae80d315",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 85,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C09:SERVICE_SCHEDULE",
    "payload": {
      "id": "d96c7d7b-6b33-551d-b0c7-58cb1f9568b7",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 86,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C09:SERVICE_DELIVERY",
    "payload": {
      "id": "3dda343d-912d-5cfe-8bc2-c2e6abcbaf06",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 87,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C14:SERVICE_SCHEDULE",
    "payload": {
      "id": "d8c848c2-b228-5841-8b90-b716edede7ae",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_SCHEDULE",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14:SERVICE_SCHEDULE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 88,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C14:SERVICE_DELIVERY",
    "payload": {
      "id": "b9674e55-6bf3-580f-a13a-d1232b598e66",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_DELIVERY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14:SERVICE_DELIVERY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 89,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C01:SERVICE_STAY",
    "payload": {
      "id": "37b8b5ac-b753-507d-8c86-70ccab98be0b",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01:SERVICE_STAY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 90,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:SERVICE_STAY",
    "payload": {
      "id": "b15b96bf-8820-55f2-9c5c-6af9a62c64a4",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:SERVICE_STAY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 91,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:SERVICE_STAY",
    "payload": {
      "id": "5aa2ff23-f52b-5c89-93d6-5dbd0da10c53",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:SERVICE_STAY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 92,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:SERVICE_STAY:C02-SHARED",
    "payload": {
      "id": "c46be6b5-d5bb-583c-b651-a5ae6d8b76a6",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": "84220d96-f0d3-5f22-8f63-9891b01673fb",
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:SERVICE_STAY:C02-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 93,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:SERVICE_STAY:C02-SOLO",
    "payload": {
      "id": "6d866d9e-3a43-5b46-a953-64a5ee0ae3d6",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": "3d2f5d92-aa1a-52aa-aa3a-4cd8b203cccd",
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:SERVICE_STAY:C02-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 94,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:SERVICE_STAY:C03-SHARED",
    "payload": {
      "id": "d147a099-8798-5ab9-979d-8c8d09779aa1",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": "8ea7af7b-41c0-5f4d-ac1e-19db432044d9",
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:SERVICE_STAY:C03-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 95,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:SERVICE_STAY:C03-SOLO",
    "payload": {
      "id": "5c7dcd69-b2ed-5956-baae-a2f5e98d418c",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": "6128b3cc-7c90-5c60-b23e-50cf28853e2d",
      "configuration_kind": "SERVICE_STAY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:SERVICE_STAY:C03-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 96,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C04:SERVICE_JOURNEY",
    "payload": {
      "id": "831043ff-44b5-5aba-a793-20ea68492edc",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_JOURNEY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04:SERVICE_JOURNEY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 97,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C05:SERVICE_JOURNEY",
    "payload": {
      "id": "6a52ed34-a3e7-584b-8b71-68d7c08499b0",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_JOURNEY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05:SERVICE_JOURNEY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 98,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C14:SERVICE_JOURNEY:C14-VEHICLE",
    "payload": {
      "id": "f7e38630-8f63-58a0-a047-41617ea763a0",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": "a117e2f1-7ee1-5b36-972c-dda97f1a4e1e",
      "configuration_kind": "SERVICE_JOURNEY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14:SERVICE_JOURNEY:C14-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 99,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C14:SERVICE_JOURNEY:C14-SEAT",
    "payload": {
      "id": "07124d3a-fcb4-53bb-8b14-408a211d1315",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": "0eae2e85-3212-5cbd-97e9-9512b452a5bf",
      "configuration_kind": "SERVICE_JOURNEY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14:SERVICE_JOURNEY:C14-SEAT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 100,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C06:SERVICE_ENTITLEMENT",
    "payload": {
      "id": "837f1c88-f63a-546a-b9e4-fa107ea1ac9e",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_ENTITLEMENT",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06:SERVICE_ENTITLEMENT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 101,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C07:SERVICE_ENTITLEMENT",
    "payload": {
      "id": "14fecf33-87e9-5b24-a862-64213dbd1e4b",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_ENTITLEMENT",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07:SERVICE_ENTITLEMENT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 102,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C08:SERVICE_ENTITLEMENT",
    "payload": {
      "id": "3d43ecc2-81b9-5bec-bea0-d82472c865be",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_ENTITLEMENT",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08:SERVICE_ENTITLEMENT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 103,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C09:SERVICE_ENTITLEMENT",
    "payload": {
      "id": "ecf3a8a7-7e99-5dca-abcc-68824bbe9bd1",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "configuration_kind": "SERVICE_ENTITLEMENT",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09:SERVICE_ENTITLEMENT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 104,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C07:SERVICE_ENTITLEMENT:C07-EDEN",
    "payload": {
      "id": "33597168-eeea-53e0-b066-179aa07eee47",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": "cd0c9dd3-df9e-5067-8105-41deb2c0cb34",
      "configuration_kind": "SERVICE_ENTITLEMENT",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07:SERVICE_ENTITLEMENT:C07-EDEN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 105,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P01:ADJUSTMENTS",
    "payload": {
      "id": "3c32d136-7ee8-5479-838f-24c7f47dc802",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "configuration_kind": "ADJUSTMENTS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01:ADJUSTMENTS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 106,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P02:ADJUSTMENTS",
    "payload": {
      "id": "3cc9a125-1137-52ea-ba54-5369140691ea",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": null,
      "configuration_kind": "ADJUSTMENTS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02:ADJUSTMENTS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 107,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P03:ADJUSTMENTS",
    "payload": {
      "id": "08ce925d-9226-5f70-88ef-c77da5d25932",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": null,
      "configuration_kind": "ADJUSTMENTS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03:ADJUSTMENTS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 108,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:ADJUSTMENTS",
    "payload": {
      "id": "7eb7099e-c0c2-5d5d-93de-73ead5a64fd9",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "configuration_kind": "ADJUSTMENTS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:ADJUSTMENTS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 109,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C01:CUSTOMER_INFORMATION",
    "payload": {
      "id": "a69c49b1-808b-54cb-a959-b7e05c945fe7",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 110,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C02:CUSTOMER_INFORMATION",
    "payload": {
      "id": "4b94fa70-964d-518d-900b-23c6ffddd968",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 111,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C03:CUSTOMER_INFORMATION",
    "payload": {
      "id": "57561871-14f5-5dc3-b4fd-61da748efb39",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 112,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C04:CUSTOMER_INFORMATION",
    "payload": {
      "id": "6ede1496-7314-5caa-b91b-b459fd8587d4",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 113,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C05:CUSTOMER_INFORMATION",
    "payload": {
      "id": "5c6873bb-c297-5b33-8d8b-6ce2c2cd3f09",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 114,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C06:CUSTOMER_INFORMATION",
    "payload": {
      "id": "4d1a0277-9b2b-58cd-9dd4-4fbd31e9e89e",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 115,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C07:CUSTOMER_INFORMATION",
    "payload": {
      "id": "96a360c3-8323-5912-87cd-19d6aa1c3b58",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 116,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C08:CUSTOMER_INFORMATION",
    "payload": {
      "id": "1996c931-2990-5cca-a3fb-4ed5dbb099c2",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 117,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C09:CUSTOMER_INFORMATION",
    "payload": {
      "id": "0c9c7429-546d-5476-8a8d-b8cd2e72d5ed",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 118,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C14:CUSTOMER_INFORMATION",
    "payload": {
      "id": "01a31be8-a8c2-5c81-9417-f66acb3c74a5",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "configuration_kind": "CUSTOMER_INFORMATION",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14:CUSTOMER_INFORMATION",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 119,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C13:TOUR_POLICY",
    "payload": {
      "id": "092cf6fc-5c96-5c55-8763-23d6dbdd03b4",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_option_id": null,
      "configuration_kind": "TOUR_POLICY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13:TOUR_POLICY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 120,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C13:TOUR_ITINERARY",
    "payload": {
      "id": "800eccda-8d21-515c-a985-5c2bed173a22",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_option_id": null,
      "configuration_kind": "TOUR_ITINERARY",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13:TOUR_ITINERARY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 121,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P01:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "9db475de-b9d3-5eac-af8b-50dab81646e2",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 122,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P02:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "435d6d6d-8fdc-5f48-a16a-c8f91ca2f184",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 123,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "P03:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "b5d27a97-99b1-5297-ab7e-83453e433cba",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 124,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C10:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "1d19fd3a-d560-5cd9-8850-7d082d2a4c5d",
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C10:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 125,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C11:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "ed7d91ee-294d-5971-9719-a31f2dd8817f",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C11:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 126,
    "table_name": "listing_configuration_scopes",
    "capture_ref": "C12:BOOKING_OBLIGATIONS",
    "payload": {
      "id": "f748859a-783b-56fa-a2a3-8d157bfd263b",
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "listing_option_id": null,
      "configuration_kind": "BOOKING_OBLIGATIONS",
      "configuration_mode": "CUSTOM",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C12:BOOKING_OBLIGATIONS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 127,
    "table_name": "listing_occurrences",
    "capture_ref": "E01-2026",
    "payload": {
      "id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "listing_option_id": null,
      "departure_rule_id": null,
      "generated_for_date": null,
      "starts_at": null,
      "ends_at": null,
      "status": "SCHEDULED",
      "cancellation_reason": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "schedule_precision": "DATE_ONLY",
      "starts_on": "2026-11-19",
      "ends_on": "2026-11-22",
      "_capture_ref": "E01-2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "time_zone": "Africa/Kampala",
      "end_date_basis": "INCLUSIVE"
    }
  },
  {
    "ordinal": 128,
    "table_name": "listing_occurrences",
    "capture_ref": "P01-2026",
    "payload": {
      "id": "88a5eeec-0046-5e49-b064-26a0e2d12646",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "departure_rule_id": null,
      "generated_for_date": null,
      "starts_at": null,
      "ends_at": null,
      "status": "SCHEDULED",
      "cancellation_reason": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "schedule_precision": "DATE_ONLY",
      "starts_on": "2026-11-19",
      "ends_on": "2026-11-23",
      "_capture_ref": "P01-2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "time_zone": "Africa/Kampala",
      "end_date_basis": "EXCLUSIVE"
    }
  },
  {
    "ordinal": 129,
    "table_name": "listing_occurrences",
    "capture_ref": "P02-2026",
    "payload": {
      "id": "3c5b1203-59f8-526d-97de-70a8458a7370",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": null,
      "departure_rule_id": null,
      "generated_for_date": null,
      "starts_at": null,
      "ends_at": null,
      "status": "SCHEDULED",
      "cancellation_reason": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "schedule_precision": "DATE_ONLY",
      "starts_on": "2026-11-19",
      "ends_on": "2026-11-23",
      "_capture_ref": "P02-2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "time_zone": "Africa/Kampala",
      "end_date_basis": "EXCLUSIVE"
    }
  },
  {
    "ordinal": 130,
    "table_name": "listing_occurrences",
    "capture_ref": "P03-2026",
    "payload": {
      "id": "564228b8-ebb9-599b-b502-c58d2dc7737a",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": null,
      "departure_rule_id": null,
      "generated_for_date": null,
      "starts_at": null,
      "ends_at": null,
      "status": "SCHEDULED",
      "cancellation_reason": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "schedule_precision": "DATE_ONLY",
      "starts_on": "2026-11-19",
      "ends_on": "2026-11-23",
      "_capture_ref": "P03-2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "time_zone": "Africa/Kampala",
      "end_date_basis": "EXCLUSIVE"
    }
  },
  {
    "ordinal": 131,
    "table_name": "event_occurrence_details",
    "capture_ref": "E01-2026",
    "payload": {
      "occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "doors_open_at": null,
      "last_entry_at": null,
      "arrival_instructions": "Kalagala Falls, Jinja; entry arrangements, doors and last entry times unconfirmed.",
      "accessibility_information": null,
      "online_join_url": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "E01-2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 132,
    "table_name": "event_occurrence_places",
    "capture_ref": "E01-MAIN",
    "payload": {
      "id": "8450bf86-722e-5bc5-915e-f7989a494d8f",
      "occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "place_resource_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "role_code": "MAIN_VENUE",
      "is_primary": true,
      "instructions": "Exact venue address and entrance to confirm.",
      "sort_order": 0,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "E01-MAIN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 133,
    "table_name": "experience_components",
    "capture_ref": "P01-C01",
    "payload": {
      "id": "349c425a-8262-50d1-bf84-1013b292df34",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "experience_option_id": null,
      "component_listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 0,
      "title_override": "Camping accommodation",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 134,
    "table_name": "experience_components",
    "capture_ref": "P01-C04",
    "payload": {
      "id": "53cada25-501f-5cae-bc06-7bd3b545edbe",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "experience_option_id": null,
      "component_listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 1,
      "title_override": "Shared festival shuttle",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 135,
    "table_name": "experience_components",
    "capture_ref": "P01-C06",
    "payload": {
      "id": "9963382b-8b3c-58e1-ac20-6a97773aee1c",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "experience_option_id": null,
      "component_listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "component_listing_option_id": "9a57fb6f-e126-5c4d-b4a8-655096d07c6b",
      "replaces_component_id": null,
      "sequence_order": 2,
      "title_override": "Breakfast provision",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 136,
    "table_name": "experience_components",
    "capture_ref": "P01-C08",
    "payload": {
      "id": "a4fbb832-d48a-5e67-a891-9adaff9418e5",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "experience_option_id": null,
      "component_listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 3,
      "title_override": "Rain-kit provision",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 137,
    "table_name": "experience_components",
    "capture_ref": "P01-C09",
    "payload": {
      "id": "4cd1db5f-64e7-520d-b457-a0f2cfd4fbc1",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "experience_option_id": null,
      "component_listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 4,
      "title_override": "Locker and charging access",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 138,
    "table_name": "experience_components",
    "capture_ref": "P02-C02",
    "payload": {
      "id": "981fdc20-c747-5170-8977-ad6d9611a9ec",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": null,
      "component_listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 0,
      "title_override": "Banda accommodation",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 139,
    "table_name": "experience_components",
    "capture_ref": "P02-C04",
    "payload": {
      "id": "2f803e20-a060-5af8-99e6-87b2cf339c33",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": null,
      "component_listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 1,
      "title_override": "Shared festival shuttle",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 140,
    "table_name": "experience_components",
    "capture_ref": "P02-C06",
    "payload": {
      "id": "0406ff16-fd3c-5505-8109-7782c3b715a6",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": null,
      "component_listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "component_listing_option_id": "519cc8a6-2cc1-54c2-b44c-dc6a6159197e",
      "replaces_component_id": null,
      "sequence_order": 2,
      "title_override": "Breakfast provision",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 141,
    "table_name": "experience_components",
    "capture_ref": "P02-C07",
    "payload": {
      "id": "1084f33f-7fb7-507a-9caa-0a910e9d40bc",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": null,
      "component_listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "component_listing_option_id": "cd0c9dd3-df9e-5067-8105-41deb2c0cb34",
      "replaces_component_id": null,
      "sequence_order": 3,
      "title_override": "Dinner entitlement",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 2,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 142,
    "table_name": "experience_components",
    "capture_ref": "P02-C09",
    "payload": {
      "id": "da283751-ed29-5cde-b494-8ad036dd5245",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": null,
      "component_listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 4,
      "title_override": "Locker and charging access",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 143,
    "table_name": "experience_components",
    "capture_ref": "P03-C03",
    "payload": {
      "id": "55cfea19-ffd2-58a6-837b-d702cb415e57",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 0,
      "title_override": "Cottage accommodation",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 144,
    "table_name": "experience_components",
    "capture_ref": "P03-C05",
    "payload": {
      "id": "2c323a41-017b-511f-b7db-971501959879",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 1,
      "title_override": "Private festival shuttle",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 145,
    "table_name": "experience_components",
    "capture_ref": "P03-C06",
    "payload": {
      "id": "c2013f38-3f20-54ff-8425-d5e54b3c832d",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "component_listing_option_id": "519cc8a6-2cc1-54c2-b44c-dc6a6159197e",
      "replaces_component_id": null,
      "sequence_order": 2,
      "title_override": "Breakfast provision",
      "notes": "Configuration proposal; multiple-room quantity needs booking allocation.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_PARTICIPANT",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 146,
    "table_name": "experience_components",
    "capture_ref": "P03-C07",
    "payload": {
      "id": "cb4c56d0-2982-5665-b313-cbcbfbf50ae5",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 3,
      "title_override": "Dinner entitlement",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 4,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 147,
    "table_name": "experience_components",
    "capture_ref": "P03-C11",
    "payload": {
      "id": "76a95522-93f5-525e-917e-1520a17dd90d",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "component_listing_option_id": "f473fd4f-7a59-5089-8552-d8e0547e4d3e",
      "replaces_component_id": null,
      "sequence_order": 4,
      "title_override": "Recovery Day: rafting",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C11",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 148,
    "table_name": "experience_components",
    "capture_ref": "P03-C09",
    "payload": {
      "id": "d30d1379-6ab3-56ff-b8f8-3b7fbe9e92ae",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": null,
      "component_listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 5,
      "title_override": "Locker and charging access",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 149,
    "table_name": "experience_components",
    "capture_ref": "P04-C10",
    "payload": {
      "id": "dd86fa05-e778-54cd-a4cb-d0fdc178489c",
      "experience_listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "experience_option_id": null,
      "component_listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 0,
      "title_override": "Recovery Day: tubing",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P04-C10",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 150,
    "table_name": "experience_components",
    "capture_ref": "P04-C07",
    "payload": {
      "id": "ec462418-506b-5a7a-a5d2-9e45f7ce67e0",
      "experience_listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "experience_option_id": null,
      "component_listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "component_listing_option_id": null,
      "replaces_component_id": null,
      "sequence_order": 1,
      "title_override": "Dinner entitlement",
      "notes": "Source quantity retained; guest/unit basis to confirm.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": null,
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P04-C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 151,
    "table_name": "experience_components",
    "capture_ref": "P02-C02-SHARED",
    "payload": {
      "id": "de06d63a-28a3-538d-951c-f09dd66f3c51",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "component_listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "component_listing_option_id": "84220d96-f0d3-5f22-8f63-9891b01673fb",
      "replaces_component_id": "981fdc20-c747-5170-8977-ad6d9611a9ec",
      "sequence_order": 0,
      "title_override": "Banda accommodation",
      "notes": "Option-specific replacement of shared accommodation component; base stays anchor recurring inclusions through effective replacement.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C02-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 152,
    "table_name": "experience_components",
    "capture_ref": "P02-C02-SOLO",
    "payload": {
      "id": "1f4b5557-0aad-580e-9e49-088d34a68794",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "experience_option_id": "3573c8c5-dde0-5137-92fb-f461fc3878cb",
      "component_listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "component_listing_option_id": "3d2f5d92-aa1a-52aa-aa3a-4cd8b203cccd",
      "replaces_component_id": "981fdc20-c747-5170-8977-ad6d9611a9ec",
      "sequence_order": 0,
      "title_override": "Banda accommodation",
      "notes": "Option-specific replacement of shared accommodation component; base stays anchor recurring inclusions through effective replacement.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C02-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 153,
    "table_name": "experience_components",
    "capture_ref": "P03-C03-SHARED",
    "payload": {
      "id": "8ad01f3a-22e9-531e-993a-cc1de41fd6aa",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "component_listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "component_listing_option_id": "8ea7af7b-41c0-5f4d-ac1e-19db432044d9",
      "replaces_component_id": "55cfea19-ffd2-58a6-837b-d702cb415e57",
      "sequence_order": 0,
      "title_override": "Cottage accommodation",
      "notes": "Option-specific replacement of shared accommodation component; base stays anchor recurring inclusions through effective replacement.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C03-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 154,
    "table_name": "experience_components",
    "capture_ref": "P03-C03-SOLO",
    "payload": {
      "id": "de2dbdc4-5f93-5826-89f8-f931a8719cad",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "experience_option_id": "a259a2b3-58d3-53b0-8b72-83d21b3b9e76",
      "component_listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "component_listing_option_id": "6128b3cc-7c90-5c60-b23e-50cf28853e2d",
      "replaces_component_id": "55cfea19-ffd2-58a6-837b-d702cb415e57",
      "sequence_order": 0,
      "title_override": "Cottage accommodation",
      "notes": "Option-specific replacement of shared accommodation component; base stays anchor recurring inclusions through effective replacement.",
      "is_required": true,
      "price_inclusion": "PACKAGE_QUOTE",
      "quantity": 1,
      "quantity_basis": "PER_BOOKING",
      "duration_override_minutes": null,
      "timing_mode": "UNSCHEDULED",
      "start_offset_minutes": null,
      "fixed_start_at": null,
      "component_occurrence_id": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C03-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 155,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P01-C04",
    "payload": {
      "id": "4588b1ed-c7ff-5dbe-bcc1-b763ff16f73a",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "component_id": "53cada25-501f-5cae-bc06-7bd3b545edbe",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "349c425a-8262-50d1-bf84-1013b292df34",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 156,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P01-C06",
    "payload": {
      "id": "ad2d24e2-3a9d-5716-9af6-fe2dc07b2a0f",
      "experience_listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "component_id": "9963382b-8b3c-58e1-ac20-6a97773aee1c",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "349c425a-8262-50d1-bf84-1013b292df34",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 157,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P02-C04",
    "payload": {
      "id": "c725eeb6-ae9a-521c-bcf3-a00ac11a7d6b",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "component_id": "2f803e20-a060-5af8-99e6-87b2cf339c33",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "981fdc20-c747-5170-8977-ad6d9611a9ec",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 158,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P02-C06",
    "payload": {
      "id": "15b3d580-ccc5-530a-8b8f-f49f5e83f578",
      "experience_listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "component_id": "0406ff16-fd3c-5505-8109-7782c3b715a6",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "981fdc20-c747-5170-8977-ad6d9611a9ec",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 159,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P03-C05",
    "payload": {
      "id": "3aebb5b3-e72a-5c71-be91-5e279731e48b",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "component_id": "2c323a41-017b-511f-b7db-971501959879",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "55cfea19-ffd2-58a6-837b-d702cb415e57",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 160,
    "table_name": "experience_component_inclusion_rules",
    "capture_ref": "P03-C06",
    "payload": {
      "id": "805d3e86-0470-53d6-bb70-2a216a16c921",
      "experience_listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "component_id": "c2013f38-3f20-54ff-8425-d5e54b3c832d",
      "quantity_anchor_component_id": null,
      "frequency_basis": "PER_NIGHT",
      "frequency_anchor_component_id": "55cfea19-ffd2-58a6-837b-d702cb415e57",
      "day_count_basis": null,
      "service_day_boundary": null,
      "maximum_included_units": null,
      "inclusion_instructions": "One service allowance per booked night; breakfast follows each night. Confirm festival-night cutoff and breakfast after checkout night. No assumed local pickup time.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 161,
    "table_name": "service_schedule_policies",
    "capture_ref": "C01",
    "payload": {
      "scope_id": "8e310c6c-8be6-569f-b5df-aa69cf93319c",
      "schedule_mode": "DATE_RANGE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 162,
    "table_name": "service_schedule_policies",
    "capture_ref": "C02",
    "payload": {
      "scope_id": "9864cda6-a987-501d-a2ec-0f4ad47d9ad4",
      "schedule_mode": "DATE_RANGE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 163,
    "table_name": "service_schedule_policies",
    "capture_ref": "C03",
    "payload": {
      "scope_id": "a1774fe1-fab5-5bdf-a56a-fca10b9f8380",
      "schedule_mode": "DATE_RANGE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 164,
    "table_name": "service_schedule_policies",
    "capture_ref": "C04",
    "payload": {
      "scope_id": "b0f51035-9d90-58e9-a9fe-519e7002fe88",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 165,
    "table_name": "service_schedule_policies",
    "capture_ref": "C05",
    "payload": {
      "scope_id": "fa68c6c8-2455-5616-9615-b42c248ed0af",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 166,
    "table_name": "service_schedule_policies",
    "capture_ref": "C06",
    "payload": {
      "scope_id": "7d913db2-e91f-5fb4-93e9-2694e6aca457",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 167,
    "table_name": "service_schedule_policies",
    "capture_ref": "C07",
    "payload": {
      "scope_id": "9d763738-0de0-5895-995c-1ca91cae93ea",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 168,
    "table_name": "service_schedule_policies",
    "capture_ref": "C08",
    "payload": {
      "scope_id": "3cf9e232-1448-53b8-b4f9-3836ba523f95",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 169,
    "table_name": "service_schedule_policies",
    "capture_ref": "C09",
    "payload": {
      "scope_id": "d96c7d7b-6b33-551d-b0c7-58cb1f9568b7",
      "schedule_mode": "DATE_RANGE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 170,
    "table_name": "service_schedule_policies",
    "capture_ref": "C14",
    "payload": {
      "scope_id": "d8c848c2-b228-5841-8b90-b716edede7ae",
      "schedule_mode": "FLEXIBLE_START",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 171,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C01",
    "payload": {
      "id": "ef0a379a-e388-5feb-b884-ffb609941ada",
      "scope_id": "74c300e5-4253-5c0c-b9bb-6c50cf078848",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Waterproof rented tent at Eden Rocks. Tent occupancy is not stated.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 172,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C02",
    "payload": {
      "id": "f0096862-be73-5be4-9f69-6c683f2706f0",
      "scope_id": "178b5a73-190c-58a7-8ed5-e1f2670753b4",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Twin banda at Eden Rocks. Advertised for two sharing, with sole-occupancy pricing.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 173,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C03",
    "payload": {
      "id": "36200eeb-2c2f-5efc-aa04-b64abeb67b4f",
      "scope_id": "58738d16-1918-56b4-9c20-345d71d47378",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Container cottage at Jinja Jungle with one bed and one day bed. Two cottages advertised.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 174,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C04",
    "payload": {
      "id": "d6ba9f8e-0265-5657-bd59-95b3d46f6ec8",
      "scope_id": "52ef026e-15a6-5fb9-b22e-c6a379ff59b2",
      "delivery_mode": "JOURNEY",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Return shared festival transport. Included package service provides after-midnight pickup every festival night.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 175,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C05",
    "payload": {
      "id": "f99a123c-8c1d-57c8-8d20-52a3fb8da7ab",
      "scope_id": "7afabf6f-3491-53de-8a4f-bb4d962a57ef",
      "delivery_mode": "JOURNEY",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Premium includes private transport to and from the festival every festival night. Standalone private arrangements need confirmation.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 176,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C06",
    "payload": {
      "id": "9f910810-2927-5dda-b0ac-d54ce4651e0e",
      "scope_id": "daa2c190-f327-5ff4-8746-d5d0426a71b7",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Breakfast at the accommodation. Budget includes a breakfast box each morning; a late breakfast box is separately purchasable.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 177,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C07",
    "payload": {
      "id": "0b98472c-da40-56db-80e1-b39bfa64196e",
      "scope_id": "ac491060-1b2f-5e70-a0c8-aa4ba7e55123",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Voucher redeemable for dinner. Comfort specifies the lodge; other redeeming venues and meal terms are unconfirmed.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 178,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C08",
    "payload": {
      "id": "c2263cec-5986-5f98-bd91-d1f607ffd42e",
      "scope_id": "63ccdbd1-ebaf-5554-8b00-38e4ae80d315",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Physical kit. Budget specifies a poncho and dry bag; confirm separately sold kit contents.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 179,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C09",
    "payload": {
      "id": "ccf0130d-4b96-54d5-b4ad-b97ec83a73f8",
      "scope_id": "3dda343d-912d-5cfe-8bc2-c2e6abcbaf06",
      "delivery_mode": "PROVIDER_LOCATION",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Secure locker and phone charging pass, sold per stay and included in the festival packages.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 180,
    "table_name": "service_delivery_configurations",
    "capture_ref": "C14",
    "payload": {
      "id": "fe79cbe6-a9b9-58a6-a0c1-b4072f5d9688",
      "scope_id": "b9674e55-6bf3-580f-a13a-d1232b598e66",
      "delivery_mode": "JOURNEY",
      "customer_location_policy": null,
      "coverage_mode": "NOT_APPLICABLE",
      "instructions": "Entebbe-Jinja return transfer: whole vehicle for up to five people or per person in a full vehicle.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 181,
    "table_name": "service_stay_policies",
    "capture_ref": "C01",
    "payload": {
      "scope_id": "37b8b5ac-b753-507d-8c86-70ccab98be0b",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 1,
      "maximum_occupants": null,
      "included_occupants": null,
      "allows_extra_occupants": false,
      "allows_stay_extensions": true,
      "instructions": "Package dates 19-22 Nov; checkout 23 Nov. Terms: arrival from 18 Nov; minimum stay 3 nights. Extra nights 18 or 23 Nov; reconcile final checkout. Exact check-in/out times not supplied.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 182,
    "table_name": "service_stay_policies",
    "capture_ref": "C02",
    "payload": {
      "scope_id": "b15b96bf-8820-55f2-9c5c-6af9a62c64a4",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 1,
      "maximum_occupants": null,
      "included_occupants": null,
      "allows_extra_occupants": false,
      "allows_stay_extensions": true,
      "instructions": "Package dates 19-22 Nov; checkout 23 Nov. Terms: arrival from 18 Nov; minimum stay 3 nights. Extra nights 18 or 23 Nov; reconcile final checkout. Exact check-in/out times not supplied.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 183,
    "table_name": "service_stay_policies",
    "capture_ref": "C03",
    "payload": {
      "scope_id": "5aa2ff23-f52b-5c89-93d6-5dbd0da10c53",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 1,
      "maximum_occupants": null,
      "included_occupants": null,
      "allows_extra_occupants": true,
      "allows_stay_extensions": true,
      "instructions": "Package dates 19-22 Nov; checkout 23 Nov. Terms: arrival from 18 Nov; minimum stay 3 nights. Extra nights 18 or 23 Nov; reconcile final checkout. Exact check-in/out times not supplied.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 184,
    "table_name": "service_stay_policies",
    "capture_ref": "C02-SHARED",
    "payload": {
      "scope_id": "c46be6b5-d5bb-583c-b651-a5ae6d8b76a6",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 2,
      "maximum_occupants": 2,
      "included_occupants": 2,
      "allows_extra_occupants": false,
      "allows_stay_extensions": true,
      "instructions": "Occupancy is the selected commercial configuration, not a certified physical maximum.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 185,
    "table_name": "service_stay_policies",
    "capture_ref": "C02-SOLO",
    "payload": {
      "scope_id": "6d866d9e-3a43-5b46-a953-64a5ee0ae3d6",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 1,
      "maximum_occupants": 1,
      "included_occupants": 1,
      "allows_extra_occupants": false,
      "allows_stay_extensions": true,
      "instructions": "Occupancy is the selected commercial configuration, not a certified physical maximum.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 186,
    "table_name": "service_stay_policies",
    "capture_ref": "C03-SHARED",
    "payload": {
      "scope_id": "d147a099-8798-5ab9-979d-8c8d09779aa1",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 2,
      "maximum_occupants": null,
      "included_occupants": 2,
      "allows_extra_occupants": true,
      "allows_stay_extensions": true,
      "instructions": "Occupancy is the selected commercial configuration, not a certified physical maximum.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-SHARED",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 187,
    "table_name": "service_stay_policies",
    "capture_ref": "C03-SOLO",
    "payload": {
      "scope_id": "5c7dcd69-b2ed-5956-baae-a2f5e98d418c",
      "minimum_nights": 3,
      "maximum_nights": null,
      "check_in_from": null,
      "check_in_until": null,
      "check_in_end_day_offset": 0,
      "check_out_by": null,
      "minimum_occupants": 1,
      "maximum_occupants": null,
      "included_occupants": 1,
      "allows_extra_occupants": true,
      "allows_stay_extensions": true,
      "instructions": "Occupancy is the selected commercial configuration, not a certified physical maximum.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-SOLO",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 188,
    "table_name": "service_journey_policies",
    "capture_ref": "C04",
    "payload": {
      "scope_id": "831043ff-44b5-5aba-a793-20ea68492edc",
      "allocation_basis": "SHARED_CAPACITY",
      "minimum_passengers": 1,
      "maximum_passengers": null,
      "departure_condition": "NO_MINIMUM",
      "minimum_departure_passengers": null,
      "maximum_intermediate_stops": 0,
      "included_waiting_minutes": null,
      "waiting_trigger": null,
      "maximum_checked_bags": null,
      "maximum_cabin_bags": null,
      "meeting_instructions": "Pickup arrangements and timings require supplier confirmation; no intermediate stops configured.",
      "delay_policy": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 189,
    "table_name": "service_journey_policies",
    "capture_ref": "C05",
    "payload": {
      "scope_id": "6a52ed34-a3e7-584b-8b71-68d7c08499b0",
      "allocation_basis": "EXCLUSIVE_RESOURCE",
      "minimum_passengers": 1,
      "maximum_passengers": null,
      "departure_condition": "NO_MINIMUM",
      "minimum_departure_passengers": null,
      "maximum_intermediate_stops": 0,
      "included_waiting_minutes": null,
      "waiting_trigger": null,
      "maximum_checked_bags": null,
      "maximum_cabin_bags": null,
      "meeting_instructions": "Pickup arrangements and timings require supplier confirmation; no intermediate stops configured.",
      "delay_policy": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 190,
    "table_name": "service_journey_policies",
    "capture_ref": "C14-VEHICLE",
    "payload": {
      "scope_id": "f7e38630-8f63-58a0-a047-41617ea763a0",
      "allocation_basis": "EXCLUSIVE_RESOURCE",
      "minimum_passengers": 1,
      "maximum_passengers": 5,
      "departure_condition": "NO_MINIMUM",
      "minimum_departure_passengers": null,
      "maximum_intermediate_stops": 0,
      "included_waiting_minutes": null,
      "waiting_trigger": null,
      "maximum_checked_bags": null,
      "maximum_cabin_bags": null,
      "meeting_instructions": "Pickup arrangements and timings require supplier confirmation; no intermediate stops configured.",
      "delay_policy": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 191,
    "table_name": "service_journey_policies",
    "capture_ref": "C14-SEAT",
    "payload": {
      "scope_id": "07124d3a-fcb4-53bb-8b14-408a211d1315",
      "allocation_basis": "SHARED_CAPACITY",
      "minimum_passengers": 1,
      "maximum_passengers": 5,
      "departure_condition": "FULL_CAPACITY",
      "minimum_departure_passengers": null,
      "maximum_intermediate_stops": 0,
      "included_waiting_minutes": null,
      "waiting_trigger": null,
      "maximum_checked_bags": null,
      "maximum_cabin_bags": null,
      "meeting_instructions": "Pickup arrangements and timings require supplier confirmation; no intermediate stops configured.",
      "delay_policy": null,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-SEAT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 192,
    "table_name": "service_journey_legs",
    "capture_ref": "C04-OUTBOUND",
    "payload": {
      "id": "d78c5bfd-cc5f-5961-a6ff-288a30838e88",
      "journey_policy_id": "831043ff-44b5-5aba-a793-20ea68492edc",
      "sequence_order": 0,
      "name": "Outbound journey",
      "leg_role": "OUTBOUND",
      "journey_context": "GENERAL",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "FIXED_PLACE",
      "origin_place_id": null,
      "destination_place_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Accommodation endpoint selected at booking; return includes after-midnight pickup in packages.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04-OUTBOUND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 193,
    "table_name": "service_journey_legs",
    "capture_ref": "C04-RETURN",
    "payload": {
      "id": "a39b98eb-2bec-5e70-9987-1e1d096de57f",
      "journey_policy_id": "831043ff-44b5-5aba-a793-20ea68492edc",
      "sequence_order": 1,
      "name": "Return journey",
      "leg_role": "RETURN",
      "journey_context": "GENERAL",
      "is_required": true,
      "origin_selection_mode": "FIXED_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Accommodation endpoint selected at booking; return includes after-midnight pickup in packages.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04-RETURN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 194,
    "table_name": "service_journey_legs",
    "capture_ref": "C05-OUTBOUND",
    "payload": {
      "id": "4481f7cc-9ba6-5936-8b4f-7639b5643d1d",
      "journey_policy_id": "6a52ed34-a3e7-584b-8b71-68d7c08499b0",
      "sequence_order": 0,
      "name": "Outbound journey",
      "leg_role": "OUTBOUND",
      "journey_context": "GENERAL",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "FIXED_PLACE",
      "origin_place_id": null,
      "destination_place_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Accommodation endpoint selected at booking; return includes after-midnight pickup in packages.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05-OUTBOUND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 195,
    "table_name": "service_journey_legs",
    "capture_ref": "C05-RETURN",
    "payload": {
      "id": "4a958cfa-c24a-5782-9db6-c2b52b293571",
      "journey_policy_id": "6a52ed34-a3e7-584b-8b71-68d7c08499b0",
      "sequence_order": 1,
      "name": "Return journey",
      "leg_role": "RETURN",
      "journey_context": "GENERAL",
      "is_required": true,
      "origin_selection_mode": "FIXED_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": "1da41c8a-0dc3-565a-ab8d-0b0479fdee20",
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Accommodation endpoint selected at booking; return includes after-midnight pickup in packages.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05-RETURN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 196,
    "table_name": "service_journey_legs",
    "capture_ref": "C14-VEHICLE-OUTBOUND",
    "payload": {
      "id": "ebf56f35-4a94-5a65-8104-9bd743fca188",
      "journey_policy_id": "f7e38630-8f63-58a0-a047-41617ea763a0",
      "sequence_order": 0,
      "name": "Outbound journey",
      "leg_role": "OUTBOUND",
      "journey_context": "AIRPORT_ARRIVAL",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": null,
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Entebbe airport / Jinja accommodation endpoints to resolve. Travel dates may precede/follow festival.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-VEHICLE-OUTBOUND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 197,
    "table_name": "service_journey_legs",
    "capture_ref": "C14-VEHICLE-RETURN",
    "payload": {
      "id": "3c8580c7-6fe6-558c-ba17-4a7c3cfc1b16",
      "journey_policy_id": "f7e38630-8f63-58a0-a047-41617ea763a0",
      "sequence_order": 1,
      "name": "Return journey",
      "leg_role": "RETURN",
      "journey_context": "AIRPORT_DEPARTURE",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": null,
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Entebbe airport / Jinja accommodation endpoints to resolve. Travel dates may precede/follow festival.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-VEHICLE-RETURN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 198,
    "table_name": "service_journey_legs",
    "capture_ref": "C14-SEAT-OUTBOUND",
    "payload": {
      "id": "1b259169-935d-58f3-8b27-eb41c011549f",
      "journey_policy_id": "07124d3a-fcb4-53bb-8b14-408a211d1315",
      "sequence_order": 0,
      "name": "Outbound journey",
      "leg_role": "OUTBOUND",
      "journey_context": "AIRPORT_ARRIVAL",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": null,
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Entebbe airport / Jinja accommodation endpoints to resolve. Travel dates may precede/follow festival.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-SEAT-OUTBOUND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 199,
    "table_name": "service_journey_legs",
    "capture_ref": "C14-SEAT-RETURN",
    "payload": {
      "id": "087a1988-d979-524a-89fe-2bb0c65ec521",
      "journey_policy_id": "07124d3a-fcb4-53bb-8b14-408a211d1315",
      "sequence_order": 1,
      "name": "Return journey",
      "leg_role": "RETURN",
      "journey_context": "AIRPORT_DEPARTURE",
      "is_required": true,
      "origin_selection_mode": "CUSTOMER_PLACE",
      "destination_selection_mode": "CUSTOMER_PLACE",
      "origin_place_id": null,
      "destination_place_id": null,
      "origin_area_id": null,
      "destination_area_id": null,
      "timing_basis": "CUSTOMER_TIME",
      "booking_event_code": null,
      "offset_minutes": null,
      "instructions": "Entebbe airport / Jinja accommodation endpoints to resolve. Travel dates may precede/follow festival.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-SEAT-RETURN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 200,
    "table_name": "service_entitlement_policies",
    "capture_ref": "C06",
    "payload": {
      "scope_id": "837f1c88-f63a-546a-b9e4-fa107ea1ac9e",
      "fulfilment_method": "DIRECT_PROVISION",
      "validity_basis": "SELECTED_DATE",
      "valid_from": null,
      "valid_until": null,
      "usage_policy": "SINGLE_USE",
      "maximum_uses": null,
      "is_transferable": false,
      "requires_collection": false,
      "collection_instructions": null,
      "redemption_instructions": "Supplier must confirm venue, validity, use restrictions and transferability before publication.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 201,
    "table_name": "service_entitlement_policies",
    "capture_ref": "C07",
    "payload": {
      "scope_id": "14fecf33-87e9-5b24-a862-64213dbd1e4b",
      "fulfilment_method": "REDEMPTION",
      "validity_basis": "BOOKED_STAY",
      "valid_from": null,
      "valid_until": null,
      "usage_policy": "SINGLE_USE",
      "maximum_uses": null,
      "is_transferable": false,
      "requires_collection": false,
      "collection_instructions": null,
      "redemption_instructions": "Supplier must confirm venue, validity, use restrictions and transferability before publication.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 202,
    "table_name": "service_entitlement_policies",
    "capture_ref": "C08",
    "payload": {
      "scope_id": "3d43ecc2-81b9-5bec-bea0-d82472c865be",
      "fulfilment_method": "DIRECT_PROVISION",
      "validity_basis": "BOOKED_STAY",
      "valid_from": null,
      "valid_until": null,
      "usage_policy": "SINGLE_USE",
      "maximum_uses": null,
      "is_transferable": false,
      "requires_collection": false,
      "collection_instructions": null,
      "redemption_instructions": "Supplier must confirm venue, validity, use restrictions and transferability before publication.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 203,
    "table_name": "service_entitlement_policies",
    "capture_ref": "C09",
    "payload": {
      "scope_id": "ecf3a8a7-7e99-5dca-abcc-68824bbe9bd1",
      "fulfilment_method": "ACCESS",
      "validity_basis": "BOOKED_STAY",
      "valid_from": null,
      "valid_until": null,
      "usage_policy": "UNLIMITED_USE",
      "maximum_uses": null,
      "is_transferable": false,
      "requires_collection": false,
      "collection_instructions": null,
      "redemption_instructions": "Supplier must confirm venue, validity, use restrictions and transferability before publication.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 204,
    "table_name": "service_entitlement_policies",
    "capture_ref": "C07-EDEN",
    "payload": {
      "scope_id": "33597168-eeea-53e0-b066-179aa07eee47",
      "fulfilment_method": "REDEMPTION",
      "validity_basis": "BOOKED_STAY",
      "valid_from": null,
      "valid_until": null,
      "usage_policy": "SINGLE_USE",
      "maximum_uses": null,
      "is_transferable": false,
      "requires_collection": false,
      "collection_instructions": null,
      "redemption_instructions": "Redeem at Eden Rocks lodge; meal allowance and validity to confirm.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07-EDEN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 205,
    "table_name": "service_entitlement_resources",
    "capture_ref": "C07-EDEN",
    "payload": {
      "entitlement_policy_id": "33597168-eeea-53e0-b066-179aa07eee47",
      "resource_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "purpose": "REDEEM_AT",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07-EDEN",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 206,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "P01-EXTEND",
    "payload": {
      "id": "32a173eb-c1ab-5705-9169-a031896aa68c",
      "scope_id": "3c32d136-7ee8-5479-838f-24c7f47dc802",
      "adjustment_type": "PERIOD_EXTENSION",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "Extra night on 18 or 23 November, on request. Final checkout and availability to confirm.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-EXTEND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 207,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "P02-EXTEND",
    "payload": {
      "id": "f0420b43-7711-5f59-a75a-3da2593f0caa",
      "scope_id": "3cc9a125-1137-52ea-ba54-5369140691ea",
      "adjustment_type": "PERIOD_EXTENSION",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "Extra night on 18 or 23 November, on request. Final checkout and availability to confirm.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-EXTEND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 208,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "P03-EXTEND",
    "payload": {
      "id": "6524e7ea-2fdb-599c-8a4c-1316c64ef5c6",
      "scope_id": "08ce925d-9226-5f70-88ef-c77da5d25932",
      "adjustment_type": "PERIOD_EXTENSION",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "Extra night on 18 or 23 November, on request. Final checkout and availability to confirm.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-EXTEND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 209,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "C03-EXTEND",
    "payload": {
      "id": "83e3ccd9-445a-5e68-9427-86bbfdac9a62",
      "scope_id": "7eb7099e-c0c2-5d5d-93de-73ead5a64fd9",
      "adjustment_type": "PERIOD_EXTENSION",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "Extra night on 18 or 23 November, on request. Final checkout and availability to confirm.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-EXTEND",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 210,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "P03-EXTRA",
    "payload": {
      "id": "5d1732ca-f8db-5ed2-b2a1-59b8c21fe1b8",
      "scope_id": "08ce925d-9226-5f70-88ef-c77da5d25932",
      "adjustment_type": "EXTRA_PARTICIPANT",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "C15: extra person at Jinja Jungle, UGX 245,000 per night; quantity limited by confirmed Unit capacity. Included benefits unconfirmed.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-EXTRA",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 211,
    "table_name": "listing_adjustment_rules",
    "capture_ref": "C03-EXTRA",
    "payload": {
      "id": "cec00e89-6056-5f88-8f72-6246f795a9e3",
      "scope_id": "7eb7099e-c0c2-5d5d-93de-73ead5a64fd9",
      "adjustment_type": "EXTRA_PARTICIPANT",
      "is_allowed": true,
      "minimum_quantity": 1,
      "maximum_quantity": null,
      "requires_requote": true,
      "requires_provider_confirmation": true,
      "instructions": "C15: extra person at Jinja Jungle, UGX 245,000 per night; quantity limited by confirmed Unit capacity. Included benefits unconfirmed.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-EXTRA",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 212,
    "table_name": "booking_documents",
    "capture_ref": "MAGMA_TERMS_2026",
    "payload": {
      "id": "2b6e0cad-b2f1-5de0-ad79-6722bd2ffe9e",
      "code": "MAGMA_TERMS_2026",
      "name": "Magma Tours Nyege Nyege 2026 booking terms",
      "description": "Supplier text; contradictions retained for clarification.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "MAGMA_TERMS_2026",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 213,
    "table_name": "booking_document_versions",
    "capture_ref": "MAGMA_TERMS_2026-V1",
    "payload": {
      "id": "b9ce4f7e-96a6-5a1c-a144-e96d74d10ec6",
      "document_id": "2b6e0cad-b2f1-5de0-ad79-6722bd2ffe9e",
      "version_number": 1,
      "content_text": "Deposit: 50% confirms your booking. The balance is due 14 days before arrival.\n     Cancellation: more than 30 days before arrival, your deposit is refunded less an admin\n     fee. Between 14 and 30 days, the deposit is forfeited. Under 14 days, there is no refund,\n     but you can transfer the booking to another guest.\n     Stay dates: arrive from 18 Nov and leave on 23 Nov. Minimum stay is 3 nights.\n     Payment: mobile money, card or bank transfer. The UGX price is locked at the exchange\n     rate on the day you book.\n\n\n\n                                                                                        \n\n\n\n\n\n     Groups: 5% off per person for groups of 5 or more.\n     Weather: November is rainy season. All rented tents are waterproof. If a camp floods,\n     you can upgrade to a room at the price difference.\n     Safety: activities such as rafting, tubing and quad biking need a signed waiver. We\n     recommend travel insurance.\n     Not included: festival ticket, drinks, personal spending, travel insurance and airport\n     transfers unless added.\n\nBook with Magma Tours to hold your place. Rooms and cottages are limited.",
      "asset_url": null,
      "content_sha256": "4f91472ef3a034cf43a402e45c89829d2ea1c0ad71b02026282526b3bc2955e3",
      "published_at": null,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "MAGMA_TERMS_2026-V1",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 214,
    "table_name": "listing_booking_obligations",
    "capture_ref": "P01-TERMS",
    "payload": {
      "id": "f170e2c0-3750-5ad3-9723-80925a743063",
      "scope_id": "9db475de-b9d3-5eac-af8b-50dab81646e2",
      "code": "MAGMA_TERMS",
      "obligation_type": "TERMS_ACCEPTANCE",
      "document_version_id": "b9ce4f7e-96a6-5a1c-a144-e96d74d10ec6",
      "is_required": true,
      "required_by_stage": "CONFIRMATION",
      "instructions": "Review and resolve supplier terms before publishing or requesting acceptance.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-TERMS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 215,
    "table_name": "listing_booking_obligations",
    "capture_ref": "P02-TERMS",
    "payload": {
      "id": "89b6fc3a-0c72-5cbd-bddb-0147cb3e1f90",
      "scope_id": "435d6d6d-8fdc-5f48-a16a-c8f91ca2f184",
      "code": "MAGMA_TERMS",
      "obligation_type": "TERMS_ACCEPTANCE",
      "document_version_id": "b9ce4f7e-96a6-5a1c-a144-e96d74d10ec6",
      "is_required": true,
      "required_by_stage": "CONFIRMATION",
      "instructions": "Review and resolve supplier terms before publishing or requesting acceptance.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-TERMS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 216,
    "table_name": "listing_booking_obligations",
    "capture_ref": "P03-TERMS",
    "payload": {
      "id": "a3c1c674-0555-5081-a5d5-d848e45c44ca",
      "scope_id": "b5d27a97-99b1-5297-ab7e-83453e433cba",
      "code": "MAGMA_TERMS",
      "obligation_type": "TERMS_ACCEPTANCE",
      "document_version_id": "b9ce4f7e-96a6-5a1c-a144-e96d74d10ec6",
      "is_required": true,
      "required_by_stage": "CONFIRMATION",
      "instructions": "Review and resolve supplier terms before publishing or requesting acceptance.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-TERMS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 217,
    "table_name": "listing_booking_obligations",
    "capture_ref": "C10-WAIVER",
    "payload": {
      "id": "d083d66c-39cc-596a-9814-fee22151bc04",
      "scope_id": "1d19fd3a-d560-5cd9-8850-7d082d2a4c5d",
      "code": "SIGNED_ACTIVITY_WAIVER",
      "obligation_type": "WAIVER",
      "document_version_id": null,
      "is_required": true,
      "required_by_stage": "BEFORE_DELIVERY",
      "instructions": "Signed waiver required by source. Actual provider waiver document is not supplied.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C10-WAIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 218,
    "table_name": "listing_booking_obligations",
    "capture_ref": "C11-WAIVER",
    "payload": {
      "id": "c2b70c01-a05b-55fc-9aba-30293f71544b",
      "scope_id": "ed7d91ee-294d-5971-9719-a31f2dd8817f",
      "code": "SIGNED_ACTIVITY_WAIVER",
      "obligation_type": "WAIVER",
      "document_version_id": null,
      "is_required": true,
      "required_by_stage": "BEFORE_DELIVERY",
      "instructions": "Signed waiver required by source. Actual provider waiver document is not supplied.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C11-WAIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 219,
    "table_name": "listing_booking_obligations",
    "capture_ref": "C12-WAIVER",
    "payload": {
      "id": "09d1dd85-dc45-5f35-b945-bbe8542bf1e3",
      "scope_id": "f748859a-783b-56fa-a2a3-8d157bfd263b",
      "code": "SIGNED_ACTIVITY_WAIVER",
      "obligation_type": "WAIVER",
      "document_version_id": null,
      "is_required": true,
      "required_by_stage": "BEFORE_DELIVERY",
      "instructions": "Signed waiver required by source. Actual provider waiver document is not supplied.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C12-WAIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 220,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "P01-OPERATOR",
    "payload": {
      "id": "affb65f8-ac50-5d2a-b08a-f7de8a483822",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P01-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 221,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "P02-OPERATOR",
    "payload": {
      "id": "5adb48fd-4dc6-5692-924c-c99edeea5dcf",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P02-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 222,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "P03-OPERATOR",
    "payload": {
      "id": "5f399bbe-61e4-5a3f-b19d-76725236a6b3",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P03-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 223,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "P04-OPERATOR",
    "payload": {
      "id": "bef9455c-2603-5d6b-844c-24c84823ad0f",
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P04-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 224,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C01-OPERATOR",
    "payload": {
      "id": "fb2323c9-bda5-512c-a1eb-bcd929d1d9f6",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C01-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 225,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C02-OPERATOR",
    "payload": {
      "id": "e7481483-2cb7-5088-a774-97855a1b027a",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C02-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 226,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C03-OPERATOR",
    "payload": {
      "id": "c9ca1912-1cd8-5401-b15d-0794396fe5b3",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C03-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 227,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C04-OPERATOR",
    "payload": {
      "id": "d883e6f4-be2c-50d4-84ce-f810b07a1e95",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C04-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 228,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C05-OPERATOR",
    "payload": {
      "id": "51f84261-b2bf-5536-840e-8e9f6cc67412",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C05-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 229,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C06-OPERATOR",
    "payload": {
      "id": "b3a2e59e-bf10-5be9-bd16-1f3d0203f760",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C06-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 230,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C07-OPERATOR",
    "payload": {
      "id": "a5699416-c196-5c4c-99dc-3840ac921051",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C07-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 231,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C08-OPERATOR",
    "payload": {
      "id": "dedb5d35-7190-5447-9e1c-e409ce882c1b",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C08-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 232,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C09-OPERATOR",
    "payload": {
      "id": "68641a75-f834-5045-a085-1bbeafcd4242",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C09-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 233,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C10-OPERATOR",
    "payload": {
      "id": "5a39de8c-0e81-5507-a8e8-a06cb9c224f2",
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C10-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 234,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C11-OPERATOR",
    "payload": {
      "id": "64eb92e3-b6dc-556b-8f52-b2fad7873dcf",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C11-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 235,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C12-OPERATOR",
    "payload": {
      "id": "e1754eb6-bba5-5332-907b-40dfafe92214",
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C12-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 236,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C13-OPERATOR",
    "payload": {
      "id": "0395bad9-a04b-5fec-bbb1-185301ec4684",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C13-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 237,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C14-OPERATOR",
    "payload": {
      "id": "7c70d802-92b4-559a-9599-6b6c783ecef8",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Magma coordinates package offer; confirm operational responsibility.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C14-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 238,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C01-ACCOM",
    "payload": {
      "id": "c2903d42-a90a-5bb8-9d61-02de96502606",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "FIXED",
      "notes": "Named accommodation establishment. Actual Unit allocations remain booking-level.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C01-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "ACCOMMODATION"
    }
  },
  {
    "ordinal": 239,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C02-ACCOM",
    "payload": {
      "id": "6613fc16-55d0-5cac-a02a-0124524849d3",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "FIXED",
      "notes": "Named accommodation establishment. Actual Unit allocations remain booking-level.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C02-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "ACCOMMODATION"
    }
  },
  {
    "ordinal": 240,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C03-ACCOM",
    "payload": {
      "id": "8e1823e3-ac32-5011-b0ef-e3ba511fc955",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "FIXED",
      "notes": "Named accommodation establishment. Actual Unit allocations remain booking-level.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C03-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "ACCOMMODATION"
    }
  },
  {
    "ordinal": 241,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C04-VEHICLE",
    "payload": {
      "id": "58212975-f373-50fb-a930-5239631da4f3",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual vehicle not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C04-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "VEHICLE"
    }
  },
  {
    "ordinal": 242,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C04-DRIVER",
    "payload": {
      "id": "b401e1b6-66fb-5aa0-9f1d-da68b64632ec",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual driver not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C04-DRIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "DRIVER"
    }
  },
  {
    "ordinal": 243,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C05-VEHICLE",
    "payload": {
      "id": "796a0f00-75c0-5b90-b49e-b33527fe1400",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual vehicle not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C05-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "VEHICLE"
    }
  },
  {
    "ordinal": 244,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C05-DRIVER",
    "payload": {
      "id": "21590bac-ce93-5a86-aecd-ca8948aa4925",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual driver not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C05-DRIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "DRIVER"
    }
  },
  {
    "ordinal": 245,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C14-VEHICLE",
    "payload": {
      "id": "95e3bfe5-4e24-5845-8e6e-9758930f59cf",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual vehicle not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C14-VEHICLE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "VEHICLE"
    }
  },
  {
    "ordinal": 246,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C14-DRIVER",
    "payload": {
      "id": "4ac78c05-353a-5a9d-95a6-296c9d56de76",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "Actual driver not named by source; select at booking.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C14-DRIVER",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "DRIVER"
    }
  },
  {
    "ordinal": 247,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C13-GUIDE",
    "payload": {
      "id": "5857e5a3-826b-5654-b063-445ee575185a",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_option_id": null,
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": null,
      "selection_mode": "DYNAMIC",
      "notes": "No guide named by source.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C13-GUIDE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "GUIDE"
    }
  },
  {
    "ordinal": 248,
    "table_name": "listing_fulfilment_requirements",
    "capture_ref": "C11-PREMIUM-OP",
    "payload": {
      "id": "9ef1b730-ba9c-5cfe-80ad-4f5e3b76cc0e",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "listing_option_id": "f473fd4f-7a59-5089-8552-d8e0547e4d3e",
      "resource_role_id": null,
      "is_required": true,
      "minimum_count": 1,
      "maximum_count": 1,
      "selection_mode": "FIXED",
      "notes": "Premium rafting option explicitly names Bungee Uganda.",
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C11-PREMIUM-OP",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_resource_role_code": "OPERATOR"
    }
  },
  {
    "ordinal": 249,
    "table_name": "listing_resources",
    "capture_ref": "P01-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "affb65f8-ac50-5d2a-b08a-f7de8a483822",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P01-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 250,
    "table_name": "listing_resources",
    "capture_ref": "P02-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "5adb48fd-4dc6-5692-924c-c99edeea5dcf",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P02-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 251,
    "table_name": "listing_resources",
    "capture_ref": "P03-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "5f399bbe-61e4-5a3f-b19d-76725236a6b3",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P03-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 252,
    "table_name": "listing_resources",
    "capture_ref": "P04-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "bef9455c-2603-5d6b-844c-24c84823ad0f",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "P04-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 253,
    "table_name": "listing_resources",
    "capture_ref": "C01-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "fb2323c9-bda5-512c-a1eb-bcd929d1d9f6",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C01-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 254,
    "table_name": "listing_resources",
    "capture_ref": "C02-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "e7481483-2cb7-5088-a774-97855a1b027a",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C02-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 255,
    "table_name": "listing_resources",
    "capture_ref": "C03-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "c9ca1912-1cd8-5401-b15d-0794396fe5b3",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C03-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 256,
    "table_name": "listing_resources",
    "capture_ref": "C04-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "d883e6f4-be2c-50d4-84ce-f810b07a1e95",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C04-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 257,
    "table_name": "listing_resources",
    "capture_ref": "C05-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "51f84261-b2bf-5536-840e-8e9f6cc67412",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C05-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 258,
    "table_name": "listing_resources",
    "capture_ref": "C06-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "b3a2e59e-bf10-5be9-bd16-1f3d0203f760",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C06-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 259,
    "table_name": "listing_resources",
    "capture_ref": "C07-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "a5699416-c196-5c4c-99dc-3840ac921051",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C07-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 260,
    "table_name": "listing_resources",
    "capture_ref": "C08-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "dedb5d35-7190-5447-9e1c-e409ce882c1b",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C08-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 261,
    "table_name": "listing_resources",
    "capture_ref": "C09-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "68641a75-f834-5045-a085-1bbeafcd4242",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C09-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 262,
    "table_name": "listing_resources",
    "capture_ref": "C10-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "5a39de8c-0e81-5507-a8e8-a06cb9c224f2",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C10-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 263,
    "table_name": "listing_resources",
    "capture_ref": "C11-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "64eb92e3-b6dc-556b-8f52-b2fad7873dcf",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C11-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 264,
    "table_name": "listing_resources",
    "capture_ref": "C12-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "e1754eb6-bba5-5332-907b-40dfafe92214",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C12-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 265,
    "table_name": "listing_resources",
    "capture_ref": "C13-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "0395bad9-a04b-5fec-bbb1-185301ec4684",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C13-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 266,
    "table_name": "listing_resources",
    "capture_ref": "C14-OPERATOR",
    "payload": {
      "fulfilment_requirement_id": "7c70d802-92b4-559a-9599-6b6c783ecef8",
      "resource_id": "9c8c751b-700d-5689-a0da-4b0a1d4a9819",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C14-OPERATOR",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 267,
    "table_name": "listing_resources",
    "capture_ref": "C01-ACCOM",
    "payload": {
      "fulfilment_requirement_id": "c2903d42-a90a-5bb8-9d61-02de96502606",
      "resource_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C01-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 268,
    "table_name": "listing_resources",
    "capture_ref": "C02-ACCOM",
    "payload": {
      "fulfilment_requirement_id": "6613fc16-55d0-5cac-a02a-0124524849d3",
      "resource_id": "fa5edf97-5bb9-595c-a4af-e3103f804d3c",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C02-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 269,
    "table_name": "listing_resources",
    "capture_ref": "C03-ACCOM",
    "payload": {
      "fulfilment_requirement_id": "8e1823e3-ac32-5011-b0ef-e3ba511fc955",
      "resource_id": "9b625049-d5f0-5637-9a23-d9e5b5d52f1e",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C03-ACCOM",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 270,
    "table_name": "listing_resources",
    "capture_ref": "C11-PREMIUM-OP",
    "payload": {
      "fulfilment_requirement_id": "9ef1b730-ba9c-5cfe-80ad-4f5e3b76cc0e",
      "resource_id": "83b442cf-1530-54b3-b466-15489702949b",
      "is_preferred": false,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "_capture_ref": "C11-PREMIUM-OP",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 271,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C01-CHECK_IN_DATE",
    "payload": {
      "id": "a617e942-2ad2-5cf4-ade1-036e6bc45ba9",
      "scope_id": "a69c49b1-808b-54cb-a959-b7e05c945fe7",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01-CHECK_IN_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_IN_DATE"
    }
  },
  {
    "ordinal": 272,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C01-CHECK_OUT_DATE",
    "payload": {
      "id": "8eeb7501-d066-54ed-b174-492c18dbf4a4",
      "scope_id": "a69c49b1-808b-54cb-a959-b7e05c945fe7",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01-CHECK_OUT_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_OUT_DATE"
    }
  },
  {
    "ordinal": 273,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C01-GUEST_COUNT",
    "payload": {
      "id": "748a4e08-feea-5f5a-b41b-245f902076bb",
      "scope_id": "a69c49b1-808b-54cb-a959-b7e05c945fe7",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 2,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01-GUEST_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "GUEST_COUNT"
    }
  },
  {
    "ordinal": 274,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C01-ROOM_PREFERENCES",
    "payload": {
      "id": "bd02ad54-a323-5c6e-adf6-6496a7c2f3f1",
      "scope_id": "a69c49b1-808b-54cb-a959-b7e05c945fe7",
      "information_field_id": null,
      "is_required": false,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 3,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01-ROOM_PREFERENCES",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "ROOM_PREFERENCES"
    }
  },
  {
    "ordinal": 275,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C02-CHECK_IN_DATE",
    "payload": {
      "id": "c860c7e1-e5e3-5ac1-8920-882d306cabe7",
      "scope_id": "4b94fa70-964d-518d-900b-23c6ffddd968",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-CHECK_IN_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_IN_DATE"
    }
  },
  {
    "ordinal": 276,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C02-CHECK_OUT_DATE",
    "payload": {
      "id": "ca1cd18f-52b0-5a17-9ebb-b1429bfa8b56",
      "scope_id": "4b94fa70-964d-518d-900b-23c6ffddd968",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-CHECK_OUT_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_OUT_DATE"
    }
  },
  {
    "ordinal": 277,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C02-GUEST_COUNT",
    "payload": {
      "id": "dc6eeea0-4808-545e-b07d-6e394adb9451",
      "scope_id": "4b94fa70-964d-518d-900b-23c6ffddd968",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 2,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-GUEST_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "GUEST_COUNT"
    }
  },
  {
    "ordinal": 278,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C02-ROOM_PREFERENCES",
    "payload": {
      "id": "20d2f8a2-2abd-59e7-8c60-f8532544eb82",
      "scope_id": "4b94fa70-964d-518d-900b-23c6ffddd968",
      "information_field_id": null,
      "is_required": false,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 3,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-ROOM_PREFERENCES",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "ROOM_PREFERENCES"
    }
  },
  {
    "ordinal": 279,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C03-CHECK_IN_DATE",
    "payload": {
      "id": "c6157fa5-dd05-5a18-9c6b-de58e4d84b11",
      "scope_id": "57561871-14f5-5dc3-b4fd-61da748efb39",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-CHECK_IN_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_IN_DATE"
    }
  },
  {
    "ordinal": 280,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C03-CHECK_OUT_DATE",
    "payload": {
      "id": "e7aa1bdb-dbab-5789-9f66-aaedfb767159",
      "scope_id": "57561871-14f5-5dc3-b4fd-61da748efb39",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-CHECK_OUT_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_OUT_DATE"
    }
  },
  {
    "ordinal": 281,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C03-GUEST_COUNT",
    "payload": {
      "id": "bf88c4ff-93a5-5441-b8b2-ad23f367ef57",
      "scope_id": "57561871-14f5-5dc3-b4fd-61da748efb39",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 2,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-GUEST_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "GUEST_COUNT"
    }
  },
  {
    "ordinal": 282,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C03-ROOM_PREFERENCES",
    "payload": {
      "id": "13a14205-667e-5653-9c30-063d195b1f20",
      "scope_id": "57561871-14f5-5dc3-b4fd-61da748efb39",
      "information_field_id": null,
      "is_required": false,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 3,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-ROOM_PREFERENCES",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "ROOM_PREFERENCES"
    }
  },
  {
    "ordinal": 283,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C04-PICKUP_TIME",
    "payload": {
      "id": "b89f4ec8-0e83-5eed-9759-53fe94187232",
      "scope_id": "6ede1496-7314-5caa-b91b-b459fd8587d4",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04-PICKUP_TIME",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PICKUP_TIME"
    }
  },
  {
    "ordinal": 284,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C04-PASSENGER_COUNT",
    "payload": {
      "id": "9b8a57d0-6ddd-56df-abd1-42137f24d67c",
      "scope_id": "6ede1496-7314-5caa-b91b-b459fd8587d4",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04-PASSENGER_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PASSENGER_COUNT"
    }
  },
  {
    "ordinal": 285,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C05-PICKUP_TIME",
    "payload": {
      "id": "aaef9541-2abb-5a8e-8465-cbebd039f30f",
      "scope_id": "5c6873bb-c297-5b33-8d8b-6ce2c2cd3f09",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05-PICKUP_TIME",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PICKUP_TIME"
    }
  },
  {
    "ordinal": 286,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C05-PASSENGER_COUNT",
    "payload": {
      "id": "c4b1fe7d-ad99-5eb3-a1c0-bd89ae7b4203",
      "scope_id": "5c6873bb-c297-5b33-8d8b-6ce2c2cd3f09",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05-PASSENGER_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PASSENGER_COUNT"
    }
  },
  {
    "ordinal": 287,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C06-QUANTITY",
    "payload": {
      "id": "8b2bd8b5-3f40-5127-819f-90f094488ac1",
      "scope_id": "4d1a0277-9b2b-58cd-9dd4-4fbd31e9e89e",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-QUANTITY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "QUANTITY"
    }
  },
  {
    "ordinal": 288,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C06-SERVICE_START_AT",
    "payload": {
      "id": "f4db8c18-d6e5-542f-8c81-e3d4ee75ada7",
      "scope_id": "4d1a0277-9b2b-58cd-9dd4-4fbd31e9e89e",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-SERVICE_START_AT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "SERVICE_START_AT"
    }
  },
  {
    "ordinal": 289,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C07-QUANTITY",
    "payload": {
      "id": "1ada4924-20bb-5bca-94a0-05a1a91ce3b4",
      "scope_id": "96a360c3-8323-5912-87cd-19d6aa1c3b58",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07-QUANTITY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "QUANTITY"
    }
  },
  {
    "ordinal": 290,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C08-QUANTITY",
    "payload": {
      "id": "02964be5-0c26-5715-80f2-9c3ad4ef1f32",
      "scope_id": "1996c931-2990-5cca-a3fb-4ed5dbb099c2",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08-QUANTITY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "QUANTITY"
    }
  },
  {
    "ordinal": 291,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C09-QUANTITY",
    "payload": {
      "id": "76d64b40-1943-554d-a770-26fa852f2a6a",
      "scope_id": "0c9c7429-546d-5476-8a8d-b8cd2e72d5ed",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09-QUANTITY",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "QUANTITY"
    }
  },
  {
    "ordinal": 292,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C09-CHECK_IN_DATE",
    "payload": {
      "id": "9470b339-4897-5407-a30a-00a98072cf37",
      "scope_id": "0c9c7429-546d-5476-8a8d-b8cd2e72d5ed",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09-CHECK_IN_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_IN_DATE"
    }
  },
  {
    "ordinal": 293,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C09-CHECK_OUT_DATE",
    "payload": {
      "id": "412825ea-545b-5397-8cf4-d31aa9cb68c4",
      "scope_id": "0c9c7429-546d-5476-8a8d-b8cd2e72d5ed",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 2,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09-CHECK_OUT_DATE",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "CHECK_OUT_DATE"
    }
  },
  {
    "ordinal": 294,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C14-FLIGHT_DETAILS",
    "payload": {
      "id": "42713bac-1040-55da-800c-41ba10514d4b",
      "scope_id": "01a31be8-a8c2-5c81-9417-f66acb3c74a5",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 0,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-FLIGHT_DETAILS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "FLIGHT_DETAILS"
    }
  },
  {
    "ordinal": 295,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C14-PASSENGER_COUNT",
    "payload": {
      "id": "402681fa-96cc-5928-8652-a95a87457cad",
      "scope_id": "01a31be8-a8c2-5c81-9417-f66acb3c74a5",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 1,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-PASSENGER_COUNT",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PASSENGER_COUNT"
    }
  },
  {
    "ordinal": 296,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C14-PICKUP_ADDRESS",
    "payload": {
      "id": "4876c347-0698-5b79-86fe-e6d32e58a34c",
      "scope_id": "01a31be8-a8c2-5c81-9417-f66acb3c74a5",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 2,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-PICKUP_ADDRESS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "PICKUP_ADDRESS"
    }
  },
  {
    "ordinal": 297,
    "table_name": "listing_customer_information_requirements",
    "capture_ref": "C14-DROPOFF_ADDRESS",
    "payload": {
      "id": "9284ccc4-0849-5dc9-be3b-bf0985c4547a",
      "scope_id": "01a31be8-a8c2-5c81-9417-f66acb3c74a5",
      "information_field_id": null,
      "is_required": true,
      "applicability_code": "ALWAYS",
      "help_text": "Collect at request; supplier confirms final arrangement.",
      "sort_order": 3,
      "is_live": false,
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-DROPOFF_ADDRESS",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer",
      "_information_field_code": "DROPOFF_ADDRESS"
    }
  },
  {
    "ordinal": 298,
    "table_name": "listing_event_associations",
    "capture_ref": "P01-E01",
    "payload": {
      "id": "6ab151bf-e613-5165-adee-e1e0772e229d",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P01-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 299,
    "table_name": "listing_event_associations",
    "capture_ref": "P02-E01",
    "payload": {
      "id": "65efe49c-8dca-500a-956e-90bf49d00ddc",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P02-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 300,
    "table_name": "listing_event_associations",
    "capture_ref": "P03-E01",
    "payload": {
      "id": "7d3ff995-d045-5006-8983-b6a4aea88e40",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P03-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 301,
    "table_name": "listing_event_associations",
    "capture_ref": "P04-E01",
    "payload": {
      "id": "50dcf68a-a6b3-51e5-84d2-fff0ee8c814f",
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "P04-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 302,
    "table_name": "listing_event_associations",
    "capture_ref": "C01-E01",
    "payload": {
      "id": "bd0e694c-c342-5463-aa23-0ae05e99fee7",
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "ACCOMMODATION_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C01-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 303,
    "table_name": "listing_event_associations",
    "capture_ref": "C02-E01",
    "payload": {
      "id": "25196b9d-0320-52a0-a68e-01f2c347b253",
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "ACCOMMODATION_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C02-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 304,
    "table_name": "listing_event_associations",
    "capture_ref": "C03-E01",
    "payload": {
      "id": "a37f1497-86c0-5d88-a392-dcb1cce5cfdc",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "ACCOMMODATION_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C03-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 305,
    "table_name": "listing_event_associations",
    "capture_ref": "C04-E01",
    "payload": {
      "id": "b5bec46a-ab50-5e65-84d8-4bca0de36d20",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "TRANSPORT_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C04-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 306,
    "table_name": "listing_event_associations",
    "capture_ref": "C05-E01",
    "payload": {
      "id": "f66e54ae-77dc-56bb-8055-03b030290970",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "TRANSPORT_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C05-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 307,
    "table_name": "listing_event_associations",
    "capture_ref": "C06-E01",
    "payload": {
      "id": "2a087585-b842-552e-b695-2405af8a9fbc",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "SUPPORTING_SERVICE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C06-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 308,
    "table_name": "listing_event_associations",
    "capture_ref": "C07-E01",
    "payload": {
      "id": "4b0e4820-37b1-590a-ae9a-32b691d6c171",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "SUPPORTING_SERVICE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C07-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 309,
    "table_name": "listing_event_associations",
    "capture_ref": "C08-E01",
    "payload": {
      "id": "eedf5f67-ee3c-5d1b-a087-9377dce9cbca",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "SUPPORTING_SERVICE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C08-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 310,
    "table_name": "listing_event_associations",
    "capture_ref": "C09-E01",
    "payload": {
      "id": "aa5d2ba7-a3ba-53b7-91cb-7930fdffbbfd",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "SUPPORTING_SERVICE",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C09-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 311,
    "table_name": "listing_event_associations",
    "capture_ref": "C10-E01",
    "payload": {
      "id": "b86665a7-6b59-5c80-8a85-6a98914732a3",
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C10-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 312,
    "table_name": "listing_event_associations",
    "capture_ref": "C11-E01",
    "payload": {
      "id": "18a2f251-ceed-5b36-ac3e-6bd08b9a0507",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C11-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 313,
    "table_name": "listing_event_associations",
    "capture_ref": "C12-E01",
    "payload": {
      "id": "53891493-5062-561e-b744-9862a44302d3",
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C12-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 314,
    "table_name": "listing_event_associations",
    "capture_ref": "C13-E01",
    "payload": {
      "id": "0cfa52b3-fb1e-59f2-82f3-71209505c855",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "RELATED_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 315,
    "table_name": "listing_event_associations",
    "capture_ref": "C14-E01",
    "payload": {
      "id": "197b182a-34b6-5eac-a2d8-b3b2e1ca6594",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "event_listing_id": "a31a6d8f-c82a-50a1-9721-f59e8979ae51",
      "event_occurrence_id": "a040f2be-5056-5e29-9889-19f82ee4215f",
      "relationship_type": "TRANSPORT_OFFER",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C14-E01",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 316,
    "table_name": "tour_policies",
    "capture_ref": "C13",
    "payload": {
      "scope_id": "092cf6fc-5c96-5c55-8763-23d6dbdd03b4",
      "schedule_mode": null,
      "participation_mode": null,
      "minimum_participants": 1,
      "maximum_participants": null,
      "departure_condition": "NO_MINIMUM",
      "minimum_departure_participants": null,
      "itinerary_day_count": 1,
      "overnight_count": 0,
      "time_zone": "Africa/Kampala",
      "is_customisable": false,
      "customisation_instructions": null,
      "preparation_instructions": "Draft day-tour configuration; duration, shared/private mode and detailed itinerary must be confirmed.",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 317,
    "table_name": "tour_itinerary_days",
    "capture_ref": "C13-DAY1",
    "payload": {
      "id": "849245e8-57ed-5d7a-8cac-0689532ef92a",
      "scope_id": "800eccda-8d21-515c-a985-5c2bed173a22",
      "day_number": 1,
      "title": "Jinja tour - itinerary to confirm",
      "description": "No route or stops listed in supplier offer.",
      "time_zone": "Africa/Kampala",
      "created_at": null,
      "updated_at": null,
      "created_by": null,
      "updated_by": null,
      "_capture_ref": "C13-DAY1",
      "_status": "DRAFT",
      "_source": "Derived PDF; original Magma offer"
    }
  },
  {
    "ordinal": 318,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "P01",
    "payload": {
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source UGX rates are authoritative. USD figures in the source are approximate at 4,120 UGX/USD. Packages are per person for four nights; Comfort/Premium sharing requires two occupants per unit. Group eligibility uses total qualifying party size, not occupants in one unit. Listed group prices are retained; no additional 5% deduction.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P01"
    }
  },
  {
    "ordinal": 319,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "P02",
    "payload": {
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source UGX rates are authoritative. USD figures in the source are approximate at 4,120 UGX/USD. Packages are per person for four nights; Comfort/Premium sharing requires two occupants per unit. Group eligibility uses total qualifying party size, not occupants in one unit. Listed group prices are retained; no additional 5% deduction.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P02"
    }
  },
  {
    "ordinal": 320,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "P03",
    "payload": {
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source UGX rates are authoritative. USD figures in the source are approximate at 4,120 UGX/USD. Packages are per person for four nights; Comfort/Premium sharing requires two occupants per unit. Group eligibility uses total qualifying party size, not occupants in one unit. Listed group prices are retained; no additional 5% deduction.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P03"
    }
  },
  {
    "ordinal": 321,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "P04",
    "payload": {
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source UGX rates are authoritative. USD figures in the source are approximate at 4,120 UGX/USD. Packages are per person for four nights; Comfort/Premium sharing requires two occupants per unit. Group eligibility uses total qualifying party size, not occupants in one unit. Listed group prices are retained; no additional 5% deduction.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P04"
    }
  },
  {
    "ordinal": 322,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C01",
    "payload": {
      "listing_id": "e79b1ea1-4582-57e1-b65c-ff6a74d3bc5b",
      "default_currency": "UGX",
      "display_mode": "REQUEST_ONLY",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C01"
    }
  },
  {
    "ordinal": 323,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C02",
    "payload": {
      "listing_id": "8be836c5-38b0-582c-8aca-a6c7156100cc",
      "default_currency": "UGX",
      "display_mode": "REQUEST_ONLY",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C02"
    }
  },
  {
    "ordinal": 324,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C03",
    "payload": {
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C03"
    }
  },
  {
    "ordinal": 325,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C04",
    "payload": {
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C04"
    }
  },
  {
    "ordinal": 326,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C05",
    "payload": {
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C05"
    }
  },
  {
    "ordinal": 327,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C06",
    "payload": {
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C06"
    }
  },
  {
    "ordinal": 328,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C07",
    "payload": {
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C07"
    }
  },
  {
    "ordinal": 329,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C08",
    "payload": {
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C08"
    }
  },
  {
    "ordinal": 330,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C09",
    "payload": {
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C09"
    }
  },
  {
    "ordinal": 331,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C10",
    "payload": {
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C10"
    }
  },
  {
    "ordinal": 332,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C11",
    "payload": {
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C11"
    }
  },
  {
    "ordinal": 333,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C12",
    "payload": {
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C12"
    }
  },
  {
    "ordinal": 334,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C13",
    "payload": {
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C13"
    }
  },
  {
    "ordinal": 335,
    "table_name": "listing_pricing_profiles",
    "capture_ref": "C14",
    "payload": {
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "default_currency": "UGX",
      "display_mode": "TIERS",
      "price_assumptions": "Source rate/unit retained without inferring per-person basis where the supplier does not state it. Extra nights require a quote. C03 EXTRA_PERSON is a supplement, not the base accommodation price.",
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C14"
    }
  },
  {
    "ordinal": 336,
    "table_name": "listing_price_offers",
    "capture_ref": "P01-R1",
    "payload": {
      "id": "7624d856-33fd-5ff5-8ffb-70e6acbc8f58",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "offer_code": "STANDARD",
      "label": "Standard",
      "amount": 455000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; Approximate source USD 110",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 0,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P01-R1"
    }
  },
  {
    "ordinal": 337,
    "table_name": "listing_price_offers",
    "capture_ref": "P01-R2",
    "payload": {
      "id": "179f4768-b830-5bb1-95ca-3f7c75aee4bf",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "offer_code": "GROUP_5_PLUS",
      "label": "Group 5+",
      "amount": 430000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; 5+ total qualifying travellers; no additional discount. Approximate source USD 104",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 5,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 1,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P01-R2"
    }
  },
  {
    "ordinal": 338,
    "table_name": "listing_price_offers",
    "capture_ref": "P01-R3",
    "payload": {
      "id": "f78c15fd-b1e7-5ec2-83da-f2cc1b327150",
      "listing_id": "603a7cbb-6153-586b-8e3e-d0d7aa3acdb3",
      "listing_option_id": null,
      "offer_code": "SOLO",
      "label": "Solo",
      "amount": 455000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; Approximate source USD 110",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 1,
      "max_guests": 1,
      "occupancy_code": "SINGLE",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 2,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P01-R3"
    }
  },
  {
    "ordinal": 339,
    "table_name": "listing_price_offers",
    "capture_ref": "P02-R1",
    "payload": {
      "id": "3fbca35a-2b94-5824-8fbc-d35e84a86ab1",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "offer_code": "STANDARD",
      "label": "Standard shared",
      "amount": 660000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; two guests sharing; amount is per person, not the two-person total. Approximate source USD 160",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": "SHARED",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 3,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P02-R1"
    }
  },
  {
    "ordinal": 340,
    "table_name": "listing_price_offers",
    "capture_ref": "P02-R2",
    "payload": {
      "id": "4e491765-852c-50f8-b0e1-3d1bae208e5b",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": "5990356d-af04-5193-ac57-f8eb8a8e4e9a",
      "offer_code": "GROUP_5_PLUS",
      "label": "Group 5+ shared",
      "amount": 625000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; two guests sharing; amount is per person, not the two-person total. 5+ total qualifying travellers; no additional discount. Approximate source USD 152",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 5,
      "max_guests": null,
      "occupancy_code": "SHARED",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 4,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P02-R2"
    }
  },
  {
    "ordinal": 341,
    "table_name": "listing_price_offers",
    "capture_ref": "P02-R3",
    "payload": {
      "id": "0d9001d8-09a8-5314-b5d5-7364901f7e7f",
      "listing_id": "bbfccfe6-47e4-5227-b606-b3979951e3df",
      "listing_option_id": "3573c8c5-dde0-5137-92fb-f461fc3878cb",
      "offer_code": "SOLO",
      "label": "Solo",
      "amount": 1090000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; Approximate source USD 265",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 1,
      "max_guests": 1,
      "occupancy_code": "SINGLE",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 5,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P02-R3"
    }
  },
  {
    "ordinal": 342,
    "table_name": "listing_price_offers",
    "capture_ref": "P03-R1",
    "payload": {
      "id": "0b6fc169-a026-5416-9bb3-d0c41258499c",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "offer_code": "STANDARD",
      "label": "Standard shared",
      "amount": 2250000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; two guests sharing; amount is per person, not the two-person total. Approximate source USD 546",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": "SHARED",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 6,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P03-R1"
    }
  },
  {
    "ordinal": 343,
    "table_name": "listing_price_offers",
    "capture_ref": "P03-R2",
    "payload": {
      "id": "b541ea3b-4aaf-5b33-846a-a8e58deed58a",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": "b1fed1cb-9ffa-5628-b1f9-bc5ebae469ed",
      "offer_code": "GROUP_5_PLUS",
      "label": "Group 5+ shared",
      "amount": 2140000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; two guests sharing; amount is per person, not the two-person total. 5+ total qualifying travellers; no additional discount. Approximate source USD 519",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 5,
      "max_guests": null,
      "occupancy_code": "SHARED",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 7,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P03-R2"
    }
  },
  {
    "ordinal": 344,
    "table_name": "listing_price_offers",
    "capture_ref": "P03-R3",
    "payload": {
      "id": "8d3e6b2f-5b90-57c4-8e1d-d0bd70426c91",
      "listing_id": "d3b54672-5eac-56ff-b101-6b0fb54c82d2",
      "listing_option_id": "a259a2b3-58d3-53b0-8b72-83d21b3b9e76",
      "offer_code": "SOLO",
      "label": "Solo",
      "amount": 3735000,
      "currency": "UGX",
      "occupancy_description": "Four-night package total; Approximate source USD 907",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": 1,
      "max_guests": 1,
      "occupancy_code": "SINGLE",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 8,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P03-R3"
    }
  },
  {
    "ordinal": 345,
    "table_name": "listing_price_offers",
    "capture_ref": "C04-R10",
    "payload": {
      "id": "d6aa1130-0f6f-5204-a069-e1ef1e1dc0dd",
      "listing_id": "99f6d231-4551-5858-9edf-91a62a08adfe",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per person per night",
      "amount": 30000,
      "currency": "UGX",
      "occupancy_description": "Per person per night; Approximate source USD 7",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": "PER_NIGHT",
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 9,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C04-R10"
    }
  },
  {
    "ordinal": 346,
    "table_name": "listing_price_offers",
    "capture_ref": "C05-R11",
    "payload": {
      "id": "a29b44e1-6335-50b9-849c-7b5611d20b27",
      "listing_id": "e8bd2c32-88fb-56af-b1ac-0b84aed208d8",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per person per night",
      "amount": 70000,
      "currency": "UGX",
      "occupancy_description": "Per person per night; Approximate source USD 17",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": "PER_NIGHT",
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 10,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C05-R11"
    }
  },
  {
    "ordinal": 347,
    "table_name": "listing_price_offers",
    "capture_ref": "C06-R12",
    "payload": {
      "id": "8d2db6d8-afe5-5293-afea-733a9e493330",
      "listing_id": "9a8b2868-b005-5a7c-97e5-ce48d5f2c550",
      "listing_option_id": "c21174f3-126a-5737-9cf7-93a1705a47e4",
      "offer_code": "ADD_ON",
      "label": "Per late breakfast box",
      "amount": 20000,
      "currency": "UGX",
      "occupancy_description": "Per late breakfast box; Approximate source USD 5",
      "pricing_basis_code": "FLAT_RATE",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 11,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C06-R12"
    }
  },
  {
    "ordinal": 348,
    "table_name": "listing_price_offers",
    "capture_ref": "C07-R13",
    "payload": {
      "id": "a204afee-dc64-5406-a135-b0dc4c28de65",
      "listing_id": "4975cbdf-c671-55cc-a7eb-77129cbf92c0",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per dinner voucher",
      "amount": 35000,
      "currency": "UGX",
      "occupancy_description": "Per dinner voucher; Approximate source USD 8",
      "pricing_basis_code": "FLAT_RATE",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 12,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C07-R13"
    }
  },
  {
    "ordinal": 349,
    "table_name": "listing_price_offers",
    "capture_ref": "C08-R14",
    "payload": {
      "id": "9aff15a5-3b04-5590-949f-24c43dcaa492",
      "listing_id": "07a162a6-4b89-52ac-9047-66f561432546",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per rain kit",
      "amount": 30000,
      "currency": "UGX",
      "occupancy_description": "Per rain kit; Approximate source USD 7",
      "pricing_basis_code": "FLAT_RATE",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 13,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C08-R14"
    }
  },
  {
    "ordinal": 350,
    "table_name": "listing_price_offers",
    "capture_ref": "C09-R15",
    "payload": {
      "id": "66cce861-4f2f-50cd-990c-393c7b1be2a9",
      "listing_id": "16ebc700-65fa-537d-a1bc-a8d2b1dfd14d",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per stay; guest basis unclear",
      "amount": 35000,
      "currency": "UGX",
      "occupancy_description": "Per stay; guest basis unclear; Approximate source USD 8",
      "pricing_basis_code": null,
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 14,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C09-R15"
    }
  },
  {
    "ordinal": 351,
    "table_name": "listing_price_offers",
    "capture_ref": "C10-R16",
    "payload": {
      "id": "e0138580-58a7-58de-ad7a-9fd4130b92a6",
      "listing_id": "db0c4cea-4c14-50e3-b5ed-9e7be38afe4e",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Participant basis not stated",
      "amount": 120000,
      "currency": "UGX",
      "occupancy_description": "Participant basis not stated; Approximate source USD 29",
      "pricing_basis_code": null,
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 15,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C10-R16"
    }
  },
  {
    "ordinal": 352,
    "table_name": "listing_price_offers",
    "capture_ref": "C11-R17",
    "payload": {
      "id": "0d0bdf29-d421-59b7-bad3-a79b0225029a",
      "listing_id": "750c0034-d4d4-5471-9903-3f3cd9a80a3c",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Participant basis not stated",
      "amount": 300000,
      "currency": "UGX",
      "occupancy_description": "Participant basis not stated; Approximate source USD 73",
      "pricing_basis_code": null,
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 16,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C11-R17"
    }
  },
  {
    "ordinal": 353,
    "table_name": "listing_price_offers",
    "capture_ref": "P04-R18",
    "payload": {
      "id": "d5624cfa-b0c7-5830-8bbc-5ac8758f4d65",
      "listing_id": "7c1ce966-9362-5098-afe0-9f1d49855d14",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Tubing plus one dinner voucher",
      "amount": 155000,
      "currency": "UGX",
      "occupancy_description": "Tubing plus one dinner voucher; Approximate source USD 38",
      "pricing_basis_code": null,
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 17,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "P04-R18"
    }
  },
  {
    "ordinal": 354,
    "table_name": "listing_price_offers",
    "capture_ref": "C12-R19",
    "payload": {
      "id": "3f5b6ddd-5fd1-587a-9542-19aa59544c02",
      "listing_id": "6c1250e9-f87b-5430-8768-843518060f35",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per hour; participant/vehicle basis unclear",
      "amount": 255000,
      "currency": "UGX",
      "occupancy_description": "Per hour; participant/vehicle basis unclear; Approximate source USD 62",
      "pricing_basis_code": null,
      "pricing_period_code": "PER_HOUR",
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 18,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C12-R19"
    }
  },
  {
    "ordinal": 355,
    "table_name": "listing_price_offers",
    "capture_ref": "C13-R20",
    "payload": {
      "id": "8e20f23c-d572-5e71-b27f-a3f7cb9bbdb1",
      "listing_id": "879f3ce8-fd39-5fe8-839e-65c5bcd4189f",
      "listing_option_id": null,
      "offer_code": "ADD_ON",
      "label": "Per person",
      "amount": 245000,
      "currency": "UGX",
      "occupancy_description": "Per person; Approximate source USD 59",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 19,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C13-R20"
    }
  },
  {
    "ordinal": 356,
    "table_name": "listing_price_offers",
    "capture_ref": "C14-R21",
    "payload": {
      "id": "7ee0c9d7-fe1a-563d-a155-53ff18506414",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": "a117e2f1-7ee1-5b36-972c-dda97f1a4e1e",
      "offer_code": "ADD_ON",
      "label": "Per vehicle up to five people",
      "amount": 2470000,
      "currency": "UGX",
      "occupancy_description": "Per vehicle up to five people; Approximate source USD 600",
      "pricing_basis_code": "PER_VEHICLE",
      "pricing_period_code": null,
      "min_guests": 1,
      "max_guests": 5,
      "occupancy_code": "PRIVATE",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 20,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C14-R21"
    }
  },
  {
    "ordinal": 357,
    "table_name": "listing_price_offers",
    "capture_ref": "C14-R22",
    "payload": {
      "id": "e6ae94c8-ed52-5e95-9551-32ba60eab0a7",
      "listing_id": "f411aa6e-1b7b-5264-9b4b-a198784273ff",
      "listing_option_id": "0eae2e85-3212-5cbd-97e9-9512b452a5bf",
      "offer_code": "ADD_ON",
      "label": "Per person in a full vehicle",
      "amount": 495000,
      "currency": "UGX",
      "occupancy_description": "Per person in a full vehicle; Approximate source USD 120",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": null,
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": "SHARED",
      "valid_from": null,
      "valid_to": null,
      "sort_order": 21,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C14-R22"
    }
  },
  {
    "ordinal": 358,
    "table_name": "listing_price_offers",
    "capture_ref": "C15-R23",
    "payload": {
      "id": "a0b1d56a-1594-5ce5-aecc-34a24fe54fe4",
      "listing_id": "5b78f41b-459b-5ff0-898c-20e0e7e6ac9f",
      "listing_option_id": null,
      "offer_code": "EXTRA_PERSON",
      "label": "Per extra person per night",
      "amount": 245000,
      "currency": "UGX",
      "occupancy_description": "Per extra person per night; C15 supplement only; confirm benefits/capacity. Approximate source USD 59",
      "pricing_basis_code": "PER_PERSON",
      "pricing_period_code": "PER_NIGHT",
      "min_guests": null,
      "max_guests": null,
      "occupancy_code": null,
      "valid_from": null,
      "valid_to": null,
      "sort_order": 22,
      "is_live": false,
      "created_by": "UPLOAD",
      "updated_by": "UPLOAD",
      "_capture_ref": "C15-R23"
    }
  }
]$magma_json$::jsonb)
 AS r(ordinal integer,table_name text,capture_ref text,payload jsonb);

-- ================= EDITABLE MAPPINGS =================
-- Resolve from the existing database. NULL means unconfirmed, never "any".
-- A subcategory code must already exist in public.subcategories.
CREATE TEMP TABLE magma_subcategory_map (
 capture_ref text PRIMARY KEY, subcategory_code text
) ON COMMIT DROP;
INSERT INTO magma_subcategory_map VALUES
 ('P01',NULL),
 ('P02',NULL),
 ('P03',NULL),
 ('P04',NULL),
 ('C01',NULL),
 ('C02',NULL),
 ('C03',NULL),
 ('C04',NULL),
 ('C05',NULL),
 ('C06',NULL),
 ('C07',NULL),
 ('C08',NULL),
 ('C09',NULL),
 ('C10',NULL),
 ('C11',NULL),
 ('C12',NULL),
 ('C13',NULL),
 ('C14',NULL),
 ('E01',NULL);
-- Example, only after selecting a real existing category:
-- UPDATE magma_subcategory_map SET subcategory_code='YOUR_EXISTING_CODE'
-- WHERE capture_ref='C13';

CREATE TEMP TABLE magma_quantity_map (
 capture_ref text PRIMARY KEY, quantity_basis text
) ON COMMIT DROP;
INSERT INTO magma_quantity_map VALUES
 ('P01-C08',NULL),
 ('P01-C09',NULL),
 ('P02-C07',NULL),
 ('P02-C09',NULL),
 ('P03-C07',NULL),
 ('P03-C11',NULL),
 ('P03-C09',NULL),
 ('P04-C10',NULL),
 ('P04-C07',NULL);
-- Confirm per-person versus per-room/booking entitlement before filling these.
-- Existing experience_quantity_bases codes govern permitted values.

CREATE TEMP TABLE magma_place_area_map (
 capture_ref text PRIMARY KEY, geographic_area_id uuid
) ON COMMIT DROP;
INSERT INTO magma_place_area_map VALUES
 ('R02',NULL), -- Eden Rocks: confirm actual geographic area
 ('R03',NULL), -- Jinja Jungle: confirm actual geographic area
 ('R05','01a12b1d-6728-7080-b21b-2eaa62c6d86a'); -- Supplier describes venue as Kalagala Falls, Jinja
-- Assign the Jinja ID to R02/R03 only if that is their actual reference area.

CREATE TEMP TABLE magma_tour_map (
 capture_ref text PRIMARY KEY, schedule_mode text, participation_mode text
) ON COMMIT DROP;
INSERT INTO magma_tour_map VALUES ('C13',NULL,NULL);
-- schedule_mode: FIXED_START or REQUESTED_START
-- participation_mode: PRIVATE or SHARED
-- No value is chosen automatically.

-- Resolve workbook helper codes against the actual seeded reference tables.
CREATE TEMP TABLE magma_lookup_map (
 target_table text, id_column text, helper_key text, lookup_table text,
 PRIMARY KEY(target_table,id_column)
) ON COMMIT DROP;
INSERT INTO magma_lookup_map VALUES
 ('listings','listing_type_id','_listing_type_code','listing_types'),
 ('resources','resource_type_id','_resource_type_code','resource_types'),
 ('listing_fulfilment_requirements','resource_role_id','_resource_role_code','resource_roles'),
 ('listing_customer_information_requirements','information_field_id','_information_field_code','booking_information_fields');
CREATE TEMP TABLE magma_errors (
 table_name text, capture_ref text, detail text
) ON COMMIT DROP;

-- Jinja is the offer's primary discovery area. Uganda remains country_code UG.
UPDATE magma_rows SET payload=jsonb_set(payload,'{geographic_area_id}',to_jsonb('01a12b1d-6728-7080-b21b-2eaa62c6d86a'::text))
 WHERE table_name='listings';
UPDATE magma_rows r SET payload=jsonb_set(r.payload,'{geographic_area_id}',to_jsonb(m.geographic_area_id::text))
 FROM magma_place_area_map m WHERE r.table_name='places' AND r.capture_ref=m.capture_ref
 AND m.geographic_area_id IS NOT NULL;
UPDATE magma_rows r SET payload=jsonb_set(r.payload,'{quantity_basis}',to_jsonb(m.quantity_basis))
 FROM magma_quantity_map m WHERE r.table_name='experience_components' AND r.capture_ref=m.capture_ref
 AND m.quantity_basis IS NOT NULL;
UPDATE magma_rows r SET payload=r.payload || jsonb_build_object('schedule_mode',m.schedule_mode,'participation_mode',m.participation_mode)
 FROM magma_tour_map m WHERE r.table_name='tour_policies' AND r.capture_ref=m.capture_ref;
-- All four date-only occurrences are now inserted using service-date migration 15.

DO $resolve$
DECLARE m record; r record; found_id uuid;
BEGIN
 FOR m IN SELECT * FROM magma_lookup_map LOOP
  IF to_regclass(format('public.%I',m.lookup_table)) IS NULL THEN
   INSERT INTO magma_errors VALUES(m.target_table,'*','Missing reference table public.'||m.lookup_table);
   CONTINUE;
  END IF;
  FOR r IN SELECT * FROM magma_rows WHERE table_name=m.target_table LOOP
   EXECUTE format('SELECT id FROM public.%I WHERE code=$1',m.lookup_table)
     INTO found_id USING r.payload->>m.helper_key;
   -- File 9_1 used LOCATION for the same physical Place resource subtype.
   -- Prefer the agreed PLACE code if present; otherwise resolve that legacy alias.
   IF found_id IS NULL AND m.lookup_table='resource_types' AND r.payload->>m.helper_key='PLACE' THEN
    EXECUTE 'SELECT id FROM public.resource_types WHERE code=$1' INTO found_id USING 'LOCATION';
   END IF;
   IF found_id IS NULL THEN
    INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Unresolved '||m.lookup_table||'.code='||coalesce(r.payload->>m.helper_key,'NULL'));
   ELSE
    UPDATE magma_rows SET payload=jsonb_set(payload,ARRAY[m.id_column],to_jsonb(found_id::text)) WHERE ordinal=r.ordinal;
   END IF;
  END LOOP;
 END LOOP;
 IF to_regclass('public.subcategories') IS NULL THEN
  INSERT INTO magma_errors VALUES('listings','*','Missing public.subcategories');
 ELSE
  FOR r IN SELECT * FROM magma_subcategory_map WHERE subcategory_code IS NOT NULL LOOP
   SELECT id INTO found_id FROM public.subcategories WHERE code=r.subcategory_code;
   IF found_id IS NULL THEN
    INSERT INTO magma_errors VALUES('listings',r.capture_ref,'Unknown subcategory code '||r.subcategory_code);
   ELSE
    UPDATE magma_rows SET payload=jsonb_set(payload,'{subcategory_id}',to_jsonb(found_id::text))
      WHERE table_name='listings' AND capture_ref=r.capture_ref;
   END IF;
  END LOOP;
 END IF;
 IF to_regclass('public.geographic_areas') IS NULL THEN
  INSERT INTO magma_errors VALUES('geographic_areas','Jinja','Missing geographic_areas table');
 ELSIF NOT EXISTS(SELECT 1 FROM public.geographic_areas WHERE id='01a12b1d-6728-7080-b21b-2eaa62c6d86a') THEN
  INSERT INTO magma_errors VALUES('geographic_areas','Jinja','User-supplied Jinja ID is absent');
 END IF;
END
$resolve$;

-- Explicit audit fields on EVERY inserted row, including resource tables.
-- Empty optional/defaulted values are omitted, so PostgreSQL defaults apply.
-- Missing mandatory supplier values are retained as NULL to fail preflight.
UPDATE magma_rows SET payload=payload || jsonb_build_object('created_by','UPLOAD','updated_by','UPLOAD');

DO $preflight$
DECLARE r record; c record; k text; expected jsonb;
BEGIN
 FOR r IN SELECT * FROM magma_rows ORDER BY ordinal LOOP
  IF to_regclass(format('public.%I',r.table_name)) IS NULL THEN
   INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Missing destination table');
   CONTINUE;
  END IF;
  FOREACH k IN ARRAY ARRAY['created_by','updated_by'] LOOP
   IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=r.table_name AND column_name=k) THEN
    INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Missing audit column '||k||'; apply agreed audit migration');
   END IF;
  END LOOP;
  FOR k IN SELECT jsonb_object_keys(r.payload) LOOP
   IF k LIKE '\_%' ESCAPE '\' OR r.payload->k='null'::jsonb THEN CONTINUE; END IF;
   IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=r.table_name AND column_name=k) THEN
    INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Workbook column '||k||' absent from actual database; no silent field removal');
   END IF;
  END LOOP;
  FOR c IN SELECT * FROM information_schema.columns WHERE table_schema='public' AND table_name=r.table_name LOOP
   IF c.is_nullable='NO' AND c.column_default IS NULL AND c.is_identity='NO' AND c.is_generated='NEVER'
     AND (NOT r.payload ? c.column_name OR r.payload->c.column_name='null'::jsonb) THEN
    INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Required value missing: '||c.column_name);
   END IF;
  END LOOP;
  IF r.table_name='resources' AND EXISTS(SELECT 1 FROM public.resources
    WHERE lower(btrim(name))=lower(btrim(r.payload->>'name')) AND id<>(r.payload->>'id')::uuid) THEN
   INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Resource name already exists under another UUID; reuse the existing resource and remap links');
  END IF;
  IF r.table_name='listings' AND EXISTS(SELECT 1 FROM public.listings
    WHERE slug=r.payload->>'slug' AND id<>(r.payload->>'id')::uuid) THEN
   INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Listing slug already exists under another UUID; reconcile before inserting');
  END IF;
  -- Known source unknowns must not be replaced by a database default silently.
  IF r.table_name='experience_components' AND r.payload->>'quantity_basis' IS NULL THEN
   INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Confirm quantity_basis; database default would invent the entitlement basis');
  END IF;
  IF r.table_name='tour_policies' THEN
   FOREACH k IN ARRAY ARRAY['schedule_mode','participation_mode'] LOOP
    IF r.payload->>k IS NULL THEN INSERT INTO magma_errors VALUES(r.table_name,r.capture_ref,'Confirm tour '||k); END IF;
   END LOOP;
  END IF;
 END LOOP;
END
$preflight$;

-- Inspect the complete list in your SQL client before the guarded insert.
SELECT DISTINCT table_name,capture_ref,detail FROM magma_errors ORDER BY 1,2,3;

DO $insert$
DECLARE r record; columns_sql text; values_sql text; clean jsonb; expected jsonb; errors text;
BEGIN
 IF EXISTS(SELECT 1 FROM magma_errors) THEN
  SELECT string_agg(table_name||' / '||capture_ref||': '||detail,E'\n') INTO errors
   FROM (SELECT DISTINCT * FROM magma_errors ORDER BY table_name,capture_ref,detail) e;
  RAISE EXCEPTION 'Magma import blocked. No business records inserted.' USING DETAIL=errors,
   HINT='Fill editable mappings and verify actual core DDL/reference seeds. Then rerun the whole file.';
 END IF;
 FOR r IN SELECT * FROM magma_rows ORDER BY ordinal LOOP
  SELECT jsonb_object_agg(key,value) INTO clean FROM jsonb_each(r.payload)
   WHERE left(key,1)<>'_' AND value<>'null'::jsonb;
  SELECT string_agg(format('%I',key),',' ORDER BY key),
         string_agg(format('x.%I',key),',' ORDER BY key)
   INTO columns_sql,values_sql FROM jsonb_object_keys(clean) AS keys(key);
  BEGIN
   EXECUTE format('INSERT INTO public.%I (%s) SELECT %s FROM jsonb_populate_record(NULL::public.%I,$1) AS x',
    r.table_name,columns_sql,values_sql,r.table_name) USING clean;
  EXCEPTION WHEN OTHERS THEN
   RAISE EXCEPTION 'Magma insert failed at % / %: %',r.table_name,r.capture_ref,SQLERRM
     USING DETAIL='The transaction is atomic: no partial business import is committed.';
  END;
 END LOOP;
 -- Run all deferred scope/Experience/itinerary validation before reporting success.
 SET CONSTRAINTS ALL IMMEDIATE;
 -- Verify database triggers preserved the requested audit actor.
 FOR r IN SELECT * FROM magma_rows ORDER BY ordinal LOOP
  SELECT jsonb_object_agg(key,value) INTO clean FROM jsonb_each(r.payload)
   WHERE left(key,1)<>'_' AND value<>'null'::jsonb;
  EXECUTE format('SELECT to_jsonb(t) FROM public.%I t WHERE to_jsonb(t) @> $1',r.table_name)
   INTO expected USING clean;
  IF expected IS NULL THEN
   RAISE EXCEPTION 'Inserted row % / % does not match expected values (including UPLOAD audit actors)',r.table_name,r.capture_ref;
  END IF;
 END LOOP;
END
$insert$;
SELECT table_name,count(*) AS inserted_rows FROM magma_rows GROUP BY table_name ORDER BY table_name;
COMMIT;
-- No business transaction is committed if preflight or a constraint fails.
-- Roll back your SQL client after an error before running this file again.
