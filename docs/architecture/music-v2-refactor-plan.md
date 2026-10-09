# Music v2 and Library Field Semantics Roadmap

Status: active; checkpoints A1–A4, the nine-kind metadata cutover, Music
v2 contract/domain/editing checkpoints C–F, workspace-facts checkpoint G, and
workspace field cleanup checkpoint H are implemented. The next stage is
contained grouping and filter alignment. Each completed
checkpoint is committed separately with a detailed Conventional Commit
message. Stages that touch Core contracts regenerate the Core bundle and update
the App pin in the same stage.

## Architectural contract

`LibraryKindFieldMetadata` is the single semantic declaration for a field:

```dart
LibraryKindFieldMetadata(
  id: 'music.disc.format',
  label: 'Disc Format',
  valueType: LibraryFieldValueType.text,
  cardinality: LibraryFieldCardinality.many,
  source: LibraryFieldSource.catalog,
  sourcePath: 'discs[].format',
  searchable: true,
  filterable: true,
  sortable: false,
  groupable: true,
  exportable: true,
  editable: true,
  vocabulary: MusicVocabularyIds.format,
)
```

The only field sources are `catalog`, `libraryEntry`, and `derived`; semantic
paths express contained values such as `discs[].format`. Cardinality is
`one` or `many`; list-valued text remains `valueType: text`. Workspace field
definitions reference this metadata and keep typed value access and narrowly
scoped presentation conversion. Columns and schemas explicitly select what
the user sees; metadata does not auto-generate a workspace.

Workspace search/sort/group, facets, and toolbar filter capability derive from
metadata and reject contradictory registrations. A many-valued field is not
sortable by default. Semantic operation IDs derive from the field ID unless an
operation is distinct, such as earliest and latest date reductions.

## Target Music model and behavior

`MusicAlbum` owns edition data: title and artist credits, release/original
release dates, label, country, barcode, catalog number, packaging, genres,
box-set state, covers, links, album credits, and discs. `MusicDisc` owns
physical/technical and recording data, credits, and tracks. `MusicCredit`
contains a stable ID, optional real `contributorId`, name/sort name, role and
optional role ID, `instruments[]`, and sequence. `MusicArtistCredit` remains a
separate model for credited artist name, join phrase, and sequence. Composition
belongs to tracks, never credits.

Core and App move together to nested `credits[]` and `discs[]` transport.
Recording date, recording locations, live/studio state, and SPARS move from the
album to discs. Disc format family is coarse (`vinyl`, `opticalDisc`, `tape`,
`digital`, `other`); the format name remains the detailed value. Known format
presets set family. Custom formats require an explicit family; canonical
parsing never guesses family from format text. Family controls are hidden for
known formats and exposed only for custom/advanced editing.

Music workspace projection builds immutable, deduplicated
`MusicWorkspaceFacts` once per canonical item. Facts cover disc formats and
families, recording date parts and earliest/latest reducers, SPARS, sound,
colors, RPM, locations, live/studio presence, contributors, roles, and
instruments. Facts are derived and non-persistent. Comparators and filters use
precomputed lookups rather than traversing discs repeatedly.

Many-valued filter semantics are: equals/is matches any member; not-equals
matches only when no member matches; contains matches any textual member; empty
means the collection has no values. Date filters match if any disc has a date
in the requested period. Grouping puts an album in every matching bucket but
only once per bucket. Many-valued fields do not receive implicit sort fields;
earliest/latest recording date are explicit scalar reducers with shared
precision rules. Summaries stay separate from semantic values in columns,
filters, and exports.

## Stages

### A. Field contract and capability ownership

**A1 — contract foundation (implemented):** add explicit cardinality, source,
and semantic source path to field metadata; migrate all currently registered
field metadata across the nine kinds; remove `textList` and the old origin
enum; validate IDs, paths, and list cardinality.

**A2 — workspace capability ownership (implemented):** every workspace field
and column references kind metadata; field capability getters and column
sort/group affordances derive from it. Sort/group factories reject unsupported
registrations, and schema column selection remains explicit. All nine kinds
are covered without changing their workspace behavior.

**A3 — facet capability ownership (implemented):** workspace facet definitions
reference field metadata, derive facet IDs and labels from it, and reject fields
that are not filterable. Facet-only fields are included in each kind's metadata
inventory.

**A4 — presentation filter capability ownership (implemented):** library
toolbar filters reference field metadata and reject definitions whose metadata
is not filterable. Existing interaction IDs and filter matching behavior stay
stable in this checkpoint.

### B. Nine-kind workspace metadata cutover

**Implemented with A1–A4:** metadata covers workspace fields, workspace facets,
and toolbar filters for Music, Book, Comic, Movie, TV, Anime, Manga, Board Game,
and Game. Schema resolution and cross-kind contracts pass; workspace selection
and existing filter interaction behavior remain explicit.

### C. Core Music v2 contract (implemented)

Define strict nested album/disc/credit/track transport and reject old root role
arrays and root recording fields. Make credit contributor references optional,
instruments a list, and disc IDs/track IDs/credit IDs stable and unique. Move
recording fields to discs and replace detailed format-family values with the
coarse family enum. Update Core schema/domain tests, regenerate its bundle, and
pin that bundle in App before continuing. Core schema tests, generated
artifacts, and the App contract pin now describe the strict nested v2 shape.

### D. App Music v2 domain and codec (implemented)

Mirror the strict Core contract in App domain models and codecs. Remove old
root contributor arrays, album recording fields, composition credits, and
silent format-family inference. Keep artist credits semantically separate.
Add strict JSON round-trip, unknown-field rejection, duplicate-ID rejection,
optional contributor ID, and old-payload rejection tests. Album recording
fields and role-specific contribution models are removed from the App domain.

### E. Disc format capabilities and presets (implemented)

Add `MusicDiscCapabilities` for color, vinyl weight, RPM, generic matrix, and
side matrices. Define Music-owned known-format presets and explicit family
selection for custom formats. Family is hidden for known formats and normal
editing shows the detailed format only.

### F. Credit and disc editing (implemented)

Refactor controllers before widgets. Move disc recording metadata APIs into
`MusicDiscListEditor`; add `MusicCreditListEditor` for album and disc scopes.
Replace Classical and People tabs with one Credits table (`Name | Role |
Instruments | Applies to`) where roles are vocabulary values. Put recording
date, locations, SPARS, and live/studio controls on each disc's details view.
Keep Tracks kind-owned and preserve track/disc lifecycle behavior. The Add and
Edit flows use one scope-aware Credits surface, and disc details own recording
controls.

### G. Music workspace facts (implemented)

Build immutable, distinct `MusicWorkspaceFacts` once per canonical projection.
Add mixed-disc fixtures and tests for deduplication, earliest/latest partial
date semantics, live/studio state, and album/disc contributor aggregation.
`MusicWorkspaceData` builds the immutable snapshot once from the canonical
album and reuses it when listening data changes. Workspace grouping and the
existing disc recording filters read deduplicated fact sets instead of
traversing discs and credits for each row comparison.

### H. Workspace field cleanup (implemented)

Reduce `MusicWorkspaceProjection` to common, personal, Music, facts, listening
summary, and required generic DTO data. Share catalog workspace fields between
Catalog Item and Library Entry; layer personal fields only onto Library Entry.
Separate format summary from contained disc format and keep storage summary,
devices, and slots as distinct values where applicable. Catalog and entry
schemas now hold the same catalog field definitions; their UI columns remain
explicit. Filters and exports read the shared definitions for those catalog
fields. `music.format_summary` is scalar derived display data, while
`music.disc.format` is a many-valued catalog field. Storage summary, device, and
slot are separate fields, and the concatenated summary is not used for filters
or grouping. Metadata and schema tests verify shared field identity and
one/many semantics.

### I. Disc and credit groups; filters and facets (in progress)

Split catalog, disc, credit, and personal grouping definitions. Add contained
groups for disc format/family/date/month/year/SPARS/sound/live-state/location/
color/RPM and contributor/role/instrument. Replace Classical and People
categories with Credits. Grouping definitions are split into catalog, disc,
credit, and personal modules; contained disc and credit filters use the same
typed workspace field getters as grouping, and `is_live` remains a boolean
field with Live/Studio presentation labels. Smart List v3 now supports equals,
not-equals, contains, and is-empty field rules; many-valued equality matches
any contained value, while not-equals requires no contained value to match.
Mixed-edition regression coverage exercises every contained disc and credit
group bucket, checks one membership per matching bucket, and verifies Smart List
Disc Format filtering against the same field getter used by grouping. Live/Studio
labels remain a presentation over boolean values. Broader filter/facet parity
coverage remains open.

### J. Scalar date sorting (implemented)

Add explicit Earliest Disc Recording Date and Latest Disc Recording Date
fields. Their metadata is scalar, derived, and sortable; both workspace
schemas expose these sorts. Share PartialDate lower/upper-bound comparison
rules with the facts reducer, put missing values last, and do not offer sort by
Disc Format without a useful scalar meaning.

### K. Search, export, corrections, and import boundary (in progress)

Export semantic values and summaries separately. Music now exports its format
summary beside raw disc formats, distinct recording dates/years, recording
properties, and credit facts through kind-owned field getters and formatters.
The shared report engine still owns encoding, selection, preview, and file
handling. Searchable metadata selects disc format, recording location, and
contributor facts; other technical and credit values stay out of the index.
Diff nested Core corrections by stable disc/credit IDs so reorder is not
delete/create. Extend CSV import only for fields it already supports; edit and
export capability alone does not imply import support. Core correction targets
expose `artist_credits`, album `credits`, and `discs` as correction-only object
lists, leaving ordinary metadata and Add schemas unchanged. Proposed Music
documents are validated against the complete strict v2 item before storage and
application, preserving nested stable IDs in before/after values.

### L. Physical code layout and cleanup (in progress)

Move domain, format capabilities, presets, edit credits/discs, workspace
facts/projection/fields/groups/sorts/columns/schemas into kind-owned folders.
Delete obsolete relation bags and presentation helpers that still combine
columns, formatting, and sorting. Remove MusicAlbumContribution, artificial
person IDs, Classical/People tabs and groups, root recording fields, old root
role arrays, family guessing, format ambiguity, duplicate capability flags,
and redundant sort/group/facet IDs. Do not add compatibility or migration
layers. Workspace column definitions, Music sorts, and date/money formatting
now live in separate modules; the former mixed schema-support helper is
deleted. A strict filename import audit found and removed the unused
`music_domain.dart` barrel; the remaining Music edit helpers have active
consumers. Remaining work is the final layout pass and cross-tree legacy audit.

### M. Performance, documentation, and release gate

Benchmark 1k and 5k albums, including multi-disc deluxe albums: initial
projection, facts construction, group switch, sort, filter, and allocations or
peak memory. Assert facts build once per canonical projection and no repeated
disc traversal in comparators. Update `current-status.md` with ownership,
cardinality, contained grouping, reducer, and derived-facts semantics.
Complete Core schema/tests, generated bundle and App pin, formatting, analysis,
architecture guards, unit/widget/integration tests, and Windows debug build
before closing Music v2.

## Required fixtures and regression gates

The mixed-disc fixture is `Deluxe Edition`: CD 1 is 2025 / DDD / studio / Abbey
Road / Producer John; CD 2 is 2026-02-18 / ADD / live / Wembley / Conductor
Jane / Orchestra LSO; Vinyl is 2024 / 45 RPM / Red. Tests cover strict domain
JSON, duplicate IDs, field metadata uniqueness and one/many correctness,
cross-kind behavior, group membership, date reductions, filters, corrections,
and edit scope changes including disc removal. Performance comparisons use
this fixture plus 1k and 5k album datasets.
