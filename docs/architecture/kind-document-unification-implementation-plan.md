# Kind Document Unification — Implementation Plan

## Objective and scope

Apply the same document architecture to Music, Movies, TV, Anime, Books,
Comics, Manga, Games, and Board Games across `collectarr-core`,
`collectarr-app`, and `collectarr-sync`. Update Admin consumers where needed.

Core stores one typed root row per concrete catalog item. Item-contained
metadata lives in validated JSONB documents on that root. App stores one
independently editable local entry containing metadata and personal state.
Each kind owns the definitions, validation, codecs, and form bindings for both.

Use a fresh schema-v1 baseline. Do not add migration code, compatibility
aliases, legacy decoders, provider integrations, or a Work/Release/Copy graph.
Do not reset, rewrite, or delete existing databases or backups.
All documentation, code comments, and implementation plans must be English.

## Start from the current working trees

Read applicable AGENTS.md files in each repository. Preserve current changes;
other work has been occurring in App and Sync. Inspect current code before
relying on previous audit counts or assuming that a reported defect remains.

## Current implementation status — 2026-10-03

The current working trees already contain the first coordinated implementation
slice. This is progress, not completion of this plan:

- Core now stores contained media, episodes, seasons, printings, credits, and
  identifiers in typed root documents for all nine kinds. Independent reusable
  records such as Book Series remain separate.
- Core create/update, proposals, Admin corrections, seeds, indexing, search,
  identifier lookup, fingerprints, and schema exports use the root documents.
- Music proposal normalization now supplies a stable position/order default
  when a manual track omits them; component IDs and list order are preserved.
- The App's duplicate `CatalogMusicItemDto`/disc/track transport graph has been
  removed. `MusicAlbum`, `MusicMedium`, and `MusicTrack` are the typed Music
  models at the Core transport boundary; the mapper translates only actual
  wire/domain naming differences. It excludes App-local track headers and
  playback fields, along with disc TOC/count/device details, from the Core
  payload; the canonical disc/track fields match the saved Music ledger.
- The unused Add-side `sameTracks`/normalization helper file has been removed;
  the active Music inspector uses its kind-owned track widget and models. The
  generic inspector widget remains temporarily because an existing widget
  test still imports it; its migration belongs in the deferred final test and
  compatibility review.
- The shared personal editor now accepts kind-contributed fields. Music's
  `Signed By` vocabulary loading and persistence live in its edit module; the
  shared editor no longer switches on Music or reads its vocabulary directly.
- Personal field registration no longer applies a global universal list. Each
  kind explicitly composes reusable common personal field specs with its own
  additions; the registry only combines those kind contributions.
- `MusicLibraryEntry` now stores `MusicAlbum` metadata as a typed value instead
  of a parallel catalog map. New-entry creation receives the selected Music
  item and assigns the local entry identity while decoding it; JSON remains at
  the persistence and Sync envelope boundary. The other two entry models
  still need the same typed consolidation. `BookLibraryEntry` has now joined
  this path with `BookCatalogMetadata`; Book Add and seed construction decode
  that typed value at the kind boundary instead of storing a second raw map.
  `AnimeLibraryEntry` now follows the same typed metadata boundary using
  `AnimeMetadata`, including its Add creation callback and seed fixtures.
  `BoardGameLibraryEntry` now stores `BoardGameMetadata` with the same strict
  create/decode and seed behavior.
  `MangaLibraryEntry` now stores `MangaMetadata`, including its selected
  catalog data during Add and typed seed construction.
  `GameLibraryEntry` now stores `GameCatalogMetadata`, with explicit kind
  validation on Add and typed seed construction.
  `MovieLibraryEntry` now stores `MovieCatalogMetadata`; Add validates its
  source kind and Movie seeds construct entries from typed catalog metadata.
- The empty Music entry-local mapper and an unused track-duration helper were
  removed after checking the app, tests, and integration-test trees for callers.
  Music listening and tracking tables remain registered and in use.
- Core schema and OpenAPI artifacts were regenerated and their pinned copies
  synced into App. Sync already accepts the complete `library_entry` envelope
  and personal-only activity entities, so this slice did not change Sync code.
- Core sources compile and the changed Music App sources pass targeted static
  analysis. Automated tests remain deferred until implementation and docs are
  complete, as requested.

Still outstanding: App's equivalent typed-entry consolidation for the other
eight kinds; removing business-field semantics from shared transport, draft,
and metadata registries; auditing old media/workspace adapters and their active
consumers; and finishing the kind-owned field/schema/forms organization. The
nine field ledgers remain authoritative, and exact CLZ parity is only confirmed
for Music until the other reference captures are available.

## Architectural decisions

1. A nested disc, track, medium, episode, printing, credit, or identifier is a
   typed value contained by its item. JSON storage does not remove its schema.
2. Core search returns root items. App's local track search/highlighting does
   not require separate Core track tables.
3. Each App entry has one local identity. Importing a Core item copies metadata;
   its optional source Core reference is provenance, not an editable parent.
4. Metadata and personal state remain logically distinct to protect the Core
   boundary, but belong to one local aggregate and one save operation.
5. Do not keep parallel hand-written DTO/domain graphs with the same fields.
   Use the kind's typed metadata model at transport and domain boundaries when
   their shape is identical. Keep a small adapter only for actual wire differences.
6. Shared code owns mechanisms and structural interfaces. It does not own
   catalogs of music, video, book, comic, game, or personal business fields.
7. Keep genuinely independent shared records such as users, locations,
   managed vocabularies, and reusable series/people where active workflows
   need their identity. Item references to them are kind-owned. Do not flatten
   unrelated application infrastructure into the item document.

## Phase 1 — Inventory and settle field ownership

For every kind, inventory Core ORM columns, nested response/proposal schemas,
App DTOs/domain models, personal models, form fields, filters, sorts, grouping,
CSV/import/export, inspector readers, tracking, and Sync payloads.

Create a per-kind ledger with:

- Canonical field key, type, nullability, default, and validation.
- Metadata or personal ownership; root or contained-object location.
- API, database, form, search, and import/export usage.
- Duplicate representation, legacy alias, or unused field.

Use the current working code as evidence. Do not claim exact CLZ parity for
the other eight kinds without reference captures. Preserve their supported
fields while applying the shared architecture.

Important Music discrepancies to resolve include old `MusicAlbum` fields
outside the current Core contract, generic track/disc DTOs, credits represented
both as role lists and contributions, partial/full date duplication, matrix
data represented in both catalog discs and personal medium details. Core now
limits Music discs and tracks to the fields recorded in the ledger. Track
headers and playback/file metadata remain App-local where still used; they are
not part of Core's canonical contract.

## Phase 2 — Core root document persistence for all kinds

Retain these root tables and move their contained rows into typed JSONB fields:

| Kind | Root | Contained data to consolidate |
|---|---|---|
| Music | `music_items` | Discs and tracks; finish the existing change |
| Movies | `movie_items` | `movie_item_media` |
| TV | `tv_items` | Seasons, media, episodes, identifiers |
| Anime | `anime_items` | Media, episodes, identifiers |
| Books | `book_items` | Printings, credits, identifiers, item series memberships |
| Comics | `comic_items` | Identifiers; existing contained details stay with the root |
| Manga | `manga_items` | Identifiers; existing contained details stay with the root |
| Games | `game_items` | Identifiers; existing contained details stay with the root |
| Board Games | `boardgame_items` | Identifiers; existing contained details stay with the root |

For Books, keep `book_series` only as an independent reusable grouping. Store
an item's membership values/references in its document instead of a join table.
Audit any additional item-contained tables outside these model files before
deleting them; table location alone does not establish ownership.

Implementation steps:

1. Define typed contained schemas in the owning kind, with stable UUIDs where
   editing, reordering, or activity references require identity.
2. Validate number/order uniqueness, required text, duration/range constraints,
   internal parent references, and identifier normalization.
3. Replace each removed relationship with root document fields. Use full value
   replacement on write so JSON changes update the root revision/timestamps.
4. Adapt create, update, get, proposals, corrections, and response serialization.
   Editing one root must not recreate unrelated component IDs.
5. Remove ORM classes, eager loaders, joins, cascade code, exports, and imports
   for eliminated contained tables.
6. Remove their standalone entity-reference registrations and routes. A nested
   component can be identified by root ID plus component ID without pretending
   to be an independently stored catalog entity.
7. Adapt Admin list/detail/corrections/counts, duplicate tooling, fingerprinting,
   search indexing, native seeds, schema visualization, and fixtures.
8. Preserve barcode/ISBN/identifier lookup. Current kind services query
   identifier tables: replace those queries with kind-owned root/JSONB queries
   and appropriate indexes. Do not remove working identifier search.
9. Keep API field names and nested response shapes consistent. Prefer the
   existing public shape where possible; regenerate both sides when it changes.

Core business field definitions also currently live in centralized files such
as `app/catalog/catalog_item_schema.py`. Move per-kind allowlists, child schemas,
defaults, and semantic validation into kind modules. The common registry should
compose their exports rather than maintain another copy of their field sets.

## Phase 3 — App typed entries and DTO consolidation

Each kind should expose a complete entry composed from typed metadata and
typed personal values. For example:

```text
MusicEntry
  identity / source reference / timestamps
  metadata: MusicMetadata
    discs: List<MusicDisc>
      tracks: List<MusicTrack>
  personal: MusicPersonalData
```

These are types within one aggregate, not separate persisted entities.

1. Replace kind `catalogData` maps in business code with the owning kind's
   typed metadata model. Validate maps once at HTTP/import/storage boundaries.
2. Use one metadata model compatible with the pinned Core contract. Remove
   duplicated `Catalog*Dto` and domain representations when identical.
3. Keep generated HTTP request/response wrappers only where necessary; generic
   envelopes carry routing data and an opaque/typed kind payload.
4. Keep one complete entry codec per kind. Serialization must preserve all
   fields, including fields absent from the currently visible form.
5. Reduce `LibraryEntryRecord` to a persistence envelope, not another business
   schema. Generic storage may serialize documents; kind codecs validate them.
6. Resolve root and component IDs consistently. Do not use a source Core ID as
   the local tracking/image/custom-field target.
7. Use read-only display projections for generic shelf/search widgets. Kind
   contributors derive those projections; projections are not persisted copies
   of editable field data.
8. Add/Edit uses one typed draft per kind and one atomic commit. Duplication
   clones the complete entry and attachments into independent local identities.
9. Align import/export, manual Add, Core Add, Sync, bulk edits, proposals, and
   activity readers with this aggregate. Core proposals serialize metadata only.

## Phase 4 — Remove business fields from shared App layers

Confirmed areas needing changes:

- `lib/core/api/dto/catalog/catalog_item_dto.dart`: semantic getters inspect
  kind fields and old alias/nesting shapes. Retain structural envelope behavior;
  move semantic reads to kind codecs and display projections.
- `catalog_disc_dto.dart` and `catalog_track_dto.dart`: Music fields are defined
  outside Music, and several disc getters always return null. Replace consumers
  with Music's typed contained models and remove the generic stubs.
- `catalog_edition_dto.dart`, `catalog_variant_dto.dart`,
  `catalog_publishing_details_dto.dart`, `catalog_series_details_dto.dart`,
  `video_catalog_details_dto.dart`, `game_catalog_details_dto.dart`, and
  `boardgame_stats_details_dto.dart`: inventory active consumers, move valid
  fields into their kinds, then delete obsolete transport graphs and aliases.
- `edit/draft/personal_state_draft.dart`: shared controllers currently define
  acquisition, condition, grading, sale, owner, tags, and wishlist fields.
  Replace this universal business draft with kind-owned typed drafts.
- `edit/sections/library_entry_personal_section.dart`: literal field keys and
  supported-field assumptions live in a common widget. Make the renderer accept
  kind-contributed field specifications/bindings; keep primitive widgets shared.
- `core/models/library_entry_projection.dart`: reduce shared personal projection
  assumptions and obsolete parent-copy semantics; keep only the display/action
  interface actually needed by mixed-kind consumers.
- Generic create/update payloads and edit capability callbacks: remove repeated
  positional personal-field APIs when one kind-owned entry command can express
  the operation safely.

The same audit applies to shared filters, grouping/sort registries, inspectors,
tracking drafts, CSV column lists, and global default field registries.

Keep `Money`, `PartialDate`, IDs, option types, schema interfaces, controls,
transport envelopes, database mechanics, and registry composition shared.
Field definitions, labels, defaults, valid options, and mapping rules belong to
the kind. Reuse implementations through explicit composition; avoid nine copies
of serialization or widget code just to relocate definitions.

## Phase 5 — Organize kind modules consistently

Use this logical organization inside the existing App kind root:

```text
kinds/<kind>/
  domain/       # entry, metadata, personal values, contained types
  data/         # boundary codecs, repositories, transport integration
  schema/       # metadata_fields, personal_fields, groups, sorts, filters
  forms/        # one draft and reusable field bindings
  add/          # thin Add orchestration
  edit/         # thin Edit orchestration
  workspace/   # display projections and kind contributions
  tracking/    # kind semantics and activity bindings, when needed
```

Adapt names to the domain, e.g. albums/discs/tracks for Music. Do not retain
release-group or copy terminology merely to fit a generic factory.
Keep Core kind schemas/models/services similarly grouped under a consistent
kind namespace. Avoid a broad file move before the field/model boundaries are
settled; update all imports and generators when moving files.

Separate repeatable activity records (listens, watch sessions, loans) and image
blobs may retain dedicated storage. Their kind semantics and entry bindings
must remain explicit. They are not a reason to reintroduce a separate copy layer.

## Phase 6 — Simplify remaining behavior and remove legacy

- Remove obsolete Music copy editors, drafts, schemas, media tabs, empty local
  mappers, unused remapping helpers, and their exports after consumers move.
- Remove Work/Release/Copy routing, projection, inspector, action, and label
  branches no longer representing actual entities.
- Remove fallback field aliases once canonical codecs handle all active data.
- Replace map-key introspection in shared UI with kind-provided behavior.
- Consolidate Notes/Rating/condition/matrix ownership to one editable source.
- Preserve existing workspace appearance and CLZ-style Music forms.
- Reuse name, date, tag, picklist, cover, and contained-list editors in Add/Edit.
- Keep identifiers/barcodes, track highlighting, episode tracking, and supported
  manual forms functional after storage changes.
- Remove empty folders, dead imports, obsolete generated ledgers, and completed
  implementation plans. Update current architecture documents and READMEs.

## Phase 7 — Sync and contract completion

Sync already has a `library_entry` payload with `catalog_data` and
`personal_data` in the current working tree. Inspect it before changing it;
the earlier report that it accepts only `collection_item` is now stale.

Keep the service envelope structural and lossless. Ensure kind documents,
attachments, custom fields, null-clears, deletes, and retries survive round trips.
Personal state must never cross into Core proposals. Re-export Core contracts,
copy the complete bundle into App with manifest verification, regenerate DTOs
and registries as appropriate, and refresh schema visualization artifacts.

## Completion criteria

- Core has one root table per kind; item-contained values use typed documents.
- No consumer queries or imports an eliminated contained ORM model/table.
- Each kind owns metadata and personal business-field definitions.
- Shared UI/transport/storage has no parallel kind business schema or null stubs.
- App exposes one complete independently editable entry with optional provenance.
- Add/Edit, duplicate, Core search/add, local search/highlighting, identifier
  lookup, tracking, import/export, and Sync preserve supported behavior/data.
- Component identity/order, null handling, timestamps, and revision rules are explicit.
- Core models/schemas import successfully; lint and App static analysis pass.
- Contract generation/pinning and schema exports succeed.
- Existing databases/backups remain untouched; schema baseline stays v1.
- Documentation and the final completion report describe remaining limitations
  accurately. Do not claim visual parity or runtime verification without evidence.

Run static analysis, lint, contract generation, and compilation as appropriate.
Do not add or run automated tests unless the user requests them; update obsolete
existing fixtures/assertions needed to match removed APIs, and report checks done.
