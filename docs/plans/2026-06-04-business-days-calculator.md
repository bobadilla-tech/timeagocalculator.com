# Plan — Business Days Calculator

**Date**: 2026-06-04\
**Status**: Shipped

## Context

Added a dedicated Business Days Calculator at `/business-days-calculator`.
Complements the existing Date Difference Calculator (which already shows a raw
business day count using weekend-only logic). This page adds:

- Country-aware holiday exclusions via Nager.Date API
- Two distinct calculation modes: between dates and add/subtract
- Quick calculation links

## Architecture

### Two calculation modes

**Between dates**: Count business days between start and end date.\
**Add/subtract**: Find the date that is N business days forward or backward from
a given date.

### Holiday data — Nager.Date API

`app/services/nager_date_client.rb` wraps `https://date.nager.at/api/v3`.

- `NagerDateClient.available_countries` → `GET /api/v3/AvailableCountries`,
  cached 7 days
- `NagerDateClient.holidays(year:, country_code:)` →
  `GET /api/v3/PublicHolidays/{year}/{countryCode}`, cached 24h
- Both methods degrade gracefully on API error (log warning, return
  empty/fallback list)
- API spec reference: `data/clients/nagerdate.json`

### Calculator service

`app/services/date_calculations/business_days_calculator.rb`

- `BusinessDaysCalculator#between(from:, to:)` → `BetweenResult`
- `BusinessDaysCalculator#add(from:, days:, direction:)` → `AddResult`
- Per-instance holiday cache keyed by year to avoid redundant API calls when
  iterating day-by-day
- Uses `Set` for O(1) holiday membership checks

### Caching note

`Rails.cache` must be configured with a persistent store (e.g. Redis) in
production for the 24h holiday cache to work across processes/restarts. In
development the default `:memory_store` works per-process.

## Files created

| File                                                         | Purpose                                |
| ------------------------------------------------------------ | -------------------------------------- |
| `app/services/nager_date_client.rb`                          | API wrapper + country/holiday fetching |
| `app/services/date_calculations/business_days_calculator.rb` | Core calculation logic                 |
| `app/controllers/calculators/business_days_controller.rb`    | Controller (inherits BaseController)   |
| `app/views/calculators/business_days/show.html.erb`          | View with mode switcher                |
| `app/javascript/controllers/business_days_controller.js`     | Stimulus: toggle between/add panels    |

## Files modified

- `config/routes.rb` — added `/business-days-calculator`
- `app/views/layouts/application.html.erb` — added "Business Days" nav link
