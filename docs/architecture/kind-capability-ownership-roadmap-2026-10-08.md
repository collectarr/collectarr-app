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
- [ ] Audit central kind switches across actions, reports, search, folders,
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
changes. The central kind-switch audit has started: stats tracking titles now
come from each kind's tracking topology, and catalog detail hydration
delegates kind-specific DTO decoding through metadata capability. The PDF
report now reads item and child-row fields, labels, defaults, and value
formatting from the kind export capability; shared code owns print layout and
file handling. The audit still needs to cover the remaining action, search,
folder, image, and vocabulary paths. A shared
`LibraryVocabularyEditAccumulator` collects schema-renderer and shell field
updates. Music binds its schema fields, custom fields, details form, and
library-entry personal fields to one accumulator for the edit session. The
shared commit boundary turns the collected values into one local vocabulary
change, while catalog-only Music edits retain the collector in the kind draft.
Remaining P0 work is tracked above.
