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

### Current Checkpoint (2026-09-03)

The executable Phase 0 baseline is green after repairing the Comic edit
regressions. `dart analyze lib --format machine`,
`flutter analyze --fatal-warnings --fatal-infos`, the focused typed/provider
tests, `flutter test`, the Dart format gate, and the architecture boundary
checker all pass. The full suite reports five intentionally skipped tests.

PR24-PR26 are represented by the existing provider-native search work. PR27 is
not applicable until a provider exposes metadata writeback; no speculative
reverse mapper should be added. The next conceptual checkpoint is PR28, whose
personal-sync separation is structurally present. Account/link persistence,
sync-policy persistence and directional filtering, three-way conflict handling,
and echo protection are covered by the AniList vertical slice. The importer
framework and the remaining provider personal-list integrations described in
Phase 7 are still open.

Known incomplete or regressed surfaces:

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

## 🎯 Remaining Implementation Plan

The order below is dependency-driven. A phase is complete only when its focused
tests pass, its callers no longer depend on the retired bridge, and the relevant
architecture-negative check prevents the old design from returning.

### Phase 0 — Restore a green migration baseline (P0, current)

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
- [ ] Finish importer convergence with `ProviderPersonalEntry` and
	`ExternalStateEngine`. The framework and TMDB preview path are now typed and
	pass Dart's `MutationOrigin.fileImport` into the apply callback; production
	import-job mutation origin propagation and any remaining provider-specific
	paths are still open.
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
- [ ] Add a live subscribable ICS feed with optional kind filters and per-kind
  settings.
- [ ] Add local notifications for loan due dates, releases, sync conflicts,
  imports, and proposals; define offsets, channels, and quiet hours.
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
