# Typed-kind parity final

> Historical completion snapshot. The status below is tied to its stated
> checkpoint and is retained as a record of that migration. It is not a current
> architecture audit; check the live source tree and current-status document.

> Current code checkpoint: `8f739e24e` (2026-09-14). AST architecture
> violations: **0**; complexity reports: **401** informational; fatal Flutter
> analyzer: **0 issues**; affected tests: **all passed**. TV and Anime custom
> episodes are fully kind-owned across domain, persistence, seeds, UI mutations
> and schema-v1 sync codecs. TMDb Movie/TV/Anime import mapping is kind-owned;
> generic Add bundle state uses only a structural summary. The matrix below is
> still a completion audit, not a claim that every remaining milestone is done.

> Updated checkpoint: `8f739e24e` (2026-09-14). AST architecture violations: **0**; complexity reports: **403** informational; `flutter analyze --fatal-warnings --fatal-infos`: **0 issues**. Shared workspace card chrome consumes kind-owned structural projections, generic Library/Shelf actions resolve transport by refs, workspace bucket/repository and metadata comparison paths use explicit schema-v1 transport values, all nine workspace projectors decode transport only inside the owning kind, and generic catalog mutations consume explicit transport values. The matrix below remains historical until all completion milestones pass.

> Current checkpoint: `84c9faf2` (2026-09-11). AST architecture violations: **0**. Complexity-budget reports: **400** informational reports. Concrete catalog codecs and kind-owned Owned persistence now back Collection CSV import, sync apply/retry, dev-seed writes through structural schema-v1 payloads. Mixed catalog repositories now use the non-generic `CatalogKindTransportBoundary`, with explicit `upsertTransportItems` writes; the public registry stores concrete kind registrations behind a tiny identity boundary and isolates navigation in `LibraryKindNavigationRegistration`; the obsolete `LibraryKindModule`/`LibraryKindSpec` facade names are gone and per-kind wiring is composition-only. Generated feature capability maps cover all nine kinds and are contract-tested. Add/Edit/provider search share `CatalogSearchCandidate`; Library Owned transport now uses concrete `LibraryOwnedItemDispatch` callbacks with no erased `Object?` value; all nine provider mappers and Add projections decode typed metadata before creating candidates; Provider Add ingest/dialog lifecycle is isolated in `LibraryProviderAddCoordinator`. The latest focused batches move affected tests to concrete registrations, preserve typed CSV v1 in-memory dispatch, remove stale planned-media naming, fix Music provider-track/Owned mutation typing, and retain `CatalogMediaKind` in provider envelopes after the wire edge. Full CI baseline remains pending.
>
> Schema policy remains version 1; no compatibility-upgrade path is being added. Remaining debt is tracked by the current branch audit.


Authoritative checkpoint: current HEAD `f1cf410c`, 2026-09-11. The migration checker now
reports **0 AST architecture violations** and **400 complexity-budget
reports**. Complexity reports are informational and are not included in the
AST count. The analyzer has no compile errors; warning/info output is
non-gating.

The latest code-only batches narrow generic linked metadata/bucket mutation and
structural export/selection paths. The preceding code-only batch deletes the mixed `LibraryEntry`/`workspaceEntries`
compatibility layer, makes `ShelfState.entries` the structural workspace
source list, removes generic report payload inspection, and keeps catalog
transport behind explicit boundary access. It passes the architecture
contract suite plus the focused Shelf/projection regression batch.
The preceding seed batch updates all nine dev-seed contributors and validators
from `trackingEntries` to `trackingLifecycles`, preserving the v1
`tracking_entry` wire/DB key. The preceding code-only batch removes the remaining `TrackingEntry` compatibility
vocabulary from lifecycle refs, mutation/editor callbacks, kind tracking
factories, tests, and registry generation. Collection import is now an
orchestration host and owned writes are executable operations rather than a
mixed `(kind, Object)` list. The v1 wire/DB identifier remains unchanged.

Audit basis: the focused affected test batches, the all-kind contract matrix,
the release/tracking/provider matrices, and the architecture contract suite.
The repository-wide fatal analyzer and full test suite were not rerun for
`2084aefc`.

The latest tracking-unit cleanup renames the remaining shared base to
`TrackingUnitSummary`, making its structural-only role explicit while concrete
kind tracking units retain their own coordinates. The preceding tracking-unit persistence cleanup deletes the universal
`TrackingUnitsCache` table and puts complete unit rows in the applicable kind
tables. The preceding schema-v1 cleanup removes redundant tracking `itemId` columns and
legacy fallback reconstruction: required catalog/target refs are stored as JSON
and indexed by `(kind,id)`. `TrackingSummary` no longer leaks progress counters,
and TMDb import settings are provider-owned. The preceding tracking cleanup replaces naked tracking-entry ids with
`TrackingEntryRef` and makes all nine tracking codecs create and
reconstruct concrete kind entries; Collection mutations and CSV import now
dispatch creation through the owning codec. The latest catalog cleanup keeps kind dispatch typed through lookup, snapshot,
summary, and physical-format repository APIs. The latest tracking cleanup separates structural summary reads from full
persistence aggregate reads; global Shelf/Activity paths no longer rehydrate
tracking coordinate tables. The latest registry cleanup deletes the generated
cross-kind ownership export barrel. The latest Owned cleanup deletes the production common `OwnedItem<TDetails>`
aggregate and its reverse summary adapter; all structural IDs now use the
reference primitives and test fixtures are explicitly test-only. The latest
edit cleanup removes common `OwnedItem` from generic edit requests,
drafts, shell callbacks, and page coordinators; each kind initializes its
personal edit state from its concrete Owned model and transfer fallbacks no
longer accept common Owned values. The latest Shelf/workspace cleanup removes common `OwnedItem` from mixed
ShelfEntry, workspace/filter/report/share paths and moves CSV condition/index/
tag presentation reads into all nine typed kind projections. The latest
release/drilldown cleanup removes common `OwnedItem` from generic
video release, Movie drilldown, bulk-action, and group-bucket APIs by using
`OwnedItemSummary`; the transfer cleanup removes common `OwnedItem` from the generic
transfer host. `TransferableOwnedItem` carries structural refs and an opaque
typed value while all nine kind modules own universal and semantic transfer
fields. The preceding cleanup removes `OwnedItem` from the generic
transfer-patch builder and moves typed decoding/field reads into all nine kind modules. The
preceding Owned projection cleanup removed the final common-to-kind reverse
constructor from Comic after removing the same dead APIs from eight kind
modules. The preceding typed-edit/transport batch renamed generic catalog codecs as
transport-only and removed the common-Owned fallback from all nine kind edit
factories. The latest typed-owned-value batch moved transfer-value fields into all nine
kind modules, renamed the generic edit surface to structural collection-value
terminology, and isolated common JSON maps at explicit serialization
boundaries. The final common-owned value batch also removed the generic
`OwnedItem.grade` identifier from in-memory code, retaining the v1 `grade` key
only at serialization boundaries. The latest typed-presentation batch moved generic release/link/search/preview
inputs to `LibraryAddCatalogItem`. The latest Shelf-boundary batch moved mixed Shelf/workspace snapshots to
`LibraryAddCatalogItem`; the latest edit-boundary batch moved generic edit flows to
the same transport boundary. The
latest concrete-dispatch batch removed registry lookup loops from the
all-kind Owned/Add/Vocabulary/completeness contract tests. The common tracking
target boundary is complete: `TrackingEntry` and
`TrackingUnit` use `OwnedItemRef` in memory, each kind codec reconstructs the
typed ref, and schema-v1 storage/sync boundaries serialize the complete ref.
The remaining global tracking debt is semantic progress storage, not naked
Owned identity.

The latest Collection CSV batch moves concrete Owned and tracking import
construction into all nine kind projections. The host now carries only
schema-v1 transport values and opaque kind cells; no wire/schema change was
made. The all-kind CSV contract instantiates every concrete Owned aggregate.

The item-image boundary is also complete: `ItemImage` and all image/cover
repository, UI, seed, and sync paths use `OwnedItemRef`; schema-v1 image
storage serializes the complete `kind:id` key without a migration.

The catalog-reference boundary is now typed in memory as well:
`CatalogEntityRef` stores `CatalogMediaKind` and an opaque `CatalogEntityTypeId`,
while API/DB/sync serialization continues to use the existing string values.
An optional opaque `parent_id` preserves nested release/edition context without
introducing kind semantics into core; the database schema remains version 1.

The current follow-up also removes string-ID catalog snapshot lookup methods
and raw string kind access from `LibraryAddCatalogItem`. Feature-layer release
and collection code now consumes the typed Add transport wrapper; wire/schema
v1 serialization remains unchanged.

The common `OwnedDetailsDraft` hierarchy and production generic OwnedDetails
codec registry are deleted. Kind Add/Edit drafts now
cross the generic host only as `JsonEncodable`, while each kind retains its
concrete draft and codec semantics.

The generated common-Owned reader used by Library detail was also deleted in
`83370c21`; loaded detail copies use `OwnedItemSummary` and `OwnedItemRef`.
The duplicate feature-level metadata search input was deleted in `84a42e27`;
Core `MetadataSearchQuery` is now the only query object at that transport
boundary.

The generic Owned Add command and `LibraryAddCapability` now transport
`CatalogEntityRef` directly. They no longer carry `PersonalItemAnchor`.
All nine kind-owned Owned aggregates, create/update payloads, edit drafts,
projections, local mappers, JSON/sync codecs, and persistence round-trips also
use typed target refs in memory. The `PersonalItemAnchor` domain object, file,
imports, and enum parsing have now been deleted from common Owned/edit-selection
code and tests. Remaining anchor usage is limited to raw v1 persistence/sync
field names in the common serialization boundary; schema version 1 and wire
payloads are unchanged.

Commit `b7d5d22` and its preceding typed-ref batches pass the focused all-kind local
mapper/round-trip, tracking, and edit test batches. The common edit result now
uses `CatalogEntityRef? targetRef`; the checker is now at **140 AST violations**
and **404 complexity reports**.

Library metadata search/cache/barcode workflows now return structural
`CatalogSearchCandidate` values. Core transport DTOs are decoded and retained
inside the catalog transport candidate, then unwrapped only at explicit
selection/import boundaries.

Owned persistence and sync dispatch no longer use generated erased operation
maps. Concrete kind functions validate the expected Owned type at the dispatch
boundary, and sync retry requires the local payload's catalog ref to construct
an `OwnedItemRef`; no bare-ID cross-kind scan remains in that path. Schema-v1
sync payloads are unchanged.

Latest verification at `f5f4a857`: focused detail, video, inspector, and
workspace tests pass; the checker reports **0 AST violations** and **405
complexity-budget reports**. The last recorded
full suite reported 1,904 passed, 5 skipped, and 27 remaining failures in
architecture, fixture, and UI expectation tests; that figure is historical,
not a rerun for commit `479781ef`. The latest focused Add, Reading Queue,
projection, insurance-value, workspace-session, and coordinator tests pass.
`flutter analyze --no-fatal-infos` reports no errors and 281 warning/info
issues.

Global Activity, Calendar, Loans, Shelf, and Home overdue projections now use
`OwnedItemRef` map/set keys, with a regression contract for equal IDs across
different kinds. No schema-v1 serialization field was changed.

Global Activity now consumes `TrackingActivitySummary` instead of full
`TrackingEntry`; hierarchy/progress/provider-specific tracking remains outside
the mixed projection.

Mixed Shelf `TrackingSummary` is also structural: it carries status, rating,
lifecycle timestamps, notes, and deletion state. `ShelfState` and the nine kind
contract/domain consumers no longer carry full `TrackingEntry`; bulk removal
resolves a v1 row only at the mutation boundary. No schema-v1 or wire-format
change was introduced.

Add owned-target checks, replacement-value aggregation, page metadata lookup,
and generic active-loan projection joins now use complete `CatalogEntityRef` or
`OwnedItemRef` values. No schema-v1 or wire-format change was introduced.

The former generic `LibraryWorkspaceEntry` compatibility name is now
`LibraryWorkspaceSource`, which is structural and no longer carries
`CatalogItemDto`, common `OwnedItem`, `kindMetadata`, or semantic Owned
getters. `ShelfEntry` retains those v1 transport objects only for explicit
export/inspector and kind CSV presentation boundaries. Shelf no longer feeds
workspace state full Tracking or common Owned collections.

Mixed `LibraryEntry`/`LibraryWorkspaceSource` consumers no longer allocate the
common `MediaTracking` wrapper. CSV, workspace, filters, and stats read the
structural tracking fields directly. Universal common tracking persistence
remains a separate unfinished cutover.

Metadata-correction proposal fields now cross the generic host through
`LibraryMetadataCorrectionValues`; kind contributors own the field codecs and
serialized maps remain only at the provider boundary. The separate Admin
catalog-correction form still needs the typed per-kind schema migration.

The central catalog entity-type enum was also removed. `CatalogEntityTypeId`
is immutable and value-based; generic refs transport opaque IDs and only the
serialization boundary knows their v1 string representation.

The current provider boundary is explicit as well: TMDb import implementation
and its preview/history/pending infrastructure live under providers, metadata
proposal callers pass `CatalogMediaKind`, and provider-to-kind tracking import
uses a structural contribution contract registered at the composition root.
The v1 CSV schema is isolated without changing its wire columns. The neutral
Owned-copy summary boundary is included in `bf45601e`, and the Core structural
tracking summary boundary is included in `35eb981f`; the current checker
result remains **0 AST violations** and **403 complexity reports**.

| Area | Comic | Manga | Book | Game | BoardGame | Movie | TV | Anime | Music |
|---|---|---|---|---|---|---|---|---|---|
| Core DTO mapping | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Core field policy | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media domain | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release domain | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned details | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Tracking domain | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release local DB | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Tracking local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Repository | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Workspace | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Fields | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Columns | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Sorts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Groups | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Facets | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Vocabularies | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Add schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media Edit schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release Edit schema | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned Edit schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Hierarchy | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Provider integrations | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Provider dependency direction | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Stats | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Value | PASS | N/A | N/A | N/A | N/A | PASS | N/A | N/A | N/A |
| Mandatory contracts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Capability contracts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| No cross-kind imports | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| No erased catalog metadata | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL |
| No false-common domain layer | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |

## Global audit status

| Check | Status |
|---|---|
| Nine active kinds are represented | PASS |
| Release participants are explicit | PASS |
| Tracking participants are explicit | PASS |
| Provider-kind pairs are explicit | PASS |
| Domain test suite | PASS |
| No erased catalog metadata | FAIL |

The erased-metadata FAIL is intentional and remains the main migration gate.
The remaining occurrences are migration surfaces and generic transport
boundaries; they are not counted as kind parity until the final deletion pass
removes or reclassifies them. The current branch audit records the remaining
debt; implementation plans are intentionally not retained in the repository.
## Current checkpoint — 2026-09-11 (`a0ec1440`)

- AST architecture violations: **0**.
- Informational complexity reports: **403**.
- Schema version: **1**; no compatibility upgrade path is being added.
- Tracking persistence: **PASS** for all nine kind-owned entry codecs and all
  applicable kind-owned unit codecs; universal cache tables/repositories are
  deleted.
- Focused migration/architecture suites: **PASS**.

Current code checkpoint: **bc1732c4**. The former common `TrackingUnit` base
is now `TrackingUnitSummary`; concrete coordinate models remain kind-owned.
Provider metadata transport is now `ProviderMetadataEnvelope`; no
`NormalizedProviderEnvelopeV1` symbol remains in code.
Docs are intentionally uncommitted.
