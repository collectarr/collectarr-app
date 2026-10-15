# Changelog

## Unreleased

### 🐛 Fixes
- Music folders now default to Artist instead of the first available group (Has Back).
- “Wrap column content” wraps long list values instead of cutting them after one line.
- The details panel keeps the last selected album after returning from a tool page and otherwise shows the first album.
- Generated cover placeholders no longer split words or show “front cover” in the title.
- Album totals in the details header use hours (1:07:22), matching the Length column.
- The Played History date field no longer clips the year and month.
- Utility actions and links on Custom Fields, Find Duplicates and Statistics use the shared blue.

### 📚 Docs
- Replaced dated audit, plan and QA reports with one living [CLZ parity report](docs/clz-parity.md) and a concise architecture status.
- Removed scripts that reset or seeded the real database, and the obsolete Collectarr Sans font tooling.


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

**Full Changelog**: https://github.com/collectarr/collectarr-app/compare/v0.1.4...v0.2.0
