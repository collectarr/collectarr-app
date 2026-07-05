# 🗺️ Collectarr App — Implementation Plan

> App owns the Flutter client, local Drift database, offline-first library UI, CSV/CLZ import-export, barcode UX, sync client UX, and user-facing collection workflows. It consumes Core metadata and optional Sync state.

> Current shipped app library kinds: `comic`, `manga`, `anime`, `book`, `game`, `boardgame`, `movie`, `tv`, `music`.

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
- Provider previews load only for the selected candidate, with neutral messaging for mixed-provider result sets
- Generic add flow supports explicit media/edition/variant/bundle-release reference selection, including bundle member preview before ingest
- Generic add dialog and workspaces for books, games, board games, movies, and music, with comic-specific add/search still owning its custom flow
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
- User-defined custom fields per media kind plus edit scope (`media` / `release`) with text values
- Custom field management in settings panel with a table-like editor, add/edit/delete, and scope/type chips
- Custom fields searchable/filterable in both comics and generic library shelves
- Custom fields shown in inspector detail panels and edit dialogs
- Multiple images per owned item with captions and sort order
- Item images shown in inspector and editable in edit dialogs
- Drift DB schema v2 with `CustomFieldDefinitionsCache`, `CustomFieldValuesCache`, `ItemImagesCache` tables
- Purchase/sell tracking fields (`soldAt`, `sellPriceCents`, `soldTo`) on owned items
- Generic edit dialogs support media-, edition-, variant-, and bundle-release-level personal anchors for owned/tracking/wishlist state
- Edit dialog footer simplified to Save-only; tab navigation uses the tab bar, close uses the title bar X button

### 🎨 UI Polish
- Distinctive library icons across the active library kinds so comics, books, games, board games, movies, and music stay visually distinct in navigation
- Animated accent theming across all UI elements (not just top/bottom bars) using `AnimatedTheme`
- Cleaner auth/login shell with fewer redundant labels and a more branded landing surface
- Platform-aware settings/tooling placement so desktop-only helpers stay off Android
- Hyperlink-driven metadata filters feed exact library filters instead of mutating the free-text search box
- Inspector/detail views surface richer personal value tracking (`cover price`, `sell price`, `profit / loss`)
- Workspace filter dialog can filter by resolved location path

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

### 🎬 Trailer Links & Physical Media Enrichment
- TrailerLink model with url, title, source, isAutomatic fields
- Trailer URLs stored as JSON in CatalogCache, projected into LibraryWorkspaceEntry
- Detail page trailer section with YouTube detection and url_launcher
- HDR formats multi-value field on OwnedItem (Drift schema, edit UI FilterChips, sync settings)
- Physical features text field on OwnedItem (edit UI, sync settings)

### 🔄 Sync & Data Integrity Improvements
- Sync freshness indicator: relative time subtitle + stale/offline warning icon on sync button
- Data-first sync: image storage moved outside DB transaction so catalog/owned data commits first
- Read-only metadata endpoints no longer require authentication (22 GET endpoints made public)
- Non-UUID item ID guards on all API call sites (seasons, volumes, bundle releases) to prevent 400/422 from synthetic TMDB-local or composite release IDs
- Friendly error messages for 401/403/connection errors during CSV import resolution

## 🎯 Active Roadmap

### 🧩 Shared Metadata Editing Contract (Admin + App)
- [ ] Continue migration of heavy custom kind editors onto shared contract primitives
	- Keep book/music/comic custom tabs on shared field primitives and trim the remaining custom adapters.
- [ ] Keep runtime drift diagnostics as a hard regression gate
	- Preserve the contract drift dashboard/tests as the client↔core key/type parity gate.

### 🧱 Library De-Generalization (final cleanup)
- [ ] Continue split of remaining generic shell decisions into explicit hooks
	- Move the remaining drilldown/sidebar/toolbar branches out of `generic/page.dart`.
- [ ] Finish the `KindWorkspaceConfig` contract for workspace rendering
	- Route available views, primary/sort/filter/folder fields, inspector sections, and add/edit capabilities through config instead of kind checks.
- [ ] Upgrade folder sidebar to support optional tree view
	- Keep current drilldown behavior, add list/tree modes, preserve expanded-node state per kind and preset, and render cumulative counts per node.
- [ ] Remove dead generic shell branches once concrete kind states own behavior.
	- Delete fallback branches after each kind-local hook lands.

### 🧩 Shared UI Shell Convergence
- [ ] Make add/edit/inspector/detail/admin dialogs share a common shell
	- Extract `LibrarySurface`, `LibraryPanelChrome`, `LibraryDialogScaffold`, and shared section/footer/empty/error states.
- [ ] Normalize panel layout across dialogs and side panels
	- Keep header, context bar, main content, optional side panel, and footer actions consistent across kinds.
- [ ] Create one panel grammar
	- Standardize title, subtitle/count, primary action, secondary menu, scrollable content, and pinned footer rules across panels.
- [ ] Add a density system
	- Support comfortable, compact, and dense modes consistently across cards, rows, inspectors, add results, comparison rows, and sidebars.
- [ ] Standardize inspector/detail/edit section ordering
	- Keep the same section order everywhere: identity, personal status, progress/ownership, format/edition/release, people, series links, images/media, notes/custom fields, source/corrections, activity/history.
- [ ] Split `LibraryAddDialog` into controller, layout, and kind adapter
	- Separate state, responsive shell, and kind-specific labels/search/preview/manual-entry groups.

### 🧭 Admin UX Consistency
- [ ] Align app-side admin proposal/editor UX with shared-field architecture
	- Keep proposal/edit flows visually distinct while sharing the same field contract.
- [ ] Keep Admin stats/dashboard wiring in parity with Core summary/image-cache contracts.
	- Keep stats/dashboard surfaces aligned with Core summary and image-cache contracts.

### 📜 Global Activity / History
- [ ] Add a global activity page
	- Reuse the existing activity aggregator without an itemId filter and add kind/event/date/source filters.
- [ ] Keep per-item activity sections intact
	- Item detail activity is already implemented; the missing piece is the collection-wide view.

### 📅 Calendar + iCalendar
- [x] Calendar page and manual ICS export
	- Local calendar aggregation and RFC 5545 export are already implemented.
- [ ] Add a live subscribable ICS feed
	- Provide a feed URL instead of only manual export, with optional kind filtering and per-kind settings.

### 🔔 Notifications
- [ ] Add local notifications
	- Start with loan due reminders, release reminders, and sync-conflict/import/proposal attention alerts.
- [ ] Define notification rules and scheduling
	- Support kind, event type, offsets, channels, and quiet hours.

### 📥 Personal List Imports
- [x] CSV/CLZ import-export
	- Existing CSV/CLZ import-export flow is already implemented.
- [x] TMDb import
	- Existing TMDb import path is already implemented.
- [ ] Add a generic importer framework for personal lists
	- Model `ImportSource`, `ImportRun`, `ImportRow`, `ImportMapping`, `ImportConflict`, and `ImportResult` once, then reuse it for third-party list imports.
- [ ] Import MAL / AniList / Trakt / Simkl / Kitsu personal lists
	- Start with MAL and AniList, then cover Trakt, Simkl, and Kitsu watched/read/rated/watchlist/progress data.

### 🚫 Lower Priority Unless Product Direction Changes
- Social/OIDC auth, collaborative lists, and media-server webhooks remain below collector-parity and metadata-contract work.
- Media-server watched sync (Plex/Jellyfin/Emby) stays low priority until the local watch-session flow and mapping layer are needed.
