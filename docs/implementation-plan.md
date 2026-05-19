# 🗺️ Collectarr App — Implementation Plan

> App owns the Flutter client, local Drift database, offline-first library UI, CSV/CLZ import-export, barcode UX, sync client UX, and user-facing collection workflows. It consumes Core metadata and optional Sync state.

## ✅ Done

### 🏗️ Infrastructure
- Split from monorepo into `collectarr/collectarr-app`
- CI runs Flutter analyze/test
- Local Drift DB stores catalog snapshots, owned items, wishlists, sync queue, and user preferences

### 🎨 Library Shell
- CLZ-style workspaces with media library top nav, accent colors, resizable panes
- View controls: table/grid/card modes, sidebars, inspectors
- Column presets, bulk editing, stats chips, quick views
- Reduced-motion support for transitions and animated gradients

### 🔍 Add / Search
- Comics-first add/search: series/issue/barcode/pull-list modes, multi-select, keyboard shortcuts
- Structured provider search context (`series`, `issue_number`, `year`) sent to Core
- Provider candidates consume Core's typed comic identity fields (`candidate_type`, `series_title`, `variant_name`)
- Generic add dialog and workspaces for manga, anime, books, games, board games, movies, TV, music
- Queue Ingest button hidden for non-admin users

### 🛠️ Admin Panel
- User management panel with role editing (viewer/editor/admin)
- Image cache panel: stats, per-provider breakdown, refresh + purge with confirmation
- Admin entry point only visible for admin-role users

### 🔄 Sync & Settings
- Sync pairing, conflict review, retry queue visibility
- Settings grouped tabs: auto-save, connection, account/admin visibility, nav preferences
- Sync history log with timestamps, push/pull/reject counts, success/error icons

### 📥 Import / Export
- CSV/CLZ import-export wizard with media-aware headers, edition title, physical format, barcode matching
- Custom field columns (`cf_*`) in CSV export/import — definitions auto-matched on import

### 🏷️ Custom Fields & Item Images
- User-defined custom fields per media type (text values, scoped to media kind)
- Custom field management in settings panel with add/edit/delete
- Custom fields searchable/filterable in both comics and generic library shelves
- Custom fields shown in inspector detail panels and edit dialogs
- Multiple images per owned item with captions and sort order
- Item images shown in inspector and editable in edit dialogs
- Drift DB schema v2 with `CustomFieldDefinitionsCache`, `CustomFieldValuesCache`, `ItemImagesCache` tables
- Purchase/sell tracking fields (`soldAt`, `sellPriceCents`, `soldTo`) on owned items

### 🎨 UI Polish
- Distinctive library icons: comics (`style`), anime (`smart_display`), to avoid confusion with books (`menu_book_outlined`)
- Animated accent theming across all UI elements (not just top/bottom bars) using `AnimatedTheme`

### 🌳 Hierarchical Shelf Display
- Hierarchy fields added to data model: `seriesId`, `seriesTitle`, `volumeName`, `volumeNumber`, `volumeStartYear`, `seasonNumber`, `episodeNumber`
- CatalogCache DB schema v4 migration with hierarchy columns
- Series grouping uses `seriesTitle` with `title` fallback across generic and comics shelf views
- Two-level grouped grid: series → volume/season sub-groups (auto-detected from data)
- Sub-group headers with collapsible sections, numeric sorting for seasons/volumes
- Inspector metadata section shows series, volume, season, episode when available

### ✅ Generic Library Bulk Actions
- Multi-select mode with toggle per item (checklist icon in toolbar)
- Bulk action menu: edit, move to owned, move to wishlist, remove selected
- Bulk edit dialog with tracking status and star rating fields
- Selection state management with auto-enable/disable

## 🔜 Next Up

### 🎯 Comics MVP Polish
- [ ] Semantic Add Series vs Add Issue: series tree for full runs vs flat issue list
- [ ] Issue/variant tree density improvements + whole-series and multi-issue selection
- [ ] Real cover behavior for GCD + ComicVine variant enrichment
- [ ] Generated fallback covers only when no usable cover exists

### 📚 Media-Specific Forms
- [ ] Books: ISBN/barcode fields, reading progress, edition data
- [ ] Games: platform/edition/condition, region variants
- [ ] Movies/TV: physical format (DVD/Blu-ray/4K), season/episode UI
- [ ] Music: format (CD/vinyl/cassette), track listing display
- [ ] Manga/Anime: publisher, volume/chapter UI polish, season tracking

### 🖥️ Platform Smoke Tests
- [ ] Web: sqlite3 WASM load, Core connection, Add dialog, import/export, covers
- [ ] Windows: local DB, resizable panes, keyboard shortcuts, barcode fallback
- [ ] Android: camera scanner, manual fallback, connection presets, narrow layout

### 🧩 Post-MVP
- [ ] QR scanning for pairing (not just QR rendering)
- [ ] ComicInfo.xml/CBZ import/export
- [ ] Local image bytes for fully offline cover storage
- [ ] Rich per-media dashboards and collection analytics
- [ ] Packaged release installers + app store preparation
- [ ] Location tracking (which shelf/box)
- [ ] Collection value totals
