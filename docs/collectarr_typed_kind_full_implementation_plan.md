
# Collectarr — Full Typed-Kind Vertical Architecture Implementation Plan

## 0. FINAL ARCHITECTURE INVARIANTS

These rules override older architecture decisions.

### 0.1 A kind owns every representation of its domain

A kind owns:

* Core DTO mapping
* canonical app domain models
* Media model
* Release / Edition model where applicable
* full Owned model
* tracking/progress domain
* local Drift schemas
* local DB mappers
* repositories
* fields
* columns
* sorts
* groups
* facets
* vocabularies
* Add
* Media Edit
* Release Edit
* Owned Edit
* hierarchy
* provider metadata integrations
* calendar projection
* barcode interpretation/resolution
* metadata override semantics
* import/export formats
* kind-specific actions
* stats
* value semantics

A developer inspecting `kinds/comic/` should be able to understand essentially everything that Comic means to Collectarr.

---

## 0.2 After kind dispatch, never erase the type

Allowed:

```text
route/search hit
    ↓
CatalogMediaKind.comic
    ↓ dispatch
Comic
    ↓
ComicMedia
ComicRelease
ComicOwnedItem
ComicWorkspaceDto
...
```

Forbidden after dispatch:

```text
ComicMedia
→ CatalogItemDto
→ Map<String,dynamic>
→ LibraryKindMetadataRuntime
→ ComicMedia again
```

Type erasure is allowed only at actual serialization boundaries:

```text
HTTP
DB
provider protocol
sync persistence
```

Immediately after reading the boundary:

```text
serialized data
→ owning kind mapper
→ typed kind domain
```

---

# 0.3 Full Owned ownership

There is NO canonical common `OwnedItem` domain object.

Each kind owns the complete model:

```text
ComicOwnedItem
MangaOwnedItem
BookOwnedItem
GameOwnedItem
BoardGameOwnedItem
MovieOwnedItem
TvOwnedItem
AnimeOwnedItem
MusicOwnedItem
```

This includes fields that happen to repeat:

```text
purchaseDate
purchasePrice
location
owner
quantity
notes
```

Duplication is intentional.

Generic code may use only structural representations such as:

```text
OwnedItemId
OwnedItemRef
OwnedItemSummary
```

Generic code must not read:

```text
condition
grade
region
packaging
grading
signature
keyComic
completeness
box/manual
matrix/runout
etc.
```

---

# 0.4 Full kind-owned persistence

Each kind owns its complete Drift tables.

Prefer:

```text
ComicMediaRows
ComicReleaseRows
ComicOwnedItems

GameMediaRows
GameReleaseRows
GameOwnedItems
```

over:

```text
GenericOwnedItems
+ nullable fields for every possible kind
```

Even generic ownership columns may be duplicated between nine tables.

`LocalDatabase` may enumerate kind table types as a composition root.

It must not define their semantic columns.

---

# 0.5 Minimal production sharing

Prefer duplication.

Do NOT create:

```text
CommonMedia
CommonPublishing
CommonRelease
CommonSerial
CommonCollectible
PrintMedia
VideoMetadata

CommonOwnedItem
CommonOwnedDetails

VideoOwnedDetails
SharedGradingDetails
SharedSignatureDetails

VideoEditDraft
PublishingEditDraft

SharedPublisherFields
SharedReleaseFields

DefaultMediaTabs
DefaultReleaseTabs

SharedVideoRepository

GenericCatalogItemV2
KindMetadataRuntimeV2
```

A shared abstraction must represent identical semantics and lifecycle, not merely similar field names.

---

# 0.6 Cross-kind dependencies

Forbidden:

```text
kinds/comic → kinds/manga
kinds/movie → kinds/tv
kinds/anime → kinds/tv
```

No kind imports another kind.

`kinds/_shared` is exceptional and should contain almost exclusively visual or genuinely technical primitives.

---

# 0.7 Provider ↔ Kind rule

Provider owns:

```text
protocol
HTTP
authentication
queries
rate limits
pagination
provider-native DTOs
provider-specific errors
```

Kind owns semantic mapping:

```text
provider-native metadata
→ typed kind domain
```

and, when supported:

```text
typed kind domain
→ provider-native metadata mutation
```

Dependency direction:

```text
providers/anilist
       ↑
       │
kinds/anime/data/providers/anilist
```

Forbidden:

```text
providers/anilist
→ AnimeMedia
```

---

# 0.8 Personal provider sync exception

Personal sync remains generic where it genuinely represents a common domain:

```text
AniList personal list DTO
    ↓
AniListSyncAdapter
    ↓
ProviderPersonalEntry
    ↓
ExternalStateEngine
```

This does not carry catalog metadata.

---

# 0.9 Feature-host rule

Features outside `kinds/` own mechanisms and hosts.

Kinds own semantic contributions.

Examples:

```text
Collection owns:
- action menu UI
- file picker
- import preview UI
- export/download plumbing

Comic owns:
- Import CLZ CSV
- Export Comic CSV
- Export ComicInfo.xml
- Comic matching rules
```

```text
Calendar owns:
- CalendarEvent model
- calendar rendering
- ICS generation

TV owns:
- how TV produces calendar events
- episode titles
- release events
```

---

# 0.10 Shared contracts are encouraged when behavior is genuinely identical

Share behavioral shape, not data shape.

Good candidates:

```text
EditSchema<TModel, TDraft>
AddSchema<TDraft>

UiAction<TContext>

ReadRepository<TId, TEntity>
MutableRepository<TId, TEntity, TCreate, TUpdate>

LibraryTable<T>
HierarchyView<TNode>

CalendarEventContributor<TContext>

ExportAction<TContext>
ImportAction<TContext, TPreview>

SummaryProjector<TSource, TSummary>

LibraryFieldDefinition<TDto, TValue>
LibrarySortDefinition<TDto>
LibraryGroupDefinition<TDto>
LibraryFacetDefinition<TDto, TValue>

VocabularyRepository

OwnedItemRef
OwnedItemSummary

CatalogSearchHit
ProviderSearchHit

ScannedCode
```

Do not add an interface just because two classes have the same properties.

Interfaces should model **behavior contracts**.

---

# 0.11 Core evolution rule

For every Core DTO field consumed by App:

```text
MAPPED
```

or:

```text
INTENTIONALLY IGNORED + reason
```

A newly generated Core field must fail CI until the owning kind classifies it.

---

# 0.12 Testing rule

If behavior is promised by multiple kinds:

> create one reusable typed contract test and execute it against every applicable kind.

Do not prove shared behavior with Comic only.

Share tests more aggressively than production domain code.

---

# PHASE A — REBASELINE THE WORKING BRANCH

## PR 0 — Branch delta audit

Before changing code:

```text
checkout typed-kind-full-implementation-plan
compare with main
```

Produce:

```text
docs/typed-kind-current-branch-audit.md
```

Classify every task in this plan:

```text
DONE
PARTIAL
NOT STARTED
OBSOLETE
```

Do not recreate landed architecture.

Also scan ALL:

```text
lib/**
```

not just:

```text
lib/features/library/**
```

for semantic leakage.

---

## PR 1 — Whole-repository semantic boundary checker baseline

Extend checker scope from Library-only to all relevant App production code.

Detect:

```text
generic → concrete kind imports

cross-kind imports

provider → kind imports

Core kind DTO imported outside owning kind integration

dynamic catalog entities

Map<String,dynamic> metadata reflection

kind semantic fields outside kinds
```

Use allowlists during migration.

The allowlist must shrink every PR.

---

# PHASE B — CONTRACT TEST FOUNDATION

## PR 2 — Typed reusable contract-test framework

Create:

```text
test/contracts/
```

Domains:

```text
core/
repository/
persistence/
workspace/
add/
edit/
owned/
actions/
provider/
calendar/
barcode/
overrides/
tracking/
```

Contracts are generic at compile time.

Production code must not become more generic just to make tests reusable.

---

## PR 3 — Core DTO adoption checker

Create test/tooling-only field policies.

Example:

```text
ComicWorkDto

mapped:
- id
- title
- publisher

ignored:
- legacy_slug
  reason: ...
```

New generated fields fail CI until classified.

---

## PR 4 — All-kind contract manifest

Mandatory for all 9:

```text
identity
Core mapping
Core field adoption
repository
media persistence
workspace
field definitions
Add
Media Edit
Owned
```

Conditional:

```text
Release
Hierarchy
Tracking
Provider integration
Calendar contribution
Barcode resolver
Import/export action
```

Explicit typed registrations only.

Do not iterate erased `LibraryKindRuntime`s.

---

# PHASE C — TINY GENERIC CONTRACTS

## PR 5 — Tiny `LibraryKindRegistration`

Reduce erased registration to navigation/dispatch entry points.

Target roughly:

```text
kind
identity

open library
open Add
open Media Edit
open Release Edit
open Owned Edit

build applicable UI actions
```

No erased access to:

```text
fields
sort
group
facet
metadata
codec
owned details
repository internals
```

---

## PR 6 — Structural repository interfaces

Where lifecycle is genuinely identical, allow small generic interfaces such as:

```text
ReadRepository<TId, TEntity>
MutableRepository<TId, TEntity, TCreate, TUpdate>
```

Do not require kinds to implement a huge universal repository.

A kind may expose extra methods freely.

Example:

```text
ComicRepository.findByIssueNumber()
BookRepository.findByIsbn()
```

remain concrete.

---

# PHASE D — DECLARATIVE ADD / EDIT

## PR 7 — Typed structural `EditSchema`

Shared only:

```text
EditSchema<TModel, TDraft>
EditTabSpec<TDraft>
EditSectionSpec<TDraft>
EditFieldSpec<TDraft>
```

Structural fields:

```text
Text
Number
Date
Money
Toggle
Select<T>
Vocabulary<T>
MultiVocabulary<T>
Image
ReadOnly
Custom
```

---

## PR 8 — Declarative Edit renderer

Renderer owns HOW:

```text
tabs
layout
validation display
dirty handling
responsive UI
save/cancel
```

Kind owns WHAT.

---

## PR 9 — Typed structural `AddSchema`

Same model for Add.

No generic publishing/video/serial sections.

---

## PR 10 — Declarative Add renderer

No semantic fields.

---

# PHASE E — KIND-OWNED ACTION SYSTEM

## PR 11 — Introduce typed `UiAction<TContext>`

Structural interface only:

```text
id
label
icon
placement
visibility/enabled state
run(context)
```

Possible structural placement:

```text
toolbar
itemMenu
bulkMenu
secondary
```

No action knows media semantics unless declared inside a kind.

---

## PR 12 — File import/export action contracts

Introduce small generic mechanics:

```text
ExportArtifact
filename
mimeType
bytes

ImportPreview
issues/conflicts/status
```

And typed contracts:

```text
ExportAction<TContext>
ImportAction<TContext, TPreview>
```

Generic infrastructure owns:

```text
file picker
save/share
preview dialog
progress
error display
```

Kind owns:

```text
format
headers
serializer
parser
matching
semantic validation
```

---

## PR 13 — Action menu host

Create generic:

```text
ActionMenu<TContext>
```

It renders actions supplied by kind.

Single-kind Library pages provide fully typed contexts.

Mixed global Shelf only uses:

```text
OwnedItemRef
CatalogEntityRef
summary
```

and dispatches immediately to the appropriate kind.

---

# PHASE F — FULL OWNED ARCHITECTURE

## PR 14 — Remove canonical common Owned domain

Begin deletion of:

```text
OwnedItem as cross-kind domain aggregate
OwnedItemDetails
defaultForKind
parseForKind

comicDetails
mangaDetails
movieDetails
...
```

Retain only structural:

```text
OwnedItemId
OwnedItemRef
OwnedItemSummary
```

---

## PR 15 — Move tracking fields out of Owned

Remove concepts such as:

```text
readStatus
rating
startedAt
finishedAt
```

from generic Owned state.

Move to typed:

```text
ComicReadingState
MangaReadingState
BookReadingState

MovieWatchState
TvWatchState
AnimeWatchState

GamePlayState
```

as applicable.

---

## PR 16 — Owned action/read projections

Create lightweight cross-kind read projection if needed:

```text
OwnedItemSummary
```

Containing only what a global UI genuinely needs:

```text
ref
title
subtitle?
image?
ownerLabel?
locationLabel?
```

Do not add `condition`, `grade`, etc. to summary merely for convenience.

---

# PHASE G — COMIC REFERENCE VERTICAL SLICE

## PR 17 — Comic typed domain

Canonical:

```text
ComicMedia
ComicRelease
ComicOwnedItem
ComicReadingState
```

plus typed IDs.

---

## PR 18 — Comic Core mapping

Direct:

```text
ComicWorkDto
→ ComicMedia
```

No generic catalog envelope.

Run Core field adoption contract.

---

## PR 19 — Comic local DB

Comic owns:

```text
ComicMediaRows
ComicReleaseRows
ComicOwnedItems
ComicReadingRows
```

No base owned union table.

---

## PR 20 — Comic repository

Typed repository only.

No `CatalogItem`.

---

## PR 21 — Comic workspace

Own:

```text
ComicWorkspaceDto
fields
columns
sorts
groups
facets
vocabularies
```

---

## PR 22 — Comic Add/Edit

Explicit:

```text
ComicAddSchema

ComicMediaEditSchema
ComicReleaseEditSchema
ComicOwnedEditSchema
```

One schema file per edit scope should visibly define all tabs/sections/fields in order.

---

## PR 23 — Comic collection actions

Move Comic semantic import/export out of Collection.

Create kind-owned actions for applicable formats:

```text
Export Comic CSV
Import Comic CSV
Import CLZ Comic CSV
Export ComicInfo.xml
other Comic-specific XML
```

Move `ComicInfoXml` under Comic.

No generic collection serializer imports Comic.

---

## PR 24 — Comic provider integrations

Provider-native DTO → Comic domain mapping lives under:

```text
kinds/comic/data/providers/<provider>/
```

---

## PR 25 — Comic calendar/barcode/override contributions

Comic owns:

```text
ComicCalendarContributor
ComicBarcodeResolver
ComicMetadataOverrideSchema
```

if supported.

No generic calendar knows Comic release semantics.

No generic barcode lookup knows issue/barcode semantics.

---

## PR 26 — Comic reference contracts

Run all applicable contracts:

```text
Core
repository
DB
workspace
Add
Media Edit
Release Edit
Owned Edit
actions
provider
calendar
barcode
overrides
```

---

## PR 27 — Comic architectural gate

Must prove:

```text
0 CatalogItem type erasure
0 generic Owned model
0 Comic semantics outside Comic except composition roots
0 Comic provider mapping inside provider package
```

Do not migrate remaining kinds until this passes.

---

# PHASE H — MANGA

## PR 28 — Manga data vertical

Own independently:

```text
MangaMedia
MangaRelease/Edition
MangaOwnedItem
MangaReadingState

Core mapper
DB
repository
workspace
fields
vocabularies
```

No Comic imports.

---

## PR 29 — Manga UX/integration vertical

Own:

```text
Add
Media Edit
Release Edit
Owned Edit

hierarchy
provider mappings
actions/import/export
calendar
barcode identifiers if applicable
overrides
stats
tests
```

AniList mapping is independent from Anime mapping.

---

# PHASE I — BOOK

## PR 30 — Book data vertical

Own:

```text
BookMedia
BookEdition
BookOwnedItem
BookReadingState

Core mapper
DB
repository
workspace
fields/vocabularies
```

---

## PR 31 — Book UX/integration vertical

Own:

```text
Add
Media Edit
Edition Edit
Owned Edit

Book ISBN resolver
Book import/export
calendar
provider mappings
hierarchy
tests
```

No generic Book Edition → `Season`.

---

# PHASE J — GAME

## PR 32 — Game data vertical

Own:

```text
GameMedia
GameRelease
GameOwnedItem
GamePlayState
```

plus Core/DB/repository/workspace.

---

## PR 33 — Game UX/integration vertical

Own:

```text
Add
Media Edit
Release Edit
Owned Edit

platform/region vocabularies
providers
barcode/product code resolution
calendar
actions
tests
```

---

# PHASE K — BOARDGAME

## PR 34 — BoardGame data vertical

Own:

```text
BoardGameMedia
BoardGameEdition
BoardGameOwnedItem
```

Full DB/repository/workspace.

---

## PR 35 — BoardGame UX/integration vertical

Own:

```text
Add
Media Edit
Edition Edit
Owned Edit
providers
actions
stats
tests
```

Do not reuse Game domain models.

---

# PHASE L — MOVIE

## PR 36 — Movie data vertical

Own:

```text
MovieMedia
MovieRelease
MovieOwnedItem
MovieWatchState
```

plus DB/repository/workspace.

Do not use shared Video domain.

---

## PR 37 — Movie UX/integration vertical

Own:

```text
Add
Media Edit
Release Edit
Owned Edit

providers
calendar
actions
tracking
tests
```

Duplicate technical fields from TV/Anime where needed.

---

# PHASE M — TV

## PR 38 — TV data vertical

Own:

```text
TvSeries
TvSeason
TvEpisode
TvRelease
TvReleaseMedia
TvOwnedItem
TvWatchState
```

plus DB/repository.

---

## PR 39 — TV UX/integration vertical

Own:

```text
workspace
hierarchy
Add
Media Edit
Release Edit
Owned Edit

episode tracking
watch sessions
providers
calendar
actions
tests
```

---

# PHASE N — ANIME

## PR 40 — Anime data vertical

Independent:

```text
AnimeMedia
AnimeEpisode
AnimeRelease
AnimeOwnedItem
AnimeWatchState
```

No TV imports.

---

## PR 41 — Anime UX/integration vertical

Independent:

```text
workspace
hierarchy
Add/Edit
tracking
providers
calendar
actions
tests
```

AniList provider mapping stays Anime-owned.

---

# PHASE O — MUSIC

## PR 42 — Music data vertical

Preserve actual Music semantics:

```text
MusicRelease
MusicMedia
MusicTrack
MusicOwnedItem
```

plus DB/repository/workspace.

---

## PR 43 — Music UX/integration vertical

Own:

```text
Add
Media/Edit scopes appropriate to Music
Release Edit
Owned Edit

track hierarchy
providers
calendar if applicable
actions
stats
tests
```

No generic `supportsTrackSearch`.

---

# PHASE P — COLLECTION FEATURE CLEANUP

## PR 44 — Replace CollectionPage hardcoded actions

Remove hardcoded:

```text
Import collection
Export collection
```

that directly launch semantic collection formats.

Global Shelf may expose:

```text
Import…
Export…
```

only as orchestration.

Selecting Import should choose:

```text
target kind
→ that kind's available ImportActions
```

or dispatch from the source file where possible.

---

## PR 45 — Remove semantic global Shelf filters

Current mixed shelf concepts such as:

```text
missingGrade
```

are not universal.

Global Shelf may keep genuinely universal:

```text
All
Owned
Wishlist
Overdue Loan
Has Notes
```

Kind-specific library pages may contribute:

```text
Missing Grade
Raw Copies
Slabbed
Incomplete
Missing Manual
etc.
```

through typed filter definitions.

---

## PR 46 — Split CSV mechanics from CSV semantics

Keep generic:

```text
CsvReader
CsvWriter
CSV escaping
row parsing mechanics
file mechanics
preview host
```

Delete canonical union schema containing:

```text
publisher
issue
variant
grade
key comic
raw/slabbed
grading company
etc.
```

Each kind owns:

```text
<Kind>CsvImportProfile
<Kind>CsvExportProfile
```

---

## PR 47 — Move CLZ semantics into relevant kinds

CLZ mappings are domain integrations.

Example:

```text
kinds/comic/integrations/clz/
```

If CLZ Book support is later needed:

```text
kinds/book/integrations/clz/
```

Do not create one giant CLZ row model containing all media types.

---

## PR 48 — Delete/rehome generic Collection XML

Current `CollectionXml` must stop knowing any catalog semantics.

Preferred:

```text
DELETE as canonical format
```

If backwards compatibility is required:

```text
legacy import adapter
→ identifies kind
→ delegates to kind importer
```

No production generic serializer reads payload keys or `comicDetails`.

---

## PR 49 — Move ComicInfo.xml into Comic

`ComicInfo.xml` is explicitly Comic domain.

Move its parser/serializer into:

```text
kinds/comic/integrations/comic_info/
```

CBZ archive/file mechanics may remain generic.

---

## PR 50 — Replace common owned collection commands

Delete:

```text
OwnedItemCommonDraft
```

and massive common command parameter sets.

Prefer typed:

```text
CreateOwnedCommand<TDraft>
UpdateOwnedCommand<TPatch>
```

or simply repository methods receiving:

```text
ComicOwnedCreate
ComicOwnedPatch
```

Contracts may be shared.

Fields may not.

---

# PHASE Q — CATALOG FEATURE REMOVAL

## PR 51 — Delete `CatalogCacheDerivedDataService`

Current generic service groups runtime metadata and feeds vocabularies/serial authority.

Move any genuinely required derived capture into owning kind repositories/actions.

No generic service imports kind `_shared` serial semantics.

---

## PR 52 — Remove generic `CatalogCacheRepository`

Each kind now has typed persistence.

Delete generic lookups like:

```text
findByBarcode
findByTitleAndIssue
```

Kind examples:

```text
ComicRepository.findByBarcode(...)
BookRepository.findByIsbn(...)
```

---

## PR 53 — Delete catalog type-erasure stack

Remove once last consumer migrated:

```text
CatalogItemDto from Library runtime
CatalogKindCodec

LibraryKindMetadataRuntime
LibraryKindMetadataDecoders

LibraryMetadataItem
LibraryCatalogItemView
LibraryMetadataTransportCodec
```

Do not introduce replacements with `V2`.

---

# PHASE R — HIERARCHY CLEANUP

## PR 54 — Delete `shelfVolumesProvider`

The current:

```text
List<Season>
getItemVolumes()
```

representation must disappear.

Kinds directly expose typed hierarchy/repositories.

---

## PR 55 — Remove generic `Season`/Volume compatibility APIs

No:

```text
Manga Chapter → Season
Book Edition → Season
```

Generic UI may use:

```text
HierarchyView<TNode>
```

but node types remain kind-owned.

---

# PHASE S — METADATA OVERRIDES

## PR 56 — Remove global item/edition/variant ontology

Current override model assumes:

```text
item
edition
variant
fieldPath
```

outside kinds.

Replace domain semantics with typed owner definitions.

Comic may define:

```text
ComicOverrideTarget
ComicOverrideFieldId<T>
```

Game may define:

```text
GameOverrideTarget
GameOverrideFieldId<T>
```

Their target structures need not match.

---

## PR 57 — Keep only generic override storage/sync mechanics

Generic persistence may store an opaque record such as:

```text
kind
targetKey
fieldKey
serialized original
serialized override
timestamp
```

Only the owning kind interprets `targetKey`, `fieldKey`, and value codec.

If typed storage can be kept per kind, prefer that.

---

# PHASE T — CALENDAR

## PR 58 — Generic calendar becomes event host only

Keep:

```text
CalendarEvent
calendar UI
event sorting
date ranges
ICS serialization
reminder plumbing
```

Remove catalog/release/watch semantic extraction from Calendar feature.

---

## PR 59 — Kind calendar contributors

Allow structural contract:

```text
CalendarEventContributor<TContext>
```

Kinds implement as applicable:

```text
ComicCalendarContributor
GameCalendarContributor
TvCalendarContributor
AnimeCalendarContributor
...
```

Kind owns event titles and semantic dates.

---

## PR 60 — Universal calendar contributors

Non-kind domains may independently contribute:

```text
Loans
global reminders
```

without going through kinds.

Calendar merges already-projected `CalendarEvent`s.

---

# PHASE U — BARCODE

## PR 61 — Keep scanner generic

Barcode scanning UI is genuinely reusable.

It should return only:

```text
ScannedCode
raw value
symbology
```

No Comic/Book/Game behavior.

---

## PR 62 — Kind-owned identifier resolvers

Kinds interpret scanned codes:

```text
ComicBarcodeResolver
BookIsbnResolver
GameBarcodeResolver
MovieBarcodeResolver
...
```

Reuse purely technical normalization/checksum code only when semantics are truly standardized.

---

# PHASE V — LOANS

## PR 63 — Loans use `OwnedItemRef`

Loans remain global because borrower/due-date behavior is genuinely cross-kind.

They store/reference:

```text
OwnedItemRef(kind, id)
```

and render:

```text
OwnedItemSummary
```

Loan code never imports:

```text
ComicOwnedItem
GameOwnedItem
```

or reads condition/grade/etc.

---

# PHASE W — PICK LISTS / VOCABULARIES

## PR 64 — Collapse duplicate pick-list infrastructure

Audit both old Collection pick-list paths and newer `features/pick_lists`.

End with one generic mechanics layer:

```text
load/save
merge
rename/delete
manage UI
normalization mechanics
```

---

## PR 65 — All concrete vocabularies stay kind-owned

No global:

```text
publisher
platform
format
region
grade
page quality
story arc
```

definitions.

If two kinds expose identical built-ins, duplicate them.

---

# PHASE X — IMPORT FRAMEWORK

## PR 66 — Separate personal imports from metadata imports

Generic personal-list import may remain around:

```text
ProviderPersonalEntry
```

Catalog metadata import belongs to kinds.

---

## PR 67 — Generic import infrastructure becomes orchestration-only

Keep:

```text
file reading
progress
preview
conflict UI
transaction execution
```

Remove:

```text
publisher matching
series+issue matching
barcode interpretation
kind metadata fields
```

Kinds provide typed parse/match/apply strategies.

---

# PHASE Y — ACTIVITY / ADMIN / SETTINGS AUDIT

## PR 68 — Activity as projected events

Activity may keep:

```text
ActivityEvent
timeline UI
filter UI
```

Kind-specific event construction/details belong to kind contributors.

No generic activity code interprets kind metadata.

---

## PR 69 — Admin kind-specific screens/actions

Audit `features/admin`.

Generic admin shell stays.

Move any:

```text
metadata field form
kind ingest behavior
kind proposal details
kind-specific correction workflow
```

into relevant kinds or kind admin actions.

---

## PR 70 — Kind-specific settings contributions

Generic settings infrastructure stays.

Kind-specific:

```text
default grouping
default sort
provider defaults
Add behavior
Edit behavior
```

are declared by kind.

Use a structural settings section contract if useful.

Do not recreate a `LibraryTypeConfig`.

---

# PHASE Z — TRACKING

## PR 71 — Define genuinely universal tracking infrastructure

If needed, generic infrastructure may know lifecycle mechanics such as:

```text
timestamp
sync status
history/event storage
```

It must not know:

```text
season
episode
volume
chapter
issue
```

---

## PR 72 — Full kind-owned tracking state

Each applicable kind owns its tracking domain and DB.

Examples:

```text
TvWatchState
TvEpisodeProgress

AnimeWatchState
AnimeEpisodeProgress

MangaReadingState
MangaChapterProgress

ComicReadingState

BookReadingState

GamePlayState
```

---

## PR 73 — Move watch/custom episode storage

TV and Anime own their own:

```text
watch sessions
custom episode semantics
```

Duplicate where appropriate.

---

# PHASE AA — AGGRESSIVE `_shared` REDUCTION

## PR 74 — Classify every `_shared` file

Allowed classifications to remain shared:

```text
VISUAL STRUCTURAL
TECHNICAL PRIMITIVE
```

Move/duplicate:

```text
DOMAIN MODEL
DOMAIN BEHAVIOR
PERSISTENCE
EDIT
FIELDS
VOCABULARY
HIERARCHY
PROVIDER MAPPING
TRACKING
```

---

## PR 75 — De-share Video

Movie/TV/Anime independently own:

```text
HDR fields
audio/subtitle fields
release fields
owned copy fields
Edit schemas
tracking
provider integrations
details/inspector composition
```

Even if copied almost verbatim.

---

## PR 76 — De-share publishing/serial domains

Comic/Manga/Book independently own:

```text
publisher
imprint
series
volume
edition
identifiers
```

No PrintMedia/Publishing abstraction.

---

# PHASE AB — ACTIONS EVERYWHERE

## PR 77 — Per-kind Library toolbar actions

Each kind explicitly declares applicable top-level actions.

Example Comic:

```text
Import CLZ CSV
Export CSV
Export ComicInfo.xml
Scan barcode
Refresh from provider
```

Game may declare different actions.

---

## PR 78 — Typed row/item actions

Per-item dropdowns use typed action contexts inside the kind.

Example:

```text
ComicItemActionContext
GameItemActionContext
```

No universal context bloated with every possible field.

---

## PR 79 — Typed bulk actions

Same approach for selections.

Structural contract can be:

```text
UiAction<List<T>>
```

or specific typed selection context.

Kind owns semantics.

---

# PHASE AC — PROVIDER CLEANUP

## PR 80 — Provider search summary only

Generic provider discovery result:

```text
ProviderSearchHit
providerId
kind
remoteId
title
subtitle?
image?
```

No full generic metadata envelope.

---

## PR 81 — Kind-owned provider metadata resolution

Selection flow:

```text
ProviderSearchHit
→ kind dispatch
→ kind provider integration
→ provider client/native DTO
→ kind mapper
→ typed domain
```

---

## PR 82 — Remove normalized provider metadata god model

If `NormalizedProviderEnvelopeV1` is no longer required for compatibility, delete it.

If temporarily required, quarantine and prevent new callers.

---

## PR 83 — Personal sync cleanup

Canonical:

```text
ProviderPersonalEntry
```

Delete:

```text
dynamic import entries
duplicate ImportRow canonical state
compatibility aliases
```

---

## PR 84 — Sync policy parity

Every configured sync field must actually be handled by `ExternalStateEngine`.

Either:

```text
implement
```

or:

```text
remove unsupported policy field
```

Contract tests per provider.

---

# PHASE AD — LOCAL DATABASE FINALIZATION

## PR 85 — `LocalDatabase` becomes composition root

Definitions for semantic tables live under kinds.

Core DB may enumerate them for Drift generation.

Universal tables remain only when genuinely universal:

```text
locations
loans
custom fields
provider accounts
provider links
sync infrastructure
```

---

## PR 86 — Kind DB ownership checker

Enforce:

```text
Comic table definition
→ kinds/comic/data/local

Game table definition
→ kinds/game/data/local
```

Central DB file may import them only for composition.

---

# PHASE AE — RUNTIME DELETION

## PR 87 — Delete giant `LibraryKindRuntime`

After all users migrated:

```text
LibraryKindRegistration
```

becomes the tiny erased boundary.

No forwarding API for every field/capability.

---

## PR 88 — Cross-kind summaries only

Legitimate erased/read models:

```text
CatalogSearchHit
OwnedItemRef
OwnedItemSummary
ProviderSearchHit
CalendarEvent
ActivityEvent
```

All are intentionally small projections.

Never expand them into canonical metadata models.

---

# PHASE AF — UI CONSISTENCY

## PR 89 — Library metrics system

One visual source for:

```text
field height
button height
row heights
panel padding
section padding
gaps
radii
breakpoints
```

---

## PR 90 — Typography system

Remove arbitrary Library hardcoded font sizes.

---

## PR 91 — Shared generic result table

```text
LibraryResultTable<T>
LibraryResultColumn<T>
```

Kinds define columns.

Shared UI defines presentation.

---

## PR 92 — Standard selection controls

Shared:

```text
LibrarySelectField<T>
LibraryVocabularyField<T>
```

No shared semantic fields.

---

## PR 93 — Shared action visuals

All kind actions use one:

```text
action menu
toolbar action
progress
error
confirmation
```

visual grammar.

Action semantics remain kind-owned.

---

# PHASE AG — ALL-KIND CONTRACT TESTING

## PR 94 — Mandatory contracts all 9 kinds

Explicitly run against:

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

Contracts:

```text
Core mapping
Core field adoption

media repository
media persistence

Owned repository
Owned persistence

workspace
fields
sort/group/facet consistency

Add
Media Edit
Owned Edit
```

---

## PR 95 — Release/Edition contracts

Run explicitly for every applicable kind.

No erased runtime loop.

---

## PR 96 — Action contracts

Every declared action must satisfy structural guarantees:

```text
unique action ID
valid label
visibility does not throw
action can initialize
correct file metadata for exports
import preview works
```

Run for every action-owning kind.

---

## PR 97 — Calendar contracts

Every calendar-capable kind:

```text
produces valid CalendarEvent
stable event IDs
correct kind reference
does not expose domain object
```

---

## PR 98 — Barcode contracts

Every resolver:

```text
normalization
unsupported input
valid resolution
ambiguous resolution
```

---

## PR 99 — Metadata override contracts

For each override-capable kind:

```text
field ID exists
target is valid
value encode/decode roundtrips
original/override comparison works
```

---

## PR 100 — Provider-kind contracts

Every actual pair explicitly tested.

Examples:

```text
Anime × AniList
Manga × AniList
Comic × ComicVine
Movie × TMDb
TV × TMDb
...
```

---

# PHASE AH — KIND-SPECIFIC SEMANTIC TESTS

## PR 101 — Comic semantics

```text
issue ordering
grading
key comic
variants
story arcs
ComicInfo/CLZ mapping
```

---

## PR 102 — Manga semantics

```text
volume/chapter ordering
publication
Manga provider mappings
```

---

## PR 103 — Book semantics

```text
editions
ISBN
reading state
```

---

## PR 104 — Game semantics

```text
releases
platform
completeness
region
```

---

## PR 105 — BoardGame semantics

```text
editions
components
mechanics/designers
owned completeness
```

---

## PR 106 — Movie semantics

```text
release/media mapping
owned copy semantics
```

---

## PR 107 — TV semantics

```text
season/episode ordering
release-episode mapping
watch sessions
calendar
```

---

## PR 108 — Anime semantics

Independent Anime behavior, not TV fixtures.

---

## PR 109 — Music semantics

```text
release/media/track structure
disc/track ordering
durations
classical metadata
owned copy state
```

---

# PHASE AI — HARD ARCHITECTURE ENFORCEMENT

## PR 110 — Cross-kind dependency enforcement

Reject:

```text
kinds/X → kinds/Y
```

---

## PR 111 — Provider dependency enforcement

Reject:

```text
providers/** → kinds/**
```

Allow provider imports only from owning kind integration folders.

---

## PR 112 — Core DTO ownership enforcement

Example:

```text
ComicWorkDto
```

allowed only in:

```text
generated API
kinds/comic/data/remote
Comic tests
```

Equivalent for all generated kind DTOs.

---

## PR 113 — Type-erasure enforcement

Reject production runtime usage of:

```text
CatalogItemDto
LibraryMetadataItem
LibraryKindMetadataRuntime

dynamic catalog item
Map<String,dynamic> semantic metadata
```

Allow Maps only in explicit serialization boundaries.

---

## PR 114 — Semantic action enforcement

Generic collection/calendar/barcode/import UI cannot:

```text
import concrete kinds
read semantic payload keys
inspect kind-owned fields
```

---

## PR 115 — DB ownership enforcement

No kind-specific table columns outside the owning kind.

---

## PR 116 — Declarative Add/Edit ownership enforcement

Concrete production:

```text
AddSchema
EditSchema
field definitions
vocabulary definitions
group/facet definitions
```

must reside in the owning kind.

Shared code may define only structural types/renderers.

---

# PHASE AJ — DELETE-ONLY CLEANUP

## PR 117 — Catalog deletions

Remove remaining:

```text
CatalogItem
CatalogKindCodec
LibraryMetadataItem
LibraryKindMetadataRuntime
CatalogCache
CatalogCacheRepository
```

as scheduled.

---

## PR 118 — Owned deletions

Remove remaining:

```text
OwnedItem common domain
OwnedItemDetails
VideoLikeOwnedDetails
shared grading/signature domain details
kind cast getters
OwnedItemCommonDraft
```

---

## PR 119 — Edit/Add deletions

Remove:

```text
KindEditDraft
GenericEditDraft
VideoEditDraft

DefaultLibraryEditPresentationBuilder
LibrarySectionRegistry

global semantic Add defaults
```

---

## PR 120 — Collection legacy deletions

Delete/quarantine:

```text
CollectionCsv union schema
CollectionXml semantic serializer
generic CLZ assumptions
generic series+issue matcher
```

---

## PR 121 — Hierarchy/tracking deletions

Delete:

```text
shelfVolumesProvider
generic getItemVolumes
generic Season used for non-season domains
generic tracking unit union
```

---

## PR 122 — Compatibility sweep

Search:

```text
legacy
compat
deprecated
temporary
fallback
planned
migration
```

Every surviving compatibility layer needs written justification.

No new abstractions in this PR.

---

# PHASE AK — FINAL PARITY AUDIT

## PR 123 — Full vertical ownership matrix

For every kind:

```text
Core mapper                         PASS
Core field adoption                 PASS

Media domain                        PASS
Release/Edition domain              PASS / N/A
Full Owned domain                   PASS
Tracking domain                     PASS / N/A

Media DB                            PASS
Release DB                          PASS / N/A
Owned DB                            PASS
Tracking DB                         PASS / N/A

Repository                          PASS

Workspace                           PASS
Fields                              PASS
Columns                             PASS
Sorts                               PASS
Groups                              PASS
Facets                              PASS
Vocabularies                        PASS

Add schema                          PASS

Media Edit schema                   PASS
Release Edit schema                 PASS / N/A
Owned Edit schema                   PASS

Hierarchy                           PASS / N/A

Actions                             PASS
Import/export                       PASS / N/A

Calendar contributor                PASS / N/A
Barcode resolver                    PASS / N/A
Override schema                     PASS / N/A

Provider integrations               PASS

Stats                               PASS
Value                               PASS / N/A

Mandatory contracts                 PASS
Capability contracts                PASS

No cross-kind import                PASS
No erased metadata                  PASS
No common Owned domain              PASS
No false-common domain abstraction  PASS
```

Only:

```text
PASS
FAIL
N/A
```

---

## PR 124 — Whole `lib/` semantic vacuum audit

Scan ALL:

```text
lib/**
```

not merely Library.

Review occurrences of:

```text
series
issue
volume
chapter
season
episode

publisher
imprint
isbn
barcode

grade
grading
key comic

hdr
audio
subtitle

platform
region

creator
character
story arc
track
```

Outside kinds, every occurrence must be classified as:

```text
structural infrastructure
universal non-kind domain
composition root
documentation/UI text
VIOLATION
```

Zero unexplained violations.

---

## PR 125 — Final documentation

Create/update:

```text
docs/architecture/kinds.md
docs/architecture/actions.md
docs/architecture/providers.md
docs/architecture/local-persistence.md
docs/architecture/owned-items.md
docs/architecture/core-contract-evolution.md
docs/architecture/testing-contracts.md
```

---

# WHAT SHOULD STAY GENERIC

The goal is not zero reuse.

The goal is zero false semantic ownership.

Keep reusable infrastructure where semantics are genuinely identical.

## UI

```text
LibraryTable<T>
HierarchyView<T>
Edit renderer
Add renderer
ActionMenu<T>
Import preview
dialog shells
metrics
typography
select/vocabulary widgets
```

## Structural domain refs/read models

```text
CatalogMediaKind
CatalogEntityRef

OwnedItemId
OwnedItemRef
OwnedItemSummary

CatalogSearchHit
ProviderSearchHit

CalendarEvent
ActivityEvent

ScannedCode
```

## Infrastructure

```text
VocabularyRepository
file picker
CSV reader/writer mechanics
XML mechanics
CBZ/ZIP mechanics
ICS writer
barcode camera/scanner
loan infrastructure
provider personal sync
```

## Small behavioral contracts

```text
ReadRepository<TId,T>
MutableRepository<...>

EditSchema<TModel,TDraft>
AddSchema<TDraft>

UiAction<TContext>

ImportAction<TContext,TPreview>
ExportAction<TContext>

CalendarEventContributor<TContext>

SummaryProjector<T,TSummary>
```

The moment such a contract starts gaining:

```text
publisher
series
edition
region
grade
season
```

it is no longer structural and must be moved back into kinds.

---

# ACTION ARCHITECTURE EXAMPLE

Comic might expose:

```text
ComicActions

library:
- Import CLZ CSV
- Export CSV
- Export ComicInfo.xml
- Refresh Metadata

item:
- Scan/Replace Cover
- Refresh From Provider
- Open Series
- Edit Media
- Edit Release

owned:
- Edit Copy
- Loan Copy
```

Game:

```text
GameActions

library:
- Import provider list
- Export Game collection CSV

item:
- Refresh Metadata
- Open Releases

owned:
- Edit Completeness
- Edit Copy
```

Generic UI knows only:

```text
there is an action
where it should be shown
how to invoke it
```

It does not know what "ComicInfo" or "Completeness" means.

---

# TEST PRINCIPLE

If `UiAction<T>` claims:

```text
visibility
enabled state
execution/error behavior
```

are common, write one action contract and execute it against actions from every kind.

If `EditSchema` claims tab/section IDs must be unique, run that test for all nine kinds.

If repository behavior is common, run the repository contract for all nine kinds.

Do not put the common fields into production merely to make those tests easy.

The rule is:

> Share behavior contracts and tests; duplicate domain data and semantics.

---

# CORE CHANGE EXAMPLE

Core adds:

```text
ComicWork.firstPrintingDate
```

After OpenAPI regeneration:

```text
ComicWorkDto.firstPrintingDate
```

CI fails:

```text
Unclassified ComicWorkDto field:
firstPrintingDate
```

Comic chooses:

```text
MAPPED
```

and updates only what is needed:

```text
ComicMedia
ComicCoreMapper

Comic DB if persisted
Comic fields if displayed
Comic Edit if editable
Comic provider mapping if relevant
tests
```

or:

```text
INTENTIONALLY IGNORED
reason: ...
```

No generic payload silently acquires the new field.

---

# RECOMMENDED MILESTONES

## Milestone 1

```text
PR 0–16
```

Audit, checker, tests, tiny contracts, Add/Edit infrastructure, actions, Owned architecture.

Re-audit.

## Milestone 2

```text
PR 17–27
```

Comic complete reference implementation.

Hard gate before continuing.

## Milestone 3

```text
PR 28–43
```

Remaining eight kinds.

Re-audit specifically for accidental:

```text
CommonPublishing
SharedVideo
CommonOwned
GenericRelease
```

abstractions.

## Milestone 4

```text
PR 44–73
```

Collection, Catalog, hierarchy, overrides, calendar, barcode, loans, vocabularies, imports, admin/settings, tracking.

This is the important new "outside Library" cleanup.

## Milestone 5

```text
PR 74–93
```

De-share, actions, providers, DB, runtime, UI.

## Milestone 6

```text
PR 94–125
```

Contracts across every kind, semantic tests, hard architecture enforcement, delete pass, parity audit, docs.

---

# REPORT FORMAT AFTER EVERY PR

```text
TASK:
STATUS:

Current branch verified:
-

Already completed before this PR:
-

Violations found:
-

Root causes:
-

Architecture changes:
-

Typed domain changes:
-

Kind-owned code added/moved:
-

Code intentionally duplicated:
-

Generic contracts introduced/reused:
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

Core DTO adoption:
PASS / FAIL / N/A

Cross-kind dependency check:
PASS / FAIL

Provider dependency check:
PASS / FAIL

Kind ownership checker:
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

# ABSOLUTE DEFINITION OF DONE

When the migration is complete:

```text
kinds/comic/
```

contains everything required to understand Comic semantics.

The same applies to every kind.

Outside kinds:

```text
Collection
Calendar
Barcode
Imports
Loans
Activity
Admin
Settings
Providers
Sync
```

know only mechanisms, orchestration, summaries and generic contracts.

They do not know:

```text
Comic grading
series/issue
TV seasons
Manga chapters
Book ISBN semantics
Game completeness
Movie packaging
Music tracks
```

unless the code in question is a kind-owned contribution.

And the central invariant is:

> **After kind dispatch, the type stays concrete.**

Combined with:

> **Share behavioral contracts and tests; duplicate domain semantics.**

