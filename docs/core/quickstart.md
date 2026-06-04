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
│   │   │   ├── calculators/    # 4 calculator controllers (namespaced)
│   │   │   ├── concerns/
│   │   │   │   └── seo_meta_taggable.rb
│   │   │   ├── events_controller.rb
│   │   │   ├── holidays_controller.rb
│   │   │   └── people_controller.rb
│   │   ├── models/
│   │   │   ├── event.rb
│   │   │   └── holiday.rb
│   │   ├── services/
│   │   │   ├── date_calculations/   # Pure Ruby calculators
│   │   │   ├── nager_date_client.rb # Nager.Date API wrapper (holiday data)
│   │   │   └── seo/
│   │   │       └── structured_data_builder.rb
│   │   ├── views/
│   │   │   ├── calculators/
│   │   │   ├── events/
│   │   │   ├── holidays/
│   │   │   ├── people/
│   │   │   └── shared/          # Reusable partials
│   │   └── javascript/
│   │       └── controllers/
│   │           ├── countdown_controller.js
│   │           ├── time_ago_controller.js
│   │           └── date_diff_controller.js
│   ├── config/
│   │   ├── routes.rb
│   │   ├── sitemap.rb
│   │   └── initializers/
│   │       ├── sidekiq.rb
│   │       ├── rack_attack.rb
│   │       └── meta_tags.rb
│   └── db/
│       ├── migrate/
│       └── seeds.rb
├── data/
│   └── seeds/
│       ├── historical_events.json
│       └── holidays.json
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

---

## Adding a Historical Event

Add to `data/seeds/historical_events.json`:

```json
{
  "title": "Event Name",
  "slug": "event-slug",
  "starts_at": "1990-01-01T00:00:00Z",
  "category": "historical",
  "source": "wikipedia",
  "description": "One or two sentences about the event."
}
```

Then re-seed (idempotent):

```bash
bin/rails db:seed
```

The page will be available at `/how-long-ago/event-slug`.

---

## Adding a Holiday Countdown

Add to `data/seeds/holidays.json`:

```json
{
  "title": "Holiday Name",
  "slug": "holiday-slug",
  "month": 3,
  "day": 17,
  "country": "US",
  "description": "Short description."
}
```

Re-seed, then visit `/countdown/holiday-slug`.

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

Email + password auth via Rails 8 `Authentication` concern. Sign up at `/sign-up`, sign in at `/session/new`.

- `Current.user` — logged-in user, available everywhere (nil if anonymous)
- `authenticated?` helper — checks session cookie
- All pages are public by default (`allow_unauthenticated_access` in `ApplicationController`)

**Password reset:** Implemented via `PasswordsController` + `PasswordsMailer`. Requires ActionMailer configured for your environment (SMTP or a provider).

**OmniAuth:** Gems installed, `Identity` model + migration ready. Add a provider gem + configure in `config/initializers/omniauth.rb`. See comments there for wiring instructions.

**Creating a test user in console:**

```ruby
User.create!(email_address: "test@example.com", password: "password123", password_confirmation: "password123")
```

---

## Useful Rails Commands

```bash
bin/rails routes                   # list all routes
bin/rails db:seed                  # re-seed (idempotent)
bin/rails sitemap:refresh          # regenerate XML sitemap
bin/rails runner "Event.count"     # quick DB check
bin/rails runner "User.count"      # check user count
```
