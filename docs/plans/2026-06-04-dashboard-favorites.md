# Dashboard, Favorites & Password Fix

**Date:** 2026-06-04
**Status:** Complete

---

## Goal

Three gaps closed in one pass:

1. Bug: editing a private countdown without changing the password triggered a validation error, making private countdowns effectively uneditable after creation.
2. UX: countdown owners had to enter their own countdown's password to view their private timers.
3. Feature: no way for users to see all their countdowns in one place, or save other users' public countdowns.

---

## Scope

### What was built

**Password validation fix**
- `validates :password, presence: true` was firing on every save for private countdowns, even when not changing the password.
- Fixed to only require password when `password_digest` is blank (first time setting it, or switching from public to private with no password yet).
- Owner now auto-bypasses the password gate on their own private countdown (`owned_by?(Current.user)` added to the `show` gate condition).

**Dashboard at `/dashboard`**
- Requires authentication — anonymous users redirected to sign-in.
- Two tab sections (client-side tab switch via Stimulus `dashboard-tab` controller, hash-based navigation):
  - **My Countdowns** — all countdowns owned by the current user, ordered by creation date. Per-row: Edit (if unlocked), Lock/Unlock, Delete. Shows private/locked badges and favorite count.
  - **Favorites** — countdowns the user has favorited, ordered by favorited_at. Per-row: Unfavorite. Shows creator email for non-owned countdowns.
- Paginated with `pagy` (20 per page, `Pagy::Backend` in controller, `Pagy::Frontend` in `ApplicationHelper`).
- "Dashboard" nav link added to layout when logged in.

**Favorites**
- `countdown_favorites` join table: `user_id` + `countdown_id`, unique compound index.
- `CountdownFavorite` model, `favorited_by?(user)` + `favorites_count` helpers on `Countdown`.
- `User` → `has_many :favorited_countdowns, through: :countdown_favorites`.
- Toggle via `POST/DELETE /c/:token/favorite` → `CountdownFavoritesController`.
- Favorite/Unfavorite button on countdown show page — visible to logged-in users on public countdowns only.
- Count displayed inline: "♥ N people favorited this".

### What was NOT built

- Real-time favorite count update (full page redirect after toggle)
- Bulk delete or bulk favorite from dashboard
- Sorting/filtering on dashboard
- Email notifications for favorites

---

## Technical Decisions

**Password validation:**
`validates :password, presence: true, if: -> { !is_public? && password_digest.blank? }` — only requires setting a password once. Subsequent edits (title, date, description changes) work without re-entering the password. Switching from public back to private also requires a password only if one was never set.

**Owner bypass on private countdown:**
Added `|| @countdown.owned_by?(Current.user)` to `show` gate. Owners always see their own countdowns without needing to enter the password. Session-based unlock still works for non-owner visitors who know the password.

**Favorites on public countdowns only:**
Private countdowns can't be favorited — the button is hidden unless `@countdown.is_public?`. This avoids exposing private countdown existence to unauthorized users via the favorites list.

**`find_or_create_by!` in favorites create:**
Idempotent — double-clicking the button or re-submitting doesn't raise a uniqueness error.

---

## Routes Added

| Method | Path | Action |
|--------|------|--------|
| `GET` | `/dashboard` | `dashboard#index` |
| `POST` | `/c/:token/favorite` | `countdown_favorites#create` |
| `DELETE` | `/c/:token/favorite` | `countdown_favorites#destroy` |

---

## Acceptance Criteria

- [x] Edit private countdown without changing password → saves successfully
- [x] Owner views own private countdown → no password gate
- [x] Non-owner visits private countdown → still hits password gate
- [x] `GET /dashboard` anonymous → redirect to sign-in
- [x] `GET /dashboard` logged-in → My Countdowns tab active
- [x] My Countdowns shows all owned countdowns with correct action buttons
- [x] Edit/Lock/Delete actions work from dashboard
- [x] Locked countdown shows no Edit button
- [x] `POST /c/:token/favorite` (logged-in, public countdown) → favorite created, button fills
- [x] `DELETE /c/:token/favorite` → favorite removed, button empties
- [x] Favorites tab shows favorited countdowns with Unfavorite button
- [x] Unfavorite from dashboard tab removes from list
- [x] Favorite count displayed on show page
- [x] Private countdown show page → no favorite button
- [x] Logged-out user → no favorite button
- [x] `bin/rails db:migrate` runs clean

---

## Natural Next Steps

- Turbo Streams for live favorite count update (no full page redirect)
- Dashboard filter: upcoming vs past, public vs private
- Bulk delete from dashboard
- "Trending" public countdowns page (order by favorites_count DESC)
- Favorite count in dashboard My Countdowns row (already shown)
