# Initial MVP

**Date:** 2026-06-03 **Status:** Complete

---

## Goal

Launch a working, SEO-ready time/date calculator platform on
timeagocalculator.com. Four core calculators, curated SEO slug pages, and
production-ready infrastructure.

---

## Scope

### Calculators

| Route                         | Feature                                              |
| ----------------------------- | ---------------------------------------------------- |
| `/time-ago-calculator`        | How long ago a past date was                         |
| `/time-until-calculator`      | How long until a future date, with live countdown    |
| `/date-difference-calculator` | Days, weeks, months, business days between two dates |
| `/age-calculator`             | Exact age from birthdate                             |

### SEO Slug Pages

| Pattern               | Content                                         |
| --------------------- | ----------------------------------------------- |
| `/how-long-ago/:slug` | Historical events (moon landing, 9/11, etc.)    |
| `/countdown/:slug`    | Holiday countdowns (christmas, halloween, etc.) |
| `/age/:slug`          | Celebrity ages (tom-cruise, taylor-swift, etc.) |

### Infrastructure

- Rails 8.1 app at `apps/web/`
- PostgreSQL + Redis + Sidekiq
- Docker Compose for dev and production
- Caddy reverse proxy with HTTPS
- XML sitemap via `sitemap_generator`
- SEO meta tags (canonical, OG, Twitter Card, JSON-LD) on every page

---

## Technical Approach

- **Stack:** Ruby on Rails 8.1, Ruby 4.0.3, Hotwire, Tailwind CSS v4, importmap
  (no Node)
- **Calculations:** Pure Ruby service objects in
  `app/services/date_calculations/` — no ActiveRecord dependency, fully
  unit-testable
- **Live countdowns:** Stimulus `countdown_controller.js` ticks with
  `setInterval`, zero server connections after initial page load
- **Forms:** GET (not POST) — results are shareable bookmarkable URLs (e.g.
  `/time-ago-calculator?date=2000-01-01`)
- **SEO:** `meta-tags` gem + `Seo::StructuredDataBuilder` for JSON-LD
  (WebApplication, Event, BreadcrumbList schemas)
- **Jobs:** Sidekiq + Redis instead of SolidQueue — aligned with Docker Compose
  service model

---

## Seed Data

**8 historical events:** moon-landing, fall-of-berlin-wall, world-war-ii-end,
covid-pandemic, september-11, first-iphone, apollo-11-launch, titanic-sinking

**7 holidays:** christmas, new-years, halloween, valentines-day,
independence-day, st-patricks-day, new-years-eve

**8 celebrity slugs (hardcoded in PeopleController):** tom-cruise, taylor-swift,
elon-musk, mrbeast, lebron-james, beyonce, dwayne-johnson, rihanna

---

## Acceptance Criteria

- [x] `GET /` renders time-ago calculator
- [x] `GET /time-ago-calculator?date=2000-01-01` returns correct human output
      ("26 years, 5 months, and 2 days ago")
- [x] `GET /time-until-calculator?date=2027-01-01` returns live countdown with
      correct years/months/days
- [x] `GET /date-difference-calculator?from=2020-01-01&to=2025-01-01` returns
      total days, business days, weeks, months, years
- [x] `GET /age-calculator?birthdate=1990-06-15` returns correct age + days
      until next birthday
- [x] `GET /how-long-ago/moon-landing` returns event page with time-ago result
- [x] `GET /countdown/christmas` returns holiday page with live countdown
- [x] `GET /age/taylor-swift` returns age page with correct age
- [x] Every page has canonical URL, OG tags, and JSON-LD structured data
- [x] `bin/rails db:seed` seeds 8 events and 7 holidays idempotently
- [x] Docker Compose (`infra/docker/compose.yml`) defines all production
      services
- [x] Sitemap config at `apps/web/config/sitemap.rb` covers all static + dynamic
      routes

---

## Out of Scope (Phase 2)

- User accounts (Devise, OmniAuth)
- Custom/shareable countdowns
- Premium plan + Stripe
- Embeddable widgets
- REST API
- AI content generation
- Sports/elections/space event ingestion
