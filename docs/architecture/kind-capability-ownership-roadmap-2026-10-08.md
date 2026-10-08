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

- [ ] Finish the strict Music contract: one canonical representation for
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

- [ ] Make common edit tabs declarative: personal data, custom fields, images,
  and links are composed by the shared edit dialog from kind contributions.
- [x] Collect vocabulary edits in a shared edit-session accumulator; kinds
  declare vocabularies and field specs emit changes.
- [ ] Share image persistence and editor lifecycle where semantics match;
  kinds declare purposes, labels, aspect ratios, and other real differences.
- [ ] Clarify reusable form schemas versus the library edit workflow in naming
  and directory boundaries.
- [ ] Standardize catalog mapper/codec contracts and expose them through kind
  registration.
- [ ] Derive correction ownership metadata from field specifications where
  possible, then keep canonicalization and diff generation shared.
- [ ] Consolidate field metadata used by filtering, sorting, exporting,
  searching, and editing without forcing unrelated fields into one model.

## P2 — shared interaction primitives and core contract cleanup

- [ ] Extract interaction-only primitives for reorderable segment tabs,
  selection toolbars, editable table headers, compact actions, and bulk action
  bars when another editor can reuse them.
- [ ] Add a thin Core response base for truly identical envelope fields; keep
  kind-specific response schemas separate.
- [ ] Remove remaining packed multi-value transports and compatibility-era
  comments/helpers after confirming their consumers are gone.

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
collections for unused roles. Remaining P0 work is tracked above.
