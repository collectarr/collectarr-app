# Remaining `LibraryKindRuntime` cutover map

Status: A1 rebaseline

Branch: `work/typed-kind-full-implementation-plan`

HEAD inspected: `b7d13497 refactor(state): remove Riverpod legacy providers`

This document is a no-behavior-change deletion map for the remaining erased
kind runtime. It records the current ownership boundary before A2 starts. It
does not introduce a replacement runtime and it must be updated when a later
PR moves a consumer.

## Current snapshot

The production tree currently contains:

- 134 Dart files referencing `LibraryKindRuntime` or `LibraryKindSpec`.
- 379 production references to those symbols.
- 39 production references to the generic typed-rehydration helpers.
- A runtime-backed registration chain:
  `LibraryKindRegistration -> _RuntimeLibraryKindRegistration -> LibraryKindRuntime`.
- A generic pseudo-kind, `genericKindModule`, for unknown kinds.

The current branch is clean before this A1 documentation change. No runtime
behavior is changed by this PR.

## Central runtime inventory

### `library_kind_module.dart`

| Area | Current symbols | Classification | Target PR |
| --- | --- | --- | --- |
| Identity/dispatch | `kind`, `identity` | Structural dispatch boundary | A2 |
| Kind capabilities | `presentation`, `metadata`, `trackingProfile`, `hierarchy`, `inspector`, `edit`, `transfer`, `stats`, `value`, `relations`, `uiPolicy`, `linkedMetadata`, `add`, `titleCapability`, `releaseCapability`, `toolbar`, `facets`, `searchTargetOptions`, `viewProfile` | Kind-owned semantic responsibility exposed through an erased aggregate | A2, A4, A7 |
| Workspace schema | `fields`, `availableGroupIdsForBrowserMode`, `availableSortIdsForBrowserMode` | Kind-owned fields/sorts/groups, currently erased | A4 |
| Workspace presentation | `defaultTableColumns`, `orderedTableColumns`, all table column methods, `buildTableCell` | Kind-owned column semantics and typed UI projection | A4 |
| Workspace execution | `compareEntriesByRules`, `subgroupKeyForEntry`, `compareSubgroupKeys`, `project`, `createWorkspaceDto`, `validateProjection` | Typed workspace/projection behavior hidden behind runtime DTOs | A4 |
| Card/projection compatibility | `buildCard`, `buildCardPresentation`, `sort`, `compare`, `groupValue`, `groupModeSupportsCompletion`, `groupSequenceValueForEntry`, `columnValue` | Kind-owned projection behavior forwarded by generic UI | A4 |
| Owned bridge | `decodeOwnedDetails`, `defaultOwnedDetails`, `defaultOwnedDetailsDraft`, `ownedDetailsDraftFromDetails`, `buildPersonalDetailsDraft`, `encodeOwnedDetails`, `validateOwnedDetails` | Compatibility bridge to common `OwnedItemDetails`/draft types | A5 and Milestone C |
| Provider/metadata bridge | `providerMapper`, `catalogMetadataDecoder`, `withCatalogMetadata` | Provider and catalog metadata are currently rehydrated through the runtime | A3, A7 |
| Runtime implementation | `LibraryKindSpec<TDto, TDetails, TDetailsDraft>` | Broad generic aggregate implementing all rows above | A2–A8, then delete |
| Runtime validation | `validateKindRuntime` | Validation currently coupled to the erased aggregate and common owned codec | A8 or typed contract replacement |

`LibraryKindProviderMapper` at the bottom of the file is also a semantic
provider bridge because it returns `CatalogItem` and accepts
`NormalizedProviderEnvelopeV1`. It is not part of the final structural
registration surface.

### `collectarr_kind_modules.dart`

| Current construct | Classification | Target |
| --- | --- | --- |
| `collectarrKindModules: List<LibraryKindRuntime>` | Erased all-kind semantic registry | A2/A8; retain only explicit typed composition registrations |
| `_LibraryKindPageBuilder` accepting `LibraryKindRuntime type` | Erased page dispatch | A2; page builders should receive the concrete kind entrypoint/configuration |
| `_RuntimeLibraryKindRegistration` | Runtime-backed registration adapter | A2; delete |
| `_registrationTemplates` | Runtime-backed page/add/edit templates | A2; replace with nine concrete registrations |
| `libraryKindRegistrationForRuntime` | Re-wraps a runtime as a registration; generic fallback returns `GenericLibraryPage` | A2; replace with dispatch by `CatalogMediaKind`/registration |
| `decodeLibraryKindMetadata` | Runtime loop plus generic map fallback | A3; delete |
| `typedCatalogItemFromCatalogItem` | Rehydrates a generic `CatalogItem` through kind decoder | A3/B milestone; callers dispatch to typed kind mappers |
| `typedCatalogItemFromMap` | Generic serialization-to-catalog-to-rehydration bridge | A3/B milestone; keep parsing only at an explicit boundary |
| `typedCatalogItemFromUnknown` | Runtime type-recovery helper | A3; delete |
| `lookupLibraryKind` / `libraryKindFor` | Erased runtime lookup | A2/A8; replace usages with structural dispatch or concrete kind selection |

### `library_kind_registry.dart`

The registry currently stores `Iterable<LibraryKindRuntime>`, validates each
runtime, exposes `allRuntimes`, and is used as the source for catalog/runtime
resolution. Its other contributor maps are already structurally useful
composition-root registries, but their construction must not require the
semantic runtime once A2 is complete.

Current follow-up targets:

- `LibraryKindRegistry` constructor and `_byKind` map: A2/A8.
- `defaultLibraryKindRegistry = LibraryKindRegistry(collectarrKindModules)`:
  A2.
- `resolveWithCatalog` extensions and
  `buildRuntimeCatalogLibraryRuntime`: A2/A4; catalog-specific labels and
  provider options need a typed catalog configuration path.
- `validateKindRuntime` calls: replace with explicit typed kind contract
  registration/validation, not a new universal spec.

## Consumer map

### 1. Composition and dispatch roots

These are the first consumers to migrate because they decide which concrete
kind is active:

- `lib/features/library/kinds/registry/collectarr_kind_modules.dart`
- `lib/features/library/library_kind_registry.dart`
- `lib/features/library/home/home_page.dart`
- `lib/features/library/runtime/library_catalog_resolution.dart`
- `lib/features/library/runtime/runtime_catalog_library_type_builder.dart`
- `lib/features/library/hierarchy/providers/library_hierarchy_provider.dart`
- `lib/features/library/providers/media_catalog_provider.dart`
- `lib/features/library/generic/page/controllers/page_view_state_controller.dart`

These files may retain `CatalogMediaKind` and small registration/ref types.
They must stop forwarding the full runtime to downstream semantic code.

### 2. Generic Library workspace and projection

The following areas use runtime methods for fields, sorting, grouping, table
cells, projections, cards, preferences, or filters:

- `lib/features/library/generic/**`
- `lib/features/library/workspace/**`
- `lib/features/library/config/library_kind_workspace_controller.dart`
- `lib/features/library/config/library_kind_browser_delegate.dart`
- `lib/features/library/config/library_kind_drilldown.dart`
- `lib/features/library/config/library_page_utilities.dart`
- `lib/features/library/config/library_media_field_labels.dart`
- `lib/features/library/config/library_group_mode_category.dart`
- `lib/features/library/config/library_stats_capability.dart`
- `lib/features/library/config/library_toolbar_config.dart`
- `lib/features/library/workspace/table/media_table_columns.dart`
- `lib/features/library/stats/stats_dashboard.dart`

Classification: typed workspace responsibility, not permanent runtime
responsibility. The generic widgets may remain generic over a typed DTO or
structural view model; they must not call a broad `LibraryKindRuntime` after
dispatch.

### 3. Add, edit, detail, inspector, and export hosts

These currently accept or forward the runtime while hosting kind behavior:

- `lib/features/library/add/**`
- `lib/features/library/edit/**`
- `lib/features/library/detail/**`
- `lib/features/library/details/**`
- `lib/features/library/inspector/**`
- `lib/features/library/selection/library_bulk_edit_dialog.dart`
- `lib/features/library/export/integration_export_dialog.dart`
- `lib/features/library/release/video_release_projection_capability.dart`

Classification: split host mechanics from kind-owned semantic contributions.
The host can keep structural action/edit contracts; concrete field lists,
provider mapping, owned details, and release semantics move to the owning
kind. This is primarily A4/A5 and later Collection/Owned milestones.

### 4. Cross-feature semantic bridges

These production files still cross the runtime boundary from outside or near
the Library feature:

- `lib/features/collection/collection_page_import.dart`
- `lib/features/settings/import_job_provider.dart`
- `lib/features/catalog/library_catalog_repository.dart`
- `lib/features/catalog/serial/serial_authority_repository.dart`

Classification: serialization/orchestration boundary only. They must not
construct or inspect a full generic kind runtime. Their concrete work belongs
in the relevant kind integration or typed repository.

### 5. Kind-local consumers

The nine kind module files currently instantiate `LibraryKindSpec` and expose
semantic capabilities through it:

- `kinds/anime/anime_kind_module.dart`
- `kinds/boardgame/boardgame_kind_module.dart`
- `kinds/book/book_kind_module.dart`
- `kinds/comic/comic_kind_module.dart`
- `kinds/game/game_kind_module.dart`
- `kinds/manga/manga_kind_module.dart`
- `kinds/movie/movie_kind_module.dart`
- `kinds/music/music_kind_module.dart`
- `kinds/tv/tv_kind_module.dart`
- `kinds/generic/generic_kind_module.dart`

Additional kind-local stats, provider, edit, and hierarchy files reference the
runtime because their current public contracts were designed around it. They
should be migrated by duplication into concrete kind modules, not by adding a
new common super-spec. The generic pseudo-kind is separately tracked as P1.4
and must not become a permanent ninth semantic implementation.

## Generic rehydration call sites

The following are the highest-risk A3/B callers because they convert data back
into a generic `CatalogItem` after a boundary:

- `lib/features/catalog/library_catalog_repository.dart`
- `lib/features/catalog/serial/serial_authority_repository.dart`
- `lib/features/collection/mutations/collection_import_service.dart`
- `lib/features/collection/mutations/owned_item_mutations.dart`
- `lib/features/collection/mutations/tracking_mutations.dart`
- `lib/features/collection/mutations/wishlist_mutations.dart`
- `lib/features/collection/repositories/shelf_controller.dart`
- `lib/features/library/add/controllers/library_add_session_controller.dart`
- `lib/features/library/add/controllers/library_add_comparisons.dart`
- `lib/features/library/add/services/library_add_workflow_service.dart`
- `lib/features/library/add/services/library_provider_orchestration_service.dart`
- `lib/features/library/config/library_group_bucket_mutation.dart`
- `lib/features/library/generic/page/coordinators/page_dialog_coordinator.dart`
- `lib/features/library/generic/page/coordinators/page_edit_coordinator.dart`
- `lib/features/library/generic/page/generic_library_page.dart`
- `lib/features/library/generic/reading_queue_dialog.dart`
- `lib/features/library/metadata/library_metadata_query.dart`
- `lib/features/library/metadata/library_metadata_compare_dialog.dart`
- `lib/features/library/metadata/provider_candidate.dart`
- `lib/features/library/inspector/metadata_correction_dialog.dart`
- `lib/features/settings/import_job_provider.dart`

Tests also use these helpers extensively. Test fixtures can be migrated after
the production boundary is established; they must not drive a new production
generic API.

## Planned cutover sequence

| Step | Change | Exit condition |
| --- | --- | --- |
| A2 | Add nine concrete registrations and make page/Add/Edit dispatch use them | No `_RuntimeLibraryKindRegistration`; registration exposes only identity and entrypoints |
| A3 | Delete generic metadata decoder and typed-catalog rehydration helpers | No production caller reconstructs typed data through the registry |
| A4 | Move projection, field, column, sort, group, facet, and workspace behavior to typed kind modules/typed UI contracts | Generic workspace code no longer needs semantic runtime methods |
| A5 | Remove owned codec/draft methods from the runtime | Runtime has no `OwnedItemDetails`/owned codec API |
| A6 | Move facet execution to typed workspace contributions | Generic facet host receives structural views only |
| A7 | Move provider mapping out of runtime | Provider-native DTO -> kind mapper -> typed kind domain |
| A8 | Delete `LibraryKindRuntime`, `LibraryKindSpec`, and stale lookup/validation APIs | Only small structural registrations/refs remain outside kinds |

## Permanent boundaries to preserve

The cutover must retain only these erased/read-level concepts where they are
actually needed:

- `CatalogMediaKind` for dispatch identity.
- `LibraryKindIdentity` for labels/icon/accent/navigation presentation.
- `LibraryKindRegistration` for page/Add/Edit entrypoints.
- `CatalogEntityRef`, `OwnedItemRef`, `OwnedItemSummary`, and other small
  structural projections.
- Generic renderers/contracts parameterized by typed data.

The following must not be reintroduced as replacements:

- `LibraryKindRuntimeV2`, `LibraryKindSpecV2`, or another broad universal spec.
- A generic owned codec/draft aggregate.
- A generic metadata envelope that returns full catalog semantics.
- A registry method exposing fields, columns, provider mappers, or owned
  details.

## A1 acceptance

- [x] Current branch and HEAD recorded.
- [x] Central runtime and registration chain identified.
- [x] Runtime API classified by ownership and target PR.
- [x] Production consumer groups identified.
- [x] Generic rehydration callers identified.
- [x] No production behavior changed.

Next PR: **A2 — Replace runtime-backed registrations with concrete
registrations.**
