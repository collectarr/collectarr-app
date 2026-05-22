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
- Provider results require explicit user selection; the dialog no longer auto-focuses the first candidate
- Provider previews are prefetched from direct provider data in bounded batches, with neutral messaging for mixed-provider result sets
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
- [x] Semantic Add Series vs Add Issue: browse-series callback navigates from series to issue mode
- [x] Issue/variant tree density improvements + whole-series and multi-issue selection
- [x] Real cover behavior for GCD + ComicVine variant enrichment
- [x] Generated fallback covers only when no usable cover exists
- [x] Music physical media formats (Vinyl, CD, Cassette, Digital)

### 📚 Media-Specific Forms
- [x] Books: physical formats (Hardcover/Paperback/Mass Market/eBook/Audiobook), reading tracking profile
- [x] Games: physical formats (Disc/Cartridge/Digital/Collector's Ed), game tracking profile
- [x] Movies/TV: physical format (DVD/Blu-ray/4K), season/episode UI
- [x] Music: format (CD/vinyl/cassette), listening tracking profile
- [x] Comics/Manga: physical formats, grading section (Raw/Slabbed, grading co., signed by, key comic, cover price)
- [x] Inspector: kind-specific grading details for comics/manga

### 🖥️ Platform Smoke Tests
- [x] Web: sqlite3 WASM load, Core connection, Add dialog, import/export, covers
- [x] Windows: local DB, resizable panes, keyboard shortcuts, barcode fallback
- [x] Android: camera scanner, manual fallback, connection presets, narrow layout

### 🧩 Post-MVP
- [x] QR scanning for pairing (not just QR rendering)
- [x] ComicInfo.xml export (CBZ dropped — not useful for a collection tracker)
- [x] Local image bytes for fully offline cover storage
- [x] Rich per-media dashboards and collection analytics
- [ ] Packaged release installers + app store preparation
- [ ] Location tracking (which shelf/box)
- [ ] Collection value totals
