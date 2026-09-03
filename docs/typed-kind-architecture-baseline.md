# Typed-Kind Architecture Baseline

Baseline for the typed-kind migration described in
`docs/collectarr_typed_kind_full_implementation_plan.md`.

## Scope

- Repository: `collectarr-app`
- Baseline branch: `main`
- Working branch: `work/typed-kind-full-implementation-plan`
- Baseline revision: `HEAD` when this document was created
- Audit scope: `lib/`, `test/`, and `tool/`, with emphasis on catalog, library,
  collection, provider, and edit boundaries
- This document is an inventory only. It does not change runtime behavior.

The inventory records the current compatibility and ownership debt. A symbol can
be a valid transport boundary and still be a migration target when it is used as
a domain object after decoding.

## Current Findings

| Area | Status | Evidence | Target |
| --- | --- | --- | --- |
| Catalog transport | Partial | `CatalogItemDto` and `CatalogKindCodec` exist, but generic callers still use the central catalog path. | Complete registry decode, then remove known-kind central switches. |
| Library metadata | Partial | `LibraryMetadataItem` still owns an interoperability catalog and `toCatalogItem()`. | Replace the bridge with typed kind catalog and entry contracts. |
| Kind runtime | Partial | `LibraryKindRuntime` is a useful dispatch boundary, but exposes generic workspace and dynamic field-registry surfaces. | Keep dispatch small and expose typed capabilities. |
| Provider mapping | Partial | Provider-native envelopes are boundary data, while add workflow code still assembles kind-specific payload maps. | Move semantic mapping to the target kind/provider mapper. |
| Edit architecture | Partial | `KindEditDraft` exists, but generic draft initialization and default presentation still carry semantic fields. | Make schemas and drafts kind-owned; keep only the visual renderer generic. |
| Owned state | Partial | `OwnedItemDetails` is a broad subtype boundary and cache repositories are centralized. | Introduce `OwnedItem<TDetails>` and kind-owned persistence. |
| Architecture checker | Partial | `tool/check_library_kind_boundaries.dart` checks some concrete imports and generic boundary types. | Add the PR 1 detections and shrink the allowlist. |

## Inventory

| Symbol | Representative file(s) | Responsibility | Type-erasure? | Semantic leak? | Target owner | Target PR |
| --- | --- | --- | --- | --- | --- | --- |
| `CatalogItemDto` | `lib/core/api/dto/catalog/catalog_item_dto.dart` | Central catalog wire DTO and known-kind decode dispatch. | Yes, at the transport boundary by design. | Yes, when used as the library domain object after decode. | Catalog envelope plus each kind's catalog codec. | PR 12, PR 70 |
| `CatalogItem` | `lib/core/models/catalog_item.dart` and catalog model callers | Broad catalog domain object shared across kinds. | Yes. | Yes; concrete publishing, video, music, game, series, and release fields are exposed centrally. | Concrete kind catalog models. | PR 70 |
| `CatalogKindCodec` | `lib/features/library/kinds/registry/library_kind_module.dart` and kind codecs | Encodes and decodes kind catalog payloads. | Only at the serialization boundary. | Not inherently; generic fallback must remain legacy-only. | Registry dispatch to the selected kind codec. | PR 70, PR 73 |
| `LibraryKindMetadataRuntime` | `lib/features/library/models/library_kind_metadata_runtime.dart` | Generic metadata runtime and decoder contract. | Yes, through a generic runtime envelope. | Potentially, if it becomes the metadata owner instead of a dispatch boundary. | Kind-owned metadata/capability contracts. | PR 5, PR 71 |
| `LibraryKindMetadataDecoders` | `lib/features/library/models/library_kind_metadata_runtime.dart` and registry callers | Selects metadata decoders for a media kind. | Yes, during dispatch. | Yes, if generic callers consume decoded metadata without a typed projection. | Registry plus concrete kind decoder. | PR 5, PR 71 |
| `LibraryMetadataItem` | `lib/features/library/models/library_metadata_item.dart` | Metadata envelope used by add, edit, detail, export, and comparison flows. | Yes; retains an interoperability catalog and `toCatalogItem()`. | Yes; it remains a central route to concrete schemas. | Kind-owned catalog/entry contracts with a small envelope only at boundaries. | PR 1, PR 70, PR 72 |
| `LibraryCatalogItemView` | `lib/features/library/models/library_catalog_item_view.dart` | Generic view wrapper around catalog data. | Yes. | Yes when callers reach concrete metadata through the wrapper. | Typed workspace/catalog projection owned by each kind. | PR 16, PR 70, PR 72 |
| `LibraryKindRuntime` | `lib/features/library/kinds/registry/library_kind_module.dart` | Runtime capability aggregate and dispatch surface for registered kinds. | Yes; currently includes broad generic capability members. | Yes where it forwards or reconstructs kind semantics. | Small `LibraryKindRegistration` plus typed capabilities. | PR 5, PR 6 |
| `LibraryKindSpec` | `lib/features/library/kinds/registry/library_kind_module.dart` | Generic typed specification used to build a runtime module. | No by itself; casts at its runtime boundary can erase it. | Possible when the spec is projected into generic fallback APIs. | Per-kind module composition. | PR 5, PR 6 |
| `OwnedItemDetails` | `lib/core/models/owned_item_details.dart` | Base union for owned details across all kinds. | Yes, as an unparameterized subtype boundary. | Yes when generic transfer code switches on concrete detail types. | `OwnedItem<TDetails>` and kind-owned details codecs. | PR 29, PR 30 |
| `comicDetails` / `mangaDetails` / `movieDetails` / `tvDetails` / `animeDetails` / `gameDetails` | `lib/core/models/owned_item.dart`, `lib/features/library/kinds/*/ownership/` | Concrete owned-detail payloads carried through generic owned item flows. | Yes when stored behind the broad base type. | Yes when generic code reads or writes their fields. | Matching kind ownership modules and persistence mappers. | PR 29, PR 31, PR 32-67 |
| `KindEditDraft` | `lib/features/library/edit/draft/kind_edit_draft.dart` | Existing extension point for kind-owned edit fields. | No, but it is not yet the effective owner everywhere. | No by itself; generic callers still bypass it. | Each kind's media/release/owned edit draft. | PR 7, PR 19-21, PR 35, PR 44 |
| `GenericEditDraft` | `lib/features/library/edit/draft/library_edit_draft.dart` | Generic edit state and initialization fallback. | Yes. | Yes; initializes publisher, series, barcode, format, number, and other kind fields. | Generic lifecycle shell plus typed kind draft. | PR 7, PR 8, PR 81, PR 83 |
| `VideoEditDraft` | `lib/features/library/kinds/_shared/video/edit/video_kind_edit_draft.dart` | Shared video-like edit semantic draft. | No, but it is a cross-kind semantic abstraction. | Yes when treated as the default video schema for all video kinds. | TV, movie, and anime-owned edit schemas, with only technical primitives shared. | PR 79, PR 80 |
| `LibrarySectionRegistry` | `lib/features/library/config/presentation/` and edit presentation callers | Central semantic section/default registry for edit presentation. | Not primarily. | Yes; it decides kind fields and sections globally. | Explicit per-kind `EditSchema` declarations. | PR 7, PR 81, PR 82 |
| `DefaultLibraryEditPresentationBuilder` | `lib/features/library/config/presentation/default_library_edit_presentation_builder.dart` | Builds generic fallback edit tabs and sections. | Not primarily. | Yes; it owns implicit publishing/video/media semantics. | Kind-owned media, release, and owned edit schemas. | PR 7, PR 19-21, PR 81 |
| `CatalogCache` | `lib/features/catalog/catalog_cache_repository.dart` and catalog cache consumers | Central cache for catalog data. | Yes when cached values are broad catalog objects. | Yes if cache users inspect concrete fields generically. | Kind-specific repositories/cache adapters behind typed APIs. | PR 70, PR 74 |
| `OwnedItemsCache` | `lib/core/db/local_database.dart`, `lib/features/collection/repositories/owned_items_cache_repository.dart` | Shared local owned-item table and cache repository. | Yes for detail payloads and kind state. | Yes when generic repository owns concrete detail semantics. | Typed owned persistence modules and shared identity columns only. | PR 29, PR 30, PR 31 |
| `TrackingEntriesCache` | `lib/features/collection/repositories/tracking_entries_cache_repository.dart` | Shared cache for tracking entries. | Yes when tracking payloads are represented generically. | Yes for kind-specific progress semantics. | Kind-owned tracking modules. | PR 75, PR 76 |
| `TrackingUnitsCache` | `lib/features/collection/repositories/tracking_units_cache_repository.dart` | Shared cache for tracking units. | Yes. | Yes when units imply episodes, chapters, volumes, discs, or tracks generically. | TV/anime/music and other applicable kind tracking stores. | PR 76, PR 77 |
| `WatchSessionsCache` | `lib/features/collection/repositories/watch_sessions_cache_repository.dart` | Shared cache for watch-session state. | Yes. | Yes; watch semantics belong only to applicable video kinds. | TV/anime/movie tracking modules as applicable. | PR 77 |
| `NormalizedProviderEnvelope` | `lib/features/providers/domain/models/normalized_provider_envelope_v1.dart` | Provider transport envelope normalized before kind mapping. | Yes, intentionally at the provider boundary. | No if decoded immediately by the selected kind mapper; yes if generic metadata is assembled from it. | Provider-native models plus target kind provider mappers. | PR 24, PR 26, PR 27 |

### Generic maps and `dynamic`

The following are known type-erasure surfaces rather than one symbol:

| Location | Finding | Classification | Target |
| --- | --- | --- | --- |
| `lib/features/library/kinds/registry/library_kind_module.dart` | `LibraryFieldRegistry<dynamic, LibraryWorkspaceDto>` on the runtime surface. | Compatibility debt. | Expose typed field operations and typed IDs; see PR 6 and PR 16. |
| `lib/features/library/add/services/library_add_workflow_service.dart` | Preview mapping assembles item-number, publishing, music, video, game, series, creator, and release maps. | Kind-specific semantic leak. | Route the envelope through `LibraryKindRuntime.providerMapper`; see PR 24-27. |
| `lib/features/library/edit/draft/library_edit_draft.dart` | Generic initialization reads concrete metadata fields and applies title-as-series fallbacks. | Kind-specific semantic leak. | Delegate initialization and submit mapping to kind edit drafts; see PR 7-10 and PR 81-83. |
| `lib/features/library/generic/transferable_field.dart` | Generic transfer logic still handles concrete owned-detail subtypes. | Ownership violation. | Move read/write behavior into typed kind transfer definitions; see PR 29-31. |
| `lib/features/providers/domain/mappers/provider_preview_mapper.dart` | Provider preview values are represented as generic maps before kind decoding. | Transport boundary with semantic spillover. | Keep provider-native preview transport, move semantic decode to kind-owned mappers. |

## PR 1 Checker Coverage

`tool/check_library_kind_boundaries.dart` now checks, among other rules:

- concrete kind imports from generic library boundaries;
- cross-kind imports;
- selected concrete kind domain types in generic boundaries;
- selected forbidden contextual semantic members;
- selected dynamic field-registry usage.
- provider-to-kind imports;
- generated Core DTO imports from kind code outside the owning kind tree;
- generic metadata `Map<String, dynamic>` and `Map<String, Object?>` usage in
  library semantic paths;
- dynamic catalog and metadata objects in library, collection, and catalog code;
- a shrinking, explicit file allowlist for existing migration debt.

The current allowlist covers 19 metadata-map files and 56 dynamic catalog files.
New files in these semantic paths are rejected until they are migrated or
explicitly classified. Provider-to-kind and generated DTO import violations are
not allowlisted in the current tree, apart from the documented shared video
provider compatibility file.

## PR 2 Typed Contract Coverage

`test/contracts/` now contains a generic registration helper and reusable typed
contracts for:

- identity, Core mapping, and Core field adoption;
- repository and persistence round trips;
- workspace, fields, sorts, groups, facets, and vocabularies;
- Add, Media Edit, Release Edit, and Owned Edit schemas;
- provider integrations and tracking.

The contracts accept typed factories and projections from each kind. They do not
import concrete production kinds and do not require production code to expose a
new compatibility abstraction. The smoke suite in
`test/contracts/typed_contract_infrastructure_test.dart` registers every
contract against a small typed fixture.

## PR 3 Core Field Adoption

`core_field_adoption_contract.dart` now includes an Analyzer AST scanner that
extracts `final` fields from a named generated DTO and validates them against an
explicit `CoreFieldAdoptionPolicy`. The smoke suite applies this check to the
current `ComicWorkDto` fields and retains a smaller fixture policy for the
unclassified-field failure path.

This is the policy mechanism and first real adoption check. Policies for every
generated Core DTO are intentionally deferred to the PR 4 manifest so that
missing kind participation cannot be overlooked.

## PR 4 Meta-contract Manifest

`kind_contract_manifest.dart` explicitly lists the nine active catalog kinds and
the participants for each contract. Core mapping, repository, media
persistence, workspace, fields, Add, Media Edit, and identity are mandatory for
every active kind. Release, Release Edit, Release persistence, tracking,
hierarchy, and provider integration are declared as optional contracts with
their current applicable participants.

`kind_contract_manifest_test.dart` rejects enum/manifest drift, requires the
complete mandatory contract set, and rejects optional participants that are not
active kinds.

## PR 5 Typed Dispatch Boundary

`library_kind_registration.dart` defines the small erased entry point for kind
dispatch: kind identity, library page construction, Add construction, and
media/release edit opening. It uses the existing typed request and result
models, and is exported through `library_kind_registry.dart`.

The existing `LibraryKindRuntime` and page switch remain unchanged for now.
Concrete registrations and caller migration are deferred to later PRs.

## PR 6 Runtime Migration Guard

`LibraryKindRuntime` is now documented as a migration-only compatibility
surface. Its current members remain available to existing generic callers, but
new dispatch contracts must be added to `LibraryKindRegistration` or to the
owning concrete kind module instead of expanding the runtime interface.

## PR 7 Structural EditSchema

`edit_schema.dart` adds the renderer-neutral edit model:
`EditSchema<TModel, TDraft>`, typed tabs, sections, and field specifications.
The shared field vocabulary covers text, number, date, money, toggle, select,
single and multi vocabulary, image, read-only, and custom fields.

Each field owns only structural data, typed draft accessors, visibility, and
validation callbacks. The schema contains no media semantics, default tabs,
global sections, or kind-specific vocabulary.

## PR 8 Generic EditSchema Renderer

`edit_schema_renderer.dart` renders any `EditSchema<TModel, TDraft>` using the
same tab, section, field, validation, dirty-state, save, cancel, and responsive
layout grammar. It dispatches only on structural field specification types;
labels, options, validation, and draft mutation remain supplied by the schema
owner.

The renderer has focused widget coverage for dirty save flow and validation
blocking. Existing kind edit dialogs are not migrated yet.

## PR 9 Structural AddSchema

`add_schema.dart` adds the renderer-neutral Add model:
`AddSchema<TDraft>`, typed sections, and field specifications matching the
structural input vocabulary needed by the generic Add renderer. Add schemas
own their labels, draft accessors, visibility, validation, and options; no
kind-specific fields or default semantic sections are shared. `EditOption` is
reused only as the structural option value for select and vocabulary fields.

The focused contract covers all Add field primitives, typed draft mutation,
section and field visibility, validation, and field ID/label invariants.

## PR 10 Generic AddSchema Renderer

`add_schema_renderer.dart` renders any `AddSchema<TDraft>` with shared section,
field layout, validation, submit/cancel, responsive layout, and async error
handling. It consumes only structural Add field specifications; kind-owned
schemas continue to decide the fields, labels, options, visibility, and
validation rules.

Focused widget coverage exercises the structural field renderers, draft
mutation through text input, successful submit, and validation blocking.

## Reproduction Commands

Run from the repository root:

```powershell
rg -n --glob 'lib/**' --glob 'test/**' --glob 'tool/**' `
  'CatalogItemDto|CatalogItem|CatalogKindCodec|LibraryKindMetadataRuntime|LibraryKindMetadataDecoders|LibraryMetadataItem|LibraryCatalogItemView|LibraryKindRuntime|LibraryKindSpec|Map<String, dynamic>|OwnedItemDetails|KindEditDraft|GenericEditDraft|VideoEditDraft|LibrarySectionRegistry|DefaultLibraryEditPresentationBuilder|CatalogCache|OwnedItemsCache|TrackingEntriesCache|TrackingUnitsCache|WatchSessionsCache|NormalizedProviderEnvelope'

dart run tool/check_library_kind_boundaries.dart
```

The first command is intentionally textual and over-inclusive. Results must be
classified using the ownership rules above; names used only for labels or widget
types are not architecture violations.

## PR 0, PR 1, PR 2, PR 3, PR 4, PR 5, PR 6, PR 7, PR 8, PR 9, and PR 10 Exit Criteria

- [x] Baseline document created.
- [x] Every suspect named by the migration plan is classified.
- [x] Type-erasure and semantic-leak examples identify a target owner.
- [x] Each migration item points to a target PR.
- [x] No production architecture change made by this audit.
- [x] Provider-to-kind import detection added.
- [x] Generated Core DTO import detection added for kind sources.
- [x] Generic metadata map detection added with an explicit debt allowlist.
- [x] Dynamic catalog object detection added with an explicit debt allowlist.
- [x] Regression tests cover every new PR 1 rule.
- [x] Generic typed contract helper added.
- [x] All contract suites listed by PR 2 added.
- [x] Smoke test registers every PR 2 contract.
- [x] Generated DTO field scanner added.
- [x] Explicit field adoption policy validation added.
- [x] A real generated DTO policy is exercised by the smoke suite.
- [x] Nine-kind contract manifest added.
- [x] Mandatory contract participants cover every active kind.
- [x] Optional contract participants are explicitly declared and validated.
- [x] Small typed dispatch boundary added.
- [x] Registration boundary exported through the library registry.
- [x] Existing runtime dispatch remains unchanged.
- [x] `LibraryKindRuntime` marked as migration-only.
- [x] New dispatch ownership is documented for future callers.
- [x] Structural `EditSchema<TModel, TDraft>` models added.
- [x] Shared typed edit field specifications added.
- [x] Schema visibility and validation callbacks covered by focused tests.
- [x] Generic `EditSchema<TModel, TDraft>` renderer added.
- [x] Renderer owns visual grammar, dirty state, validation display, and save/cancel.
- [x] Renderer widget coverage added without migrating existing kind dialogs.
- [x] Structural `AddSchema<TDraft>` models added.
- [x] Add field specifications keep options and accessors typed.
- [x] Add schema contract coverage added without introducing kind semantics.
- [x] Generic `AddSchema<TDraft>` renderer added.
- [x] Add renderer owns visual grammar, validation, submit/cancel, and async state.
- [x] Add renderer widget coverage added without migrating existing kind dialogs.

## PR 11 Comic Domain Split

`ComicMedia` now owns the former `ComicCatalogMetadata` semantic model, while
`ComicCatalogMetadata` and `ComicMetadata` remain compatibility typedefs for
incremental caller migration. `ComicMediaId` is a typed identity value object
and is serialized only at the media JSON/sync boundary.

The existing `ComicRelease` and `ComicOwnedDetails` models are exposed through
the Comic domain surface. `ComicRelease.typedId` provides the typed
`ComicReleaseId` projection while its existing string identity remains the
explicit Core/JSON compatibility boundary. No generic catalog inheritance was
introduced.

Focused contract coverage verifies media construction and serialization,
compatibility alias decoding, typed ID equality, release identity projection,
and owned-details exposure.

- [x] `ComicMedia` introduced as the named owner of Comic media semantics.
- [x] `ComicMediaId` and `ComicReleaseId` added.
- [x] Existing release and owned-details models exported from the Comic domain.
- [x] Compatibility aliases retained for incremental migration.
- [x] Focused Comic domain contract added.

## PR 12 Comic Core Mapper

`ComicCoreMapper.fromWorkDto` maps `ComicWorkDto` directly to `ComicMedia`.
Core fields are projected into typed Comic values: contributors become
`ComicCreatorCredit`, issues become `ComicRelease`, and the Comic discriminator
is validated at the mapper boundary. The generated DTO import is constrained to
this explicit Comic adapter by the architecture checker.

`ApiComicRemoteSource` fetches a typed `ComicWorkDto` through the Core API and
returns the mapped `ComicMedia`. Its fetcher is injectable, keeping the source
testable without introducing a second transport abstraction.

Focused coverage verifies direct field mapping, contributor and issue
conversion, typed remote fetching, Core round-trip preservation, and explicit
classification of every `ComicWorkDto` field.

- [x] Direct `ComicWorkDto` to `ComicMedia` mapper added.
- [x] Typed contributor and issue projections added.
- [x] Comic remote source added with Core API integration.
- [x] Core mapping and field-adoption contracts added.
- [x] Generated DTO boundary allowlist narrowed to the Comic mapper.

## PR 13 Comic Local Media And Release Schema

`ComicMediaRows` and `ComicReleaseRows` are now typed Drift tables defined under
the Comic module. Media identity is the media primary key; release identity is
scoped by the owning media through a composite `(mediaId, id)` key. Comic-only
collections and nested semantic values are stored in explicitly named JSON
columns for the Comic persistence mapper to interpret.

`LocalDatabase` registers both tables and advances the cache schema to v7. The
existing destructive cache migration remains the upgrade path, so no user
authored data migration is required.

Focused DB coverage inserts and reads one media row and one release row,
verifies their association, and updates the existing schema reset assertions.

- [x] Typed `ComicMediaRows` Drift table added under Comic.
- [x] Typed `ComicReleaseRows` Drift table added under Comic.
- [x] Comic tables registered in `LocalDatabase` schema v7.
- [x] Generated Drift database updated.
- [x] Focused schema and migration coverage added.

## PR 14 Comic Local Mapper And Persistence Contract

`ComicLocalMapper` now owns the explicit conversion between `ComicMedia` and
`ComicMediaRow`, and between `ComicRelease` and `ComicReleaseRow`. Scalar values
and dates map directly to typed Drift columns. Lists and nested Comic values are
encoded only in the JSON columns declared by the Comic schema.

The mapper preserves typed media identity, requires persisted IDs, restores
optional release aggregates supplied by the repository, and tolerates malformed
non-critical JSON by restoring an empty collection or absent nested value.

Focused persistence coverage exercises minimal and fully populated media,
nullable/default fields, Unicode, nested series/publishing values, links,
creator/key-event values, release variants, and composite release ownership.

- [x] `ComicMedia` to/from `ComicMediaRow` mapper added.
- [x] `ComicRelease` to/from `ComicReleaseRow` mapper added.
- [x] Comic local mapper exported through the Comic domain surface.
- [x] Persistence round-trip contract added.

## PR 15 Comic Repository

`ComicRepository` now exposes typed media and release operations over the Comic
local tables. It assembles media aggregates by loading their separately stored
releases, searches the local Comic media table with deterministic ordering, and
constrains release reads by both media and release identity.

Media updates persist the parent and embedded releases in one transaction.
Release updates use the composite parent/release key. An empty embedded release
list does not delete existing rows, so replacement semantics remain an
explicit future operation rather than an accidental side effect of an update.

The repository optionally falls back to the typed `ComicRemoteSource` on a
local media miss, then caches the fetched aggregate through the same local
mapper. It returns only `ComicMedia` and `ComicRelease` values and does not
dual-write the legacy generic catalog cache.

Focused repository coverage verifies local aggregate assembly, typed search,
composite release lookup, upsert behavior, remote fallback, and missing-media
behavior without a remote source.

- [x] Typed Comic media/release repository added.
- [x] Local aggregate assembly and deterministic queries added.
- [x] Optional typed remote fallback added.
- [x] Repository contract coverage added.

## PR 16 Comic Workspace Typed Facets

Comic workspace facets are now declared by the Comic schema as typed
`LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>` values for
publisher, genre, character, story arc, writer, and artist. The Comic module
registers those definitions and its erased runtime callback delegates to the
matching typed extractor instead of rebuilding Comic metadata from the generic
catalog cache.

Focused workspace coverage verifies the complete facet ID and label surface,
typed extraction for all six facets, and runtime delegation through the
existing compatibility callback.

- [x] Typed Comic facet definitions added.
- [x] Comic facet definitions registered in the kind module.
- [x] Runtime facet adapter delegates to typed workspace values.
- [x] Focused Comic workspace facet contract added.

## PR 17 Comic Vocabulary Ownership

Comic vocabulary ownership is now covered by a dedicated contract over
`ComicVocabularies.all`. The ten kind-owned definitions cover publisher,
imprint, series group, physical format, condition, grade, page quality, key
category, story arc, and crossover. No Comic defaults are added to the shared
vocabulary layer; the existing typed projectors and Comic capability remain
the ownership boundary.

The contract verifies the complete vocabulary count, unique IDs and values,
non-empty labels, and the existing built-in value surface.

- [x] Comic vocabulary definitions remain kind-owned.
- [x] Comic vocabulary capability registration is covered.
- [x] Focused Comic vocabulary contract added.

Next work is PR 18: define the typed Comic Add schema.

## PR 18 Comic Add Schema

`comic_add_schema.dart` now declares the manual Comic Add surface in two
ordered sections: Main and Collector. The schema owns the 14 fields backed by
`ComicAddManualDraft`, including issue identity, variant, barcode, cover date,
cover image, and collector grading/signature data. The Series picker remains
an external authority control in the existing pane because it has no manual
draft property.

Publisher and Format are typed `VocabularyAddField` definitions backed by the
Comic publisher and physical-format vocabularies. Schema-level validation and
section visibility remain explicit callbacks, while the current pane can
continue loading user-managed options and rendering its existing controls.

Focused Add coverage verifies section and field ordering, unique labeled field
registration, vocabulary option bindings, and typed getter/setter round trips
for every manual draft property.

- [x] Typed Comic Add schema added.
- [x] Main and Collector sections declared explicitly.
- [x] Publisher and Format vocabulary bindings added.
- [x] Add contract and focused schema coverage added.

## PR 19 Comic Media Edit Schema

`comic_media_edit_draft.dart` now provides a Comic-owned media draft adapter
over the existing media controller state. It preserves the current fallback
behavior for series title, publisher, imprint, page count, and physical
format while exposing typed values and setters for the declarative schema.

`comic_media_edit_schema.dart` declares the complete seven-tab media surface:
Main, Details, Creators, Characters, Links, Covers, and My Images. Main and
Details explicitly own the issue, publication, identifier, date, language,
genre, crossover, and story-arc fields. Publisher, Imprint, Series Group, and
Format are bound to Comic-owned vocabularies. Creator, character, link, cover,
and photo collections remain explicit custom fields so their existing dynamic
controls do not leak into generic edit infrastructure.

Schema-level validation covers non-negative page counts and invalid date text.
The focused contract verifies tab and field uniqueness, labels, ordering,
vocabulary bindings, typed round trips, clearing nullable vocabulary values,
and validation failures.

- [x] Typed Comic Media Edit draft added.
- [x] Seven media tabs and their sections declared explicitly.
- [x] Comic vocabulary bindings and media validation added.
- [x] Media Edit contract and focused schema coverage added.

## PR 20 Comic Release Edit Schema

Comic release semantics are now represented by the existing typed
`ComicRelease` model and a dedicated `ComicReleaseEditDraft`. The draft owns
mutable title, publication, identifier, date, cover, and variant state and can
serialize the edited values back to a `ComicRelease` without losing its typed
variant list.

`comic_release_edit_schema.dart` declares one Release tab with explicit
Identity, Publication, Artwork, and Variants sections. The release ID is
read-only, while edition title, publisher, imprint, ISBN, UPC, release date,
and cover image have typed edit fields. Variants remain an explicit Comic
custom field because their dynamic controls belong to the release surface,
not to generic publishing infrastructure.

Dedicated Release and Release Edit contracts verify non-empty identity,
unique schema tabs and fields, labels, vocabulary bindings, typed round trips,
variant preservation, and release identity validation.

- [x] Typed Comic Release Edit draft added.
- [x] Release, edition, variant, and identifier fields declared explicitly.
- [x] Comic publisher and imprint vocabulary bindings added.
- [x] Release and Release Edit contracts with focused coverage added.

## PR 21 Comic Owned Edit Schema

Comic-owned grading, signature, key-issue, preservation, and cover-price
values now have a dedicated `ComicOwnedEditDraft`. The draft covers the full
typed `ComicOwnedDetails` surface, including custom labels and key severity,
and can produce both the domain model and the existing owned-details command
draft for compatibility with current edit flows.

`comic_owned_edit_schema.dart` declares one Owned tab with explicit Collector,
Signature, Key comic, and Preservation and value sections. Raw/slabbed uses a
typed selection, page quality and key category use Comic-owned vocabularies,
and key reason/category/severity become visible only when Key comic is
enabled. Cover price uses the shared money field shape while its validation
remains owned by the Comic schema.

The focused Owned Edit contract verifies unique tabs and fields, labels,
vocabulary bindings, visibility transitions, complete typed round trips, and
negative cover-price validation. The existing hardcoded pane remains the
runtime adapter for legacy fields, while the combined Comic editor now embeds
the typed Owned schema for owned items without duplicating those fields in the
old Value tab.

- [x] Typed Comic Owned Edit draft added.
- [x] Collector, signature, key, preservation, and value sections declared.
- [x] Comic page-quality and key-category vocabulary bindings added.
- [x] Owned Edit contract and focused schema coverage added.

## PR 22 Comic Hierarchy, Stats, and Value

Comic hierarchy diagnostics now belong to the kind-owned hierarchy capability.
The generic helper dispatches by the registered media kind, while Comic and
Manga provide typed series and release-variant diagnostics. Generic sequence
gap infrastructure uses sequence terminology and no longer encodes issue
semantics.

Key-comic counts are calculated by `ComicStatsCapability`, and cover-price
aggregation is calculated by `ComicValueCapability` through a structural
collection-value summary. Shared `ShelfState` and toolbar projection counts
no longer carry Comic-specific key or cover-price fields. The Comic transfer
configuration also owns its cover-price transfer key rather than inheriting it
from the generic release list.

Focused hierarchy, stats, value, transfer, projection, shelf, and dashboard
tests verify the typed dispatch and preserve the existing UI-facing behavior.

- [x] Comic hierarchy diagnostics moved behind a kind-owned capability.
- [x] Key-comic and cover-price aggregation moved out of shared state.
- [x] Comic cover-price transfer ownership made explicit.
- [x] Generic hierarchy sequence terminology cleaned up.
- [x] PR22 focused contract coverage added.

## PR 23 Comic Media Edit Runtime

Comic media-, release-, and owned-scope editing now resolve to kind-owned typed
dialog builders. The builders reuse the existing Comic edit controllers through
typed drafts, render their schemas with the generic schema renderer, and emit
the existing `LibraryEditSelection` contract on Save. The Combined editor
embeds the Owned schema only for owned items, while Release uses its dedicated
dialog and Media keeps its existing scope.

The shared Edit schema renderer now handles both typed select and vocabulary
fields through erased callback adapters. Empty vocabulary values are represented
as `null`, preserving valid dropdown state for schemas whose optional fields are
not populated.

- [x] Comic Media scope registered with the typed schema runtime.
- [x] Existing Comic edit draft/controller lifecycle reused.
- [x] Typed Media schema runtime coverage added.
- [x] Typed Release and Owned schema runtime coverage added.
- [x] Select and vocabulary renderer dispatch made type-safe at runtime.

The Comic Add pane now renders its Main and Collector fields through
`comicAddSchema` and the generic Add renderer. Series remains an explicit
authority picker because it is not a manual-draft property, while publisher and
format options continue to come from the kind-owned vocabulary and pick-list
services.

- [x] Comic Add schema connected to the manual runtime pane.
- [x] Runtime Add vocabulary options injected into the typed schema.
- [x] Comic Add pane contract updated for schema-rendered fields.

Next work is the remaining typed Comic Add workflow behavior and the follow-on
kind runtime migrations.