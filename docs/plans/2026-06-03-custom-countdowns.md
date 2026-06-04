# Custom Countdown Feature

**Date:** 2026-06-03
**Status:** Complete

---

## Goal

Let anyone create a shareable countdown timer without an account. Core growth channel — every shared countdown is a backlink and a return visit.

---

## Scope

### What was built

- Creation form at `/countdowns/new` — title, target date/time, optional description, public/private toggle with password
- Shareable countdown page at `/c/:token` — live ticking timer, copy-link button
- Password gate at `/c/:token/unlock` — bcrypt-protected private countdowns with session-based auth

### What was NOT built (out of scope)

- User-owned countdowns (requires accounts — Phase 2)
- Countdown listing / directory
- Edit or delete after creation
- Expiry or auto-cleanup of old countdowns

---

## Technical Approach

**Token design:** `SecureRandom.urlsafe_base64(8)` → 11-char URL-safe token. Generated in `before_validation` so uniqueness validation passes on first save. Never user-supplied.

**URL:** `/c/:token` — short, distinct from `/countdown/:slug` (holidays). Existing shares never break when Phase 2 adds vanity URLs.

**Privacy:** `has_secure_password validations: false` on `Countdown` model. Password required only when `is_public = false` (conditional validation). Session key `"countdown_auth_#{token}"` set on correct password — cookie-based, no external deps.

**Live timer:** Reuses existing `countdown_controller.js` Stimulus controller (same as holiday pages). Zero server load after initial render.

**New Stimulus controllers:**
- `countdown_form_controller.js` — toggles password fields on public/private switch
- `clipboard_controller.js` — copy-to-clipboard with 2s "Copied!" feedback

**Gems added:** `bcrypt ~> 3.1.7` (was absent from Gemfile).

See full architecture doc: [docs/core/countdown-architecture.md](../core/countdown-architecture.md)

---

## Acceptance Criteria

- [x] `GET /countdowns/new` → 200, creation form renders with public/private toggle
- [x] Password fields hidden when public, visible when private (Stimulus toggle)
- [x] `POST /countdowns` (public) → 302 → `/c/:token`
- [x] `POST /countdowns` (private + password) → 302 → `/c/:token`
- [x] `GET /c/:token` (public) → 200, live countdown ticks, copy link button present
- [x] `GET /c/:token` (private, no session) → 302 → `/c/:token/unlock`
- [x] `GET /c/:token/unlock` → 200, password form renders
- [x] `POST /c/:token/unlock` (wrong password) → 422, "Incorrect password" shown
- [x] `POST /c/:token/unlock` (correct password) → 302 → `/c/:token`, authenticated
- [x] `/c/:token` (private, authenticated) → 200, countdown renders with "Private" badge
- [x] Token unique index enforced in DB
- [x] `countdown[is_public]=0` without password → validation error, re-render form

---

## Natural Next Steps

### Phase 2 — User Accounts

- Associate countdown to `user_id` FK (column already exists and is nullable)
- Show "My countdowns" dashboard at `/dashboard`
- Add edit/delete for owned countdowns
- Vanity URLs: `/u/:username/:slug` as alias for `/c/:token`
- "Claimed" badge on public user countdowns

### Countdown Directory

- Public index at `/countdowns` listing recently created public countdowns
- Category tags (birthday, wedding, event, etc.)
- Trending countdowns by view count

### Sharing Improvements

- OG image generation (target date rendered as an image for link previews)
- WhatsApp / Twitter / email share buttons alongside copy link
- QR code download

### Countdown Management

- Expiry policy — auto-archive countdowns past their target date after N days
- Edit form (title, description, target date — not password — for authenticated owner)
- View counter

### Widget

- Embeddable countdown widget:
  ```html
  <script src="https://timeagocalculator.com/widget.js"></script>
  <div data-countdown="TOKEN"></div>
  ```
- Each embed = potential backlink

### SEO

- Public countdowns indexed: canonical URL + OG tags already in place
- Sitemap entry for public countdowns (`/c/:token`) once a volume threshold is reached
