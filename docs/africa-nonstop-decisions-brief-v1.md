# Africa Nonstop — Decisions Brief

> Status key: **Confirmed** = agreed/current direction; **Open** = decision still required; **Idea** = discussed but not approved for implementation. Where documents conflict, the latest confirmed chat decision and SRS v2 take precedence over SRS v1.

## Product purpose

- **Confirmed:** Africa Nonstop is a destination discovery, trip-planning and human-assisted travel-orchestration platform. It combines a destination Guide, discoverable listings, the Nonstop Engine, traveller accounts, concierge/booking operations and administration.
- **Confirmed:** The core journey is **Discover → Save → Plan/Orchestrate → Request Booking → Human Confirmation/Fulfilment → Manage Trip → Concierge**. The listing is what the traveller discovers; the trip is what they build; the trip request is what operations confirms and fulfils.
- **Confirmed:** Primary commercial audience: international travellers considering or visiting Uganda. Initial pilots also serve people already in Uganda. Secondary users/beneficiaries are local operators/providers and Nonstop admin/concierge staff.
- **Confirmed:** The problem is fragmented destination knowledge, listings, logistics and support. The value is a coordinated, accessible mechanism that helps travellers discover, combine and safely experience more of Uganda, with accountable human support while automation matures.
- **Confirmed:** Nightlife is a pilot use case, not the product architecture.

## Brand and positioning

- **Confirmed:** **Africa Nonstop** is the wider platform/brand. **Kampala Nonstop** is the Uganda-facing destination brand. Uganda is the first and only market at launch; Kampala is the principal gateway and initial inventory scope, not the full geographic limit of the Uganda product.
- **Confirmed:** 2026 proposition: **“Get to Uganda, we’ll give you things to do.”** 2027/V1 proposition: **“We’ll get you to Uganda and fully support you there.”**
- **Confirmed:** Use locally informed, practical, curated and transparent language. Do not present V0 as a fully automated OTA: availability, price and fulfilment are human-confirmed.
- **Confirmed:** Use British English in product copy: *traveller, favourites, organise, neighbourhood*.
- **Proposed legal position:** **Nonstop Uganda Ltd trading as Kampala Nonstop** is the proposed Uganda owner/rights holder. Do not treat incorporation, assignment or parent-platform IP ownership as complete without legal confirmation.
- **Open:** Final public domain structure (`kampalanonstop.com` versus an Africa Nonstop Uganda path) and whether the supporting line **“an Africa Nonstop destination”** should appear under the Kampala Nonstop mark.
- **Open:** No formal brand-personality statement or final tagline beyond the dated campaign propositions above has been approved.

## Visual direction

- **Confirmed:** Website typeface is **Noto Sans KR**. **Working guideline:** use regular for body/UI and bold for headings, buttons and navigation, with hierarchy mainly through size and weight.
- **Rejected:** **Malgun Gothic** was replaced because its Microsoft licensing does not make it safe to assume the desktop font may be uploaded as a webfont.
- **Confirmed:** Responsive desktop, tablet and mobile UI. The approved mobile mock-up target is 420 px wide, full-page/scrollable, with no device frame and no horizontal scrollbar. Components and imagery must reflow as mobile layouts, not merely shrink.
- **Confirmed homepage treatments:** Template Itineraries and Featured Experiences replace the earlier Explore Category carousel; each uses a 3 × 2 desktop panel layout; image numbers are removed; each section has a containing section box. The post-hero three-panel group is called **Themes**.
- **Working recommendation, not locked:** Hero heading `clamp(40px, 5vw, 64px)`, about 64 px desktop and 40–44 px mobile, with tight line-height. Validate with Noto Sans KR before making it a design token.
- **Open:** No final colour palette, spacing scale, icon system, image treatment, component tokens or definitive hero type size is established in the available decisions. Preserve approved wireframe structure while these are resolved.

## Website and content

- **Confirmed desktop navigation:** **Home, Hot Picks, Discover, Guide, Support, Dashboard**, followed by heart/favourites, notification bell and **Plan My Trip**.
- **Confirmed homepage structure:** Hero; Trip Quiz; Themes (**Kampala Energy, Nature Access, Purpose-Led Travel**); Local Knowledge; Template Itineraries; Featured Experiences; **Discover Uganda Your Way**; footer. Themes are navigational/editorial groupings, not data entities.
- **Confirmed discovery entry question:** **“What brings you to Uganda?”** with four paths: **I know why I’m going; Help me decide; I already have dates; I only have a few free days.** The quiz captures traveller type, trip type, available time and what matters most, then presents three recommendations plus the full list, duration selection and **View My Trip**.
- **Confirmed orchestration order:** traveller/purpose context, dates and fixed anchors, then travel prerequisites (**flights → accommodation → visa → airport transfers/arrival**), followed by transport, experiences and concierge. Fixed events, weddings, meetings, permits and appointments configure a trip; they do not create separate product stacks.
- **Confirmed primary conversion CTA:** **Request Booking**. V0 submits a trip/service request for admin/concierge review; it does not promise instant booking or make online payment a launch gate.
- **Confirmed V0 surfaces/capabilities:** limited Uganda Guide and FAQ; Kampala-focused discovery/search/details; collections/lists; Local Gems and Hot Picks; trips and itinerary; request/status management; user dashboard; traveller–concierge messaging and notifications; admin-managed listings/content; operator/contact notes; banner advertising; Local Knowledge; waitlist/acquisition; future-ready payment architecture.
- **Confirmed waitlist rules:** wide desktop form; hero copy **“Join our wait list and win a return flight to Uganda”**; marketing consent at the bottom; no “anything else” field. Acquisition source is hidden and derived from landing context, UTM parameters, referral/QR/campaign links using controlled values where practical. Countries of interest is also a hidden form field. Store consent and attribution auditably.
- **Confirmed waitlist interest labels:** Food & Local Life; Culture & Heritage; Music, Nightlife & Entertainment; Nature & Wildlife; Adventure & Outdoors; Events & Festivals; Wellness & Relaxation; Sports & Recreation; Other. These are user-interest choices, not automatically the canonical catalogue categories.
- **Confirmed terminology:**

  | Term | Use |
  | --- | --- |
  | Activity | Real-world business/directory entity: something a traveller can do. |
  | Activity Type | Controlled classification of **what** the activity is. |
  | Event | Time-bound occurrence; Events/What’s On is a discovery view, not a primary category. |
  | Experience | Curated sequence/combination of activities; not a base entity. |
  | Tour | Structured route/touring product, potentially combining places, activities and services. |
  | Listing | Discoverable platform record wrapping a place, organisation, service, activity, tour or other entity. |
  | Hot Pick | Actively featured/editorial or commercial recommendation. |
  | Local Gem | Distinctive local listing underrepresented on mainstream platforms. |
  | Tag / Attribute | A related theme / a property-value. Neither replaces structural classification. |

- **Idea:** Natural-language requests such as “find me a Kampala comedy club tonight and a nightclub afterwards” are desirable, but were explicitly treated as potentially beyond V0.

## Technical decisions

- **Confirmed stack:** Angular frontend; PostgreSQL database; versioned REST/JSON APIs; blob/object storage for images/media. Angular is locked. PostgreSQL supersedes MySQL.
- **Open backend:** Laravel/PHP is the current proposal but remains subject to technical approval. Python was explored; no alternative was selected.
- **Confirmed environments/hosting shape:** two VPSs—production physically isolated on its own VPS; development, test and staging share a separate non-production VPS. Non-production uses one PostgreSQL server with separate databases/users per environment; production has its own PostgreSQL instance/database. Hosting provider and final managed-service choices remain open.
- **Confirmed deployment principles:** Git version control; separate dev/test/staging/production configuration; controlled promotion; responsive builds; API documentation (OpenAPI/Swagger recommended); automated testing, UAT and handover documentation.
- **Known development risk/recommendation:** The active Angular repo has been run inside Dropbox, which can lock Vite/Angular cache renames on Windows. Prefer a non-synchronised local repo with Git as the source-control mechanism; never version `.angular`, `node_modules` or `dist`.
- **Confirmed security baseline:** HTTPS; authentication and role/permission authorisation; protected admin/concierge endpoints; input validation; rate limiting; secure uploads; password hashing; CSRF/XSS protection where applicable; parameterised PostgreSQL access; audit logs; secrets/config separation; monitoring and backups.
- **Confirmed operations model:** Admin manages content initially. Use reusable service-request, assignment, status, notes, messaging and fulfilment workflows; broad concierge scope must not become a separate software flow per service. Accessibility, pacing and dietary requirements belong on traveller/trip context and flow into recommendations and provider verification.
- **Confirmed advertising:** Admin-managed campaigns with start/end dates, active state, approved predefined placement/size, uploaded creative, external link, impressions and clicks. No advertiser self-service or billing in V0.
- **Confirmed analytics requirement:** Track total waitlist sign-ups, those later registered, and conversion rate; also banner impressions/clicks and acquisition source. **Open:** analytics/CRM products and privacy implementation.
- **Confirmed data-model guardrails:** plural `snake_case` tables; `id` as PostgreSQL UUID primary key (UUIDv7 preferred for new IDs); stable reference `code`; `TIMESTAMPTZ` timestamps; separate `is_active` and `visibility`; soft-retire referenced data; junctions only for genuine many-to-many relationships. Canonical taxonomy is global where practical and destination availability is mapped, not duplicated.
- **Confirmed geography:** `countries` + controlled `geographic_area_types` + self-referencing `geographic_areas`; variable hierarchy depth; `destinations` is a separate product/business concept; `locations` stores precise addresses/coordinates. Canonical geography must not be auto-created from user/API/AI free text. Proximity should ultimately use coordinates.
- **Current planning assumption:** initial capacity baseline is 10,000 requests/day, modelled as roughly 100 API calls per session (~100 daily users). Validate before sizing production.
- **Not required for V0:** Firebase/Firestore; mandatory Redis/message queues; direct automated booking/payment; vendor self-service. Redis/cache/queues should be added only when workload justifies them. An Azure-based controlled AI planner was explored but is not a locked V0 dependency.

## Current priorities

- **Now (September 2026):** ship the campaign/waitlist acquisition layer with attributable source, interests, Uganda intent, consent, segmentation and follow-up; continue the Angular public experience.
- Translate the completed conceptual taxonomy into the physical PostgreSQL schema, constraints, migrations and seed/reference data. Produce ERD and API/page specifications from SRS v2—not v1.
- Lock the remaining foundations: backend framework, authentication/roles, API boundaries, UI/design system, CI/CD, monitoring, secrets, media delivery and detailed VPS deployment.
- Define V0 acceptance criteria for Guide, Discover, Nonstop Engine, account/dashboard, request/concierge operations, admin, communications, data/content operations, advertising and public acquisition.
- **Milestones:** Oct 2026 operational preparation; Nov 2026 limited V0 commercial pilot around Nyege Nyege Uganda; Dec 2026 V0.1 festive stress-test; Jan–Feb 2027 V0.5 international-trip hardening; **15 Mar 2027 V1 AFCON commercial release**; Apr–Jun scale; **19 Jun–17 Jul 2027 AFCON live operations**.
- **Do not change without discussion:** Uganda-first/Kampala-inventory scope; Angular/PostgreSQL; Noto Sans KR; the human-confirmed V0 flow; the canonical entity/taxonomy meanings; flexible geography model; current navigation/homepage structure; hidden acquisition attribution; production/non-production isolation.

## Open questions

- Approve Laravel or select another backend; define authentication/session approach, roles and permissions.
- Finalise the physical Trip/Itinerary/Trip Request/Booking schema; tour/activity/service normalisation; provider and multi-provider ownership; category/subcategory cardinality; attributes; destination-to-geography mapping; location/geocoder and possible PostGIS use.
- Choose hosting/provider details, CI/CD, monitoring/logging, secrets management, object storage/CDN, SMTP/transactional email, CRM and analytics tooling.
- Decide guest registration timing; trip editing/sharing; confirmation SLA; cancellations/refunds; pricing, taxes and fees; currency/payment gateway/manual payment; availability/capacity; vendor self-service, commission and payouts.
- Approve banner sizes/placement inventory and Local Knowledge content, placement triggers and rotation.
- Complete the visual system: palette, spacing, icons, image rules, responsive tokens and final hero typography.
- Decide when budget is requested in the trip flow; it should not add friction before useful recommendations unless required as a hard constraint.
- Decide whether/when natural-language trip search enters scope. It is an idea, not a V0 commitment.
- Confirm the final company/IP/domain arrangements and whether **“an Africa Nonstop destination”** is used as supporting brand copy.

## Source notes

- **Kampala_Nonstop_SRS_v2.pdf** (governing SRS; supersedes **Monir-Kampala_Nonstop_SRS.pdf** v1).
- **Kampala Nonstop Roadmap 2026–2027**; **Africa Nonstop — V0 Agile Project Tracker**; **Nonstop Full Data Model Taxonomy**; **Africa Nonstop — Conceptual Data Buckets & Classes**; **Africa Nonstop — Conceptual Data Model & Database Conventions**; **Africa Nonstop — Concierge Services & V0 Scope**.
- Key chats: *Concept Paper for Copyright* (27 Jul 2026); *Tech Stack & Misc*; *High-Level Database Design*; *Agile Project Planning*; *Roadmap Planning Milestones*; *Waitlist Interest Feature*; *Homepage Mockup Generation*; *Name Discovery Themes*; *Trip Orchestration Brainstorm*; *VPS Help*; and the website-font update replacing Malgun Gothic with Noto Sans KR.
