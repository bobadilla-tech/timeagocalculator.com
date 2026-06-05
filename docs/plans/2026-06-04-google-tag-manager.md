# Google Tag Manager Setup

**Date**: 2026-06-04\
**Status**: Shipped

## Container

- **GTM ID**: `GTM-5DDT3RPS`

## Changes

Single file modified: `app/views/layouts/application.html.erb`

1. **JS snippet** added before `</head>` — fires GTM on every page load
2. **`<noscript>` iframe** added immediately after `<body>` opening tag —
   fallback for users with JavaScript disabled

## Verification

- View source on any page → search for `GTM-5DDT3RPS`
- GTM preview mode (`tagmanager.google.com`) → connect to site → confirms
  dataLayer fires
