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

## 🎯 Current Priorities

### ⚙️ Provider Workflow / Core API Efficiency
- [ ] Stop automatic provider search after every successful core search; make it demand-driven or confidence-based
- [ ] Replace add-dialog preview fan-out with selection-only preview loading or a real batch preview endpoint
- [ ] Add short-lived Core-side preview caching keyed by `(provider, provider_item_id)`
- [ ] Reuse hydrated preview data for ingest so preview → ingest does not repeat full upstream fetch/normalize work
- [ ] Keep provider image mirroring off the synchronous search hot path where possible

### 📚 CLZ Parity Gaps That Still Matter
- [ ] Hyperlink filtering from creators/characters/publishers/series facts into live library filters
- [ ] Real location tracking model (room / shelf / box / bin), not just a single `storageBox` field
- [ ] Collection value totals and per-library value summaries from owned-item purchase/current values
- [ ] Key-issue / key-release markers, richer slab / grading-company details, and collector-facing variant notes
- [ ] Run-completeness tools: missing issues for comics, missing volumes/seasons where the data model supports it
- [ ] Richer physical-media presentation for music, movies/TV, and games using fields already available from provider previews
- [ ] Investigate optional cover-photo recognition / scan-to-identify for comics as a later Core capability

### 🧭 Yamtrack-Inspired Gaps Worth Evaluating
- [ ] Direct imports from tracker ecosystems (Trakt, Simkl, MyAnimeList, AniList, Kitsu) where they reduce manual collection entry
- [ ] Per-item tracking history / activity timeline
- [ ] Saved lists / shortlists beyond owned + wishlist
- [ ] Calendar and notification surfaces only if they clearly improve release / pull-list workflows

### 🚫 Lower Priority Unless Product Direction Changes
- [ ] Social/OIDC auth, collaborative lists, and media-server webhooks remain below collector-parity work for now

### 🧩 Release / Ops
- [ ] Packaged release installers + app store preparation
