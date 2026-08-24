# Outside-Kinds Generic Audit

This is the PR 0 rebaseline and full ownership audit for `main` at `eac0e7c7` (2026-08-24). The scan covers
`lib/features/library/**`, excluding `lib/features/library/kinds/**`. Textual matches
such as widget names and user-facing labels are recorded as false positives unless
they carry kind semantics.

### Revision note

The current checked-out `main` has advanced to `a2e4321c`. In this revision,
`lib/features/library/models/library_metadata_item.dart` is 131 lines and
`GenericKindMetadataPayload` has zero matches under `lib/`. A report showing roughly
468 lines or that symbol is from an older/stale served revision and must not be used
as evidence against the current tree. The current, reproducible PR1 debt is the
forwarding getter facade and the broad `toCatalogItem()` interoperability path.

### Current working-tree status

The forwarding getter declarations have now been removed and the known callers
have been moved to explicit `toCatalogItem()` calls. This is still a transition
state, not the target architecture: `LibraryMetadataItem` retains an internal
interoperability catalog and remains widely used by runtime APIs. The current
working tree is not a commit-ready PR because the full semantic migration is
not complete and the transition bridge is still carrying behavior.

The implementation plan now intentionally favors semantic duplication per kind.
Shared code is limited to technical shell, transport, persistence primitives,
layout, and registry composition. The comic catalog/workspace/presentation/
inspector projection slice now reads `ComicCatalogMetadata` directly and has no
`toCatalogItem()` usage under `kinds/comic/`; the remaining comic provider, add,
edit, detail, export, hierarchy, and entry paths still require migration. The
bridge must shrink and then be deleted rather than receive more fallback logic.

The intended boundary remains: generic library code consumes typed capabilities and
workspace DTOs; concrete schemas and behavior live in `kinds/<kind>/`, with registry
and composition roots as the only explicit exceptions.

## Status Summary

| Invariant | Current status | Evidence |
| :--- | :--- | :--- |
| No concrete kind imports outside `kinds/` | **Mostly passed** | No `kinds/<kind>/` import was found outside the registry; `CatalogMediaKind` is still used by generic boundary APIs. |
| No concrete kind branches in generic behavior | **Partial** | Hierarchy child labels now come from `LibraryHierarchyCapability`; presentation and transfer semantic fallbacks remain. |
| No broad central metadata superset | **Partial** | Forwarding getters are gone, but `LibraryMetadataItem` still retains an interoperability catalog and reconstructs `CatalogItem`. |
| No runtime `GenericKindMetadataPayload` | **Passed** | Zero matches under `lib/`. |
| Generic sync envelope plus kind codec | **Partial** | `toSyncPayload()` delegates encoding, but `toCatalogItem()` remains a central transport bridge used by generic code. |
| No generic `LibraryFieldRegistry<dynamic, ...>` | **Failed** | `LibraryKindRuntime.fields` is declared as `LibraryFieldRegistry<dynamic, LibraryWorkspaceDto>`. |
| No generic semantic `Map<String, Object?>` | **Failed** | Provider preview and add mapping pass concrete semantic payload maps to the central decoder. |
| PR 1 decomposition complete | **Not complete** | Callers were migrated mechanically, but typed per-kind catalog and entry contracts have not replaced the central runtime object. |

## Inventory and Classification

| Location | Match | Classification | Remaining action |
| :--- | :--- | :--- | :--- |
| `lib/features/library/models/library_metadata_item.dart` | Internal catalog bridge plus former semantic field surface | **Compatibility debt** | Replace the central runtime object with kind-owned catalog/entry contracts. `toCatalogItem()` is temporary interoperability only. |
| `lib/features/library/models/library_metadata_item.dart` | `CatalogMediaKind` identity and `LibraryKindMetadataRuntime` | **Allowed boundary** | Keep the typed identity and runtime envelope. Do not add concrete schema switches here. |
| `lib/features/library/add/services/library_add_workflow_service.dart` | `metadataItemFromPreview()` builds item-number, publishing, music, video, and game maps | **Kind-specific violation** | Move preview-to-kind decoding into the provider/kind mapper. Keep only the generic envelope in this service. |
| `lib/features/library/add/controllers/library_add_preview_controller.dart` | `Map<String, AdminProviderPreview>` | **Transport-only** | The preview DTO may remain at the provider boundary; mapping semantics must be owned by the kind mapper. |
| `lib/features/library/hierarchy/ui/hierarchy_children_section.dart` | Child labels are supplied by `LibraryHierarchyCapability`; the concrete switch was removed. | **Resolved** | Keep hierarchy labels and child loading in kind-owned capability implementations. |
| `lib/features/library/generic/projection/**` | Group/sort/column orchestration through runtime field definitions | **Allowed boundary** | Generic presentation delegates to registered typed definitions. Preserve this direction. |
| `lib/features/library/kinds/registry/library_kind_module.dart` | `LibraryFieldRegistry<dynamic, LibraryWorkspaceDto>` on `LibraryKindRuntime` | **Compatibility debt** | Tighten the runtime interface around typed capability methods; do not replace it with another untyped registry. |
| `lib/features/library/workspace/schema/library_field_registry.dart` | `sortEntries`, `compareEntries`, `getGroupValue`, `getColumnValue` | **Allowed boundary** | These are registry operations, but their runtime-facing `dynamic`/cast surface should be reduced during the field-registry migration. |
| `lib/features/library/config/library_type_config.dart` | `LibraryTypeConfig` forwards kind behavior and contains issue-number fallback | **Compatibility debt** | Move remaining behavior to the registered runtime/capabilities; retain config as composition data. |
| `lib/features/library/metadata/provider_candidate.dart` and add workflow | Provider candidate/preview mapping into `LibraryMetadataItem` | **Kind-specific violation** | Use the selected `LibraryKindRuntime.providerMapper`; generic code should not assemble concrete fields. |
| `lib/features/library/config/library_metadata_capability.dart` | Provider support filtering by `CatalogMediaKind` | **Allowed boundary** | This is provider capability selection, not concrete schema behavior. Keep it typed and avoid concrete branches. |
| `lib/features/library/edit/draft/library_edit_draft.dart` | Generic edit initialization reads item number, publisher, edition, barcode, and variant | **Kind-specific violation** | Initialize common draft fields generically and let `KindEditDraft`/kind edit capability own concrete fields. |
| `lib/features/library/config/generic_library_media_presentation.dart` and `workspace_presentation_support.dart` | Publisher, audience rating, variant, and other concrete display fields | **Generic presentation violation** | Use the registered workspace DTO projection/capability; no new generic semantic fallback. |
| `lib/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart` | Bulk replacement for publisher, country, language, age rating, and similar fields | **Kind-specific violation** | Route editable field identity and replacement through typed field definitions. |
| `lib/features/library/details/**`, `inspector/**`, `export/**` | Generic views reach concrete fields through `toCatalogItem()` or forwarding getters | **Compatibility debt** | Migrate each consumer to a capability/projection; do not retain central forwarding getters. |
| `lib/features/library/kinds/registry/collectarr_kind_modules.dart` | Imports and registration of all production kind modules; decoder switch | **Allowed boundary / explicit registry** | This is the composition root exception. Keep concrete imports and decoder dispatch here. |
| `lib/features/library/kinds/_shared/**` | Video/print reusable primitives | **Allowed shared primitives** | Shared only where the domain concept is genuinely compositional; no generic media superset. |
| Names such as `Season`, `Episode`, `Volume`, `Chapter`, `Disc`, `Track`, `Series` in generic paths | Widget names, route labels, field IDs, or textual labels without schema branching | **False positive** | No action unless the match reads or mutates concrete metadata. |

## Named Acceptance Surfaces

| Surface | Current finding | Classification |
| :--- | :--- | :--- |
| `LibraryMetadataItem` | Forwarding getters are removed, but the internal catalog bridge remains. | **Compatibility debt / PR 1 incomplete** |
| `CatalogItemDto` | Sealed transport DTO factory normalizes and dispatches concrete wire DTOs. | **Transport-only / allowed boundary** |
| Hierarchy providers and UI | Child-section labels now come from kind-owned `LibraryHierarchyCapability`; legacy provider files still require review. | **Partial / hierarchy UI resolved** |
| `LibraryKindRuntime` | A capability owner exists, but its field registry contract still exposes `dynamic` and generic workspace DTOs. | **Compatibility debt** |
| `LibraryTypeConfig` | Still carries compatibility behavior and delegates some kind semantics directly. | **Compatibility debt** |
| Provider mapping | `AdminProviderPreview` is retained at transport boundary, but generic add workflow maps concrete payload fields. | **Kind-specific violation** |
| Facets | Facet module is registered per runtime; generic sidebar category orchestration is capability-based. | **Allowed boundary**, with semantic field bulk-edit paths still needing migration. |
| Edit fallback | Generic edit draft initialization still reads concrete metadata fields and has title-as-series fallback flags. | **Kind-specific violation / compatibility debt** |

## PR 1 Exit Criteria

PR 1 is **not complete on current main**. The forwarding getters are gone, but
the required follow-up is to replace the central runtime object itself with
typed per-kind catalog and entry contracts, migrate every caller to kind-owned
projection/capability access, and move provider preview decoding and edit
fallback out of generic services. Do not add more state to the bridge or grow a
new generic payload superset.

## Full Ownership Audit

### P0: Remove the metadata facade

`LibraryMetadataItem` no longer exposes forwarding getters, but its internal
interoperability catalog and `toCatalogItem()` still reconstruct a broad
`CatalogItem` and expose concrete schemas to callers. This is the largest
remaining compatibility shortcut.

Required sequence:

1. Define typed per-kind catalog and entry contracts on the existing kind
	runtime/capabilities for release/variant selection, creator presentation,
	links, and kind metadata.
2. Migrate add, edit, inspector, detail, export, metadata comparison, series, and
	 stats callers.
3. Keep `toCatalogItem()` only as an explicit transport/interoperability bridge.
4. Delete the forwarding getters and add a regression check forbidding their return.

Do not replace them with `GenericMediaMetadata`, `PublishingMetadata`, or another
cross-kind projection object.

### P0: Move provider preview mapping to kinds

`LibraryAddWorkflowService.metadataItemFromPreview` currently assembles item number,
publishing, music, video, game, series, creator, and release maps before invoking a
global decoder. The generic service therefore knows all production schemas.

The existing ownership path is sufficient:

```text
provider API -> NormalizedProviderEnvelopeV1 -> LibraryKindRuntime.providerMapper
						 -> typed kind metadata -> LibraryMetadataItem envelope
```

Each production kind already has a provider mapper under `kinds/*/provider/`. Route
the workflow through that mapper and keep `AdminProviderPreview` at the UI/API
boundary only. Do not return generic metadata plus corrections maps as the semantic
result.

### P0: Delete generic semantic presentation fallback

`workspace_presentation_support.dart` and the generic presentation builders contain
large semantic switches for video, music, game, publishing, creator roles, owned
details, and print fields. These are not universal presentation rules.

Move bucket labels, field labels, and value extraction to the registered typed field
definitions and kind presentation capabilities. Generic presentation may render a
descriptor, but it must not decide that a field named `series`, `publisher`,
`runtime`, `platform`, or `imprint` means the same thing for every kind.

### P0: Remove concrete owned-detail fallbacks

`generic/transferable_field.dart` directly handles concrete owned-detail types and
can create `MovieOwnedDetails` as a fallback when writing unsupported video fields.
That is both an ownership violation and a data-integrity risk.

The subtype-replacement fallback has been removed: unsupported video writes now leave
the existing owned-details value unchanged. The remaining concrete read/write switch
still belongs behind typed transfer definitions and remains a PR7/PR8 migration item.

Regression coverage now verifies kind-owned child-title callbacks and the generic
`Contents` fallback in
`test/features/library/hierarchy/library_hierarchy_capability_test.dart`.

Move read/write functions into typed transfer definitions owned by the kind runtime
or owned-details codec. Unsupported fields must fail explicitly or be unavailable;
they must never silently change the owned-details subtype.

### P1: Finish hierarchy ownership

`hierarchy/ui/hierarchy_children_section.dart` now delegates child labels to the
kind capability. `providers/seasons_provider.dart`,
`providers/volumes_provider.dart`, and the legacy section widgets must be removed or
made transport-only.

Generic hierarchy may know only `node`, `parent`, `children`, `level`, `label`,
secondary label, image, progress, actions, and ordering. TV owns seasons/episodes,
manga owns volumes/chapters, book owns its series/edition hierarchy, and music owns
discs/tracks. Child labels and loading must come from `LibraryHierarchyCapability`.

### P1: Reduce `LibraryTypeConfig`

`LibraryTypeConfig` currently duplicates runtime behavior and is involved in a
two-way ownership relationship with `LibraryKindRuntime`. It still carries
title-as-series fallback flags, edit/add/transfer behavior, field configuration,
and presentation wiring.

Move semantic behavior to the existing metadata, hierarchy, edit, transfer, add,
facet, and field capabilities. Retain only immutable presentation/composition data
such as labels, icon, workspace identity, and generic defaults. Remove
`manualAddUsesTitleAsSeries`, `editUsesTitleAsSeries`, and equivalent compatibility
lookups once their callers are migrated.

### P1: Hide the field registry

`LibraryKindRuntime.fields` exposes `LibraryFieldRegistry<dynamic, LibraryWorkspaceDto>`
even though `LibraryKindSpec<TDto, TDetails>` is typed internally. The registry then
recovers type safety with casts in `sortEntries`, `compareEntries`, `getGroupValue`,
and `getColumnValue`.

Expose only high-level runtime operations and available typed descriptors. Decode
preference/database strings at the boundary into `LibrarySortId`, `LibraryGroupId`,
and `LibraryFieldId`; runtime APIs must not receive raw strings. Migrate tests and
callers instead of preserving deprecated string wrappers.

### P1: Finish typed facets

`LibraryFacetDefinition<TKind, TDto, TValue>` is typed, but `LibraryFacetModule`
reintroduces `dynamic` definition collections and string facet IDs. Keep the
existing facet definitions and query/session machinery, but move extraction,
labels, and bucket construction behind the kind runtime. Generic UI should render
definitions and buckets only.

The same typed field identity should be reused where it covers facet identity; do
not create a second incompatible ID system.

### P1: Make edit state kind-owned

`LibraryEditDraft.fromFields` still initializes item number, publisher, edition,
barcode, variant, physical format, country, language, series, editions, and
variants. `KindEditDraft` exists, but `GenericEditDraft` remains the effective
fallback owner.

The generic edit shell should own lifecycle, responsive layout, navigation, save,
cancel, dirty state, generic validation, custom fields, image management, and
capability composition. Kind drafts should own semantic fields and submit payloads.
Remove generic fallbacks that assume publisher, series, barcode, number, format,
grading, episode, or volume semantics.

### P1: Complete the catalog transport split

`core/api/dto/catalog/catalog_item_dto.dart` is still a broad central superset. Its
factory and decode paths know about publishing, video, music, game, board-game
statistics, series, editions, trailers, comic fields, and compatibility fallbacks.

The existing `CatalogKindCodec` infrastructure should become the only known-kind
decode path:

```text
CatalogItemEnvelopeDto(common, payload)
	-> registry.require(kind).catalogCodec.decode(payload)
	-> typed kind catalog DTO
```

Restrict `GenericCatalogItemDto` and `_FallbackCatalogKindCodec` to explicit
unknown/legacy compatibility. Remove the central `switch (resolvedMediaKind)` after
all known-kind callers use the registry.

### P2: Unify provider and sync ownership

`ProviderConnector` and its capability interfaces exist, but the active
`ProviderRegistry` still stores the older `MetadataProvider` abstraction. Make the
connector registry the composition root, retaining old adapters only as connector
capabilities during migration.

`ExternalStateEngine` has useful isolated diff semantics, but it is not wired to
provider accounts, provider links, local tracking, sync policy persistence,
mutation origin, or sync runs. Wire those pieces only after connector ownership is
unified. AniList should be the first complete vertical slice, including pull, push,
link persistence, three-way conflicts, and echo protection.

## Recommended Implementation Order

| Priority | PR | Exit condition |
| :--- | :--- | :--- |
| P0 | PR1 metadata decomposition | No concrete fields/getters on `LibraryMetadataItem`; all callers use typed kind ownership. |
| P0 | PR2 catalog envelope/codecs | Known kinds decode through registry codecs; central DTO is a small transport envelope. |
| P1 | PR3 hierarchy | No generic Season/Episode/Volume/Chapter semantics or compatibility providers. |
| P1 | PR4 provider mappers | Generic add flow passes normalized envelope to the selected kind mapper. |
| P1 | PR5 runtime typing | No public string runtime APIs or dynamic field registry contract. |
| P1 | PR6 type config | `LibraryTypeConfig` is presentation/composition data only. |
| P1 | PR7 facets | Facet behavior uses typed identities and kind-owned extraction. |
| P1 | PR8 edit shell | Generic edit shell has no concrete kind semantics or subtype fallbacks. |
| P1 | PR9 architecture CI | Negative tests prevent the violations above from returning. |
| P2 | PR10-13 provider/sync | One connector registry, wired state engine, AniList vertical slice, unified services UI. |

Parallel completeness work should begin with manga, then anime, board game, book,
TV, music, game, movie, and comic. For every field, verify ownership across domain,
provider, mapper, persistence, DTO, projection, field definition, edit, export,
import, inspector, and tests. Every field must explicitly be media/work, release,
copy/personal, derived, or provenance data.

## Reusable Foundations Already Present

- `LibraryKindRuntime` and `LibraryKindRegistry` already compose the kind-owned
	metadata, hierarchy, inspector, edit, transfer, add, provider, facet, codec,
	projector, and owned-details capabilities.
- `LibraryKindMetadataRuntime` already supports kind-owned sync serialization.
- All nine production kinds are registered, and all have provider mapper classes.
- `NormalizedProviderEnvelopeV1` is an appropriate provider transport boundary.
- `CatalogKindCodec`, typed workspace DTOs, workspace projectors, field definitions,
	and preference codecs already exist.
- Hierarchy, edit, transfer, facet, inspector, and metadata capability interfaces
	exist and should be strengthened rather than duplicated.
- Existing registry validation, provider envelope tests, kind vertical-slice tests,
	and isolated sync-engine tests provide migration gates.

## Risks and Required Regression Coverage

- **Data loss:** remove forwarding only after every caller has a typed replacement;
	add metadata and sync round-trip tests.
- **Wrong kind routing:** test registry codec dispatch for every known kind and
	explicit unknown-kind behavior.
- **Owned-detail corruption:** test every transfer field against every owned-details
	subtype and assert unsupported writes do not create another subtype.
- **Preference breakage:** preserve decoding of qualified and legacy persisted IDs at
	the boundary while removing string IDs from runtime APIs.
- **Payload drift:** test missing, malformed, flattened legacy, and envelope-shaped
	provider/catalog payloads at transport boundaries only.
- **Circular config/runtime ownership:** validate registry initialization and module
	construction after reducing `LibraryTypeConfig`.
- **Architecture regression:** extend
	`tool/check_library_kind_boundaries.dart` with negative cases for concrete imports,
	kind switches, semantic hierarchy types, string runtime APIs, dynamic registries,
	broad metadata getters, and central codec switches.

## Validation Gate

Run after every migration PR:

```powershell
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-warnings --fatal-infos
flutter test
dart run tool/check_library_kind_boundaries.dart
```

Run Core `pytest` and its repository checks whenever Core DTOs, provider transport,
or sync persistence are changed. No PR is complete while compatibility wrappers are
merely deprecated, while a generic fallback still decides kind semantics, or while
the new path is covered only by positive tests without architecture-negative tests.
