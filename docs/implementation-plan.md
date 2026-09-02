# 🗺️ Collectarr App — Implementation Plan

> App owns the Flutter client, local Drift database, offline-first library UI, CSV/CLZ import-export, barcode UX, sync client UX, and user-facing collection workflows. It consumes Core metadata and optional Sync state.

## Architecture Decision: Semantic Ownership Per Kind

The generic library layer is now treated as a technical shell, not as an owner
of media semantics. Intentional duplication across the nine kinds is preferred
to a central metadata facade that loses information and reconstructs
`CatalogItem` objects through compatibility bridges.

Shared code may own routing, state orchestration, persistence primitives, API
transport, layout primitives, loading/error states, and registry composition.
Kind code must own publisher, series, issue/volume/season numbering, editions,
variants, barcode/ISBN, physical format, country/language, ratings, creators,
links, publishing metadata, and hierarchy semantics.

The target also applies to local storage and workspace projections. A cache table
may store an opaque catalog envelope, and a generic workspace may carry universal
layout identity, but neither may become a denormalized semantic registry. Typed
kind codecs and capabilities are the only place where a known kind's payload is
decoded or interpreted.

The migration is incremental and must stay green per vertical slice. Do not add
new fields or forwarding getters to `LibraryMetadataItem`; do not make
`toCatalogItem()` a runtime dependency. It is temporary transport
interoperability only and is scheduled for removal.

### Current Rebaseline (2026-09-02)

The current checkout contains a large uncommitted architecture migration. It is
not commit-ready: the architecture boundary check passes, but the library does
not yet compile cleanly and the full Flutter test/format gates have not been run
successfully after the latest changes.

Completed in the current working tree:

- Edit presentation is neutral: generic grading, Comic, Game, cover-price, and
	key-specific labels/visibility flags were removed; kind presentation builders
	own their labels and tab ordering uses neutral priorities.
- `MediaEditFields`, `ReleaseEditFields`, and `edit_field_config.dart` were
	removed. Projectors, field definitions, and kind capabilities are now the
	intended source of field behavior.
- Generic hierarchy presentation no longer owns video display/grouping types,
	reading-queue visibility, index reassignment, or concrete collection labels.
	Reading queue and index reassignment are explicit kind toolbar actions.
- Detail slots were renamed to neutral roles (`identity`, `personal`,
	`progress`, `metadata`, `relations`, `links`, `media`, `notes`, `source`,
	`activity`).
- The boundary checker now rejects imports from all of `kinds/**` in generic
	library code, including `_shared`, except for explicit registry composition.
	`dart run tool/check_library_kind_boundaries.dart` reports no AST boundary
	violations; its complexity warnings remain informational debt.
- `LibraryCommonMetadata` was deleted. `LibraryMetadataItem` is flattened to
	universal identity/display fields plus typed `kindMetadata`.
- `LibraryMetadataTransportCodec` now owns catalog-envelope conversion at the
	transport boundary. Provider mappers and several metadata flows construct the
	flattened item directly.
- `CatalogCache` is now an opaque `id`/`kind`/`payloadJson`/`cachedAt` table,
	schema version 6. `CatalogCacheRepository`, workspace cache reads, and serial
	authority updates no longer reconstruct denormalized kind columns.
- Drift bindings were regenerated successfully. The generator still reported
	the malformed Book presentation declaration described in the immediate gate
	below.

Known incomplete or regressed surfaces:

- `dart analyze lib --format machine` still reports compile errors from old
	`LibraryMetadataItem` facade calls, workspace adapter references, the malformed
	Book presentation file, music mapping, fallback video formats, and test
	factories. There is also a misplaced link-builder call that must be routed to
	the edit contract or removed.
- `library_kind_metadata_values.dart` is only a temporary compatibility helper.
	It must not become a generic release/edition registry.
- `WorkspaceCommonProjection` and `WorkspaceDtoAdapter` still centralize
	semantic fields and are used by many generic cards, grouping, search, detail,
	export, and refresh paths.
- `CatalogCommonDto` and convenience getters on `CatalogItemDto` still expose a
	broad transport superset. They are compatibility bridges, not the target API.
- Shared video still contains the common semantic implementation. Anime, Movie,
	and TV presentation/release/edit ownership has not yet been fully split.
- `OwnedItemsCache` still contains Comic, video, and Game semantic columns.
	`CatalogCacheDerivedDataService` also needs to move out of repository-level
	orchestration into an explicit sync/composition boundary.
- The dynamic field registry, dynamic facet definitions, generic edit semantic
	fields, condition/grade fallback vocabulary, planned-media transition APIs,
	and several `LibraryKindRuntime` forwarding members remain.

The shipped kinds remain: `comic`, `manga`, `anime`, `book`, `game`, `boardgame`,
`movie`, `tv`, and `music`.

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
- CatalogCache is now schema v6 with an opaque catalog envelope; hierarchy values are decoded through kind-owned projections
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

### ⚡ Architecture & Collection Mutations Simplification
- Decomposed monolithic `CollectionMutations` into dedicated modular services (`mutations/`, `events/`, `runner/`, `providers/`) for owned items, wishlist, tracking, watch sessions, custom episodes, and metadata overrides
- Introduced strongly typed Domain Value Objects (`Money`, `OwnedItemId`) and backoff integration with `SyncRetryPolicy`
- Refactored kind workspace preference codecs, field registry definitions, and workspace presentation adapters across all 9 supported library kinds

## 🎯 Remaining Implementation Plan

The order below is dependency-driven. A phase is complete only when its focused
tests pass, its callers no longer depend on the retired bridge, and the relevant
architecture-negative check prevents the old design from returning.

### Phase 0 — Restore a green migration baseline (P0, current)

- [ ] Repair `kinds/book/presentation.dart`, including the missing
	`booksMetadataLabels` declaration, and rerun the Book analyzer slice.
- [ ] Resolve the remaining `dart analyze lib --format machine` errors without
	restoring semantic getters or payload factories to `LibraryMetadataItem`.
	The current error list includes detail/hero/wiring, editor, export, grouping,
	inspector, reports, workspace, serial/video, and test-factory callers.
- [ ] Replace every remaining `.payload`, `.editions`, `.releaseDate`,
	`.releaseYear`, `.trailerUrls`, `.toSyncPayload()`, and `fromCatalogItem`
	access on `LibraryMetadataItem` with either the explicit transport codec or a
	typed kind capability. Audit both `lib/` and tests, not only the current
	compiler-reported files.
- [ ] Make the release/link descriptor API consistent. Link loading belongs to
	the kind-owned edit/presentation contract that consumes it; generic code must
	not call a method that exists only on a different builder interface.
- [ ] Replace the temporary `library_kind_metadata_values.dart` helper with
	typed per-kind readers/codecs for release date/year, editions, title extension,
	trailers, and other release data. Delete the helper once all callers move.
- [ ] Keep `CatalogCacheRepository` compatible with current import callers through
	a typed transport-boundary API. Do not leave `Iterable<dynamic>` as a permanent
	runtime contract; migrate callers to `CatalogItem` or the opaque envelope.
- [ ] Resolve fallback physical formats through registry/composition data. Do not
	import `_shared/video` into generic catalog code merely to restore a constant.
- [ ] Run the focused analyzer after each repair, then require zero compile errors
	from `dart analyze lib --format machine` before starting the next phase.

### Phase 1 — Finish typed metadata and catalog transport ownership (P0)

- [ ] Define the final typed kind catalog/entry contracts for all nine kinds.
	They must cover release/edition and variant selection, creators, links,
	publisher/series/number display, title extension, and kind-specific metadata
	without introducing a cross-kind superset.
- [ ] Route generic add, edit, inspector, detail, export, comparison, report,
	series, and stats code through those capabilities/descriptors. Generic code may
	render a descriptor or invoke a callback; it may not parse a kind payload.
- [ ] Finish the comic vertical slice across provider mapper, add, edit,
	workspace, inspector, detail, export, hierarchy, entry helpers, and tests.
	Then use the same checklist for Book, Manga, Anime, Movie, TV, Music, Game,
	and Board Game, recording any intentional kind differences in their modules.
- [ ] Remove `LibraryMetadataItem` from runtime APIs after all consumers migrate.
	Keep catalog envelope conversion in `LibraryMetadataTransportCodec` only while
	transport interoperability requires it; do not add new domain behavior there.
- [ ] Reduce `CatalogItemDto`/`CatalogCommonDto` to an identity/envelope boundary.
	Remove semantic convenience getters such as publisher, barcode, physical
	format, release date/year, trailers, and editions from generic consumers.
- [ ] Make known-kind decoding go through the registered `CatalogKindCodec`.
	Retain a deliberately isolated fallback only for unknown or legacy payloads;
	do not grow a central known-kind switch.
- [ ] Verify provider preview and add workflows accept normalized envelopes and
	delegate semantic decoding to the selected kind mapper. Remove any remaining
	generic construction of publishing, music, video, game, series, or creator
	maps.

### Phase 2 — Remove workspace semantic authority (P0)

- [ ] Delete `WorkspaceCommonProjection` and `WorkspaceDtoAdapter`.
- [ ] Give each kind workspace DTO direct, typed fields or typed kind metadata.
	Keep `LibraryWorkspaceDto` limited to universal structural identity needed for
	layout, selection, title, and cover rendering.
- [ ] Migrate generic adapter consumers in cards, flow tiles/carousels, grouping,
	search, page/detail actions, page-number navigation, collection actions,
	entry helpers, hero/export/sharing/value/stats/refresh, and kind filters.
- [ ] Add a kind-owned search/filter projection contract so publisher,
	item/issue/volume number, series, release year, and equivalent fields remain
	searchable without restoring common workspace fields. Preserve the behavior
	currently lost when SQL cache filtering was removed; title-only fallback is
	not the finished behavior.
- [ ] Keep grouping, sorting, and column orchestration generic, but make value
	extraction call typed kind field descriptors rather than casting a common DTO.
- [ ] Add workspace projection tests for title, cover, scope, release selection,
	search, grouping, and missing/malformed kind payloads for every kind.

### Phase 3 — Split Anime, Movie, and TV video ownership (P0/P1)

- [ ] Move Anime presentation and release fields into Anime-owned builders and
	contracts, including anime format, broadcast, studios, episodes, and physical
	release details.
- [ ] Move Movie video/release fields into Movie-owned builders and contracts,
	including runtime, technical format, HDR/audio, distributor, region, and
	trailer presentation.
- [ ] Move TV season/episode/broadcast and box-set release behavior into TV-owned
	builders and contracts.
- [ ] Split shared video edit support, edit tabs, release-source readers, and
	inspector/detail sections where they decide semantic behavior. Duplication is
	acceptable; retain only technical primitives, transport models, and reusable
	widgets under `_shared/video`.
- [ ] Remove shared configurable semantic label bags and video entry-type lists
	once each kind declares its own behavior. Add focused Anime/Movie/TV tests for
	release decoding, edit initialization, trailers, drilldown, and hierarchy.

### Phase 4 — Type the runtime, fields, facets, and edit contracts (P1)

- [ ] Reduce `LibraryKindRuntime` forwarding members to typed capability access.
	Keep registry/composition concerns at the registry boundary, not in generic
	semantic helpers.
- [ ] Reduce `LibraryTypeConfig` to immutable identity/presentation/composition
	data. Remove title-as-series flags and other behavior duplicated by kind
	capabilities.
- [ ] Replace the public `LibraryFieldRegistry<dynamic, LibraryWorkspaceDto>`
	contract with erased runtime descriptors and typed IDs for field, group, sort,
	and column operations. Decode legacy persisted strings only at the boundary.
- [ ] Type facet module definitions and mode identities. Remove generic dynamic
	definition collections and semantic string-mode branching.
- [ ] Move condition and grade vocabulary ownership into each kind. Remove the
	`kGeneralConditions` fallback from capability defaults and AddDialog/inspector
	paths; unsupported kinds must expose no vocabulary rather than inherit a
	misleading one.
- [ ] Finish generic edit-shell cleanup: `CommonMetadataDraft` and the shell own
	lifecycle, layout, personal state, custom fields, images, validation, and save;
	kind drafts own number, publisher, series, release, format, grading, episode,
	volume, and other semantic state.
- [ ] Move concrete owned-detail transfer reads/writes behind typed kind transfer
	definitions. Unsupported fields must be unavailable or fail explicitly and
	must never replace an owned-details subtype.
- [ ] Remove planned-media transition APIs and numeric subgroup assumptions after
	their callers use typed capability IDs and explicit hierarchy state.

### Phase 5 — Finish opaque persistence and cache behavior (P1)

- [ ] Keep `CatalogCache` opaque and add round-trip tests for every kind,
	malformed/legacy payloads, unknown kinds, title lookup, barcode lookup, and
	title-plus-issue lookup through kind-owned search capabilities.
- [ ] Move `CatalogCacheDerivedDataService` out of repository-level behavior into
	sync/orchestration or an explicit registry composition boundary. The cache
	repository should only persist and retrieve opaque envelopes.
- [ ] Remove semantic columns from `OwnedItemsCache`, either by making kind-owned
	details opaque JSON or by introducing per-kind persistence codecs/tables. The
	migration must preserve Comic grading/key/cover-price data, video technical
	data, and Game completeness/value data.
- [ ] Update Drift schema/migrations and generated bindings only after the final
	storage shape is agreed. Add migration tests for existing local databases and
	sync payload round trips.
- [ ] Ensure local workspace filtering/search uses kind-owned extraction rather
	than reintroducing SQL columns for publisher, series, item number, or format.

### Phase 6 — Converge UI shells after ownership is stable (P1/P2)

- [ ] Finish the shared shell grammar for add, edit, inspector, detail, and admin:
	header/context bar, main content, optional side panel, pinned footer, loading,
	empty, and error states.
- [x] Keep the `LibraryAddDialog` split into controller, layout, and kind adapter;
	the remaining `part of` pane/extensions can be removed later if they obstruct
	testing or ownership, but they are not a migration blocker.
- [ ] Add centralized comfortable/compact/dense metrics and apply them to cards,
	rows, inspectors, add results, comparison rows, and sidebars.
- [ ] Keep neutral detail section roles and make kind-owned sections populate them.
	Validate the ordering and responsive behavior on desktop and narrow layouts.
- [ ] Complete the admin proposal/editor alignment without reintroducing a
	semantic shared-field contract. Preserve proposal-specific provenance and
	correction controls.

### Phase 7 — Provider, sync, and importer convergence (P1/P2)

- [ ] Make `ProviderConnector` the active provider registry composition root;
	retain legacy metadata adapters only behind connector capabilities during the
	transition.
- [ ] Wire `ExternalStateEngine` to provider accounts, links, local tracking,
	sync policy persistence, mutation origin, sync runs, three-way conflicts, and
	echo protection. Use AniList as the first complete vertical slice.
- [ ] Integrate the importer framework with `ProviderPersonalEntry` and
	`ExternalStateEngine`; replace remaining `ImportRow`/`ProviderImportId` runtime
	paths with typed entries and `MutationOrigin.import`.
- [ ] Add personal-list imports in this order: MAL and AniList, then Trakt, Simkl,
	and Kitsu, covering watched/read/rated/watchlist/progress data.
- [ ] Keep contract drift diagnostics as a hard client/Core regression gate and
	synchronize snapshots only when the Core contract actually changes.

### Phase 8 — Product completeness backlog (P2, independent of the migration)

- [ ] Add optional cover-art recognition for comics after measuring barcode and
	provider-search quality; keep local-first OCR/reranking as the default.
- [ ] Add optional pricing integrations for comics (CovrPrice) and games
	(PriceCharting), with cached values, source timestamps, and clear provenance.
- [ ] Complete comic collector features: key issue markers, grading-company
	fields/slab presentation, and missing-issue/run completeness views where not
	already covered by the current migration.
- [ ] Add book reader/person tracking, richer personal ratings, and audiobook
	details where the domain contract supports them.
- [ ] Add movie random picker and custom episode data where still absent.
- [ ] Surface Music track/disc listings and add vinyl pressing/condition details.
- [ ] Add Game platform/region/edition depth and console/hardware cataloging only
	if it remains within product scope.
- [ ] Add collection value totals and valuation history as local/personal data,
	independent of Core catalog semantics.
- [ ] Add a live subscribable ICS feed with optional kind filtering and settings.
- [ ] Add local notifications for loans, releases, sync conflicts, imports, and
	proposals, with event rules, offsets, channels, and quiet hours.
- [ ] Keep social/OIDC, collaborative lists, media-server integrations, and
	webhooks below collector parity unless product direction changes.

### Execution checkpoints

1. Phase 0 must end with a clean library analyzer and a focused test pass.
2. Phases 1–3 must end with no generic metadata/workspace/video semantic
	 authority and no `LibraryMetadataItem` runtime facade dependency.
3. Phases 4–5 must end with typed runtime operations and no semantic god-schema
	 in catalog or owned-item persistence.
4. Phase 6 must end with consistent responsive shells and density behavior.
5. Phase 7 is complete only when one provider has a full pull/push/conflict
	 vertical slice and importer entries use the same state engine.
6. Phase 8 can ship independently, but every feature must classify fields as
	 media/work, release/edition, copy/personal, derived/session, or provenance.

### Operational follow-ups

- [ ] Validate global Activity and bring collection-wide filters to parity with
  per-item activity/history sections.
- [x] Keep calendar aggregation and manual RFC 5545 export.
- [ ] Add a live subscribable ICS feed with optional kind filters and per-kind
  settings.
- [ ] Add local notifications for loan due dates, releases, sync conflicts,
  imports, and proposals; define offsets, channels, and quiet hours.
- [x] Keep the existing CSV/CLZ, TMDb, and generic personal-list importer
  foundations.
- [ ] Finish importer integration with `ProviderPersonalEntry` and
  `ExternalStateEngine`, then implement MAL/AniList followed by Trakt, Simkl,
  and Kitsu watched/read/rated/watchlist/progress imports.
- [ ] Keep admin proposal/editor UX visually distinct while aligning its typed
  field contract and Core summary/image-cache dashboard contracts.
- [ ] Keep social/OIDC, collaborative lists, media-server integrations, and
  webhooks below collector parity unless product direction changes.

### Validation gate

Run the focused check for the touched phase first. The migration is not ready to
land while any compile error remains, even if the architecture checker passes.

```powershell
# Required after the current repair phase
dart format --output=none --set-exit-if-changed .
dart analyze lib --format machine

# Required before declaring the migration complete
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-warnings --fatal-infos
flutter test
dart run tool/check_library_kind_boundaries.dart
```

Additional gates:

- Run Drift migration and round-trip tests after any schema change.
- Run provider contract, metadata transport, workspace projection, and
	kind-specific vertical tests for every changed kind.
- Run Core `pytest` and repository checks whenever app changes depend on Core
	DTOs, provider transport, or sync persistence contracts.
- Add architecture-negative coverage for concrete kind imports, semantic kind
	switches, broad metadata getters, dynamic field/facet registries, common
	workspace adapters, semantic persistence columns, and central known-kind codec
	dispatch before removing the corresponding migration phase.
- Update `docs/outside-kinds-generic-audit.md`, `docs/kind-field-ownership.md`,
	and this plan after each ownership boundary is completed so the documentation
	describes the checked-out architecture rather than the intended one.
