# 🗺️ Collectarr App — Implementation Plan

> App owns the Flutter client, local Drift database, offline-first library UI, CSV/CLZ import-export, barcode UX, sync client UX, and user-facing collection workflows. It consumes Core metadata and optional Sync state.

> Current shipped app library kinds: `comic`, `book`, `game`, `boardgame`, `movie`, `music`. Older `manga` / `anime` / `tv` references below are historical planning context unless they are called out explicitly as future work.

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
- User-defined custom fields per media type (text values, scoped to media kind)
- Custom field management in settings panel with add/edit/delete
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

## 🎯 Current Priorities

### 🧱 Library De-Generalization / Kind Ownership
- [x] Route library home through concrete kind page entrypoints in `kinds/*/page.dart`
- [x] Rename the old shared shell surface to `GenericLibraryPage` so known kinds no longer expose `LibraryPage` directly
- [x] Move presentation builders into kind-local files
- [x] Move workspace/release entry builders into kind-local files
- [x] Reduce `kinds/shared/workspace_presentation_support.dart` so it no longer owns workspace/release factory wiring
- [x] Move simple bucket-label builders into `book`, `game`, `boardgame`, `music`, and generic presentation files
- [x] Make `BookLibraryPageState` the first concrete kind state and move the drilldown decision into that local state
- [x] Fork concrete page-state ownership for `game`, `boardgame`, `music`, `movie`, and `comic`
- [x] Continue exposing small overridable hooks from `GenericLibraryPageState` and move the corresponding behavior into kind-local states one decision at a time
- [x] Decide whether `movie` keeps the shared video drilldown behavior as a reusable base hook or gets its own explicit local implementation
- [x] Move any remaining kind-specific toolbar/sidebar/detail-shell decisions out of `generic/page.dart` into `kinds/*/page.dart`
  - Last hardcoded `CatalogMediaKind.comic` check in `workspace.dart` replaced with `presentation.usesCompactTableLayout` config flag
  - Remaining `widget.type.*` reads in shell are legitimate config lookups, not kind branches
- [x] Shrink `GenericLibraryPage` to a thin fallback shell plus shared utilities instead of the primary behavior owner for known kinds
  - Shell defaults are now inert (false/null); all behavioral hooks are explicitly opted-in by kind-local states
  - Video drilldown logic is shared via `VideoDrilldownLibraryPageState` base, not shell decisions
- [x] Re-evaluate `kinds/shared/workspace_presentation_support.dart` after movie/comic migration; keep only helpers that are still truly shared after the shell split
  - File has 2 consumers (movie, comic presentations) — correctly scoped as a shared bucket-label utility
- [x] Add focused page-state coverage for kind-local hook overrides so further shell extraction stays safe

Architecture rule for this track: prefer kind-local ownership and explicit code over additional generic helper layers, even when that introduces controlled duplication.

### ⚙️ Provider Workflow / Core API Efficiency
- [x] Stop automatic provider search after every successful core search; only fall back to provider search on Core misses
- [x] Replace add-dialog preview fan-out with selection-only preview loading
- [x] Add short-lived Core-side preview caching keyed by `(provider, provider_item_id)`
- [x] Reuse hydrated preview data for ingest so preview → ingest does not repeat full upstream fetch/normalize work
- [x] Keep provider image mirroring off the synchronous search hot path where possible

### 📚 CLZ Parity Gaps That Still Matter
- [x] Hyperlink filtering from creators/characters/publishers/series facts into live library filters
- [x] Finish real location hierarchy productization: structured location assignment/filtering, dedicated management, first-class grouping, and synced location definitions now exist
- [x] Personal value tracking now extends beyond inspector/detail into sold summaries plus collection-level buy/sell drill-downs in stats
- [x] Key-issue / key-release markers, richer slab / grading-company details, and collector-facing notes are now surfaced in workspace badges/cards/detail views
- [x] Run-completeness tools: stats now surface missing comic issues, missing volumes, and missing seasons in dedicated gap cards
- [x] Richer physical-media presentation for music, movies/TV, and games using fields already available from provider previews
- [x] Bundle-aware add/edit flows now treat collected editions, season packs, and other provider bundle releases as first-class references instead of media-only fallbacks
- [x] Ship an app-local cover-photo recognition / scan-to-identify prototype for comics
	- Local flow now covers photo import, review/crop/rotate, extracted-text preview, safe fallback into normal search, and local reranking of search/provider candidates.
	- OCR is local-first: Android/iOS use on-device ML Kit where supported, while unsupported platforms fall back to reviewed text without sending images to the server.
	- Low-confidence results still degrade to ordinary search seeded by extracted hints; the flow never auto-ingests from a cover scan.
- [ ] Decide whether any Core-side cover-photo ranking service is still needed after the local-first App prototype
	- Measure accuracy and latency on real mobile devices before moving more responsibility into Core.
	- Validate the iOS path on macOS/Xcode hardware; current Windows-side validation only covers Android build success plus app/widget tests.
	- Only introduce server-side candidate ranking or image hosting if local OCR + reranking proves insufficient.

Current app-side parity work is largely complete; the main remaining app architecture work is the library de-generalization track above, plus hardening the local scan-to-identify flow on real mobile devices and deciding whether Core needs any photo-ranking role at all.

### 🎨 CLZ-Style UI Overhaul (v0.1.0-alpha.1)
- [x] Add dialog: live autocomplete from catalog, browse tab merged into search
- [x] Add dialog: CLZ-style edition picker with format icons replacing dropdowns
- [x] Cover tiles: compact grid with format badge + year row below titles
- [x] Inspector panel polish: title → publisher (year) → format badges → barcode → genres → synopsis → status chips
- [x] Inspector hover animation enabled
- [x] Sidebar: categorized group-by dropdown (Main, Edition, Cast & Crew, Personal)
- [x] Expanded group modes for movie libraries using video-oriented facets such as year, series, studio, genre, country, language, format, creator, location, title, and ownership
- [x] Grid spacing tightened (10px → 6px)
- [x] Schema version reset to v1 for clean alpha baseline

### 🔴 CLZ Web Parity — Critical UX Gaps
- [x] **Toolbar search** — Always-visible search input in workspace toolbar to filter current library
- [x] **Sorting system + saved presets** — Multi-field sort (e.g. Title ASC → Year DESC → Series ASC) with named favorites
- [x] **Collection status filter** — Dropdown filter: All / In Collection / For Sale / Wish List / On Order / Sold / Not in Collection
- [x] **A-Z alphabet bar** — Quick letter buttons across top for initial-letter filtering, greyed for unused letters
- [x] **Multiple view types** — Add List view and Horizontal Cards alongside existing cover grid
- [x] **Multi-select & batch actions** — Checkbox items → Edit / Remove / Export / Duplicate / Loan / Transfer
- [x] **Panel layout options** — User toggles inspector position: Horizontal Split / Vertical Split / No Details
- [x] **Resizable panels** — Drag handles on sidebar and inspector with remembered widths

### 🟡 CLZ Web Parity — Tools & Features
- [x] **Sidebar favorites** — Pin frequently-used group modes to top of dropdown
- [x] **Sidebar search** — Text input to filter sidebar bucket names
- [x] **Sidebar sort toggle** — Switch between alphabetical and by-count ordering
- [x] **Statistics page** — Charts by genre, year, watch counts, total runtime, value totals
- [x] **Find Duplicates** — Detect duplicates by title, barcode, title+format
- [x] **Loan Manager** — Track loaned items with due dates and return tracking
- [x] **Print to PDF** — Configurable PDF export with columns, covers, sorting
- [x] **Pick List management** — Edit/merge/remove pick list values (genres, formats, etc.)

### 🟢 CLZ Web Parity — Polish
- [x] **Scope pill** — When filtering by person/value, show a pill badge with "× clear"
- [x] **Transfer Field Data** — Bulk move/copy data between fields across items, with conflict resolution (skip/overwrite/append)
- [x] ~~**Multiple collections per library**~~ — Won't do: redundant with smart lists, user folders, status filters, and multi-user support
- [x] **Shelf view** — 3D shelf rendering with visual skin options
- [x] **Themes/skins** — Dark and Light mode with palette-based ThemeExtension toggle in Settings
- [x] **Watch/Read/Play history** — Full consumption tracking: dates, location, count
- [x] **Value tracking** — Purchase price, current value, currency totals, charts
- [x] **Item count display** — "42 movies" always visible in toolbar

### 🧭 Location Hierarchy Follow-up
- [x] Owned-item sync payload now includes `location_id`
- [x] Inspector assignment flow supports picking and clearing a hierarchical location without accidental clears on cancel
- [x] Workspace filtering can target resolved location paths
- [x] Add a dedicated location management surface for rename / delete / reparent / description editing
- [x] Let users assign locations in add flow, edit dialog, and bulk edit without falling back to the old free-text location entry
- [x] Introduce a first-class location group mode / sidebar bucket instead of reusing the old free-text location column path
- [x] Location definitions sync as first-class personal metadata alongside `location_id` assignments

### 🧭 Yamtrack-Inspired Gaps Worth Evaluating
- [x] Direct imports from tracker ecosystems (Trakt, Simkl, MyAnimeList, AniList, Kitsu) where they reduce manual collection entry
	- TMDB import landed first (CSV/JSON file import with batch hydration via Core). Settings page shows all import sources in a compact 2-column grid; TMDB is functional, others show "Coming soon".
	- Prioritize import-only flows before any bidirectional sync; App mostly needs credential entry, import previews, and duplicate-resolution UX.
	- Keep provider/source adapters modular so additional import-only sources can land without rebuilding the workflow surface.
- [x] Per-item tracking history / activity timeline
	- Activity timeline section on detail page aggregates events from owned items, tracking entries, watch sessions, wishlist, and loans into a chronological rail view.
	- 11 event kinds: added, removed, wishlisted, purchased, started, finished, sold, loaned, returned, watched, rated.
- [x] Saved lists / shortlists beyond owned + wishlist
	- Smart lists (saved filter/sort presets) with full CRUD via toolbar menu.
	- User folders (manual shortlists) with folder management dialog, folder assignment from detail page, and toolbar access.
	- Folders support create, rename, delete, and per-item add/remove membership.
- [x] Calendar and notification surfaces only if they clearly improve release / pull-list workflows
	- Calendar page added as a top-level navigation tab showing release dates, loan due/return dates, purchase dates, started/finished dates, and watch sessions.
	- Month grid view with day selection and event list. Events aggregated from existing collection data.

### 🚫 Lower Priority Unless Product Direction Changes
- [ ] Social/OIDC auth, collaborative lists, and media-server webhooks remain below collector-parity work for now

### 🧩 Release / Ops
- [ ] Packaged release installers + app store preparation
	- Produce signed desktop installers first (Windows at minimum), then document update/distribution strategy before spending time on store-specific packaging.
	- Keep release work aligned with settings/bootstrap polish so first-run connection, sync pairing, and local DB migration behavior are installer-safe.

## Library Refactor Next Slice Checklist

This is the concrete backlog for the current `lib/features/library/**`
ownership pass.

1. [x] Move one more behavior hook from `GenericLibraryPageState` into `BookLibraryPageState`.
2. [x] Create matching concrete state classes for `game`, `boardgame`, `music`, `movie`, and `comic` pages.
3. Split the remaining shell decisions into explicit hooks: workspace override, detail/drilldown routing, sidebar scope behavior, and any kind-specific toolbar actions.
4. [x] Decide whether movie/video drilldown stays as a shared reusable behavior or moves fully into `movie/page.dart`.
5. Remove any generic shell branches that become dead once a kind owns the behavior locally.
6. Re-check `kinds/shared/workspace_presentation_support.dart` and keep only helpers still used by multiple concrete kinds after the page-state split.
7. [x] Add or extend focused widget tests around kind-page dispatch and state-hook behavior each time a new hook moves.
8. When enough hooks have moved, split `generic/page.dart` further so the fallback shell is assembled from smaller shared utilities instead of one monolithic state class.
