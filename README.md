<p align="center">
  <img src="docs/assets/collectarr-icon.svg" alt="Collectarr app icon" width="104" height="104">
</p>

# Collectarr App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub Release](https://img.shields.io/github/v/release/collectarr/collectarr-app)
[![Issues](https://img.shields.io/github/issues/collectarr/collectarr-app)](https://github.com/collectarr/collectarr-app/issues)
![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Windows%20%7C%20Android-lightgrey)

> A local-first collection manager for comics, books, games, board games, movies, music, and more.

Collectarr is built for people who want a CLZ-style collection workflow without
locking the entire experience behind a hosted metadata UI. The app keeps your
library locally, works offline, supports multiple media types, and talks to
`collectarr-core` only for canonical metadata, provider search, admin tooling,
and optional shared services. Optional multi-device sync lives in
`collectarr-sync`.

The goal is simple: fast local shelves, rich metadata, flexible ownership
tracking, and a UI that feels like a serious collection tool instead of a thin
web wrapper.

The current in-app library registry ships six active kinds: comics, books,
games, board games, movies, and music.

## What Collectarr Focuses On

- **Local-first ownership** — your collection state lives in the app, not only on a remote account
- **Multi-media support** — one app for comics, books, games, board games, movies, and music
- **Collector workflows** — variants, formats, barcode flows, grouped shelves, bulk editing, and custom fields
- **Provider-backed metadata** — canonical metadata comes from `collectarr-core` and its provider integrations
- **Admin-friendly architecture** — image cache controls, ingest flows, proposals, and provider health exist as first-class features

## Highlights

- **Offline-first local library** — personal collection + wishlist stored in local Drift DB
- **Catalog snapshots** — cached Core data so saved items stay useful offline
- **CLZ-style workspaces** — cover/grid/table views, filters, series sidebars, inspectors, column presets, bulk editing
- **Smart add / search** — structured series, issue, barcode, candidate tree, and whole-series handling
- **Trailer links** — YouTube-detected trailers on detail pages for movies and games
- **HDR & physical media** — HDR format multi-select and features text for physical media tracking
- **CSV import / export** — Collectarr/CLZ-friendly with media-aware headers + custom field columns
- **TMDB import** — import TMDB CSV/JSON exports with batch hydration and duplicate detection
- **Barcode scanning** — camera scanner where available + manual fallback everywhere
- **Sync support** — optional multi-device sync via `collectarr-sync` with conflict review, retry queue, and freshness indicator
- **Admin panel** — user management, image cache controls, provider health (admin-only)
- **Sync history** — timestamped log with push/pull/reject counts
- **Custom fields** — user-defined fields per media type with search/filter and CSV support
- **Multiple images per item** — local item photos with captions and sort order
- **Bundle-aware add/edit flows** — choose media, edition, variant, or bundle-release references with member previews and anchor-aware personal item editing
- **Story arc & character facets** — filter library by story arcs and characters with facet buckets
- **Provider previews** — see story arc, character, and credit previews in add/search dialogs
- **Media-aware metadata UI** — shared inspector/add preview with type-specific music, game, and video metadata presentation
- **Explicit add selection** — add/search results stay unselected until you choose one, while direct provider previews are prefetched in bounded batches
- **Animated accent theming** — smooth color transitions across all UI elements when switching libraries

## Collectarr vs CLZ

| Area | Collectarr | CLZ |
|------|------------|-----|
| Ownership model | Local-first database in the app with optional sync | Primarily account/cloud-centric workflow |
| Media scope | Multi-media in one product: comics, books, games, movies, music, board games | Split across separate product lines / apps |
| Metadata architecture | Open provider pipeline via `collectarr-core` | Closed commercial metadata stack |
| Admin / power-user tooling | Built-in provider health, ingest, proposals, image cache, audit-style workflows | End-user product first, limited self-host/admin surfaces |
| Offline behavior | Strong offline shelf usage with cached catalog snapshots | Depends more on CLZ service/app model |
| Custom workflows | Easier to extend in code: custom fields, import/export, provider rules, UI behavior | Mature polished product, but less customizable by developers |
| Best fit | Users who want control, flexibility, and a hackable stack | Users who want a polished turnkey commercial solution |

Collectarr deliberately takes inspiration from CLZ's strengths around browsing,
shelf views, and collector ergonomics, but it optimizes for ownership of data,
multi-media support, and extensibility.

## Quick Start

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

### Run on Web

```powershell
flutter run -d chrome `
  --dart-define=COLLECTARR_API_BASE_URL=http://localhost:8010 `
  --dart-define=COLLECTARR_SYNC_BASE_URL=http://localhost:8020 `
  --dart-define=COLLECTARR_SYNC_KEY=collectarr-sync-dev-key
```

The web build uses Drift with sqlite3 WASM and stores the local database in
IndexedDB.

### Run on Windows

```powershell
flutter run -d windows
```

## Product Shape

The app is the local client layer. It owns:

- local Drift storage for your library state
- collection workflows such as add, edit, barcode, import/export, shelves, and inspectors
- media-aware presentation and collector-specific UI
- optional sync client behavior

It does not try to duplicate the Core backend's responsibilities. Canonical
metadata, provider integrations, ingest/admin logic, and image delivery policy
live in `collectarr-core`.

## Extending Library Metadata

When you add a new library kind or want richer metadata for an existing one,
the app now has a single shared metadata pipeline instead of separate per-screen
renderers.

1. Add or update the library config and field labels for the new kind.
2. Project any new canonical fields into `CatalogItem`, the Drift cache, and `LibraryWorkspaceEntry`.
3. Reuse the default shared metadata presenter, or register a kind-specific presenter in `lib/features/library/metadata/library_metadata_content.dart` when that media type needs a different fact layout.
4. Keep add/search labels aligned with the same type config so preview rows and inspector rows use the same terminology.

That keeps new library support additive: most kinds can ride the shared UI,
while exceptions only need a focused presenter registration instead of a new UI
stack.

## Add/Search Behavior

Provider search keeps the result list neutral until the user explicitly selects a
candidate. The dialog still loads direct provider previews up front, but does
so in bounded batches so large result sets do not fan out into an unbounded
burst of preview requests.

When Core exposes editions, variants, or bundle releases for a selected result,
the add flow can anchor against those references directly. Bundle releases stay
previewable before ingest so box sets, season packs, and collected editions can
be reviewed by member list instead of being treated like opaque metadata.

Provider candidate lists can also be mixed when Core enriches or falls back to a
secondary source. The app surfaces that mix with provider badges and neutral
messaging instead of claiming the requested provider fully failed when both
providers contributed results.

The generic edit dialog follows the same model after ingest: owned, tracking,
and wishlist entries can switch between media-, edition-, variant-, and
bundle-release-level anchors without dropping back to media-specific dialogs.

## Release Policy

Release publishing is manual-only. The `Release` GitHub Actions workflow uses
`workflow_dispatch`; pushing to `main` runs CI only — no auto-publish.

The first packaged rollout keeps installation manual. The in-app updater stays
hidden until the release workflow also publishes installer assets that the
desktop client can install directly.

## Related Repos

| Repo | Purpose |
|------|---------|
| `collectarr-core` | Canonical metadata catalog, providers, image delivery, admin APIs |
| `collectarr-sync` | Optional personal sync service |

## Roadmap

See [docs/implementation-plan.md](docs/implementation-plan.md) for the full roadmap.

---

## Support

If Collectarr is useful to you, you can support ongoing development on Ko-fi:

[![Support me on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/saitatter)
