<p align="center">
  <img src="docs/assets/collectarr-icon.svg" alt="Collectarr app icon" width="104" height="104">
</p>

# 📱 Collectarr App

> Flutter client for Collectarr — your personal collection manager across web, Windows, and Android.

The app owns the local Drift database, offline-first library UI, import/export,
barcode UX, sync client UX, and user-facing collection workflows. The canonical
metadata catalog lives in `collectarr/collectarr-core`. Optional multi-device
personal sync lives in `collectarr/collectarr-sync`.

## ✨ Features

- 🗄️ **Offline-first local library** — personal collection + wishlist stored in local Drift DB
- 📦 **Catalog snapshots** — cached Core data so saved items stay useful offline
- 🎨 **CLZ-style workspaces** — cover/grid/table views, filters, series sidebars, inspectors, column presets, bulk editing
- 🔍 **Smart add/search** — structured series, issue, barcode, candidate tree, and whole-series handling
- 📖 **Manga volumes** — volume/chapter data from Core providers (MangaDex)
- � **TV seasons** — season/episode data for TV and anime
- 📥 **CSV import/export** — Collectarr/CLZ-friendly with media-aware headers + custom field columns
- 📷 **Barcode scanning** — camera scanner where available + manual fallback everywhere
- 🔄 **Sync support** — optional multi-device sync via `collectarr-sync` with conflict review and retry queue
- 🛠️ **Admin panel** — user management, image cache controls, provider health (admin-only)
- 📊 **Sync history** — timestamped log with push/pull/reject counts
- 🏷️ **Custom fields** — user-defined fields per media type with search/filter and CSV support
- 🖼️ **Multiple images per item** — local item photos with captions and sort order
- 🎨 **Animated accent theming** — smooth color transitions across all UI elements when switching libraries

## 🚀 Quick Start

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

### 🌐 Run on Web

```powershell
flutter run -d chrome `
  --dart-define=COLLECTARR_API_BASE_URL=http://localhost:8010 `
  --dart-define=COLLECTARR_SYNC_BASE_URL=http://localhost:8020 `
  --dart-define=COLLECTARR_SYNC_KEY=collectarr-sync-dev-key
```

The web build uses Drift with sqlite3 WASM and stores the local database in
IndexedDB.

### 🖥️ Run on Windows

```powershell
flutter run -d windows
```

## 📦 Release Policy

Release publishing is manual-only. The `Release` GitHub Actions workflow uses
`workflow_dispatch`; pushing to `main` runs CI only — no auto-publish.

## 🗂️ Related Repos

| Repo | Purpose |
|------|---------|
| `collectarr/collectarr-core` | 🎯 Canonical metadata catalog, providers, image delivery, admin APIs |
| `collectarr/collectarr-sync` | 🔄 Optional personal sync service |

## 🗺️ Roadmap

See [docs/implementation-plan.md](docs/implementation-plan.md) for the full roadmap.
