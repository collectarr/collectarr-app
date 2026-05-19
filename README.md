<p align="center">
  <img src="docs/assets/collectarr-icon.svg" alt="Collectarr app icon" width="104" height="104">
</p>

# Collectarr App

Flutter client for Collectarr across web, Windows desktop, and Android.

The app owns the local Drift database, offline-first library UI, import/export,
barcode UX, sync client UX, and user-facing collection workflows. The canonical
metadata catalog lives in `collectarr/collectarr-core`. Optional multi-device
personal sync lives in `collectarr/collectarr-sync`.

## What It Does

- Runs a local-first personal collection database with owned and wishlist state.
- Caches Core catalog snapshots so saved items remain useful offline.
- Provides CLZ-style library workspaces with cover/grid/table views, filters,
  series sidebars, inspectors, column presets, and bulk editing.
- Supports comics-first add/search flows with structured series, issue,
  barcode, candidate tree, and whole-series provider candidate handling.
- Shows manga volume/chapter data from Core providers such as MangaDex.
- Imports and exports Collectarr/CLZ-friendly CSV data.
- Supports barcode scanning where available and manual barcode fallback
  everywhere else.
- Pairs with `collectarr-sync` for optional personal multi-device sync,
  conflict review, retry queue visibility, and backup guidance.

## Development

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

Run on web:

```powershell
flutter run -d chrome `
  --dart-define=COLLECTARR_API_BASE_URL=http://localhost:8010 `
  --dart-define=COLLECTARR_SYNC_BASE_URL=http://localhost:8020 `
  --dart-define=COLLECTARR_SYNC_KEY=collectarr-sync-dev-key
```

The web build uses Drift with sqlite3 WASM and stores the local database in
IndexedDB. The canonical catalog cache can be rebuilt from the metadata API; old
browser-local sql.js data is not migrated when switching to the WASM database.

Run on Windows:

```powershell
flutter run -d windows
```

## Release Policy

Release publishing is manual-only. The `Release` GitHub Actions workflow uses
`workflow_dispatch`; pushing to `main` should run CI, not publish a GitHub
Release or tag. Publish only after explicitly running the release workflow and
reviewing the generated version and notes.

## Repository Boundary

This repository owns the Flutter UI, local catalog snapshots,
owned/wishlist/personal collection data, CSV/CLZ import-export, barcode
scanning/manual fallback, sync pairing, conflict review, and local retry queue.

Related repositories:

- `collectarr/collectarr-core`: canonical metadata catalog, providers, image
  delivery, admin APIs, and Core Admin Console
- `collectarr/collectarr-sync`: optional personal sync service

## Current Focus

See [docs/implementation-plan.md](docs/implementation-plan.md) for the active
App roadmap.

Near-term App work:

- keep generic Add flows aligned with Comics while consuming Core provider
  routing instead of exposing provider choice to users
- improve comics add/search UX: real series candidates, issue/variant trees,
  multi-select, keyboard navigation, metadata previews, and cover fallbacks
- deepen media-aware edit/import forms for books, games, movies, TV, anime,
  manga, board games, and music
- polish volume/chapter UI for manga and season/episode UI for video libraries
- polish sync UX: pairing, conflict diff/actions, retry queue visibility, and
  backup/restore guidance
- smoke test web, Windows, and Android barcode/fallback flows before MVP
