# Collectarr App — Full Typed-Kind Architecture Migration Plan

## Final Architecture Invariants

### A. Kind ownership

A kind owns **every representation of its domain data**:

- generated Core DTO mapping
- app domain models
- media model
- release/edition model when applicable
- local Drift tables
- local DB mapping
- repositories
- owned details
- tracking details
- fields
- columns
- sorts
- groups
- facets
- vocabularies
- Add
- Media Edit
- Release Edit
- Owned Edit
- hierarchy
- provider metadata integrations
- stats/value semantics

### B. Never erase the type

After dispatching to a concrete kind, never convert its domain object through:

- `CatalogItemDto`
- `LibraryMetadataItem`
- `LibraryCatalogItemView`
- `LibraryKindMetadataRuntime`
- generic metadata `Map<String, dynamic>`
- `dynamic`

Serialization may erase the type **only at real boundaries**:

- HTTP
- DB
- provider protocol
- sync persistence

Immediately after reading from a boundary, decode into the concrete kind type.

### C. Minimal sharing

Prefer duplication between kinds.

Do **not** introduce domain abstractions merely because fields happen to share names.

Allowed duplication examples:

- `Comic.publisher` and `Manga.publisher`
- `Movie.region` and `TV.region`
- `Anime.audioTracks` and `Movie.audioTracks`
- `Comic.releaseDate` and `Game.releaseDate`

Do **not** create:

- `CommonPublishingMetadata`
- `CommonMediaMetadata`
- `CommonReleaseMetadata`
- `CommonSerialMetadata`
- `PrintMediaMetadata`
- `VideoMetadata`
- `PublishingEditDraft`
- `VideoEditDraft`
- `SharedPublisherFields`
- `SharedReleaseFields`
- `DefaultMediaTabs`
- `DefaultReleaseTabs`
- `SharedVideoRepository`
- `GenericCatalogItemV2`
- `KindMetadataRuntimeV2`

### D. Dependency rules

- `kinds/X` must **never** import `kinds/Y`.
- `providers/**` must **never** import `library/kinds/**`.
- provider-native models belong to providers.
- Provider → Kind semantic mapping belongs to the target kind.
- Kind → Provider write mapping also belongs to the kind.
- generic personal sync mapping to `ProviderPersonalEntry` remains provider-owned.

### E. Declarative Add/Edit

Every kind explicitly declares:

- its Media Edit tabs
- Media Edit sections
- Media Edit fields

Every release-capable kind explicitly declares:

- Release Edit tabs
- Release Edit sections
- Release Edit fields

Every kind explicitly declares its Add schema.

No global default production tabs.
No global semantic section registry.
No implicit publishing/video/media schemas.

### F. Core evolution

Every generated Core DTO field must be explicitly classified by the owning kind as:

- mapped
- intentionally ignored

New Core fields may never silently enter the App without classification.

### G. Testing

If behavior is promised by multiple kinds, it **must** be represented by a reusable typed contract test and run against **every applicable kind**.

Testing generic behavior with one representative kind is insufficient.

**Share tests more aggressively than production domain code.**

### H. Execution

Before implementing:

- inspect current `main`
- identify already-completed work
- do not recreate it

Prefer:

- DELETE
- MOVE
- DUPLICATE
- SIMPLIFY

over compatibility layers.

After every PR run:

```bash
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-warnings --fatal-infos
flutter test
dart run tool/check_library_kind_boundaries.dart
```

Also run any newly introduced contract/schema checkers.

Report results and **STOP**.
Do not automatically start the next PR.

---

# Final Target Structure

A mature kind should look approximately like:

```text
kinds/comic/

  comic_kind.dart
  comic_registration.dart

  domain/
    comic_media.dart
    comic_release.dart
    comic_owned_details.dart
    comic_tracking.dart
    comic_ids.dart

  data/
    remote/
      comic_core_mapper.dart
      comic_remote_source.dart

    local/
      comic_media_table.dart
      comic_release_table.dart
      comic_owned_details_table.dart
      comic_tracking_tables.dart
      comic_local_mapper.dart
      comic_dao.dart

    providers/
      comicvine/
        comic_comicvine_mapper.dart
        comic_comicvine_integration.dart

      metron/
        comic_metron_mapper.dart
        comic_metron_integration.dart

    comic_repository.dart

  workspace/
    comic_workspace_dto.dart
    comic_fields.dart
    comic_columns.dart
    comic_sorts.dart
    comic_groups.dart
    comic_facets.dart

  vocabulary/
    comic_vocabularies.dart

  add/
    comic_add_draft.dart
    comic_add_schema.dart
    comic_add_search.dart

  edit/
    media/
      comic_media_edit_draft.dart
      comic_media_edit_schema.dart
      comic_media_edit_mapper.dart

    release/
      comic_release_edit_draft.dart
      comic_release_edit_schema.dart
      comic_release_edit_mapper.dart

    owned/
      comic_owned_edit_draft.dart
      comic_owned_edit_schema.dart

  hierarchy/
    comic_hierarchy.dart

  stats/
    comic_stats.dart

  value/
    comic_value.dart
```

Not every kind needs every folder.

**Absence of a module = capability absent.**

No need for `supportsRelease = false` if a kind simply has no Release module.

---

# PHASE 0 — Baseline and Safety Net

## PR 0 — Architecture inventory

### Objective

Capture the exact architecture debt before migration.

### Inventory

Search current `main` for:

```text
CatalogItemDto
CatalogItem
CatalogKindCodec

LibraryKindMetadataRuntime
LibraryKindMetadataDecoders

LibraryMetadataItem
LibraryCatalogItemView

LibraryKindRuntime
LibraryKindSpec

Map<String, dynamic>
dynamic

OwnedItemDetails
comicDetails
mangaDetails
movieDetails
tvDetails
animeDetails
gameDetails

KindEditDraft
GenericEditDraft
VideoEditDraft

LibrarySectionRegistry
DefaultLibraryEditPresentationBuilder

CatalogCache
OwnedItemsCache
TrackingEntriesCache
TrackingUnitsCache
WatchSessionsCache

NormalizedProviderEnvelope
```

### Produce

```text
docs/typed-kind-architecture-baseline.md
```

For every suspect:

```text
symbol
file
responsibility
type-erasure?
semantic leak?
target owner
target PR
```

### No architecture change

This PR is audit-only unless current `main` already fails build/tests.

---

## PR 1 — Introduce architecture checker baseline

Extend the checker enough to record but not yet reject all future architecture rules.

Add detection for:

```text
cross-kind imports
provider -> kind imports

kind generated DTO imports outside matching kind

generic metadata Map usage
dynamic catalog objects
```

Initially allowlist existing migration debt.

This gives us a shrinking allowlist.

---

# PHASE 1 — Test Architecture First

## PR 2 — Typed contract-test infrastructure

Create:

```text
test/contracts/
```

with typed reusable suites.

Initial contracts:

```text
kind_identity_contract.dart

core_mapping_contract.dart
core_field_adoption_contract.dart

repository_contract.dart
persistence_contract.dart

workspace_contract.dart
fields_contract.dart
sort_contract.dart
group_contract.dart
facet_contract.dart
vocabulary_contract.dart

add_contract.dart

media_edit_contract.dart
release_edit_contract.dart
owned_edit_contract.dart

provider_integration_contract.dart

tracking_contract.dart
```

Contract helpers may be generic.

Production domain must not change merely to accommodate the tests.

---

## PR 3 — Core DTO field adoption checker

Implement test/tooling which compares generated DTO fields against explicit kind policy.

Example test-only configuration:

```dart
CoreDtoFieldPolicy(
  dtoName: 'ComicWorkDto',

  mapped: {
    'id',
    'title',
    'publisher',
    'issueNumber',
  },

  intentionallyIgnored: {
    ignored(
      'legacySlug',
      reason: 'Core-only compatibility field',
    ),
  },
);
```

If Core later adds:

```text
firstPrintingDate
```

the test must fail with something like:

```text
ComicWorkDto contains an unclassified field:
firstPrintingDate

Classify as:
- mapped
- intentionallyIgnored
```

### Important

Policy stays test/tooling-only.

Do not add another runtime abstraction for this.

---

## PR 4 — Meta-contract manifest

Create a test manifest guaranteeing all nine kinds participate in mandatory contracts.

Mandatory:

```text
Core mapping
repository
media persistence
workspace
fields
Add
Media Edit
identity
```

Optional contracts explicitly declared:

```text
Release
Release Edit
Release persistence
Tracking
Hierarchy
Provider integration
```

This prevents accidentally testing shared behavior only against Comic.

---

# PHASE 2 — Tiny Dispatch Boundary

## PR 5 — Introduce `LibraryKindRegistration`

Create a very small erased entry point:

```dart
abstract interface class LibraryKindRegistration {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;

  Widget buildLibraryPage(...);

  Widget buildAdd(...);

  Future<void> openMediaEdit(...);

  Future<void> openReleaseEdit(...);
}
```

Do not migrate everything yet.

Current runtime may remain temporarily behind compatibility.

---

## PR 6 — Stop extending `LibraryKindRuntime`

Mark the giant runtime surface as migration-only.

No new methods such as:

```text
columnValue()
groupValue()
sort()
project()
codec
ownedDetailsDecoder
providerMapper
```

may be added.

Start moving callers toward concrete kind modules.

---

# PHASE 3 — Declarative Edit Infrastructure

## PR 7 — Structural `EditSchema`

Create structural renderer models:

```dart
EditSchema<TModel, TDraft>
EditTabSpec<TDraft>
EditSectionSpec<TDraft>
EditFieldSpec<TDraft>
```

Shared field specs:

```text
TextEditField
NumberEditField
DateEditField
MoneyEditField
ToggleEditField
SelectEditField<T>
VocabularyEditField<T>
MultiVocabularyEditField<T>
ImageEditField
ReadOnlyEditField
CustomEditField
```

No media semantics.

---

## PR 8 — Generic Edit renderer

Create one renderer capable of consuming any:

```dart
EditSchema<TModel, TDraft>
```

Renderer owns:

```text
tabs UI
sections UI
field layout
validation display
dirty state
save/cancel
responsive layout
```

It does **not** own:

```text
which tabs
which fields
which labels
which vocabularies
```

---

## PR 9 — Structural `AddSchema`

Equivalent:

```dart
AddSchema<TDraft>
AddSectionSpec<TDraft>
AddFieldSpec<TDraft>
```

Reuse visual field primitives where sensible.

Do not share semantic field definitions.

---

## PR 10 — Generic Add renderer

One renderer.

Kind declares content.

Renderer declares visual grammar.

---

# PHASE 4 — Comic Reference Implementation

Comic proves the architecture before migrating everything else.

## PR 11 — Comic domain split

Introduce explicit:

```text
ComicMedia
ComicRelease
ComicOwnedDetails
ComicTracking details as needed

ComicMediaId
ComicReleaseId
```

Migrate existing `ComicCatalogMetadata` semantics toward `ComicMedia`.

No generic catalog inheritance beyond truly structural interfaces.

---

## PR 12 — Comic Core mapper

Create:

```text
comic/data/remote/comic_core_mapper.dart
comic/data/remote/comic_remote_source.dart
```

Direct:

```text
ComicWorkDto
→ ComicMedia
```

No intermediate:

```text
CatalogItemDto
Map payload
LibraryKindMetadataRuntime
```

Add:

```text
Comic Core mapping contract
Comic Core field adoption test
```

---

## PR 13 — Comic local media/release schema

Move Comic persistence schema under Comic.

Create typed Drift tables.

Possible:

```text
ComicMediaRows
ComicReleaseRows
```

Nested arrays may still be JSON columns if that is the appropriate storage representation.

Only Comic interprets them.

---

## PR 14 — Comic local mapper + persistence contract

Implement:

```text
ComicMedia ↔ ComicMediaRow
ComicRelease ↔ ComicReleaseRow
```

Tests:

```text
minimal round trip
full round trip
nullable values
lists
unicode
nested values
```

---

## PR 15 — Comic repository

Create typed API:

```dart
Future<ComicMedia?> getMedia(...);
Future<List<ComicMedia>> search(...);

Future<List<ComicRelease>> releasesFor(...);
Future<ComicRelease?> getRelease(...);

Future<void> updateMedia(...);
Future<void> updateRelease(...);
```

Hide remote/cache policy.

No generic Catalog objects leave the repository.

---

## PR 16 — Comic workspace typed

Create/finish:

```text
ComicWorkspaceDto
ComicWorkspaceProjector

ComicFields
ComicColumns
ComicSorts
ComicGroups
ComicFacets
```

All operate on Comic types.

Add all workspace contracts.

---

## PR 17 — Comic vocabulary ownership

Comic declares all concrete vocabularies.

Examples:

```text
publisher
imprint
condition if kind-specific
grade
page quality
key categories
formats
story arcs
```

No global Comic defaults.

Add vocabulary contract.

---

## PR 18 — Comic Add schema

Create one readable:

```text
comic_add_schema.dart
```

Explicitly declares:

```text
sections
fields
ordering
visibility
vocabulary bindings
validation
```

No generic publishing schema.

---

## PR 19 — Comic Media Edit schema

Create:

```text
comic/edit/media/
```

One schema file should make the form understandable without looking elsewhere.

Explicit:

```text
tabs
sections
fields
visibility
validation
```

Add Media Edit contract.

---

## PR 20 — Comic Release Edit schema

If Comic release semantics are distinct, create:

```text
comic/edit/release/
```

Explicit release/edition/variant/identifier fields.

Add Release + Release Edit contracts.

---

## PR 21 — Comic Owned Edit

Move grading/key/collector fields to:

```text
comic/edit/owned/
```

No generic:

```text
showsComicCollectorFields
keyComicLabel
```

Add Owned Edit contract.

---

## PR 22 — Comic hierarchy/stats/value typed

Remove remaining Comic semantics from generic hierarchy/stats layers.

Comic owns:

```text
series/issue hierarchy
key-comic stats
cover-price stats
Comic-specific grouping
```

---

# PHASE 5 — Provider/Kind Architecture

## PR 23 — Provider dependency rules

Enforce:

```text
providers/** -> kinds/**
FORBIDDEN
```

Provider is allowed to know only:

```text
CatalogMediaKind identity
provider-native DTOs
provider protocol
```

---

## PR 24 — Provider-native metadata models

For each existing provider, ensure native models remain provider-owned.

Examples:

```text
AniListAnime
AniListManga

TmdbMovie
TmdbTvSeries

ComicVineIssue
ComicVineVolume
```

No kind models imported.

---

## PR 25 — Generic provider search hit becomes summary-only

Canonical generic metadata search result:

```dart
ProviderSearchHit {
  ProviderId providerId;
  CatalogMediaKind kind;
  String remoteId;

  String title;
  String? subtitle;
  String? imageUrl;
}
```

No full normalized god metadata envelope required for Add/search.

---

## PR 26 — Comic provider integrations

For each Comic metadata provider:

```text
comic/data/providers/<provider>/
```

Mapper:

```text
ProviderNativeComic
→ ComicMedia / ComicRelease
```

Provider remains unaware of Comic.

Add provider integration contract for every integration.

---

## PR 27 — Kind-owned reverse provider mapping

Where metadata writeback exists:

```text
ComicMedia
→ ComicProviderWriteMapper
→ Provider-native mutation input
→ Provider client
```

Still owned by Comic.

Provider never imports Comic.

### Status (2026-09-03)

Not applicable in the current checkout. Metadata providers expose only
read-oriented `search` and `fetchItem` capabilities. The provider write APIs
currently present are personal-list synchronization and Core ingest/admin
operations; there is no provider metadata mutation endpoint or client
capability to map into. Do not add a speculative reverse mapper. Resume this
PR only when metadata writeback is introduced; until then, continue with PR 28
and keep its personal-sync path separate from catalog metadata.

---

## PR 28 — Personal provider sync explicitly separate

Document and enforce:

```text
METADATA:
provider-native DTO
→ kind-owned mapper
→ kind domain

PERSONAL:
provider list DTO
→ provider-owned mapper
→ ProviderPersonalEntry
→ ExternalStateEngine
```

Do not mix catalog metadata into `ExternalStateEngine`.

### Status (2026-09-03)

Structurally present in the current checkout: provider personal-list mappers,
file import capabilities, and `ExternalStateEngine` use
`ProviderPersonalEntry`, while kind-owned metadata mapping remains separate.
Durable account/link persistence is now backed by the shared Drift database,
while provider credentials remain in secure storage. Sync-policy persistence
and directional filtering, three-way conflict handling, and echo protection
are covered by the AniList vertical slice. The importer framework and TMDB preview path now consume
`ProviderPersonalEntry` end to end; the duplicate `ImportRow` representation
and its conversion bridge are removed, and `MutationOrigin.fileImport` reaches
the typed apply callback. Production import jobs now carry their origin through
collection mutations, and file imports are prevented from writing back to
external providers. TMDB account imports now persist a stable account identity
and create links with the imported provider snapshot after local application.
All supported file-import surfaces now offer explicit provider-account
selection; imports without a selected account remain intentionally unlinked.
Production collection mutations now read local tracking/wishlist state and
push linked changes through the coordinator, while provider pulls apply back
through the same typed mutation path. The PR remains open for the remaining
provider personal-list integrations described in Phase 7. Continue from this
PR; do not reopen PR27
without a provider metadata writeback capability.

---

# PHASE 6 — Owned State

## PR 29 — `OwnedItem<TDetails>`

Refactor:

```dart
OwnedItem<TDetails>
```

Universal fields only:

```text
identity
quantity
purchase info
owner/location
notes
sale state if universal
```

Kind details:

```text
TDetails
```

Delete runtime helper getters:

```text
comicDetails
mangaDetails
movieDetails
...
```

### Status (2026-09-03)

The model now carries `TDetails extends OwnedItemDetails`, and its constructor,
JSON factory, and `copyWith` preserve that concrete details type. Existing
kind call sites now read and write their concrete `details` type, including
shared collection, inspector, export, and video-like surfaces. The runtime
per-kind detail getters and compatibility helpers have been removed. PR29 is
complete; continue with PR30.

---

## PR 30 — Base Owned DB cleanup

Reduce generic ownership table to genuinely universal state.

Review every column.

Move:

```text
Comic grading
key comic
HDR
video packaging
game completeness
etc.
```

out.

### Status (2026-09-03)

Complete. `OwnedItemsCache` now keeps only universal ownership state plus the
persisted `kind` and opaque `detailsJson` payload. The v9-to-v10 migration
preserves legacy Comic, video, and Game values, prefers `CatalogCache.kind`
when it can identify the owned item, and falls back to legacy-column
inference otherwise. Repository round-trip and malformed-payload fallback
tests cover the new storage contract. Continue with PR31.

---

## PR 31 — Comic owned details DB

Create:

```text
ComicOwnedDetailsRows
```

### Status (2026-09-03)

Complete for the typed persistence slice. `ComicOwnedDetailsRows` is registered
in the local Drift database with typed scalar columns for all Comic-owned
details, and `ComicLocalMapper` provides validated row conversions. Schema 11
creates the table on v10 upgrades and preserves the v9-to-v11 migration path.
Mapper, schema-registration, and migration tests cover populated/default rows,
nullable values, UTC dates, identity validation, and existing cache
preservation. `OwnedItemsCache.detailsJson` remains the canonical generic
cache/sync representation; this PR does not dual-write or change generic
repository authority. Continue with PR32.

under Comic.

Round-trip contract.

---

# PHASE 7 — Manga

## PR 32 — Manga domain + Core mapper

Independent:

```text
MangaMedia
MangaRelease/Edition if needed
MangaOwnedDetails

MangaWorkDto
→ MangaMedia
```

Do not import Comic.

Core adoption tests.

### Status (2026-09-03)

Complete. `MangaMedia` now owns the direct Core work projection, and
`MangaCoreMapper` maps every `MangaWorkDto` field without passing through
`CatalogItemDto`, Book semantics, or another kind module. `ApiMangaRemoteSource`
provides the injectable Core fetch boundary. The compatibility Manga mapper
now returns `MangaCatalog` instead of delegating to Book. Focused tests cover
field mapping, kind validation, remote fetching, round-trip preservation, and
explicit Core field adoption. Continue with PR33.

---

## PR 33 — Manga local DB + repository

Create Manga-owned:

```text
media tables
release tables if required
owned detail tables
local mapper
repository
```

Persistence contracts.

### Status (2026-09-03)

Complete. `MangaMediaRows` and `MangaOwnedDetailsRows` are registered as
Manga-owned Drift tables in schema v12. `MangaLocalMapper` provides validated
media and owned-details row conversions, preserving Manga lists as explicitly
named JSON columns and owned fields as typed scalar columns. `MangaRepository`
supports cache-first media reads, deterministic search, upserts, owned-details
round-trips, and typed remote fallback. Focused schema, mapper, repository,
and v10-to-v12 migration tests cover the persistence contract. Continue with
PR34.

---

## PR 34 — Manga workspace + vocabularies

Independent:

```text
MangaWorkspaceDto
MangaFields
MangaColumns
MangaSorts
MangaGroups
MangaFacets
MangaVocabularies
```

Duplication with Comic is intentional.

### Status (2026-09-03)

Complete. Manga now has an explicit contract for its typed workspace registry:
base and kind-specific fields are registered, columns/sorts/groups resolve to
Manga IDs, defaults resolve to declared definitions, and the preference codec
remains Manga-owned. Typed facet definitions cover publisher, genre, character,
theme, and demographic; character intentionally returns no values until the
workspace projection carries Manga media character appearances. Manga's five
vocabularies are registered through the kind edit capability. Contract tests
cover IDs, definitions, extracted values, facets, and vocabulary ownership.
Continue with PR35.

---

## PR 35 — Manga Add + Edit

Create:

```text
MangaAddSchema
MangaMediaEditSchema
MangaReleaseEditSchema if applicable
MangaOwnedEditSchema
```

### Status (2026-09-03)

Complete. Manga now has typed Add, Media Edit, and Owned Edit schemas, with
Manga-specific vocabularies and complete grading and collector-field
transport. The media and ownership schemas use the generic schema renderer,
and the Manga edit capability registers the media dialog plus the combined
editor's custom Owned tab. Manga has no applicable Release Edit schema:
`MangaMetadata.editions` is a catalog snapshot and there is no Manga-owned
release model or release edit command to update. Contract tests cover schema
shape, typed field bindings, validation, selection updates, and nested grading
equality. Continue with PR36.

---

## PR 36 — Manga hierarchy/providers/stats

Manga-owned hierarchy:

```text
series
volume
chapter
```

No generic Season conversions.

Manga provider integrations independent from Anime even for AniList.

### Status (2026-09-04)

Complete for the Manga hierarchy, provider, and stats slice. Manga hierarchy
now owns typed series, volume, and chapter nodes, groups raw Manga chapter
rows into ordered volumes, and maps them to generic UI nodes only at the
presentation boundary. The Manga path uses a dedicated raw chapter API
boundary and does not convert through the generic `Season` model. Manga's
provider mapper now exposes typed `MangaMetadata` decoding and rejects
non-Manga envelopes, so the shared AniList adapter remains independent from
Anime semantics. Manga stats derive missing volumes directly from typed
metadata rather than serialized payloads.

Focused hierarchy/provider/stats tests and the existing Manga vertical slice
tests pass. Full validation passed for `build_runner`, `flutter analyze
--fatal-warnings --fatal-infos`, `flutter test` (`+1523`, 5 skipped), and
PR36-file format checks. The global format check still reports the existing
unmodified `manga_repository.dart`; the architecture checker still reports
the four pre-existing violations and existing complexity-budget findings.
Continue with PR37.

---

# PHASE 8 — Book

## PR 37 — Book domain + Core mapper

Create typed:

```text
BookMedia
BookEdition/Release
BookOwnedDetails
```

Direct Core DTO mapping.

### Status (2026-09-04)

Complete for the Book domain and Core mapper slice. Book now has typed media
and release identifiers, a `BookMedia` domain model, typed release/edition
fields, and direct mapping from `BookWorkDto` and `BookEditionDto`. The Book
remote source fetches typed Core work DTOs, validates the Book kind boundary,
and maps them without going through the generic `CatalogItemDto` transport
model. Existing `BookCatalogItem` and `BookOwnedDetails` compatibility paths
remain available for the later persistence and UI migration slices.

Focused Book Core mapping tests cover work and edition field adoption, typed
variants, wrong-kind rejection, remote-source mapping, and round-trip
preservation. Continue with PR38.

---

## PR 38 — Book DB + repository

Kind-owned tables and persistence.

### Status (2026-09-04)

Complete for the Book persistence slice. Book now has kind-owned Drift tables
for media, editions, and owned details, with schema migration v12 -> v13.
Local mappers preserve typed work fields, edition fields, variants, and opaque
transport lists/maps. `BookRepository` persists and reloads media with
edition children, supports typed media/release lookup and deterministic
search, caches typed remote fetches, and round-trips `BookOwnedDetails`.
Focused mapper, repository, and database migration tests cover the new
boundaries. Continue with PR39.

---

## PR 39 — Book workspace/vocabularies

Independent publishing fields.

Do not share with Manga.

### Status (2026-09-04)

Complete. Book now exposes a complete kind-owned workspace registry with
stable field, column, sort, and group IDs, typed facet definitions for authors,
publishers, genres, formats, subjects, and translators, and external facet
buckets for genre and subject. Book vocabulary IDs and definitions remain
independent under the `book.*` namespace, including the condition vocabulary.
Contract tests cover registry uniqueness, default resolution, typed facet
extraction, external facet registration, and vocabulary ownership. Continue
with PR40.

---

## PR 40 — Book Add/Edit/providers/hierarchy

Explicit:

```text
BookAddSchema
BookMediaEditSchema
BookEditionEditSchema
BookOwnedEditSchema
```

Remove any Book Edition → generic Season compatibility.

### Status (2026-09-04)

Complete. Book now owns explicit Add, media edit, release edit, and owned
edit schemas, with typed release hierarchy nodes and provider envelope
validation. Book hierarchy loading uses `BookWorkDto` and never routes Book
editions through the generic `Season` API; legacy volume loading remains
explicitly scoped to its non-Book callers. Release metadata round-trips
preserve identifiers, artwork, publication details, status, audio length, and
variants.

---

# PHASE 9 — Game

## PR 41 — Game domain + Core mapping

Use distinct:

```text
GameMedia
GameRelease
GameOwnedDetails
```

Core Work and Release stay separate.

### Status (2026-09-04)

Complete. Game now has typed media and release identifiers, distinct
`GameMedia` and `GameRelease` models, direct mapping from `GameWorkDto` and
`GameReleaseDto`, and separate remote fetches for works and releases. The
legacy Game catalog mapper remains available while the typed Core boundary is
introduced. Focused mapping, remote-source, round-trip, field-adoption, and
wrong-kind tests pass. Continue with PR42.

---

## PR 42 — Game DB/repository

Separate media/release/owned tables.

### Status (2026-09-04)

Complete. Game persistence now owns separate media, release, and owned-details
tables at schema version 14. Typed local mappers preserve Game metadata,
release fields, list values, and raw payloads, while `GameRepository` provides
transactional media-plus-release updates, deterministic search, release
lookup/enumeration, owned-details persistence, and typed remote fallback with
cache population. Focused mapper, repository, and migration tests pass.

---

## PR 43 — Game workspace/vocabularies

Game owns:

```text
platform
region
release format
etc.
```

---

## PR 44 — Game Add + Media/Release/Owned Edit

This is an important proof of Media vs Release schemas.

Explicitly separate them.

No generic release field set.

---

## PR 45 — Game providers/tracking/stats

Game-specific providers and progress semantics.

---

# PHASE 10 — BoardGame

## PR 46 — BoardGame domain + Core mapping

Explicit:

```text
BoardGameMedia
BoardGameEdition
BoardGameOwnedDetails
```

Don't force Edition into another kind's Release semantics.

---

## PR 47 — BoardGame DB/repository/workspace

All BoardGame-owned.

---

## PR 48 — BoardGame Add/Edit/providers/stats

Create:

```text
BoardGameMediaEditSchema
BoardGameEditionEditSchema
```

Independent from Game.

---

# PHASE 11 — Movie

## PR 49 — Movie domain + Core mapping

Create independent:

```text
MovieMedia
MovieRelease
MovieOwnedDetails
MovieTracking
```

No shared Video domain model.

### Status (2026-09-04)

Complete. Movie now has independent typed media, release, release-media, and
tracking models, typed identifiers, direct `MovieWorkDto` mapping, release
payload mapping, and an injectable typed remote source. Core collections are
decoded into Movie-owned value types rather than remaining as generic payloads.
Focused mapping, remote-source, wrong-kind, round-trip, and field-adoption tests
pass. Continue with PR50.

---

## PR 50 — Movie DB/repository/workspace

Movie-owned tables.

Duplicate video technical columns if needed.

### Status (2026-09-05)

Complete. Movie now has dedicated Drift media, release, and owned-details
tables, typed local mappers, repository cache/remote fallback, schema migration
to v17, and a typed `MovieMedia` workspace projection. Existing video workspace
access remains as a compatibility bridge while Movie fields consume typed media
where available. Focused Movie, workspace, repository, and database migration
tests pass. Continue with PR51.

---

## PR 51 — Movie Add/Edit

Explicit:

```text
MovieAddSchema
MovieMediaEditSchema
MovieReleaseEditSchema
MovieOwnedEditSchema
```

No `VideoEditDraft`.

### Status (2026-09-05)

Complete. Movie now exposes an independent manual `MovieAddSchema`, typed
media/release/owned edit drafts and schemas, Movie-owned release add state, and
validation for identity, runtime, and dates. The new edit contracts preserve
typed Movie models and do not depend on a shared video edit draft. Focused add
and edit schema tests pass. Continue with PR52.

---

## PR 52 — Movie providers/stats/value

Movie provider integration owned by Movie.

### Status (2026-09-05)

Complete. Movie provider mapping now validates the normalized kind and keeps
provider image fallback deterministic while decoding into Movie-owned catalog
metadata. Movie stats no longer contain TV season-gap semantics; they expose
typed runtime, audience-rating, genre, director, and physical-format
aggregations. Movie value semantics are registered through
`MovieValueCapability`, covering owned market values and optional provider
valuations preserved by the Movie domain models. Focused provider, stats, and
value tests pass. Continue with PR53.

---

# PHASE 12 — TV

## PR 53 — TV typed domain matching Core

Use actual semantics:

```text
TvSeries
TvSeason
TvEpisode
TvRelease
TvReleaseMedia
```

No generic `Season`.

### Status (2026-09-05)

Complete. TV now exposes its own typed series, season, episode, release,
release-media, episode-map, contributor, identifier, and character models.
`TvCoreMapper` maps the generated Core DTO graph directly into those models,
including nested seasons, releases, media, mappings, and typed credits. The
legacy shared-video mapper remains isolated for the compatibility editor path.
Focused Core mapping and TV vertical-slice tests pass. Continue with PR54.

---

## PR 54 — TV DB/repository

TV-specific tables:

```text
series
seasons
episodes
releases
release media/maps
owned
tracking
```

### Status (2026-09-05)

Complete. TV now has dedicated Drift tables for series, seasons, episodes,
releases, release media, episode maps, and owned details. The typed repository
hydrates and persists the complete nested graph transactionally, while the
remote source supports cache population and fallback. Schema version 18 and
its migration coverage are in place. Continue with PR55.

---

## PR 55 — TV workspace/hierarchy

TV owns Season/Episode hierarchy.

Generic hierarchy renderer only renders typed nodes supplied to it.

### Status (2026-09-05)

Complete. TV workspace projections now carry a typed `TvSeries` graph through
the TV-owned workspace mapper, while legacy catalog/video projections remain
available as compatibility bridges. TV hierarchy loading maps Core seasons and
episodes through TV-owned models before producing generic renderer nodes, and
the shelf drilldown consumes `TvSeason`/`TvEpisode` internally. Focused
workspace, hierarchy, and drilldown tests pass. Continue with PR56.

---

## PR 56 — TV Add/Edit

Explicit:

```text
TvAddSchema
TvMediaEditSchema
TvReleaseEditSchema
TvOwnedEditSchema
```

### Status (2026-09-05)

Complete. TV now exposes an independent typed add schema and release-add
draft, plus media, release, and owned edit schemas backed by `TvSeries`,
`TvRelease`, and `TvOwnedDetails`. Validation covers identity and date
consistency, and the typed drafts preserve nested TV graphs and raw fields.
The legacy generic edit draft remains available only for the existing dialog
bridge. Focused Add/Edit contract and round-trip tests pass. Continue with
PR57.

---

## PR 57 — TV providers/tracking/watch sessions

TV-owned:

```text
episode progress
watch sessions
custom episodes if appropriate
```

No `_shared/video` persistence.

### Status (2026-09-05)

Complete. TV now has dedicated typed watch-session, episode-progress, and custom-episode models and Drift tables (schema 19), a typed tracking repository, provider envelope mapping with kind validation and image fallback, and a TV-owned tracking profile. Focused tracking/provider, migration, and repository tests pass. Continue with PR58.

---

# PHASE 13 — Anime

## PR 58 — Anime domain/Core mapping

Independent:

```text
AnimeMedia
AnimeEpisode
AnimeRelease
AnimeOwnedDetails
AnimeTracking
```

Do not import TV.

### Status (2026-09-05)

Complete. Anime now has independent typed media, episode, release, and tracking models with typed identifiers, direct Core `AnimeSeriesDto` mapping, nested contributor/character/identifier/episode decoding, release payload mapping, wrong-kind validation, and an injectable typed remote source. Anime domain exports and Core mapper boundaries are in place, and focused mapping, remote-source, tracking round-trip, and field-adoption tests pass. Continue with PR59.

---

## PR 59 — Anime DB/repository/workspace

Duplicate TV-like schema where appropriate.

Intentional.

### Status (2026-09-05)

Complete. Anime now has dedicated Drift media, episode, release, owned-details, and tracking tables at schema 20, typed local mappers, repository cache/remote fallback, and migration coverage from v19. Workspace projections carry an Anime-owned `AnimeMedia` graph, hierarchy loading maps typed episodes into generic renderer nodes, and legacy metadata/video projections remain only as compatibility bridges. Focused Anime, workspace, hierarchy, repository, and database tests pass. Continue with PR60.

---

## PR 60 — Anime Add/Edit

Explicit Anime schemas.

Do not reuse TV schemas.

### Status (2026-09-05)

Complete. Anime now exposes an independent typed add schema, release-add
draft, media/release/owned edit drafts and schemas, plus Anime-owned physical
format, region, packaging, distributor, and HDR vocabularies. The legacy
generic edit draft remains only as the existing dialog bridge. Focused add,
edit, contract, and round-trip tests pass. Continue with PR61.

---

## PR 61 — Anime providers

Example:

```text
providers/anilist/
    AniList native models

kinds/anime/data/providers/anilist/
    AnimeAniListMapper
    AnimeAniListIntegration
```

Manga maintains its own separate AniList mapper.

### Status (2026-09-05)

Complete. Anime has a kind-owned AniList mapper for native AniList models and
normalized envelopes, an integration facade that forces the Anime query kind,
provider image fallback, native title/credit/relation mapping, and explicit
wrong-kind validation. Manga keeps its existing separate mapper. Focused
provider mapping tests pass. Continue with PR62.

---

## PR 62 — Anime tracking/hierarchy/stats

Anime-specific semantics.

No generic Video behavior.

### Status (2026-09-05)

Complete. Anime now owns its tracking profile and collection statistics, with
episode totals and Anime-specific genre, studio, format, and source-material
facets. The Anime kind module no longer uses the shared generic video tracking
profile. Focused tracking, stats, and Anime vertical-slice tests pass.

---

# PHASE 14 — Music

## PR 63 — Music typed domain

Preserve actual Core semantics:

```text
MusicRelease
MusicMedia
MusicTrack
MusicOwnedDetails
```

Do not force Music into series/work/release assumptions from other kinds.

### Status (2026-09-05)

Complete. Music now has typed release, media, track, and identifier models with
direct Core mapping, wrong-kind validation, nested media/track decoding, and a
typed remote-source boundary. Legacy catalog names remain only as an explicit
compatibility bridge. Focused Music mapping and round-trip tests pass. Continue
with PR64.

---

## PR 64 — Music DB/repository

Music-owned release/media/track schema.

### Status (2026-09-05)

Complete. Music has dedicated Drift release, media, track, and owned-details
tables at schema 21, typed local mappers, transactional graph persistence,
remote fallback/cache, and parent-ownership validation. Migration coverage
preserves existing catalog cache data. Focused Music repository and database
tests pass. Continue with PR65.

---

## PR 65 — Music workspace/vocabularies

Music-owned:

```text
formats
genres
credits
classical metadata
etc.
```

### Status (2026-09-05)

Complete. Music workspace projection now hydrates a Music-owned typed release
graph, including media and tracks, while retaining legacy catalog metadata only
as a compatibility bridge. Music owns format, genre, media-type, credit-role,
record-label, and country vocabularies. Focused workspace and vocabulary tests
pass. Continue with PR66.

---

## PR 66 — Music Add/Edit

Explicit:

```text
MusicAddSchema
MusicMediaEditSchema if appropriate
MusicReleaseEditSchema
MusicOwnedEditSchema
```

Do not depend on generic `supportsTrackSearch`.

### Status (2026-09-05)

Complete. Music exposes independent add, release-add, release-edit, media-edit,
and owned-edit drafts/schemas with Music-specific fields and validation. The
existing generic edit draft remains only for the current dialog bridge. Focused
schema, validation, and typed round-trip tests pass. Continue with PR67.

---

## PR 67 — Music providers/tracking/stats

Music-specific track/hierarchy/stats behavior.

### Status (2026-09-05)

Complete. Music now owns a typed MusicBrainz mapper and integration facade,
release/media/track hierarchy projection, release/media/track tracking state,
and collection statistics for tracks, media, artists, genres, formats, and
labels. The Music module no longer uses the shared generic listening profile
and loads children through the typed Core Music release graph. Focused provider,
hierarchy, tracking, statistics, and vertical-slice tests pass. Continue with
PR68.

---

# PHASE 15 — Remove Legacy Hierarchy Abstractions

## PR 68 — Delete generic `getItemVolumes()` style APIs

Remove any APIs translating:

```text
Manga Chapter → Season
Book Edition → Season
Volume → Season
```

Each kind calls its typed API directly.

### Status (2026-09-05)

Complete. The generic `ApiClient.getItemVolumes()` route and its legacy
Season-producing adapters are gone. Comic hierarchy loading now consumes
`ComicWorkDto` through the Comic mapper, while Manga shelf loading consumes
`MangaWorkDto` and `MangaSeriesHierarchy`; the collection shelf no longer
depends on generic Season/Episode models for Manga. Focused API, Comic, and
Manga hierarchy tests pass. Continue with PR69.

---

## PR 69 — Make hierarchy renderer type-generic, not domain-generic

Allowed:

```dart
HierarchyView<TNode>
```

Not:

```text
Season
Volume
Episode
Chapter
Issue
```

in generic models.

Kinds define their nodes.

### Status (2026-09-05)

Complete. The shared hierarchy provider and renderer operate on
`LibraryHierarchyNode` trees and never materialize Season, Volume, Episode,
Chapter, or Issue domain objects. Kind-owned mappers produce the transport
nodes at the boundary, while the generic UI only handles labels, children,
actions, and presentation metadata. Continue with PR70.

---

# PHASE 16 — Remove Catalog Type Erasure

## PR 70 — Remove `CatalogItemDto` from Library runtime

All nine kinds should now map generated DTOs directly.

Target:

```text
CatalogItemDto usages under Library/Collection business code = 0
```

If API legacy code still needs it, quarantine it.

### Status (2026-09-05)

Complete. Library and Collection runtime paths now convert legacy cache/API
catalog DTOs through the explicit metadata transport codec and continue with
`LibraryMetadataItem`; Collection mutations, the add-session hydration path,
serial authority cache, shelf, workspace, and generic dialogs no longer refer
to `CatalogItem` directly. The manga hierarchy callback was also moved to the
typed Core work endpoint, removing the stale generic chapter-row API call.
Legacy DTO construction remains isolated in the catalog cache and transport
adapter boundaries for the subsequent wrapper removal PRs. Continue with PR71.

---

## PR 71 — Delete `LibraryKindMetadataRuntime`

Delete:

```text
LibraryKindMetadataRuntime
LibraryKindMetadataDecoders
DefaultMapKindMetadata
EmptyKindMetadata
```

No replacement V2.

### Status (2026-09-05)

Complete. The shared metadata runtime interface, global decoder container, and
map fallback implementations are deleted. Concrete kind metadata/media models
remain responsible for their own payload serialization; the transitional
catalog view keeps only the boundary decoding needed until PR72 removes the
remaining library wrappers. Continue with PR72.

---

## PR 72 — Delete Library catalog wrappers

Delete:

```text
LibraryMetadataItem
LibraryCatalogItemView
LibraryMetadataTransportCodec
```

Replace callers with concrete kind types.

### Status (2026-09-05)

Complete. The three Library catalog wrappers are deleted. Library, Collection,
add/edit, provider, cache, and import paths now use `CatalogItemDto` directly;
the kind registry attaches concrete metadata only when a catalog boundary is
hydrated, and `CatalogItemDto.copyWith` preserves that metadata through edits.
Continue with PR73.

---

## PR 73 — Delete `CatalogKindCodec`

Serialization is now local to actual boundaries:

```text
Core mapper
local mapper
provider mapper
sync mapper
```

No global metadata codec registry.

### Status (2026-09-05)

Complete. `CatalogKindCodec`, its default implementation, global registry, and
all module registrations are deleted. Each kind now exposes its own metadata
decoder callback through the kind module, while domain models keep their local
`toJson` serialization for Core, provider, edit, and sync boundaries.
Continue with PR74.

---

## PR 74 — Delete generic catalog cache

Once all kinds have typed Drift schemas:

```text
DELETE CatalogCache
DELETE generic CatalogCacheRepository
```

No canonical `id + kind + payloadJson` media store.

---

# PHASE 17 — Tracking De-Generalization

## PR 75 — Generic personal tracking base

Decide what is genuinely universal:

Potentially:

```text
status
rating
startedAt
completedAt
notes
```

Nothing media-hierarchy-specific.

---

## PR 76 — Split tracking units into kinds

Delete generic union fields:

```text
seasonNumber
episodeNumber
volumeNumber
chapterNumber
issueNumber
```

Kind tables instead.

---

## PR 77 — TV/Anime watch storage split

Move:

```text
WatchSessions
CustomEpisodes
```

to actual owners.

Duplicate between TV/Anime if semantics differ.

---

# PHASE 18 — Reduce `_shared`

## PR 78 — Full `_shared` audit

Every `kinds/_shared/**` file gets classified:

```text
VISUAL STRUCTURAL
TECHNICAL PRIMITIVE
DOMAIN MODEL
DOMAIN BEHAVIOR
PERSISTENCE
EDIT
FIELDS
VOCABULARY
HIERARCHY
PROVIDER
```

Only first two categories normally survive.

---

## PR 79 — De-share Video

Move/duplicate into Movie/TV/Anime:

```text
domain models
Edit
Add
tracking
detail
inspector
provider mappings
persistence
release logic
hierarchy
fields
vocabularies
```

Keep shared technical primitives only under very strict criteria.

---

## PR 80 — De-share publishing/serial leftovers

Any shared:

```text
series
publisher
edition
volume
print media
```

domain behavior gets duplicated/moved into actual kinds.

---

# PHASE 19 — Generic Edit Cleanup

## PR 81 — Delete global Edit semantic defaults

Delete:

```text
DefaultLibraryEditPresentationBuilder
global production tabs
global section defaults
Comic/Game booleans
generic grading/key labels
```

---

## PR 82 — Delete `LibrarySectionRegistry`

No global registry containing:

```text
tv_episodes
music_track_listing
seriesHierarchy
video_specs
```

Kinds declare sections directly in schemas.

---

## PR 83 — Delete central Edit draft hierarchy

Delete remaining:

```text
KindEditDraft
GenericEditDraft
VideoEditDraft
ComicEditDraft in generic folder
GameEditDraft in generic folder
...
```

Every draft lives in owner kind.

---

# PHASE 20 — Generic Add Cleanup

## PR 84 — Delete global semantic Add defaults

No default media/publishing fields.

Every Add field comes from kind's schema.

---

## PR 85 — Split oversized Add dialog controller/layout

Shared Add infrastructure may keep:

```text
dialog shell
mode selection
provider result host
manual form host
save lifecycle
```

Move controllers/state into smaller structural classes.

No semantic fields.

---

# PHASE 21 — UI Convergence

Architecture is now clean; visual convergence can happen safely.

## PR 86 — `LibraryMetrics`

One source:

```text
fieldHeight
buttonHeight
iconButtonSize

dialogHeaderHeight
panelHeaderHeight

tableRowHeight
resultRowHeight

panelPadding
sectionPadding

gapXs
gapSm
gapMd
gapLg

responsive breakpoints
```

Density:

```text
comfortable
compact
dense
```

---

## PR 87 — Typography grammar

Remove arbitrary Library `fontSize:` usages except explicit design-system exceptions.

Use semantic roles.

---

## PR 88 — Shared result table renderer

Create typed structural:

```dart
LibraryResultTable<T>
LibraryResultColumn<T>
LibraryResultRow<T>
```

Kinds provide columns.

Example Comic:

```text
Series
Issue
Variant
Publisher
```

Manga separately:

```text
Series
Volume
Publisher
Language
```

Same appearance, different semantics.

---

## PR 89 — Shared selection controls

Standardize:

```dart
LibrarySelectField<T>
LibraryVocabularyField<T>
```

No production semantic field subclasses in shared.

---

## PR 90 — Edit visual parity contract

Add widget contract tests verifying every kind's declarative schema renders under:

```text
desktop
compact
dense
```

for all nine kinds.

Contract executed for every applicable kind.

---

## PR 91 — Add visual parity contract

Same for Add schemas.

---

# PHASE 22 — Provider Final Cleanup

## PR 92 — Remove normalized metadata god envelope

If `NormalizedProviderEnvelopeV1` is no longer needed for actual metadata import, remove/quarantine.

Do not replace with V2.

---

## PR 93 — Provider metadata integration contracts

Every provider-kind mapping runs shared contract:

```text
native DTO maps successfully
identity preserved
title/required fields preserved
no provider DTO escapes integration
no kind model enters provider code
```

Explicit invocations, e.g.:

```text
Anime × AniList
Manga × AniList
Comic × ComicVine
...
```

---

## PR 95 — Sync policy parity

Make `ProviderSyncPolicy` fields exactly match what `ExternalStateEngine` actually processes.

Either implement fields or remove false capabilities.

Add contract tests per personal-sync provider.

---

# PHASE 23 — DB Composition Root

## PR 96 — Final `LocalDatabase` reduction

Final core DB file may enumerate tables:

```text
ComicMediaRows
MangaMediaRows
TvEpisodeRows
...
```

because Drift requires composition.

But column semantics live exclusively in kind files.

Universal tables only remain in `core/db` when genuinely universal.

---

## PR 97 — DB schema ownership checker

Enforce:

```text
Comic table definitions
→ only kinds/comic/data/local

Manga tables
→ only kinds/manga/data/local

etc.
```

Allow central Drift composition root to import them.

---

# PHASE 24 — Final Runtime Reduction

## PR 98 — Delete giant `LibraryKindRuntime`

Replace final consumers with tiny:

```text
LibraryKindRegistration
```

The erased boundary ends immediately after dispatch.

---

## PR 99 — Cross-kind search summary model

One legitimate erased model:

```dart
CatalogSearchHit {
  CatalogEntityRef ref;
  CatalogMediaKind kind;

  String title;
  String? subtitle;
  String? imageUrl;
}
```

Upon click:

```text
kind dispatch
→ typed repository
```

No complete generic metadata.

---

# PHASE 25 — Final Architecture Checker

## PR 100 — Hard enforce dependency rules

Reject:

```text
kinds/X -> kinds/Y

providers -> kinds

generic Library -> concrete kind
except approved composition roots
```

Also generic Library cannot import `_shared` domain modules.

---

## PR 101 — Hard enforce type safety

Reject runtime use of:

```text
CatalogItemDto
LibraryKindMetadataRuntime
LibraryMetadataItem
LibraryCatalogItemView

dynamic catalog item
Map<String,dynamic> metadata
```

Allow Maps only in explicit serialization/data-layer allowlists.

---

## PR 102 — Hard enforce Core DTO ownership

Example:

```text
ComicWorkDto
```

only permitted in:

```text
generated API
kinds/comic/data/remote
Comic tests
```

Equivalent rule for all kind-specific Core DTOs.

---

## PR 103 — Hard enforce declarative Add/Edit ownership

Concrete production:

```text
EditSchema
AddSchema
FieldDefinition
FacetDefinition
GroupDefinition
VocabularyDefinition
```

must belong to relevant kind except generic class definitions/structural fixtures.

---

# PHASE 26 — Final Delete Pass

## PR 104 — Delete-only architecture sweep

Search:

```text
CatalogItem
CatalogKindCodec

KindMetadataRuntime
LibraryMetadataItem
LibraryCatalogItemView

KindEditDraft
GenericEditDraft
VideoEditDraft

LibrarySectionRegistry
DefaultLibraryEditPresentationBuilder

plannedMedia

compat
legacy
deprecated
temporary
fallback
migration
```

Each survivor gets:

```text
DELETE
```

or explicit architectural justification.

No new abstraction in this PR.

---

# PHASE 27 — Core Evolution Contract for All Kinds

## PR 105 — All generated DTO policies complete

Every generated DTO consumed by Library has:

```text
mapped fields
intentionally ignored fields + reason
```

No unclassified fields.

Include media and release DTOs.

Examples:

```text
ComicWorkDto
GameWorkDto
GameReleaseDto
TvSeriesDto
TvEpisodeDto
TvReleaseDto
MusicTrackDto
...
```

---

## PR 106 — CI fails on unclassified Core field

Wire checker into CI.

Future workflow:

```text
Core adds field
     ↓
regenerate API
     ↓
CI fails in owner kind
     ↓
developer maps or ignores explicitly
```

This is desired behavior.

---

# PHASE 28 — All-Kind Contract Matrix

## PR 107 — Mandatory contracts across all nine kinds

Explicitly run:

```text
identity
Core mapping
Core field adoption
media repository
media persistence
workspace
fields
sort/group/facet structural validity
Add
Media Edit
```

for:

```text
Comic
Manga
Book
Game
BoardGame
Movie
TV
Anime
Music
```

Do not iterate erased runtime objects.

Use explicit typed invocations.

---

## PR 108 — Release contracts

Run for every release/edition-capable kind:

```text
release domain
repository
persistence
Release Edit
```

The test manifest explicitly lists participants.

---

## PR 109 — Tracking contracts

Run shared tracking behavioral contracts against every tracking-capable kind.

Examples:

```text
status persistence
progress persistence
round-trip
reset
completion semantics where structurally promised
```

Kind-specific semantics remain separate tests.

---

## PR 110 — Provider contracts

Run generic provider-integration contracts against **every actual provider-kind pair**, not one provider.

---

# PHASE 29 — Final Kind-Specific Tests

## PR 111 — Comic semantic test suite

Examples:

```text
issue ordering
grading
key comic
story arc behavior
variant logic
```

---

## PR 112 — Manga semantic tests

```text
volume/chapter ordering
demographic/publication behavior
```

---

## PR 113 — Book semantic tests

```text
edition behavior
ISBN/identifier semantics
```

---

## PR 114 — Game semantic tests

```text
release/platform
completeness
region
```

---

## PR 115 — BoardGame semantic tests

```text
edition distinctions
designers/mechanics/families
```

---

## PR 116 — Movie semantic tests

```text
release/media semantics
```

---

## PR 117 — TV semantic tests

```text
season/episode ordering
release episode maps
watch sessions
```

---

## PR 118 — Anime semantic tests

Independent from TV.

---

## PR 119 — Music semantic tests

```text
disc/track ordering
track durations
release/media structure
classical metadata
```

---

# PHASE 30 — Final Parity Audit

## PR 120 — Full nine-kind parity report

Produce:

```text
docs/typed-kind-parity-final.md
```

For every kind:

```text
Core DTO mapping                PASS
Core field policy               PASS

Media domain                    PASS
Release domain                  PASS / N/A
Owned details                   PASS
Tracking domain                 PASS / N/A

Media local DB                  PASS
Release local DB                PASS / N/A
Owned local DB                  PASS
Tracking local DB               PASS / N/A

Repository                      PASS

Workspace                       PASS
Fields                          PASS
Columns                         PASS
Sorts                           PASS
Groups                          PASS
Facets                          PASS
Vocabularies                    PASS

Add schema                      PASS

Media Edit schema               PASS
Release Edit schema             PASS / N/A
Owned Edit schema               PASS

Hierarchy                       PASS / N/A

Provider integrations           PASS
Provider dependency direction   PASS

Stats                           PASS
Value                           PASS / N/A

Mandatory contracts             PASS
Capability contracts            PASS

No cross-kind imports           PASS
No erased catalog metadata      PASS
No false-common domain layer    PASS
```

Only:

```text
PASS
FAIL
N/A
```

No `partial`.

---

## PR 121 — Final semantic-vacuum audit

Outside kinds, classify every remaining occurrence of:

```text
series
issue
volume
chapter
season
episode

publisher
imprint
barcode
ISBN

HDR
track
platform
grade
story arc
character
creator
```

Semantic generic use must be zero.

Structural/UI/help/test text can be justified.

---

## PR 122 — Final deleted-code proof

Verify zero production usage of:

```text
CatalogItemDto
LibraryMetadataItem
LibraryCatalogItemView
LibraryKindMetadataRuntime
CatalogKindCodec

GenericEditDraft
KindEditDraft
VideoEditDraft

LibrarySectionRegistry
DefaultLibraryEditPresentationBuilder

CatalogCache
generic TrackingUnits union
```

where those components were scheduled for removal.

---

## PR 123 — Final documentation

Create/update:

```text
docs/architecture/kinds.md
docs/architecture/providers.md
docs/architecture/local-persistence.md
docs/architecture/core-contract-evolution.md
docs/architecture/testing-contracts.md
```

The core architecture document should contain exactly these rules:

```text
A kind owns every representation of its domain data.

After kind dispatch, never erase the type.

Provider owns protocol.
Kind owns semantic provider mapping.

Kinds never import other kinds.

Prefer production duplication over false-common abstractions.

Share behavioral contract tests across every applicable kind.
```

---

# Final Test Structure

Recommended:

```text
test/

  contracts/

    core/
      core_mapping_contract.dart
      core_field_adoption_contract.dart

    repository/
      media_repository_contract.dart
      release_repository_contract.dart

    persistence/
      media_persistence_contract.dart
      release_persistence_contract.dart
      owned_persistence_contract.dart

    workspace/
      workspace_contract.dart
      fields_contract.dart
      sorts_contract.dart
      groups_contract.dart
      facets_contract.dart

    add/
      add_contract.dart

    edit/
      media_edit_contract.dart
      release_edit_contract.dart
      owned_edit_contract.dart

    provider/
      provider_integration_contract.dart

    tracking/
      tracking_contract.dart

  kinds/

    comic/
      fixtures/
      comic_contracts_test.dart
      comic_core_mapping_test.dart
      comic_behavior_test.dart

    manga/
      ...

    book/
      ...

    game/
      ...

    boardgame/
      ...

    movie/
      ...

    tv/
      ...

    anime/
      ...

    music/
      ...
```

---

# Contract Test Philosophy

The helper may be shared:

```dart
void runMediaPersistenceContract<
  TMedia,
  TRepository
>(
  MediaPersistenceFixture<TMedia, TRepository> fixture,
) {
  ...
}
```

But calls are explicit and typed:

```dart
runMediaPersistenceContract(
  ComicPersistenceFixture(),
);

runMediaPersistenceContract(
  MangaPersistenceFixture(),
);

runMediaPersistenceContract(
  MoviePersistenceFixture(),
);
```

Not:

```dart
for (final runtime in LibraryKindRegistry.all) {
  runSomethingDynamic(runtime);
}
```

A little duplication in tests is valuable because it documents exactly which kinds promise the behavior.

---

# Core Evolution Final Behavior

Future example:

Core adds:

```text
ComicWork.firstPrintingDate
```

Pipeline:

```text
Core DB
↓
ComicWorkV1Response
↓
OpenAPI
↓
ComicWorkDto.firstPrintingDate
↓
CI
↓
FAIL:

Unclassified ComicWorkDto field:
firstPrintingDate
```

Then developer chooses:

```text
mapped
```

and updates:

```text
ComicMedia
ComicCoreMapper
ComicMediaTable if cached
ComicLocalMapper
field/Edit UI if desired
tests
```

or:

```text
intentionallyIgnored(
  reason: ...
)
```

Nothing silently flows through a generic payload.

---

# Provider Final Model

Metadata:

```text
AniList API
    ↓
AniListAnime
    ↓
AnimeAniListMapper
    ↓
AnimeMedia
```

Location:

```text
providers/anilist/
  AniList API + native models

kinds/anime/data/providers/anilist/
  semantic mapping
```

Manga separately:

```text
kinds/manga/data/providers/anilist/
```

No shared AniList Anime/Manga mapper.

Personal sync:

```text
AniListMediaListEntry
       ↓
AniListSyncAdapter
       ↓
ProviderPersonalEntry
       ↓
ExternalStateEngine
```

That's intentionally generic because this is **personal state**, not media metadata.

---

# Local DB Final Model

Central:

```text
core/db/
```

contains only:

1. truly universal table definitions;
2. Drift database composition root.

Kind:

```text
kinds/comic/data/local/
```

owns Comic table definitions.

```text
kinds/tv/data/local/
```

owns TV table definitions.

The composition root may list all of them:

```dart
@DriftDatabase(
  tables: [
    Locations,
    ProviderAccounts,

    ComicMediaRows,
    ComicReleaseRows,

    MangaMediaRows,

    GameMediaRows,
    GameReleaseRows,

    TvSeriesRows,
    TvEpisodeRows,
    TvReleaseRows,

    ...
  ],
)
```

That is not a semantic violation.

It only composes schemas.

---

# Recommended Milestone Boundaries

Do not execute all 123 PRs without checkpoints.

### Milestone 1 — PR 0–10

Baseline + test infrastructure + tiny runtime + declarative Add/Edit infrastructure.

### Milestone 2 — PR 11–31

Comic complete vertical slice + provider architecture + typed ownership.

**Major audit after this milestone.**

If Comic still passes through `CatalogItem`, do not migrate the other kinds yet.

### Milestone 3 — PR 32–67

Manga → Music.

**Second major audit.**

Verify that duplication remained intentional and no new:

```text
CommonPublishing*
Video*
CommonRelease*
SharedMedia*
```

domain layer appeared.

### Milestone 4 — PR 68–85

Hierarchy cleanup + complete removal of catalog type erasure + tracking + `_shared` + old Add/Edit architecture.

### Milestone 5 — PR 86–99

UI convergence + provider cleanup + DB composition + tiny final runtime.

### Milestone 6 — PR 100–123

Hard enforcement + all-kind contract testing + semantic suites + final docs/parity.

---

# Gemini Report Format After Every PR

```text
TASK:
STATUS:

Current main verified:
-

Already solved before this task:
-

Violations found:
-

Root causes:
-

Architecture changes:
-

Typed domain changes:
-

Kind-specific code moved:
-

Code intentionally duplicated:
-

Generic code simplified:
-

Compatibility code removed:
-

Compatibility code intentionally remaining:
-

Files added:
-

Files modified:
-

Files deleted:
-

Tests added:
-

Contract tests executed:
-

Core schema adoption check:
PASS / FAIL / N/A

Kind boundary checker:
PASS / FAIL

dart format:
PASS / FAIL

build_runner:
PASS / FAIL

flutter analyze:
PASS / FAIL

flutter test:
PASS / FAIL

Remaining debt directly related to this PR:
-

Recommended next PR:
-

STOP.
```

---

# Absolute Definition of Done

At the end, opening:

```text
kinds/comic/
```

must be enough to understand:

- how Comic arrives from Core;
- Comic's canonical App domain model;
- how it is stored locally;
- its owned details;
- its tracking;
- which providers it supports and how they map;
- its fields/columns/groups/facets;
- its vocabularies;
- its Add form;
- its Media Edit tabs/sections/fields;
- its Release Edit tabs/sections/fields;
- its stats/value logic.

The same must be true for all other eight kinds.

If Core gains a new field, CI must point directly to the owning kind and require it to be explicitly **mapped** or **intentionally ignored**.

The final architecture should have:

```text
very little shared production domain code
strong compile-time typing
kind-owned persistence
kind-owned provider semantic mapping
declarative Add/Edit per kind
shared UI infrastructure only
shared contract tests across every applicable kind
```

The guiding rule remains:

> **Share tests more aggressively than production domain code.**
