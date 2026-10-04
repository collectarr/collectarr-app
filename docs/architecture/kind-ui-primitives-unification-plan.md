# Kind UI Primitives Unification — Audit and Implementation Plan

Date: 2026-10-02

## Scope and decisions

Unify Manual Add and Edit for Music, Movies, TV, Anime, Books, Comics,
Manga, Games, and Board Games. This is a source audit and implementation
handoff; runtime visual parity has not been established by this audit.

Apply this alongside `kind-document-unification-implementation-plan.md`.
Each App entry contains editable metadata and personal state. Core receives
metadata only. Do not restore Work/Release/Copy editing scopes or provider
search/import. Viewer users can create local entries and propose to Core;
direct Core creation remains an editor/admin action.

Preserve the previously requested Music dialog appearance and workspace
appearance. Shared chrome, spacing, labels, controls, and interaction patterns
should match that reference. Kinds retain their own fields and meaningful tabs.
Do not claim exact CLZ parity for kinds without reference captures.

Read applicable AGENTS.md files and inspect current working trees first.
Preserve uncommitted changes. Several files are already undergoing refactoring;
confirm every finding before changing it. Documentation remains English.

## Implementation progress

Updated 2026-10-04. This work is in progress; the checklist below is not a
claim of full Add/Edit parity.

Completed implementation slices:

- Add and Edit schema fields now share one responsive field layout for column
  count, spans, full-width fields, visibility, and right alignment.
- The shared Add pane no longer owns the Catalog Item title field. Each of the
  nine kind schemas contributes a required title field, and the dialog header
  reads the same draft value. Manual Add now contributes a Personal tab for
  every kind unless the kind already provides one.
- Embedded Edit schema tabs use an explicit embedded constructor instead of
  empty Save/Cancel callbacks. The parent dialog remains the save owner.
- Shared edit text fields and Add schema text/select controls use external
  labels and the common control height. Schema validators are registered with
  the active Form; numeric minimum, maximum, and decimal-place constraints are
  enforced on raw input.
- Movie manual Add now uses the managed multi-value Genre vocabulary and
  exposes Display Title, Original Title, Localized Title, and Search Aliases.
  Clearing supported optional Movie metadata is preserved on save.
- Game edit fields use stable draft-owned controllers and configured physical
  format/platform vocabularies. Comic edit host access requires the registered
  typed draft, with temporary controller fallbacks removed. Movie/TV/Anime
  custom tab builders also require their typed drafts; the current specs tabs
  read draft-owned controllers rather than shared dummy controllers.
- Schema fields and custom Edit fields now delegate responsive geometry to one
  configurable field layout. Existing breakpoints, column counts, spans,
  full-width placement, and right alignment remain caller configuration.
- Legacy multi-vocabulary fields now use the shared chip field, and single
  vocabulary fields share the labelled dropdown control. Managed vocabulary
  buttons remain separate from choosing or typing a value.
- Schema text, number, and money inputs and custom Edit text inputs share the
  same base text-form control and common minimum height.
- Kind Add/Edit fields and metadata comparison views now use consistent title
  casing for common labels such as Sort Title, Original Title, Search Aliases,
  Release Date, Custom Fields, and My Images.
- Edit extra tabs now require stable IDs. Personal-tab detection and Flutter
  tab keys no longer depend on the visible label text.
- Music Tracks now compares each disc against the active disc when painting
  the disc selector; the previous shadowed variable made every disc appear
  selected.
- Edit validation checks visible schema fields across inactive tabs and can
  run a validator contributed by an extra tab. When a non-mounted tab contains
  the first invalid field, the renderer switches to that tab and shows the
  validation message in the shared feedback area.
- The shared multi-value picker now follows the pick-list dialog behavior:
  top alignment, explicit Close, and no outside-click dismissal.
- All live library Add/Edit, bulk-edit, Comic, Game, and Music multi-value
  fields now use the shared chip control. Its picker retains search and Clear;
  custom text entry and existing vocabulary-change callbacks remain connected.
- Movie, TV, and Anime Edit fields without a configured vocabulary now use the
  shared labelled text control, matching their Add inputs and avoiding empty
  picker dialogs. Their supported movie genres and Movie/TV audio and subtitle
  vocabularies remain selectable.
- Replaced the accidental `EntryPolicy details` heading with `Digital Entry
  Details` across all kind edit presentations.
- The previous `TagPickListField` and `MultiSelectPickListField` have no live
  library call sites. Their public barrel export and golden fixture remain for
  the final cleanup pass; the old implementation is not used by the app UI.

Still outstanding:

- Add and Edit do not yet use one complete kind-owned field definition for all
  nine kinds. Movie still has separate scalar Add fields and typed Edit credit
  editors; other kinds also have separate catalog/entry compositions.
- The Add and Edit renderers still own separate submission/error lifecycles and
  controller registries. Validation policy for fields in unmounted tabs still
  needs to be made explicit, and focus does not yet move to the first invalid
  control after the renderer switches tabs.
- Legacy custom tabs and kind-specific tab composition still have divergent
  implementations. Responsive field geometry and the basic vocabulary/text
  controls are now shared, but date, image, ordered-list, credit, and selection
  flows still have separate behavior. Runtime screenshots at matching size and
  text scale have not been reviewed.
- The legacy pick-list source and its golden are retained temporarily even
  though application call sites have moved to the shared chip control. Remove
  the wrapper, barrel exports, and replace the golden during final UI cleanup.
- Music tracks, credits, covers, links, images, and personal fields have not
  yet converged on one complete Add/Edit draft lifecycle.

## 1. What is already shared

All nine `kinds/<kind>/add/<kind>_add_manual_pane.dart` files instantiate
`LibraryAddManualPaneShell`. Movies does not have an independent Manual Add
dialog shell. That shell uses `LibraryEditDialogScaffold`, so replacing the
Movie pane with another shell alone will not resolve the differences.

Existing reusable mechanisms worth retaining and improving:

- `edit/shell/library_edit_scaffold.dart`: dialog chrome.
- `ui/primitives/library_form_controls.dart`: external labels, groups,
  partial dates, segmented choices.
- `schema/library_field_spec.dart` and `library_field_spec_control_builder.dart`:
  typed field descriptions and control rendering.
- `ui/primitives/library_dropdown_pick_field.dart` and
  `library_multi_value_pick_field.dart`: single/multiple selection.
- `ui/primitives/library_ordered_names_field.dart`: ordered name/sort-name rows.
- `edit/sections/item_images_edit_section.dart`, custom-field sections,
  action footers, and the existing shared external-link editor.

All paths below are relative to `lib/features/library/` unless stated otherwise.

## 2. Current implementation matrix

The Add column lists kind-contributed tabs. The shared shell additionally adds
My Images and adds Custom Fields only when definitions are nonempty.

| Kind | Manual Add composition | Edit composition / identified divergence |
| --- | --- | --- |
| Music | Main, Details, Classical, People, Tracks, Personal, Covers, Links | Main registered edit route uses typed schema dialog; Add credits/tracks/links/covers still have independent widgets and bindings. An additional entry edit dialog exists; check callers before deleting. |
| Movies | One Main schema with mixed metadata fields | Generic session/presentation renderer; separate catalog/entry tab lists, custom tabs, controller-based fields, shared dummy controllers. |
| TV | One Main schema | Generic editor plus a separately registered typed media editor; duplicated video credits/spec controls and dummy controllers. Custom episode dialog is another surface to audit. |
| Anime | One Main schema | Registered edit routes use generic editor; an additional typed media dialog exists. Duplicated video credits/spec controls and dummy controllers. |
| Books | Main, plus managed publisher/format selection support | Generic editor with separate catalog/entry presentation and an embedded entry schema renderer. |
| Comics | Main, Details, plus Series identity control | Generic entry editor and separately registered typed catalog editor; large custom tab/host adapter implementation with temporary controller fallbacks. |
| Manga | Identity, Publication, plus Series identity control | Registered routes use generic editor; a separate typed media editor exists. Managed series/publisher selection logic overlaps Comics/Books. |
| Games | One Main schema | Generic editor plus embedded entry schema; custom Main/Release fields, build-time controllers, and a hard-coded platform list. |
| Board Games | One Main schema | Generic renderer with catalog/entry presentation lists and embedded entry schema; shared release identity groups remain. |

The presence of a raw Flutter control is not automatically a defect. The
problem is duplicated presentation/behavior, inconsistent validation, or a
binding that cannot save the value. Specialized content editors are allowed
inside the common form lifecycle.

## 3. Confirmed shared defects and inconsistencies

### 3.1 Manual Add shell owns business fields and nested scroll containers

Evidence: `add/panes/library_add_manual_pane_shell.dart`.

- Injects its own raw Title TextFormField into the first tab. The kind cannot
  place Title within its canonical Main layout or supply the same validation
  and label treatment as Edit.
- Wraps all tab contents in EditTabShell, while automatic Custom Fields and
  My Images contents are already EditTabShell instances. Other contributed
  tab widgets can also own their scroll/padding.
- Embedded AddSchemaRenderer adds another 16px horizontal / 14px top padding
  inside the tab shell. Layout density differs from direct Edit fields.
- Displays `main` and `entry defaults` badges, exposing implementation terms.
- Personal is not automatically contributed for all kinds. Music explicitly
  supplies it; the other eight manual panes do not.

Choose exactly one tab viewport owner, one scroll owner, and one padding
owner. The shell must not define Title or personal field semantics.

### 3.2 Add and Edit schema renderers duplicate layout and lifecycle

Evidence: `add/schema/add_schema_renderer.dart` and
`edit/schema/edit_schema_renderer.dart`.

Both implement field visibility, Wrap geometry, breakpoints 680/960,
column spans, right alignment, controller maps, validation traversal, and
submit state. The control builder is shared, but the form architecture is not.

Embedded Add does not invoke its own `_submit()` validation path. The outer
action bar calls Form.validate(), whereas schema text/number fields render
`errorText` without registering their schema validators with TextFormField.
Movie candidate creation separately checks its schema-level validator; this
does not replace consistent field validation and visible error routing.

Number field minimum/maximum/decimalPlaces are present in field specs but
the control builder does not enforce them. Invalid numeric text can become
null; integer callers can truncate decimals. Preserve raw input and distinguish
empty, invalid, and valid values before updating the typed draft.

The control builder clears labels in `_controlDecoration()`, but external
labels are only added for text, number, money, and partial dates. Review
standalone Add select and read-only controls for missing labels. Embedded
Add currently selects Edit control mode: lifecycle mode and picker behavior
should not be coupled to whether the widget is embedded.

### 3.3 Two control families and multiple grid mechanisms remain

Evidence: `edit/fields/edit_dialog_widgets.dart`,
`ui/primitives/library_selection_fields.dart`, and the schema control builder.

LibraryEditTextField still uses an InputDecoration label; schema text fields
use LibraryFormField external labels. `LibraryVocabularyField` now renders
multi-value vocabularies with the shared chip field and single-value
vocabularies with the labelled dropdown control. The old tag-pick-list widget
remains only as an unused public export and golden fixture pending final
cleanup.
AddSchemaRenderer, EditSchemaRenderer, LibraryEditDenseFields,
LibraryEditResponsiveRow, and other responsive-row helpers own overlapping
geometry. Consolidate the mechanisms, with explicit layout parameters where
the kind needs them.

### 3.4 Shared personal widgets still define business fields

Evidence: `add/panes/library_add_manual_personal_tab.dart`,
`edit/sections/library_entry_personal_section.dart`, and
`edit/schema/library_edit_schema_dialog.dart`.

The Add personal tab independently builds Condition, Purchase Price, Currency,
etc. using mixed raw and common controls. The typed Edit dialog automatically
injects a generic Personal section and detects duplicates partly by label.
Move semantic definitions/defaults/validation to kind-owned personal schemas.
Shared widgets should render contributed fields. Identify tabs by stable IDs,
not localized labels. Avoid a second personal draft only for Add.

## 4. Movies: defects to fix before visual cleanup

### Resolved P0 — Specs state and temporary controllers

Movie, TV, and Anime specs now bind to their typed edit draft controllers, and
the save path reads those same values. No static dummy controllers remain.
Custom tab builders reject a missing or mismatched typed draft with a clear
state error instead of constructing fallback controllers. Movie Cast/Crew
mutations notify the owning draft so the tab rebuilds after additions.

### P1 — Add/Edit fields and tab coverage differ

Evidence: `kinds/movie/add/movie_add_manual_pane.dart`,
`forms/movie_catalog_field_specs.dart`, `edit_dialog.dart`, and `edit/tabs/`.

- Genres now uses the managed multi-value picker in both Movie Add and Edit.
- Movie, TV, and Anime country/language/rating fields without configured
  vocabularies now use matching text controls in Add and Edit. Movie/TV audio
  and subtitle fields retain their registered vocabulary pickers. Add and Edit
  still use different people editors: Add has flat director/character text,
  while Edit has typed Cast/Crew tabs.
- Add includes cover URL text instead of the same cover editor.
- The entry tab list omits Main, Cast, Crew, and Links supplied by the catalog
  list. Local complete-entry editing must expose editable metadata as well.
- `edition` and `specs` both display Edition Details in the entry tab list.
- Empty option lists are no longer passed to Movie/TV/Anime fields as if they
  were managed pickers. Fields without an actual kind vocabulary use text
  controls; Movie Genre and Movie/TV audio and subtitle options come from their
  registered vocabularies.
- The `discs` switch branch has no matching tab in either Movie tab list.
  Its widget is read-only. Decide whether current typed item media needs a
  real editor; otherwise remove the unreachable branch/widget after tracing
  all callers. Do not reintroduce a separate release entity.
- Kind form labels use `Sort Title`; the pinned generated metadata label still
  says `Sort title` and requires an update at its contract source/generator.

### P1 — Clearing fields and links need a save audit

Clearing Movie genres and supported optional metadata now persists an explicit
empty or null value rather than restoring the old catalog value.

`MovieEditController.buildUpdatedTrailerUrls()` only retains automatic links;
user links are loaded/saved separately by CatalogEntityRef. Trace the current
commit calls and move entry-local editable links to the complete entry draft,
consistent with the document plan. Two locally duplicated entries must not
share editable links accidentally through a Core source identity.

## 5. Target structure

Use this structure as a responsibility map, adapting names to current code:

```text
features/library/
  forms/
    library_form_definition.dart       # generic tabs/sections/layout contracts
    library_form_renderer.dart         # one field/layout renderer
    library_form_session.dart          # controllers, errors, dirty state
    library_form_dialog.dart           # common shell + Add/Edit actions
  ui/primitives/
    ... existing controls, improved in place ...
  kinds/<kind>/forms/
    <kind>_metadata_fields.dart
    <kind>_personal_fields.dart
    <kind>_form_definition.dart         # tabs, groups, spans, visibility
    <kind>_form_draft.dart              # one complete entry editing draft
    <kind>_form_bindings.dart           # only where a real conversion is needed
```

Do not introduce this as an additional permanent layer over both old renderers.
Extract/reuse existing implementations and delete the superseded paths after
the routes are switched. Do not duplicate identical model fields in bindings.

Modes specify initial data, allowed actions, and persistence destination.
The kind's field definitions and layout do not fork between local Add/Edit.
Core proposal projection excludes personal fields without needing another
editor graph. Read-only catalog inspection is a capability, not a copy scope.

Shared primitives must own visual/control mechanics only. Kind forms own
labels, canonical keys, vocabularies, data types, role choices, validators,
tab placement, and metadata/personal classification.

## 6. Implementation sequence

### Phase A — Inventory and stabilize active routes

1. Trace `kinds/registry/collectarr_kind_edit_registry.dart`, each kind's
   edit contribution, Add contribution, and every child-dialog opener.
2. Create a field coverage ledger for all kinds: canonical path/type,
   Add presence/control, Edit presence/control, save binding, and inspector
   reader. Include supported fields currently absent from one form.
3. Resolve the Movie/TV/Anime dummy bindings and build-time controller
   fallbacks. Inspect Games and the Comic host adapter for the same issue.
4. Confirm obsolete dialogs by callers, not filename. Do not remove active
   episode/volume/track editors solely because they are kind-specific.
5. Pick the old Music visual reference from repository history and existing
   saved CLZ Music HTML. Record the commit/capture and measurements before
   adjusting shared tokens. Keep the workspace restoration out of this
   dialog refactor unless an actual shared-token regression requires it.

### Phase B — Consolidate shared form mechanics

1. Extract one responsive field layout from the existing schema renderers.
   Support column counts, spans, full-width fields, and explicit groups.
2. Extract one lifecycle for controller ownership, raw input, validation,
   errors, dirty state, and asynchronous submission. Keep stable field IDs.
3. Validate all contributed tabs, including unmounted/lazy tabs and custom
   editors. Navigate to and focus the first invalid field. Hidden fields
   follow an explicit kind visibility/validation policy.
4. Connect outer Add actions and Edit Save to this lifecycle. All actions
   share validation; each has its own authorized persistence destination.
   Busy state prevents duplicate submission and unsafe navigation. Failures
   keep the draft and show an actionable error in the visible shell.
5. Refactor LibraryEditTextField and schema text rendering onto the same
   primitive. Normalize labels for select/date/image/read-only controls too.
6. Supply vocabulary keys explicitly from kind specs. Remove suffix/option-set
   guessing where an explicit declaration can replace it. Share managed-list
   loading and custom-value staging across Add/Edit.
7. Remove Title injection, implementation badges, and nested tab shells.
   Contribute Custom Fields/My Images/Personal through stable tab IDs and
   one viewport owner. Preserve discoverability when custom definitions
   are empty, using an intentional empty state/manage action.

### Phase C — Movies as the first complete conversion

1. Create one complete Movie form draft from the canonical kind model and
   personal state. Preserve all supported fields from both current editors.
2. Compose Main, Details, Cast, Crew, Personal, Custom Fields, Covers,
   My Images, Links, and tracking/media tabs where current data supports them.
   Avoid duplicate labels; final placement comes from the coverage ledger.
3. Render scalar fields through common primitives and kind-owned specs.
   Use typed multi-values for genres, typed credits for people, managed
   vocabularies for supported selections, and canonical date controls.
4. Replace cloned credit rows with a shared list mechanism supporting add,
   remove, stable row identity, reorder where ordering matters, and optional
   role/character/instrument cells contributed by the kind. Extend the
   ordered-names primitive or build on it; do not discard credit details.
5. Reuse common covers/images/link editors with staged draft callbacks.
   Keep metadata links and private links distinct only where required by
   their semantics; persistence remains entry-local and atomic.
6. Wire Add and Edit to this same definition. Preserve local Manual Add,
   wishlist/tracking actions, and Core proposals with current permissions.
7. Trace replacement callers, then remove old Movie presentation builders,
   custom tab switch, dummy/fallback controllers, duplicated field groups,
   and dead read-only media UI. Keep only genuinely specialized content.

### Phase D — Apply the conversion to every remaining kind

| Kind | Required work |
| --- | --- |
| TV | Reuse video field/credit mechanisms; replace dummy spec state; unify generic and registered typed entry points; keep season/episode editing within the same draft/save lifecycle. |
| Anime | Same video cleanup; remove fallback edition controllers; reconcile the extra media dialog with active routes; preserve kind-specific series/episode fields. |
| Books | Unify catalog/entry schemas and managed publisher/format bindings; contribute authors/translators/other credits via shared list controls; retain identifiers and publication details. |
| Comics | Replace repeated controller fallbacks in comic_edit_host_adapter; unify generic entry and typed catalog hosts; retain series/issue, grading, variants, and meaningful credit structures. |
| Manga | Consolidate series/publisher picker mechanics with other kinds; keep volume/publication semantics in Manga; reconcile generic/extra media editors. |
| Games | Remove build-created release controllers and no-op callbacks; replace hard-coded platform options with Game vocabularies; integrate embedded entry schema with complete form. |
| Board Games | Merge separate catalog/entry compositions, release identity groups, and embedded entry schema; retain players/age/play-time/components and play tracking as typed kind features. |
| Music | Retain reference layout; converge Add/Edit credits, discs/tracks, covers, links, and personal controls. Preserve track-search highlighting in App. Delete the extra entry editor only after verifying callers. |

For all kinds, field coverage must be equal between local Add and Edit except
explicit action-dependent fields. Do not imitate Music's musical tab names
for other kinds. A common dialog mechanism does not require identical content.

### Phase E — Cleanup and documentation

1. Search for all superseded renderer/host/controller/group references before
   deleting their files. Remove empty folders and unused exports/imports.
2. Delete cloned Movie/TV/Anime credit/tab layout helpers after shared adoption.
3. Remove old catalog/entry/copy presentation branches once no active route
   depends on them. Rename Release/Work/Copy UI infrastructure to its current
   responsibility; retain legitimate music release dates and edition fields.
4. Standardize English label casing: Sort Title, Custom Fields, My Images,
   Release Date, etc. Replace internal policy jargon with meaningful labels.
5. Update README and architecture docs to describe one complete local entry,
   one shared form lifecycle, kind-owned semantic definitions, and common UI
   primitives. Retire completed plans only after their requirements are met.

## 7. Completion criteria and review checklist

- Every kind routes Manual Add and local Edit through the same form mechanism.
- The coverage ledger accounts for every supported metadata/personal field;
  no editable field writes a dummy controller, no-op callback, or unused draft.
- Removing genres, names, optional dates, and links actually clears them.
- Tab switches, reorders, and rebuilds preserve edits and field focus identity.
- Dialog controllers have a single owner and disposal lifecycle. Independent
  dialogs and duplicated entries cannot share mutable controllers/state.
- Scalar inputs and complex row controls follow common labels, spacing,
  heights, typography, focus treatment, error style, and managed-pick behavior.
- Label/control contrast is reviewed in light and dark themes against actual
  backgrounds; accent is not assumed readable for small or bold text.
- Narrow widths and text scaling retain readable labels and reachable actions;
  avoid fixed heights that clip validation messages or scaled text.
- Each tab owns one viewport/scroll surface; no doubled borders or padding.
- Save stages metadata, personal fields, links, images, tracking, and custom
  values consistently. Cancel produces no unintended persistence.
- Viewer Manual Add remains local; Core proposal/direct-write permissions stay
  explicit. Personal data never enters Core payloads.
- Compare screenshots of Add/Edit for each kind at matching viewport, scale,
  theme, and seeded content. Compare shared chrome against the agreed Music
  reference. Report remaining differences instead of declaring source-level
  refactoring to be visual parity.

Do not add or run tests unless requested. Static analysis and manual runtime
review can be performed during implementation; record what was actually checked.
This audit itself did not run the application or execute tests.
