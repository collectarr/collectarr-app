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
flutter run -d chrome
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
