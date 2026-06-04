# Footer Sitemap and Placeholder Pages

## Current State

- The existing application footer is minimal and only shows a dynamic site copyright.
- Several footer destinations from the reference image already exist as routes and pages.
- Several footer destinations are missing routes and views.
- `/events` has a route and controller action. An event index view exists in the current working tree.

## Goals

- Add the full footer sitemap from the reference image.
- Make every internal footer link resolve.
- Add basic structures for missing pages.
- Use Bobadilla Technologies copyright.

## Acceptance Criteria

- Footer appears on standard app pages.
- Footer links to all reference-image destinations.
- No internal footer link raises routing or template errors.
- Copyright reads `© 2025 Bobadilla Technologies` and links to `http://bobadilla.tech/`.
- Missing feature pages clearly exist as basic placeholders.

## Next Steps

- Replace placeholder calculator pages with real tools.
- Add real URLs for Buy Me a Coffee, Facebook, and Twitter.
- Decide whether feedback and bug reports should become forms, mailto links, or issue tracker links.
- Add richer legal/support copy for Privacy Policy, Terms, Contact, and FAQs.

## Implementation Plan

- Missing pages to add as basic placeholders:
  - Privacy Policy (`/privacy`)
  - Terms of Service (`/terms`)
  - Contact (`/contact`)
  - FAQs (`/faqs`)
  - Support / Buy Me a Coffee (`/support`)
  - Feedback (`/feedback`) — either a simple mailto or a tiny form
  - Bug reports (`/bugs`) — link to issue tracker or mailto

- Routing and controller approach:
  - Reuse `PagesController` (or add `StaticPagesController`) to serve static placeholders.
  - Add `get` routes in `config/routes.rb` for each path above.

- Views and content:
  - Create `app/views/pages/<name>.html.erb` for each page with an `h1`, short explanatory paragraph, and a TODO note for richer copy.
  - Use a shared partial for legal footer copy where appropriate.

- Footer and templates:
  - Update the footer partial to include the full sitemap links, using path helpers (`privacy_path`, `terms_path`, ...).
  - Ensure external links open in a new tab and have `rel="noopener"`.

- Tests and verification:
  - Add a simple integration test verifying the footer renders and every internal footer link returns `200`.
  - Manually visit each new route in development to confirm no template or routing errors.

- Acceptance and polish:
  - Replace placeholder copy with final legal/support content when available.
  - Replace `Buy Me a Coffee`, Facebook, and Twitter placeholders with real URLs.

## Owners, Estimates, and Next Steps

- Owner: `web` app maintainer (default: whoever owns front-end templates).
- Estimated effort: 2–4 hours to add placeholders, footer links, and basic tests.
- Next immediate actions:
  1.  Add the `get` routes and placeholder views.
  2.  Update the footer partial to include the new links.
  3.  Add a small integration test that checks each link resolves.

If you want, I can implement the `routes`, controller actions, views, and a test now—shall I proceed?
