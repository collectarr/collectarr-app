# Changelog

## [1.1.0](https://github.com/collectarr/collectarr-app/compare/v1.0.4...v1.1.0) (2026-07-08)

## What's Changed

### ✨ Features
- Added the collection activity page with filters and a broader timeline for collection-level actions.
- Added the folder-tree sidebar mode plus folder shelf entry support for folder-style browsing.
- Added the loans manager tab so lent items can be tracked from the app.
- Added collection calendar export to `.ics` so key dates can be shared outside the app.
- Added typed custom fields and kind-aware session history for read, watch, listen, and play flows.
- Expanded typed TV, movie, music, book, boardgame, and comic flows with dedicated inspectors, release/media handling, episode editing, and fractional volume support.
- Added admin proposal tools, stats, health checks, barcode lookup, and contract drift gating.

### 🐛 Fixes
- Stabilized cover loading and cache widths so grid and detail views stay consistent.
- Stabilized grouped workspace layout, navigation chrome, and sync connection handling.
- Fixed TV, video, and comic editor regressions, removed legacy item-season lookups, and cleared analyzer leftovers.

### ♻️ Refactors
- Aligned generic library, inspector, and edit-dialog flows with typed metadata and shared field primitives.
- Consolidated shared add-dialog, inspector, and edit-field scaffolding.
- Reworked library chrome, grouping, and tab routing through the shared shells.
- Split TV, movie, music, book, boardgame, and comic workspace paths into cleaner kind-specific builders.
- Continued kind-switch and editor-flow cleanups across the library surfaces.

### 🧰 CI & Build
- Tightened analyzer/lint follow-up and release/build housekeeping.

### 📚 Docs
- Refreshed release notes and editor guidance.

### 🧪 Tests
- Added and updated coverage for TV routes, contract drift, and editor regressions.

**Full Changelog**: https://github.com/collectarr/collectarr-app/compare/v1.0.4...v1.1.0
