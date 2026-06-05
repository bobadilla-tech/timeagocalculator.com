# Developer Quick Start

- Ruby 4.0.3 (`rbenv` or `asdf`)
- PostgreSQL running locally
- Redis running locally
- Bundler (`gem install bundler`)

---

## Setup

```bash
# Install gems and set up database
cd apps/web bundle install && bin/rails db:create db:migrate db:seed
```

---

## Run

```bash
# From apps/web/
bin/dev
```

This starts:

- Rails server on `http://localhost:3000`
- Tailwind CSS watcher (`bin/rails tailwindcss:watch`)

Procfile is at `apps/web/Procfile.dev`.

## Project Structure

```
timeagocalculator.com/
├── apps/web/                   # Rails 8.1 application
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── calculators/    # Time Ago, Time Until, Date Diff, Age, Business Days,
│   │   │   │                   # Day of the Week — all namespaced under Calculators::
│   │   │   ├── date_pages_controller.rb  # /date/:year/:month/:day SEO result pages
│   │   │   ├── home_controller.rb        # Landing page (events + hero forms)
│   │   │   ├── events_controller.rb
│   │   │   └── people_controller.rb
│   │   ├── models/
│   │   │   └── event.rb
│   │   ├── services/
│   │   │   ├── date_calculations/   # Pure Ruby calculators (TimeAgoCalculator, TimeUntilCalculator)
│   │   │   ├── events/
│   │   │   │   ├── ingestor.rb      # Orchestrates all sources
│   │   │   │   └── sources/         # curated, leaders, nager_date, open_holidays, calendarific
│   │   │   ├── nager_date_client.rb # Nager.Date API wrapper
│   │   │   └── seo/
│   │   │       └── structured_data_builder.rb
│   │   ├── views/
│   │   │   ├── calculators/
│   │   │   ├── date_pages/          # /date/:year/:month/:day result page
│   │   │   ├── home/                # Landing page
│   │   │   ├── events/
│   │   │   ├── people/
│   │   │   └── shared/              # _footer, _date_formats, _structured_data
│   │   └── javascript/
│   │       └── controllers/
│   │           ├── countdown_controller.js      # Live countdown for future dates/events
│   │           ├── time_since_controller.js     # Live elapsed seconds for past dates
│   │           ├── date_redirect_controller.js  # Form → /date/:year/:month/:day
│   │           └── navbar_controller.js         # Mobile hamburger toggle
│   ├── config/
│   │   ├── routes.rb
│   │   ├── sitemap.rb
│   │   └── initializers/
│   │       ├── sidekiq.rb
│   │       ├── rack_attack.rb
│   │       └── suppress_gem_warnings.rb
│   └── db/
│       ├── migrate/
│       ├── seeds/
│       │   └── data/                # JSON seed files (included in Docker image)
│       │       ├── curated_events.json   # Annual/recurring events template
│       │       └── leaders.json          # US Presidents, UK PMs, UK Monarchs
│       └── seeds.rb
├── data/                       # Legacy location — NOT in Docker image. Use db/seeds/data/ instead.
├── infra/
│   ├── docker/
│   │   ├── compose.yml          # Production
│   │   └── compose.override.yml # Development
│   ├── caddy/
│   │   └── Caddyfile
│   └── scripts/
│       └── deploy.sh
└── docs/
```

> **Seed file location:** All JSON seed files must live in
> `apps/web/db/seeds/data/` (inside the Docker build context). The `data/`
> directory at the monorepo root is **not** copied into the container.

---

## Adding a Curated Event

Add to `apps/web/db/seeds/data/curated_events.json`:

```json
{
  "title": "Event Name",
  "slug_base": "event-name",
  "category": "sports",
  "recurrence": "annual",
  "typical_month": 2,
  "typical_day": 1,
  "description": "One or two sentences.",
  "wikipedia_title": "Event Name",
  "country_codes": ["US"],
  "featured": false
}
```

Then re-ingest (idempotent):

```bash
bin/rails events:ingest
```

The event will be available at `/events/event-name-2026`.

---

## Adding a Celebrity Age Page

Edit `app/controllers/people_controller.rb`, add to the `PEOPLE` constant:

```ruby
"first-last" => { name: "First Last", birthdate: Date.new(1990, 6, 15) },
```

Visits `/age/first-last`.

---

## Running Tests

```bash
# From apps/web/
bin/rails test
```

---

## Docker (Dev)

```bash
# From repo root
docker compose -f infra/docker/compose.yml -f infra/docker/compose.override.yml up
```

Rails on `http://localhost:3000`, Postgres on `5432`, Redis on `6379`.

---

## Auth

Email + password auth via Rails 8 `Authentication` concern. Sign up at
`/sign-up`, sign in at `/session/new`.

- `Current.user` — logged-in user, available everywhere (nil if anonymous)
- `authenticated?` helper — checks session cookie
- All pages are public by default (`allow_unauthenticated_access` in
  `ApplicationController`)

**Password reset:** Implemented via `PasswordsController` + `PasswordsMailer`.
Requires ActionMailer configured for your environment (SMTP or a provider).

**OmniAuth:** Gems installed, `Identity` model + migration ready. Add a provider
gem + configure in `config/initializers/omniauth.rb`. See comments there for
wiring instructions.

**Creating a test user in console:**

```ruby
User.create!(email_address: "test@example.com", password: "password123", password_confirmation: "password123")
```

---

## Useful Rails Commands

```bash
bin/rails routes                         # list all routes
bin/rails db:seed                        # re-seed base data (idempotent)
bin/rails sitemap:refresh                # regenerate XML sitemap
bin/rails events:seed_leaders            # seed US Presidents / UK PMs / UK Monarchs (~62 records)
bin/rails events:ingest                  # full event ingest (2yr behind + 3yr ahead, fetches images)
bin/rails events:refresh                 # refresh upcoming events (current + next 2yr, faster)
bin/rails events:backfill_images         # backfill Wikipedia images for events missing image_url
bin/rails runner "Event.count"           # quick DB check
bin/rails runner "Event.where(category: 'leaders').count"  # verify leaders seeded
```
