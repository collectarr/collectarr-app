# Collectarr App

Flutter client for Collectarr across web, Windows desktop, and Android.

The app owns the local Drift database, offline-first library UI, import/export,
barcode UX, sync client UX, and user-facing collection workflows.

The canonical metadata catalog lives in `collectarr/collectarr-core`. Optional
multi-device personal sync lives in `collectarr/collectarr-sync`.

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

## Repository Boundary

This repository owns:

- Flutter UI
- local catalog snapshots
- owned/wishlist/personal collection data
- CSV/CLZ import-export
- barcode scanning/manual fallback
- sync pairing, conflict review, and local retry queue

Related repositories:

- `collectarr/collectarr-core`: canonical metadata catalog, providers, image
  delivery, admin APIs, and Core Admin Console
- `collectarr/collectarr-sync`: optional personal sync service

## Current Focus

See [docs/implementation-plan.md](docs/implementation-plan.md) for the active
App roadmap.

Near-term App work:

- finish CLZ-style consistency across all libraries: toolbar, sidebars, empty
  states, inspectors, add dialogs, settings, shelf, and accent behavior
- keep generic Add flows aligned with Comics while consuming Core provider
  routing instead of exposing provider choice to users
- improve comics add/search UX: series vs issue modes, issue/variant tree,
  multi-select, keyboard navigation, compact metadata previews, and real cover
  fallbacks
- deepen media-aware edit/import forms for books, games, movies, TV, anime,
  manga, board games, and music
- polish sync UX: pairing, conflict diff/actions, retry queue visibility, and
  backup/restore guidance
- smoke test web, Windows, and Android barcode/fallback flows before MVP
