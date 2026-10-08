# Kind Capability Ownership Roadmap

This roadmap records the architecture work for making each library kind the
owner of its semantic contributions while keeping reusable UI, persistence,
and serialization mechanics shared. A new kind should primarily require
registration and files under `features/library/kinds/<kind>/`.

## Working rules

- Keep domain meaning in the owning kind; keep rendering, lifecycle, and file
  mechanics in shared infrastructure.
- Prefer existing contribution contracts over parallel registries.
- Keep kind-specific differences explicit. Do not build universal domain
  models for fields whose meaning differs by kind.
- Remove superseded code after cutovers; compatibility shims are not a goal.
- Make each coherent stage reviewable and commit it with a Conventional Commit
  subject accepted by semantic-release, for example
  `refactor(library): collect edit vocabulary changes in the shared session`.
- Update this roadmap as stages land. Do not mark a stage complete until its
  implementation and relevant checks are complete.

## P0 — stabilize the current Music cutover and next growth points

- [x] Finish the strict Music contract: one canonical representation for
  dates, extras, format data, and other duplicated fields; keep import
  normalization separate from canonical write validation.
- [x] Move CSV/TXT export field definitions and default columns to kind-owned
  contributions while keeping encoding, file handling, and column selection
  shared.
- [x] Audit central kind switches across actions, reports, search, folders,
  edit setup, display, images, and vocabulary; move semantic behavior to kind
  contributions where the current architecture permits it.
- [x] Reduce `MusicAlbumEditDraft` orchestration by separating album values,
  discs, credits, links, and track editing logic where useful.
- [x] Audit Music edit/forms for orphaned components after cutover and delete
  confirmed dead code.

## P1 — consolidate shared edit and kind contracts

- [x] Make common edit tabs declarative: personal data, custom fields, images,
  and links are composed by the shared edit dialog from kind contributions.
- [x] Collect vocabulary edits in a shared edit-session accumulator; kinds
  declare vocabularies and field specs emit changes.
- [x] Share image persistence and editor lifecycle where semantics match;
  kinds declare purposes, labels, aspect ratios, and other real differences.
- [x] Clarify reusable form schemas versus the library edit workflow in naming
  and directory boundaries.
- [x] Standardize catalog mapper/codec contracts and expose them through kind
  registration.
- [x] Derive correction ownership metadata from field specifications where
  possible, then keep canonicalization and diff generation shared.
- [x] Move kind-specific indexed search values from DTO overrides into
  searchable workspace field metadata; keep title, custom-field, personal,
  and date indexing in the shared search layer.
- [x] Reuse typed workspace field identity, labels, and value getters for
  overlapping kind-owned report columns; keep export formatting and layout
  settings in the export contribution.
- [ ] Consolidate field metadata used by filtering, sorting, exporting,
  and editing without forcing unrelated fields into one model.

## P2 — shared interaction primitives and core contract cleanup

- [ ] Extract interaction-only primitives for reorderable segment tabs,
  selection toolbars, editable table headers, compact actions, and bulk action
  bars when another editor can reuse them.
- [x] Add a thin Core response base for truly identical envelope fields; keep
  kind-specific response schemas separate.
- [x] Remove packed multi-value transports; no quoted `||` delimiter remains
  in App or Core source.
- [x] Remove active compatibility and migration paths after their consumers
  are removed.

## Execution status

The repository already has per-kind modules, CSV import/projection profiles,
and several capability registries. Implementation should extend those
boundaries instead of introducing a second ownership system. The CSV/TXT
export page now consumes a structural export capability; Music owns its item
fields, child rows, labels, and default filenames. The shared page owns column
selection, sorting, quoting, preview, and file handling. The Music edit/forms
reference audit removed three unreferenced pre-cutover helpers; the disc text
field, disc tab button, disc details view, and active form adapters remain in
use. `MusicDiscListEditor` owns discs and composes `MusicTrackListEditor` for
track hierarchy, ordering, and duration state. `MusicAlbumEditDraft` now
combines those editors with scalar values, credits, links, and vocabulary
changes. The central kind-switch audit is complete: stats tracking titles and
compact row facts now come from kind capabilities, empty report flows require
an explicit kind, and catalog detail hydration delegates kind-specific DTO
decoding through metadata capability. The shared library scan now finds no
direct kind model checks or enum branches outside registration maps; action,
search, folder, edit, image, and vocabulary behavior routes through existing
kind contributions. The PDF
report now reads item and child-row fields, labels, defaults, and value
formatting from the kind export capability; shared code owns print layout and
file handling. A shared
`LibraryVocabularyEditAccumulator` collects schema-renderer and shell field
updates. Music binds its schema fields, custom fields, details form, and
library-entry personal fields to one accumulator for the edit session. The
shared commit boundary turns the collected values into one local vocabulary
change, while catalog-only Music edits retain the collector in the kind draft.
Kind-specific search tokens now come from searchable workspace field
definitions instead of per-kind DTO getters. The shared index collects those
typed values through each kind's catalog workspace registry while retaining
common title, custom-field, location, and date handling. Search fields include
metadata such as Music barcode/catalog number, Movie studio, Game region, and
TV barcode even when those fields are not visible workspace columns.
Music's item export columns now reuse the catalog workspace definitions for
artist, title, format, barcode, catalog number, release date, track count, and
label. Their shared field IDs and labels line up with workspace metadata while
CSV/PDF formatting, visibility, and ordering remain export-specific.
Music fields shared by edit forms and workspace now take canonical IDs and
labels from one kind-owned definition. The typed workspace field, sort, group,
and facet identifiers, workspace labels, form fields, and form layouts reuse
those values. Draft readers, writers, validation, and vocabulary behavior stay
in the edit form specs; the broader cross-kind field metadata consolidation is
still open. Book now shares the same contract for subtitle, series, publisher,
format, release date, page count, and ISBN across workspace and form metadata.
The Book edition-title field remains distinct from the workspace work title;
their shared word does not make them the same field. Movie shares it for title,
original title, genre, age and audience ratings, runtime, format, release date,
and barcode. The movie publisher and distributor fields stay separate because
they read different metadata values. Board Game now shares publisher, release
date, barcode, player counts, play-time bounds, complexity, BGG rating/rank,
and expansion target IDs and labels across forms and workspace fields.
Music release, original release, and recording dates now have one canonical
`{year, month, day}` representation across the Core model, API, correction
flow, search projection, App mapper, and pinned contract. Core rejects legacy
date strings and `*_date_parts` fields on Music writes. Music `extra` is now a
`list[str]` through Core JSONB storage, API responses, corrections, App forms,
vocabulary edits, grouping, and pinned field metadata; the packed `||` form is
gone. The broader strict Music contract remains open for other payload
normalization. Canonical Music disc documents now reject
missing component IDs and track positions/orders instead of generating them;
the correction editor sends explicit disc and track identities, track
positions have one string representation, and Core's request/response
contracts require every track identity, order, and hierarchy flag. App rejects
incomplete Core disc rows. Disc format labels and format families stay on
discs, while the album format summary remains derived; the unsupported
album-level format proposal was removed. Music credit writes now require
explicit IDs, names, person references, and ordering; Core no longer creates
credit IDs from strings or missing values, and App emits complete rows. Core
also rejects implicit RPM/weight conversions, untrimmed Music disc/root text,
credit text, and correction values that were previously whitespace-collapsed
or silently deduplicated. Music external links now have one strict `{url, title?,
description?}` shape in Core, correction payloads, and App decoding; malformed
rows and legacy link aliases are rejected instead of normalized or dropped.
Music's Core/local field-name translations now live in the catalog mapper;
local JSON decoding no longer accepts old `label`, `country`, `spars`, or
artist-credit aliases. The App mapper now requires complete response
collections and validates root, disc, track, link, and credit value types
before constructing the local model. Core canonical Music documents now reject
unknown root and nested fields instead of filtering them away, and tracks are
declared only inside discs rather than as a duplicate root field. Manual Add emits
the same empty collections when a role or list has no values. Core requires
canonical Music collections, including disc sound types, even when empty; it
preserves submitted artist text and item order instead of deriving or sorting
values. Local Music snapshots now
reject malformed album/disc/track rows, unknown aliases, and numeric coercion;
the `entry_type` header fallback and silent dropping of invalid child rows are
gone.
Local artist and role credit rows now also require explicit identities, text,
and sequence values; numeric sequence coercion and the default `Artist` role
are gone.
Manual Music Add now emits complete artist and role credit collections,
including explicit credit/person identity and sequence, plus empty canonical
collections for unused roles. Canonical write schemas validate rather than
normalize Music payloads; normalization remains in import/seed paths. The P0
Music cutover is complete.

The Music My Images tab now uses the shared `ItemImagesEditSection` for upload,
caption/type editing, ordering, rotation, crop, restore, and removal. Music
supplies its image vocabulary, labels, count, and tab copy; cover-source selection
and its square crop workflow remain kind-specific. The Music image repository
adapter has been removed. Music reads and saves through the shared item-image
repository; the kind model owns only the mapping between its cover/personal
purposes and the stored image type.

Shared edit presentations can now contribute standard tab specs with target
scope and placement around kind tabs. Game and Movie use this for Personal,
Custom Fields, and My Images, so their presentation builders no longer repeat
those specs across catalog and entry tab lists. The typed schema dialog now
composes Personal, Custom Fields, My Images, and Links from structured
contributions. Music provides its personal layout and fields, custom-field
values, image purpose and vocabulary controls, and typed link mapping; the
shared dialog owns the common tab and editor lifecycles. Music Covers stays a
kind-specific crop and source-selection workflow.

Book, Comic, Manga, and TV now also declare their common Custom Fields, Links,
Personal, and image tabs through presentation contributions where those tabs
already existed. Comic scopes Personal and Custom Fields to library entries;
the other migrated tab specs preserve their previous sections, labels, and
ordering. The Manga duplicate Links tab was removed during the move. Anime now
declares Links across targets and Personal, Custom Fields, and Photos for
tracked or entry contexts; Boardgame declares Links and My Images. Music still
uses the typed schema dialog with the same shared Personal, Custom Fields,
My Images, and Links lifecycle. Album Credits, Tracks, and Covers remain
Music-owned because their data and interactions are kind-specific.

Reusable field specs, form schemas, renderers, and validation now live under
`features/library/forms/`; the library edit schema/dialog workflow remains under
`features/library/edit/schema/`. Catalog transport already uses the shared
`CatalogKindTransportCodec<T>` interface for typed decoding, encoding, and
workspace projection. Each `LibraryMetadataCapability` now owns its codec;
mixed catalog infrastructure derives its dispatch list from that capability
registry. Music encoding delegates to its canonical mapper, while the other
kinds encode their typed JSON documents.

Core response schemas for Anime, Board Game, Book, Comic, Game, Manga, Movie,
Music, and TV now inherit identical `id`, `kind`, `title`, and `revision`
envelope fields from a thin base. Per-kind response fields and kind literals
remain in their owning schemas.

The App and Core source audit found no quoted `||` multi-value transport
delimiter. Catalog-owned manual links are no longer copied into a local entry
as a compatibility fallback; entry-local links load only from their own store.
The one-time Music Collector user-field transfer and Music Label's legacy
export-based import are removed with their dedicated UI, source metadata, and
configuration. Ordinary file imports remain part of each kind's import
capability.

Admin correction fields now come from Core's per-kind metadata field schema.
Kind contributors retain only correction codecs and writers for physical
formats, links, related entities, Music extras/tracks, explicit kind aliases,
and required titles; repeated direct readers for ordinary canonical fields
are removed. The shared correction builder owns field applicability and
presentation from Core metadata while preserving kind-specific save behavior.
