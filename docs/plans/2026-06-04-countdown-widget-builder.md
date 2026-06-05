# Plan — Countdown Widget Builder

**Date**: 2026-06-04\
**Status**: Shipped

## Context

New page at `/countdown-widget-builder` where users configure a visual countdown
widget and copy an embeddable `<iframe>` snippet to paste on their own website.

## Architecture

### No database

Widget config lives entirely in the iframe URL query params. Nothing is stored.

### Two endpoints

| Endpoint                        | Purpose                                   |
| ------------------------------- | ----------------------------------------- |
| `GET /countdown-widget-builder` | Builder page (full app layout)            |
| `GET /widget/countdown?...`     | Rendered widget HTML only (widget layout) |

### Live preview

Stimulus controller (`countdown_widget_controller.js`) directly mutates the
preview div on every form input change. Zero latency — no server round-trip
needed.

### Widget delivery

The embed code is an `<iframe>` pointing to `/widget/countdown?params...`. The
widget endpoint renders minimal HTML with:

- Inline CSS driven by URL params (colors, radius, shadow, font, scale)
- Inline JavaScript countdown tick (no Stimulus, no importmap — fully
  standalone)
- Attribution link: "Powered by TimeAgoCalculator.com"

## Files created

| File                                                        | Purpose                                            |
| ----------------------------------------------------------- | -------------------------------------------------- |
| `app/controllers/widgets_controller.rb`                     | `builder` + `countdown` actions                    |
| `app/views/layouts/widget.html.erb`                         | Minimal layout (no nav, no Tailwind, no importmap) |
| `app/views/widgets/builder.html.erb`                        | Builder page (two-column form + preview)           |
| `app/views/widgets/countdown.html.erb`                      | Widget HTML rendered in widget layout              |
| `app/javascript/controllers/countdown_widget_controller.js` | Builder Stimulus controller                        |

## Files modified

- `config/routes.rb` — added `/countdown-widget-builder` and `/widget/countdown`
- `app/views/layouts/application.html.erb` — added "Widget Builder" nav link

## Widget params reference

| Param         | Type                    | Default                      | Notes                           |
| ------------- | ----------------------- | ---------------------------- | ------------------------------- |
| `title`       | string                  | "My Countdown"               | HTML-escaped in widget          |
| `date`        | ISO date                | tomorrow                     |                                 |
| `time`        | HH:MM                   | "00:00"                      |                                 |
| `tz`          | IANA timezone           | "UTC"                        | e.g. "America/Lima"             |
| `bg`          | hex color               | "#213B7A"                    | validated by regex              |
| `title_color` | hex                     | "#ffffff"                    |                                 |
| `num_color`   | hex                     | "#ffffff"                    |                                 |
| `label_color` | hex                     | "#cccccc"                    |                                 |
| `radius`      | 0–40                    | 20                           | border-radius px                |
| `shadow`      | none/soft/medium/strong | "none"                       | CSS box-shadow preset           |
| `font`        | whitelisted string      | "system"                     | Google Fonts loaded per-request |
| `scale`       | 50–200                  | 100                          | font/size scale %               |
| `layout`      | horizontal/vertical     | "horizontal"                 |                                 |
| `show_date`   | true/false              | "true"                       |                                 |
| `date_format` | long/short/numeric      | "long"                       |                                 |
| `units`       | CSV                     | "days,hours,minutes,seconds" | subset of valid units           |

## Security notes

- Color params sanitized with `/\A#[0-9a-fA-F]{3,6}\z/` regex before injecting
  into CSS
- Title HTML-escaped with `h()` before rendering
- Font param validated against a whitelist
- Units param intersection with `%w[days hours minutes seconds]` whitelist
- `raw units.to_json` is safe because units are whitelisted strings
