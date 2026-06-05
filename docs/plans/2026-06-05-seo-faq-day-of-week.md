# 2026-06-05 — SEO Clean URLs, FAQ Section, Leaders Data, Day of the Week Calculator

## Status: ✅ Complete

---

## What was built

### 1. SEO Clean URL Architecture

- Route: `GET /date/:year/:month/:day` → `DatePagesController#show`
- `DatePagesController` handles past (TimeAgoCalculator) and future
  (TimeUntilCalculator)
- Title: standalone "How Long Ago Was June 4, 2026?" (no site prefix — removed
  `site:` from `display_meta_tags`)
- Canonical URL set per date page
- `date_redirect_controller.js` — Stimulus controller, intercepts form submit →
  builds clean URL
- Old query-param URL `/time-ago-calculator?date=2026-06-04` → 302 to
  `/date/2026/june/4`

### 2. Landing Page & Navbar Redesign

- New `HomeController` + `home/index.html.erb`
- Dark navy hero with "Check a Date" (date-redirect controller, any date) and
  "Compare Two Dates" forms
- Quick Calculators 4-card grid
- Events section: featured hero + Coming Up Next sidebar + Annual Highlights
- CSS-only dropdown navbar: Date Tools + Calculators submenus; mobile hamburger
  via `navbar_controller.js`

### 3. Date Page Enhancements

- Dark countdown section (D/H/M/S) — future uses `countdown` controller, past
  uses `time-since` controller
- Prose description (day of week, day of year, week number, quarter, leap year)
- 2-column Q&A grid ("How many months/weeks/days/hours/minutes/seconds
  ago/until?")
- Date formats section (US, UK, ISO 8601, Abbreviated, Full)

### 4. FAQ Section on Date Pages

- Static FAQs: day of week, age if born on that date (past only), date formats
- Dynamic: "What happened on [date]?" from events matching `starts_at::date`
- Dynamic: "Who was in power on [date]?" from leaders matching term range
- schema.org FAQPage JSON-LD for Google rich snippets

### 5. Leader Seed Data

- `apps/web/db/seeds/data/leaders.json` — 62 records
  - US Presidents: 1897–present (McKinley → Trump 2nd term)
  - UK Prime Ministers: 1895–present (Lord Salisbury → Keir Starmer)
  - UK Monarchs: 1837–present (Queen Victoria → King Charles III)
- `Events::Sources::Leaders` service
  (`apps/web/app/services/events/sources/leaders.rb`)
- `rake events:seed_leaders` task (upserts by slug)
- Wired into `Events::Ingestor#collect_records`

### 6. Seed File Path Fix

- Seed JSON files moved from `data/seeds/` (monorepo root, not in Docker image)
  to `apps/web/db/seeds/data/`
- Updated `SEED_PATH` in `Events::Sources::Curated` and
  `Events::Sources::Leaders`

### 7. Bug Fixes

- `ArgumentError: All objects being inserted must have the same keys` — fixed in
  `Ingestor#upsert_all` by normalizing all record key sets to union before
  upserting
- `NagerDate IN nil error` — `holidays_with_names` now guards
  `result.is_a?(Array) ? result : []`
- `omniauth-rails_csrf_protection` updated `~> 1.0` → `~> 2.0`
- `config/initializers/suppress_gem_warnings.rb` silences the persistent
  `ActiveSupport::Configurable` deprecation from that gem

### 8. Footer Fixes

- Calculators section: was missing `<ul>`, had misplaced Facebook/Twitter `<li>`
  items — fixed
- Follow Us: Facebook + Twitter replaced with Instagram (`bobadilla.tech`) +
  LinkedIn (`bobadilla-tech`)
- Date Tools: removed misplaced "Buy Me a Coffee"; added "Create Widget"

### 9. Day of the Week Calculator (full build)

- Dedicated `Calculators::DayOfTheWeekController`
- Route updated from `pages#day_of_the_week` →
  `calculators/day_of_the_week#show`
- View: two-column layout (main + sidebar)
  - Dark blue Year/Month/Day form
  - Result card: big day name + Day of Year / Week Number / Quarter / Days in
    Month grid
  - Popular Lookups: This Week pills (today highlighted), First of the Month,
    Notable Upcoming Dates
  - Related tools (2-col cards)
  - About section
  - Other Date Tools 4-col grid
  - Sidebar: Check a Date, Days Between, Popular Countdowns, Buy Me a Coffee

### 10. Deployment Guide

- Added Part 5.1: seed commands (`seed_leaders`, `ingest`, `refresh`,
  `backfill_images`)
- Noted seed files are bundled inside image at `db/seeds/data/`
- Added monthly cron suggestion for `events:refresh`

## Files changed (key)

| File                                                        | Change                                                              |
| ----------------------------------------------------------- | ------------------------------------------------------------------- |
| `config/routes.rb`                                          | `/date/:year/:month/:day` route; day-of-week → dedicated controller |
| `app/controllers/date_pages_controller.rb`                  | NEW — canonical date result page                                    |
| `app/controllers/home_controller.rb`                        | NEW — landing page with events                                      |
| `app/controllers/calculators/day_of_the_week_controller.rb` | NEW                                                                 |
| `app/views/date_pages/show.html.erb`                        | NEW — countdown, Q&A, FAQ, date formats                             |
| `app/views/home/index.html.erb`                             | NEW — hero + forms + events                                         |
| `app/views/calculators/day_of_the_week/show.html.erb`       | NEW                                                                 |
| `app/views/layouts/application.html.erb`                    | Navbar redesign; removed `site:` from meta_tags                     |
| `app/views/shared/_footer.html.erb`                         | Social links, HTML structure fix                                    |
| `app/services/events/sources/leaders.rb`                    | NEW                                                                 |
| `app/services/events/ingestor.rb`                           | Added Leaders; key normalization fix                                |
| `app/services/events/sources/curated.rb`                    | SEED_PATH updated                                                   |
| `app/services/nager_date_client.rb`                         | nil guard on JSON result                                            |
| `app/javascript/controllers/date_redirect_controller.js`    | NEW                                                                 |
| `app/javascript/controllers/time_since_controller.js`       | NEW                                                                 |
| `app/javascript/controllers/navbar_controller.js`           | NEW                                                                 |
| `config/initializers/suppress_gem_warnings.rb`              | NEW                                                                 |
| `db/seeds/data/curated_events.json`                         | Moved from `data/seeds/`                                            |
| `db/seeds/data/leaders.json`                                | NEW                                                                 |
| `lib/tasks/events.rake`                                     | Added `seed_leaders` task                                           |
| `docs/deployment.md`                                        | Added Part 5.1 ingestion section                                    |
