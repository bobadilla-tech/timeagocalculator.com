# Product Vision

**timeagocalculator.com**

A platform for calculating:

- How long ago something happened
- How long until something happens
- Time between two dates
- Age calculators
- Countdown timers
- Event countdowns
- Historical event timelines
- Custom shareable countdowns
- Embeddable widgets
- Public and private countdown pages

Long-term:

- API
- User accounts
- Premium plans
- Event ingestion platform
- AI-generated informational pages

---

# MVP

## Core Calculators

### Time Ago Calculator

Examples:

- How long ago was January 1, 2000?
- How long ago was COVID declared a pandemic?
- How long ago was World War II?

Output:

- Years
- Months
- Days
- Hours
- Minutes
- Human-readable text

Example:

> January 1, 2000 was 26 years, 5 months and 2 days ago.

---

### Time Until Calculator

Examples:

- How long until Christmas?
- How long until New Year?
- How long until my birthday?

Output:

- Countdown
- Years/months/days
- Live updating timer

---

### Date Difference Calculator

Examples:

- Days between two dates
- Business days between dates
- Weeks between dates
- Months between dates

---

### Age Calculator

Examples:

- How old am I?
- How old is someone born on X date?

SEO monster because:

- "How old is Tom Cruise?"
- "How old is Elon Musk?"
- etc.

---

# SEO Strategy

## Landing Page Types

### Generic

```
/time-ago-calculator
/time-until-calculator
/date-difference-calculator
/age-calculator
```

---

### Holiday Pages

```
/countdown/christmas
/countdown/new-years
/countdown/halloween
/countdown-thanksgiving
```

Future:

```
/countdown/christmas-2027
/countdown/christmas-2028
```

---

### Historical Events

```
/how-long-ago/moon-landing
/how-long-ago/fall-of-berlin-wall
/how-long-ago/world-war-ii-end
```

---

### Sports

```
/countdown/super-bowl-2027
/countdown/world-cup-2030
/countdown-nba-finals-2027
```

---

### Celebrity Birthdays

```
/age/tom-cruise
/age/taylor-swift
/age/mrbeast
```

Huge SEO surface.

---

### Dynamic Date Pages

Generate pages automatically.

Examples:

```
/how-long-ago/january-1-2020
/how-long-ago/july-4-1776
```

Potentially millions of pages.

Need careful indexing strategy.

---

# User Accounts (Phase 2)

Authentication:

- Devise
- Google OAuth
- GitHub OAuth

Users can:

- Create countdowns
- Create anniversaries
- Create reminders
- Public countdowns
- Private countdowns
- Share links

Examples:

```
/u/eliaz/my-wedding
/u/eliaz/marathon
```

---

# Premium Plan

Monthly subscription.

Features:

- No ads
- Unlimited countdowns
- Premium themes
- Custom domains
- Widget customization
- API access

---

# Widget Platform

One of the strongest growth channels.

Example embed:

```html
<script src="https://timeagocalculator.com/widget.js"></script>
<div data-countdown="christmas"></div>
```

Thousands of backlinks.

Possible widgets:

- Christmas countdown
- New Year countdown
- Event countdown
- Birthday countdown
- Age widget
- Time since widget

---

# Event Ingestion System

Create an internal event database.

## Sources

- Sports schedules
- Public holidays
- Elections
- Space launches
- Movie releases
- Major conferences

Store:

```ruby
Event
  title
  slug
  starts_at
  category
  description
  source
```

Generate pages automatically.

---

# AI Content Generation

Generate supporting content.

Example:

```
How long until Christmas 2027?
```

Page contains:

- Countdown
- Date information
- Day of week
- Historical Christmas facts
- FAQ

Not AI spam.

Use AI only to enrich pages.

---

# Technical Architecture

## Stack

### Backend

- Ruby on Rails 8
- PostgreSQL
- Redis
- Sidekiq

---

### Frontend

- Hotwire
- Turbo
- Stimulus
- Tailwind CSS v4

Avoid React.

This app does not need it.

---

### Auth

- Devise
- OmniAuth

Providers:

- Google
- GitHub

---

### Deployment

Docker-first.

Services:

```yaml
web
postgres
redis
sidekiq
nginx
```

Deploy on:

- Hetzner VPS

Single-server architecture initially.

---

# SEO Infrastructure

## Sitemaps

Use:

- sitemap_generator

Separate sitemap indexes:

```text
/sitemaps/pages.xml
/sitemaps/events.xml
/sitemaps/holidays.xml
/sitemaps/countdowns.xml
/sitemaps/blog.xml
```

---

## Structured Data

JSON-LD:

- FAQ
- Article
- Breadcrumb
- Event
- WebApplication

Critical for rankings.

---

## Metadata

Every page gets:

- Canonical URL
- OpenGraph
- Twitter Card
- Schema.org data

---

# Database Model (Initial)

```ruby
User

Countdown
  title
  slug
  target_date
  public
  user_id

Event
  title
  slug
  starts_at
  category
  source

Holiday
  title
  country
  date

BlogPost
  title
  slug
  content

Subscription
  user_id
  stripe_customer_id

ApiKey
  user_id
  token
```

---

# Future API

Endpoints:

```http
GET /api/v1/timeago

GET /api/v1/countdown

GET /api/v1/events

GET /api/v1/holidays
```

Usage:

```http
GET /api/v1/timeago?date=2020-01-01
```

Returns:

```json
{
  "years": 6,
  "months": 2,
  "days": 4
}
```

---

# Growth Opportunities

1. Widget embeds → backlinks
2. Sports countdown pages
3. Holiday countdown pages
4. Historical event pages
5. Celebrity age pages
6. User-generated countdowns
7. API access
8. Programmatic SEO at scale
9. Blog content
10. Public countdown directory

# Project Structure

The project will be organized as a monorepo, even though the initial
implementation consists of a single Rails application. This keeps the
architecture flexible for future additions such as APIs, workers, ingestion
services, and administrative tools.

## Repository Layout

```text
timeagocalculator/

├── apps/
│   └── web/
│       └── Rails application
│
├── docs/
│   ├── plans/
│   ├── core/
│   ├── architecture/
│   ├── seo/
│   ├── operations/
│   └── runbooks/
│
├── infra/
│   ├── caddy/
│   ├── docker/
│   └── scripts/
│
├── data/
│   ├── seeds/
│   ├── imports/
│   └── exports/
│
├── tools/
│   └── development utilities
│
└── README.md
```

## apps/

Application code lives under the apps directory.

Initially:

```text
apps/
└── web/
```

Future examples:

```text
apps/
├── web/
├── api/
├── worker/
└── admin/
```

The Rails application should remain isolated within apps/web to avoid repository
root clutter.

## docs/

Documentation is treated as a first-class part of the project.

### docs/plans

Contains implementation plans and task breakdowns.

Example:

```text
docs/plans/
├── 2026-06-03-initial-mvp.md
├── 2026-06-10-user-accounts.md
└── 2026-06-15-widget-platform.md
```

Each plan should contain:

- Goal
- Scope
- Technical approach
- Acceptance criteria
- Rollout strategy

Plans are temporary working documents.

### docs/core

Permanent documentation.

Examples:

- Product vision
- Tech stack decisions
- Coding standards
- Domain model documentation
- Architecture decisions

This directory becomes the project's source of truth.

### docs/architecture

Architecture-specific documents.

Examples:

- SEO generation pipeline
- Countdown architecture
- Event ingestion system
- Widget platform design

### docs/operations

Operational documentation.

Examples:

- Deployment procedures
- Hetzner setup
- Backups
- Monitoring
- Incident response

### docs/runbooks

Step-by-step guides.

Examples:

- Local Stripe testing
- Creating production releases
- Running imports
- Rotating secrets

## infra/

Infrastructure and deployment configuration.

### infra/caddy

Caddy configuration.

Examples:

```text
infra/caddy/
├── Caddyfile
└── snippets/
```

### infra/docker

Docker-related assets.

Examples:

```text
infra/docker/
├── compose.yml
├── web.Dockerfile
├── worker.Dockerfile
└── scripts/
```

### infra/scripts

Deployment and operational scripts.

Examples:

```text
infra/scripts/
├── deploy.sh
├── backup.sh
└── restore.sh
```

## data/

Contains managed data assets.

Examples:

- Holiday datasets
- Event imports
- Seed data
- Generated SEO content

Examples:

```text
data/
├── holidays/
├── sports/
├── historical-events/
└── generated/
```

## Future-Proofing

The repository should be organized so that future services can be added without
restructuring the project.

Potential future services:

- Event ingestion worker
- Public API
- Premium subscription platform
- Widget rendering service
- AI content generation service

The initial deployment remains a single Rails monolith running on one VPS, but
the repository structure should support future extraction when necessary.
