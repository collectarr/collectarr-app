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
  unused generic inspector widget and shared disc/track DTOs were removed after
  the App source audit found no runtime callers; stale test imports remain for
  the deferred final test cleanup.
- The shared personal editor now renders personal fields from each kind's
  contributed specifications. Those specs provide the field area, editor type,
  display order, vocabulary list, currency relationship, and enum options.
  The shared section no longer hardcodes universal field keys or switches on a
  kind. Music's `Signed By` vocabulary loading and persistence remain in its
  edit module. The unsupported `Quantity` control was removed because quantity
  is not part of any kind's personal-data model.
- Personal field registration no longer applies a global universal list. Each
  kind explicitly composes reusable common personal field specs with its own
  additions; the registry only combines those kind contributions.
- All nine local entry aggregates now hold kind-owned typed metadata rather
  than a second raw catalog map: `MusicAlbum`, `MovieCatalogMetadata`,
  `TvMetadata`, `AnimeMetadata`, `BookCatalogMetadata`,
  `ComicCatalogItem`, `MangaMetadata`, `GameCatalogMetadata`, and
  `BoardGameMetadata`. Add validates the selected kind and builds the typed
  value at the kind boundary; seed fixtures also construct typed metadata.
  JSON remains at persistence and Sync envelope boundaries. Music assigns the
  local entry identity during decode; Comic binds its typed metadata ID to the
  local entry identity.
- All nine complete local entries now group their personal values in
  kind-owned `*PersonalData` models alongside typed metadata. Their entry
  codecs preserve the existing persistence and Sync envelope shape; Add,
  update, and seed construction use the typed models. Comic reading state is
  now contained in `ComicPersonalData`; the separate tracking and activity
  records remain separate.
- The personal-field `copyWith` façade and flattened personal getters have
  been removed from all nine entry aggregates. Call sites now read and update
  personal values through the kind-owned `entry.personal` value.
- The App transport boundary no longer falls back to the old `name`, `aliases`,
  cover URL, nested `publishing`, or `trailers` field shapes. The canonical
  `variant_name` key is now read and written by the kind metadata models and
  seed factory for every kind that has that field.
- Anime and TV workspace/catalog projections now read their kind-owned typed
  metadata instead of parallel `AnimeCatalogItem`/`TvCatalogItem` work-release
  snapshots. Their obsolete catalog snapshot mappers were removed after a
  production consumer audit. Add preview, duplicate detection, workspace links,
  CSV output, and common workspace facts use the typed metadata models.
- Anime's active workspace DTO and transport codec now decode `AnimeMetadata`
  directly. The intermediate workspace mapper and its legacy `AnimeMedia`
  conversion were removed. Catalog lookup now also decodes the root metadata
  document directly, and the former mixed Anime catalog repository was reduced
  to the separate user-created episode store. Anime manual Add now edits that
  same typed metadata model; its legacy media/release form adapters and domain
  models have been removed.
- Anime and TV metadata now own the catalog display fields used by their
  candidate projections, including title variants, search aliases, covers,
  and partial release dates. Their decoders no longer accept the obsolete
  `issue_number`, `overview`, nested TV `video`, or alternate TV rating and
  publisher shapes. The pinned kind ledgers remain the source for canonical
  field keys.
- Movie workspace, Add preview, links, CSV, and contained-media editing now
  consume `MovieCatalogMetadata` directly. The duplicate `MovieCatalogItem`
  snapshot and mapper were removed. Movie media and disc rows are represented
  by the kind-owned `MovieMediaMetadata` type and validate their required
  positive media number. The Movie decoder now reads root media fields instead
  of the nested `video` shape and no longer reads `issue_number`, `sort_title`,
  or the duplicate root `discs` payload.
- Movie metadata no longer retains a raw payload map or the shared generic
  series/publishing DTO. The direct `physical_format` field is the single
  stored format value; its human-readable label is derived from the kind-owned
  format vocabulary in forms and projections. Obsolete raw `series` and
  `publishing` fallbacks were removed from Movie Add, and format statistics no
  longer count the same format twice. Movie people and characters are now
  kind-owned typed values; the role views are derived from their typed credits
  rather than persisted as duplicate role arrays. Core's Movie document and
  typed response now include `display_title`, `original_language`, `studio`,
  `production_companies`, and `series_title`; the App metadata encoder emits
  exactly the pinned Movie field set. The Movie transport codec decodes only
  kind data, keeping envelope identity outside metadata. The Movie ledger is
  synchronized to the contract, but remains provisional: the saved CLZ Edit
  form is unavailable and App-local media details still need an ownership
  review. The workspace projection no longer retains a second transport DTO;
  Add previews, format hints, lookup, and calendar dates read the typed Movie
  document rather than generic transport field getters.
- Book workspace, Add preview, links, CSV, author spotlight, statistics, and
  editing now consume `BookCatalogMetadata` directly. The duplicate
  `BookCatalogItem` snapshot and mapper were removed. Printings, credits,
  identifiers, series memberships, and characters remain typed values inside
  the Book document. The pinned Core contract now includes the Book form's
  existing subjects, back-cover image, original-language/publication details,
  edition details, binding, dimensions, and audiobook length. The Book ledger
  remains provisional because its saved Edit-form capture is unavailable.
- Board Game transport, workspace, facets, Add previews, inspector, duplicate
  detection, and CSV now consume `BoardGameMetadata` directly. The duplicate
  `BoardGameCatalogItem` wrapper and mapper were removed after a production
  caller audit; the separate typed ID used by play-session activity remains.
  Board Game field ownership remains provisional and does not claim CLZ parity.
- Game transport, workspace, facets, Add previews, calendar, lookup, and CSV
  now consume `GameCatalogMetadata` directly. The duplicate `GameCatalogItem`
  wrapper and mapper were removed after moving the remaining lookup and calendar
  reads to the kind model. Game's field ledger remains provisional; this change
  does not establish CLZ parity.
- Comic's Core item schema now retains its existing form values for cover date,
  variant description, key events, volume number, and volume start year. Comic
  response schemas type creators, characters, links, story arcs, identifiers,
  and key events instead of exposing arbitrary object maps. The App now writes
  cover date, variant description, and key events to the pinned contract, and
  its date form preserves partial cover dates when another field is edited.
  Comic identifiers, story arcs, creators, and characters are now represented
  by Comic-owned typed values through edit, lookup, workspace, and inspector
  projections; Core accepts the Comic character editor's `real_name` field.
  App-side Comic field filtering was removed so Core's kind-owned validator is
  the only proposal allowlist. Comic's metadata aggregate now stores its
  series, publishing, format, identifier, creator, character, story-arc, and
  key-event data in Comic-owned typed fields; it no longer keeps generic nested
  series/publishing DTOs or a raw payload map. Workspace, edit, inspector,
  statistics, CSV, and ComicInfo projections read those typed fields. The
  Comic Add/Edit adapter preserves typed fields it does not expose. Its CLZ
  field ledger stays provisional until a saved Edit-form capture is reviewed.
- Comic Add field projections and digital-format hints now read
  `ComicCatalogItem` directly instead of falling back to semantic getters on
  the generic transport DTO. The single-use `ComicCoreMapper` forwarding class
  was removed; transport identity remains separate at the catalog boundary.
- The empty Music entry-local mapper and an unused track-duration helper were
  removed after checking the app, tests, and integration-test trees for callers.
  Music listening and tracking tables remain registered and in use.
- The unused `upsert` operation was removed from the shared typed catalog
  transport codec and all kind codecs after a production call-site audit found
  no callers. The shared catalog transport repository remains the persistence
  path because it carries item identity separately from metadata. Old nested
  `publishing.cover_price_cents` fallbacks were also removed.
- Mixed search candidates and the Shelf now get display titles and covers from
  the owning kind's transport summary. Calendar, lookup, and hierarchy views
  for Books, Movies, and Manga decode or project their kind metadata directly.
  The generic `CatalogItemDto` no longer supplies a universal resolved-title
  or display-cover fallback.
- `CatalogItemDto` now exposes only structural identity, kind, origin, and
  kind-data transport behavior; its generic title, cover, date, identifier,
  publisher, variant, and format getters have been removed. Mixed activity and
  calendar labels use the registered kind summary, and kind-specific date,
  format, barcode, and hierarchy reads now decode their owning metadata model.
  Development seed callers were updated to use kind metadata for these reads;
  the seed fixture builder still has shared convenience inputs that need a
  separate ownership review.
- Anime and TV link editors now decode their link lists through their own
  metadata models. The shared catalog transport no longer parses generic
  `trailer_urls` or `external_links` into a cross-kind link property.
- Format badges for Anime, TV, and Manga now come from the selected item's
  kind-level format fields; hydration no longer carries a generic `editions`
  array. The shared `CatalogItemDto` no longer defines or serializes that
  legacy edition collection. Its remaining per-kind edition models and legacy
  editors still need to be audited and removed or replaced by supported
  kind-owned contained data.
- `sort_key` interpretation now belongs to Game, Board Game, Manga, and Comic
  metadata projections; the generic transport no longer applies a
  cross-kind `sort_title` fallback or exposes a generic sort-key setter.
- Synopsis reads now come from the kind-owned metadata in catalog projections;
  the shared transport no longer interprets either `synopsis` or the legacy
  `description` alias. Canonical edit commits now serialize each kind's typed
  metadata document; nullable fields are patched explicitly so clearing a form
  value does not fall back to the previous value. Image hydration also updates
  typed metadata. The shared transport no longer exposes generic field
  `copyWith` or merge methods.
- Comic search previews now read the issue number from `ComicCatalogItem`, and
  the shared `itemNumber` projection no longer falls back to `issue_number`.
- Anime physical media is now represented by an Anime-owned `media` value with
  the Core document's required `position` and typed media fields. Anime edit,
  vocabulary, and workspace projections consume that root document directly;
  seed data no longer manufactures edition or release nodes.
- Anime workspace studio display now reads the typed `AnimeMetadata.studios`
  value, and barcode/title lookup reads typed fields from the root
  `AnimeMetadata` document. The manual Add draft and candidate builder now use
  that same model instead of maintaining parallel `AnimeMediaFormValues` and
  `AnimeReleaseFormValues`. Repeated media region data stays in the typed
  contained-media list. The shared hierarchy projector now builds its episode
  nodes from typed root episodes and season-contained episodes. The obsolete
  `AnimeMedia`, `AnimeRelease`, and media-parent `AnimeEpisode` models and IDs
  have been removed. Anime's entry Add draft now stores its personal fields
  directly rather than nesting them under a release-named draft.
- `AnimeMetadata` now gives its recognized rating, audio, catalog number, video
  presentation, plot, release-status, and series-tag fields explicit types.
  Creators, contributors, characters, identifiers, seasons, and episodes also
  use Anime-owned value types matching Core's child schemas. The `rawPayload`
  map has been removed from `AnimeMetadata`; unsupported Anime relation aliases
  were removed after a production call-site audit found no consumers.
- `TvMetadata` owns its recognized catalog fields and contained seasons,
  media, episodes, credits, characters, and identifiers as typed values. Its
  raw metadata payload and the separate `TvSeries` workspace projection have
  been removed; TV workspace and inspectors now project from the typed root.
- Removed the unreferenced Anime media edit dialog and separate Anime
  media/release schema exports. The manual Add schema now edits `AnimeMetadata`
  directly; obsolete form value and adapter files were removed. The episode
  hierarchy reads the typed Catalog Item document. The current Edit UI still
  has a custom controller whose fields should be consolidated into the shared
  typed form infrastructure.
- Core now declares Anime and TV media, season, and episode shapes inside each
  kind's schema module rather than centralizing those definitions in the shared
  document module. Movie media, Book printings and series memberships, and
  Manga chapters are also defined by their owning Core kind modules. The
  emitted field shapes are unchanged; App's remaining raw Anime/TV metadata
  maps and legacy projections are still outstanding.
- Anime and TV no longer accept a separate untyped root `discs` array. Their
  physical package contents use the kind-owned `media` list, while `nr_discs`
  remains a scalar catalog field. This removes an obsolete duplicate payload
  shape from the Core schema and App's residual raw-field maps. Core's OpenAPI
  and Catalog Item contract bundle were regenerated, and the verified bundle
  is pinned in App.
- TV manual Add edits `TvMetadata` directly. Its candidate and proposal are
  built from the typed model, and the parallel `TvCatalogItemFormValues` shape
  has been removed. The old TV Edit repository and tabs were subsequently
  moved to the root document and the unused Work/Release model graph removed.
- Development seeds for all nine kinds now place repeated item data in their
  kind document: media, seasons/episodes, printings, Music discs/tracks, and
  issue or platform details no longer require an edition/release graph. Seed
  validation checks the contained values and their stable IDs in place.
- TV root media now uses the kind-owned `TvMediaMetadata` shape matching Core's
  `TV_MEDIA` document. TV metadata no longer serializes generic editions or a
  parallel physical-release list, and its media tab and vocabulary readers use
  the contained root values. TV's transport codec, workspace projection, and
  identifier lookup now consume `TvMetadata` directly. Manual Add,
  hierarchy, season tracking, episode ratings, and the media/episode Edit tabs
  also use its typed contained values. The unused `TvRepository`,
  `TvCoreMapper`, and Work/Release-shaped TV model graph were removed. Local
  custom episodes and watch/tracking records remain separate personal data.
  The unused local mapper, release-named Add draft, TV domain umbrella with
  obsolete display-level enums, and unreachable discs tab were also removed.
  Root-level and season-contained episodes share one typed season projection;
  episode-to-media assignments remain dialog-local and are not persisted.
- Manga metadata no longer exposes a generic `CatalogEditionDto` list or
  release conversion helpers. Manual Add writes its edition, format, and
  identifier values directly on the Manga document; the unused release
  prefill/update adapters were removed. The older Manga workspace hierarchy is
  still a separate outstanding migration. Manga presentation now reads its
  typed page count and imprint fields directly instead of a permanently-null
  shared publishing DTO. Its `series_title`, `volume_name`, and string-valued
  `volume_number` now map directly to the Core Manga document; the nested
  generic `series` DTO and `item_number` alias were removed. The local serial
  authority remains responsible for reusable series grouping, while the item
  document keeps only its own series title and volume facts.
- Anime, TV, and Board Game no longer keep a second generic nested `series`
  object. Their series title is a direct kind-owned value; TV's season and
  episode numbers remain direct typed item fields. Core now accepts and returns
  `series_title` for these kinds, and the pinned catalog contract was
  regenerated. Core's editorial field schema also exposes it to Admin
  corrections. The development seed factory flattens its detail inputs into
  the item document instead of writing `series`, `video`, `game`, `music`, or
  `publishing` wrapper objects.
- The unused shared `BoardGameStatsDetailsDto` was removed after a full App
  source and fixture reference search found no callers.
- The generic `CatalogEditionDto` and `CatalogVariantDto` were removed from the
  App transport surface after the active-library audit found no production
  consumers. Their remaining references are confined to old tests and
  fixtures, which are deferred until the final test cleanup pass.
- Music development seed tracks and discs now use Music-specific seed values
  and encode into the canonical contained `discs -> tracks` document shape.
  The obsolete generic inspector and Core API disc/track DTOs are gone; Music's
  active model and editor remain the only production owners of track data.
- Generic Core API DTOs for publishing, series, video, and game detail objects
  have been removed. Development fixtures now use seed-only typed values, and
  the seed factory no longer accepts `Object`-typed detail values.
- The unused Catalog Item target-ref adapter was removed after a repository-wide
  production call-site search found no consumers.
- Core now accepts and exports the Board Game fields already exposed by the App
  form, including player/play-time details, ratings, people, languages, themes,
  and expansion data. The form uses Core's `min_age` and `variant_name` keys;
  App's pinned contract was regenerated. This does not establish CLZ parity.
- Core's Game document and response now retain the active App fields
  `franchise`, `original_language`, `languages`, and the normalized
  `physical_format_label`; App's kind model writes those fields explicitly and
  the pinned contract was regenerated.
- Game metadata now has explicit properties for the complete pinned Game root
  field set instead of retaining a `rawPayload` map. Identifier objects and
  string identifiers, person credits, and links have Game-owned value types;
  canonical decoding no longer accepts nested `game`/`series` wrappers or
  singular-platform and plural-publisher aliases. Partial release dates are
  preserved through the App model. Core and App now also expose and pin
  `toy_subtype` and `toy_type`, which the Game inspector already displayed.
  The Add field schema exposes those two values. Game's PriceCharting
  identifier and multi-tier valuation ownership still needs a separate review;
  those values are not part of the Core document.
- Removed the empty Game local mapper after the production reference search
  found only its own export. The active Game entry repository remains in use.
- Board Game metadata now has explicit fields for the complete pinned Board
  Game root contract, including typed identifiers, contributors, characters,
  external links, and partial release dates. Manual Add, Edit, workspace,
  inspection, and CSV projections consume those typed values; `rawPayload` and
  its field aliases have been removed from the Board Game kind. This keeps the
  existing provisional Board Game field set and does not establish CLZ parity.
- Manga's Catalog Item transport now decodes the kind-owned `MangaMetadata`
  model instead of the parallel `MangaMedia` projection. Removed the unused
  standalone Manga media edit dialog/schema and its work/publication wrappers;
  the shared kind Add/Edit and workspace paths remain active. Manga's root
  metadata no longer retains an arbitrary payload map. Chapters, characters,
  credits, identifiers, and external links now have Manga-owned typed values;
  manual Add and canonical Edit update typed Manga metadata, and catalog,
  workspace, and inspector projections read it. The remaining field ownership
  differences are still under review against Manga's provisional Core ledger.
  The unreachable empty Manga local mapper and unused per-kind domain ID shell
  were removed; the typed entry repository remains the active local store.
- Core schema and OpenAPI artifacts were regenerated and their pinned copies
  synced into App. Sync already accepts the complete `library_entry` envelope
  and personal-only activity entities, so this slice did not change Sync code.
- Core sources compile, and the changed per-kind App entry, Add, and seed files
  pass targeted static analysis. Automated tests remain deferred until
  implementation and docs are complete, as requested.

Still outstanding: completing field ownership and typed schema organization
across all kinds; replacing the universal `PersonalStateDraft` with kind-owned
typed drafts and moving remaining validation/serialization adapters out of the
shared personal editor; removing active edition/media projections and duplicated shared DTO
graphs from the remaining kinds; and finishing kind-owned field, schema, and
form organization. Anime's workspace, lookup, catalog transport, manual Add,
and episode hierarchy now use the flattened typed document. Its current Edit
UI still has a custom controller with duplicate field controllers to move into
the shared typed form infrastructure. TV workspace, manual Add, hierarchy,
tracking, and Edit tabs now consume `TvMetadata` and its contained typed
values; custom episodes and watch history remain separate local personal
records.
Manga's root map has been removed, but App/Core field ownership differences
remain under review against its provisional ledger. Game's
PriceCharting identifier and valuation snapshots still need an ownership
decision and are not in the Core contract. The nine field ledgers
remain authoritative, and exact CLZ parity is only confirmed for Music until
the other reference captures are available.

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
- `catalog_edition_dto.dart`, `catalog_variant_dto.dart`, and
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
