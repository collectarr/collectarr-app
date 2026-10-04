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
- Movie Add and Edit now use the same kind-owned Cast/Crew row model and
  editor. Manual Add has separate Cast and Crew tabs; rows can be added,
  removed, edited, and reordered, and the candidate builder retains their
  names and roles. The old free-text Director(s) Add field and its draft value
  were removed. `movie_edit_models.dart` was removed after its remaining
  external-link use moved to its owning shared edit model.
- Movie Characters now use the shared ordered-name editor in Add and Edit.
  The list is editable and reorderable; an expandable details area edits
  aliases, role, description, and image URL while preserving character IDs.
- Movie's local entry Edit tab that contains the video specifications is now
  labelled `Specs`, avoiding the duplicate `Edition Details` tab label.
- Movie's local-entry tab list now reuses the catalog metadata tabs, exposing
  Main, edition details, plot, Cast, Crew, Links, tracking, covers, and images
  alongside its Personal, Custom Fields, and Specs tabs. The shared metadata
  tab is labelled `Main` in both scopes.
- Movie, TV, and Anime user links now live in the shared local-entry edit
  draft, load and save by the actual `LibraryEntryRef`, and are committed with
  the entry edit. Manual links found in the old catalog payload are retained
  for catalog-only edits and moved into the local entry on its next save.
- Movie, TV, and Anime Links tabs now share one tab layout for read-only catalog
  links and editable local links; each kind supplies only its catalog-link data.
- TV and Anime Manual Add now have separate Cast and Crew tabs backed by
  kind-owned editable credit rows. Their candidate builders serialize typed
  person models rather than flattening creators into a comma-separated field.
- Book Add and Edit now share a kind-owned ordered name editor for Authors and
  Translators. Add stores typed credits instead of a comma-separated string;
  Edit's Credits tab now renders those same editors, preserves credit metadata,
  and writes the visible order back to the credit sequence.
- TV and Anime render their shared physical-media Specs tab through one
  video-kind component. Movie now renders the same Audio, Subtitles, Screen
  ratio, Layers, Color, and Discs values through its shared Add/Edit catalog
  schema; Movie and TV retain managed Audio/Subtitles vocabularies, while Anime
  keeps text input.
- Movie Manual Add now includes Audio tracks, Subtitles, Screen ratio, Layers,
  Color, and Discs in its kind-owned fields and serializes them into the Movie
  catalog document. Audio and subtitle choices use the existing Movie
  vocabularies; empty optional values remain omitted for a new item.
- Movie Manual Add now organizes the shared Movie field definitions into Main,
  Edition details, Plot, and Specs tabs alongside Covers, Cast, and Crew.
  Characters use the same editor in Add and Edit under Cast; user images and
  personal fields remain supplied by the common dialog shell.
- Movie scalar catalog metadata now uses `MovieCatalogFormValues` and one
  `movieCatalogItemFields` definition in both Add and Edit. Title, Main,
  Edition, Specs, Plot, and Cover tabs use the same schema renderer and field
  IDs. Edit no longer creates a second set of scalar metadata controllers;
  catalog persistence reads the shared values and keeps nullable clears and
  partial release dates. The catalog-only Edit tab also exposes Specs, and the
  duplicate scalar Edit tab widgets were removed. Cast/Crew rows remain in the
  kind-owned Edit controller, while Characters share the form values draft.
- TV catalog metadata now uses the Add field schema and renderer in Edit for
  Main, Edition, Specs, Plot, Covers, and Characters. The separate TV scalar
  controllers and duplicate Main/Edition/Specs tab widgets were removed;
  catalog media, episode editing/mapping, and typed credit editors remain
  kind-owned. Display Title and Localized Title are available in both Add and
  Edit, and character edits retain their existing metadata.
- Anime Main, Details, Edition, Specs, Cover, and Synopsis now use the same
  kind-owned Add schema and renderer in Edit. The typed Anime metadata draft is
  authoritative during save; the duplicate generic canonical controller
  schema and character-name controller are removed. Matching character names
  retain their metadata while editing. Anime series, episode, disc, cast, crew,
  and Links editors remain specialized where they own distinct behavior.
- Music Add and Edit now use the same `musicAlbumFields` definitions backed by
  `MusicAlbumFormValues` for scalar catalog metadata. The Add draft exposes its
  existing field API as accessors over those values, while child editors retain
  their own typed state. The Add pane title field ID now matches the schema.
  Add and Edit credit, track, image, link, and personal submission lifecycles
  remain separate.
- Book now uses one kind-owned schema for the Main, Links, Covers, and Plot
  fields in Add and Edit. The shared schema edits typed Book form values,
  including identifiers, publication details, and partial dates; Edit no
  longer keeps a second set of scalar controllers. Authors and Translators
  update the same typed credit values in both forms. Metadata not exposed by
  these tabs remains intact when saving, including additional credit roles and
  existing character details. Entry details and shared personal-state
  composition remain separate from this catalog-field slice.
- TV Manual Add now uses the shared multi-vocabulary controls and TV vocabulary
  IDs for Audio tracks and Subtitles, matching its Edit Specs controls while
  retaining the existing comma-separated catalog representation.
- TV and Anime Manual Add now divide schema fields into the same Main/Details,
  Edition, Specs, Plot, and Cover areas exposed by their Edit dialogs. Their
  existing typed Cast and Crew editors remain separate tabs; Anime's title and
  people fields retain a dedicated Details tab. Each tab reads and writes the
  same kind-owned Add draft through a filtered view of its schema.
- Book Manual Add now separates Main, Credits, identifier Links, Covers, and
  Plot into distinct dialog tabs. Authors and Translators stay on the shared
  typed credit editors, while the existing managed Publisher and Format
  options remain available across tab switches. The Links tab exposes ISBN
  separately from Barcode, and Book Edit uses the same two typed identifiers;
  editing ISBN preserves its original value until changed and clears stale
  ISBN-10/ISBN-13 variants only when the displayed identifier is edited.
- Game Add and Edit now use the same kind-owned field definitions and embedded
  schema renderer for Main, Edition details, Description, and Covers. The
  shared typed values preserve partial release dates, physical-format IDs,
  metadata credits, and optional image fields; the duplicate scalar edit
  controller was removed. Game-specific Entry details remain on their typed
  editor.
- Board Game Manual Add now groups its existing kind-owned fields into Main,
  Edition Details, Gameplay & Ratings, Description, and Covers. Shared schema
  section filtering preserves layout and visibility configuration while a tab
  presents a focused subset. Its Links tab uses the shared links table, with
  controller rows owned and disposed by the Board Game Add draft. Board Game
  Edit now renders those same catalog field definitions and typed values across
  Main, Edition Details, Gameplay & Ratings, Description, and Covers; its
  duplicate scalar controllers were removed. The kind-specific Entry details
  editor and shared personal state remain separate.
- Manga Manual Add now uses Main, Edition Details, Details, Plot, and Covers
  tabs, all backed by the same Manga draft and schema definitions. Its series
  selector and managed publisher, imprint, and format vocabularies stay owned
  by the stateful Manga pane.
- Comic Manual Add now separates Issue identity, Edition Details, publication
  metadata, and Covers into focused tabs backed by its existing draft and
  managed vocabulary state. Its Links tab now uses the shared links table and
  stores manual external links in the Comic catalog model. Creators and
  Characters now use the shared ordered name/detail editor and the same
  kind-owned row models as Edit. The Add fields cover Name/Role and
  Character/Real name; the richer creator and character metadata still needs
  a parity review.
- The TV/Anime-specific Name/Role editor is now a library UI primitive that
  also supports Comic Add's different detail labels. Editable Comic people
  drafts now live in `comic/forms/` and are shared by Add and Edit.
- Kind Add drafts now opt into resource disposal only when they own resources.
  Movie, TV, and Anime dispose their controller-backed credits; kinds with
  plain data drafts no longer carry empty `dispose()` methods.
- The shared video Specs section now also edits Screen ratio. TV and Anime
  hydrate their existing Specs controllers from metadata and persist all
  fields, including explicit clears; their Add forms expose the same supported
  Layers and Color fields. TV's Specs tab is registered in its active Edit
  tabs, and Anime's existing Details, Edition, Cast, Crew, Specs, and Links
  editors are now reachable from its active tab sets.
- Movie, TV, Anime, and Comic now use one shared ordered name/detail list for
  compatible credit/person rows in Add and Edit. It owns row layout, empty
  states, adding, removal, and reordering; kind-owned row models, controller
  disposal, and default values remain in their drafts.
- TV catalog and entry Edit registrations now use one typed custom-tab
  dispatcher for Specs, credits, metadata, catalog media, episode editing,
  and episode/media mapping. The duplicate scope dispatcher was removed.
- TV Characters are editable in both Add and Edit. Editing a character name
  retains its existing catalog identity, aliases, role, description, and image;
  removing a name removes that character from the metadata.
- Anime Characters are now editable in both Add and Edit with the same
  metadata-preserving name list behavior.
- Manga Characters are now editable in both Add and Edit. Matching names retain
  existing character IDs, aliases, roles, descriptions, and images; removing a
  name removes that character from catalog metadata.
- Manga Add and Edit now expose the same modeled metadata across Main, Edition
  Details, Details, Plot, and Covers. ISBN and Barcode, and Format and Binding,
  have independent editors; series group, publication data, descriptions,
  themes, demographic, status, and serialization platform are persisted. Add no
  longer shows Distributor or Country / region fields because the Manga model
  has no corresponding properties and those values were discarded.
- Manga Edit now renders its previously hidden metadata controllers in typed
  Edition Details and Details schemas. ISBN/Barcode changes also update their
  identifier records, and publication year, partial publication date, series
  group, and back cover map to their corresponding metadata fields.
- Manga Genres and Themes now use the shared chip picker in Add and Edit. Edit
  Format, Publisher, and Imprint use the same kind vocabulary definitions as
  Add; demographic aliases and extended edition-format labels map to their
  typed values instead of silently falling back.
- The Movie, TV, and Anime edit-tab helper files no longer carry unused
  responsive-field wrappers. TV/Anime credit tabs adapt their typed controller
  rows directly to the shared editor. Their remaining Add/Edit field parity is
  still open beyond Cast and Crew.
- The unused legacy `TagPickListField` implementation has been removed after
  confirming it had no application callers. Its golden fixture is deferred to
  the final test cleanup, as requested.
- Manga Edit now uses explicit kind-data patches for Genres, Themes, Authors,
  Artists, nullable publication fields, and partial release dates. Empty lists
  and blank nullable values clear stored data instead of restoring the previous
  metadata; blank language and country still resolve to the kind defaults
  because the Manga model requires non-null values for them.
- Game edit fields use stable draft-owned controllers and configured physical
  format/platform vocabularies. Comic edit host access requires the registered
  typed draft, with temporary controller fallbacks removed. Movie, TV, and
  Anime custom tab builders require their typed drafts; Movie scalar fields
  use `MovieCatalogFormValues`, and TV/Anime Specs use their own draft values.
- Book, Game, and Board Game edit drafts that contain only plain form values no
  longer declare or pass empty disposal callbacks. Embedded schema renderers
  own and dispose their temporary input controllers; kind drafts retain
  disposal only when they own resources.
- The eight kinds using `LibraryEditRenderer` now pass the edit request to the
  renderer instead of constructing `LibraryEditShellState` in their dialog
  widget's `build()` method. The renderer creates the request-backed draft in
  its `initState` and disposes it with the renderer. The unused `fromDraft`
  constructor and optional Game/Board Game draft-wrapper parameters were
  removed after a call-site audit. Music already creates and disposes its
  kind-owned edit draft in its state object's lifecycle. Custom field and
  child-editor controller ownership still needs its own audit.
- Schema fields and custom Edit fields now delegate responsive geometry to one
  configurable field layout. Existing breakpoints, column counts, spans,
  full-width placement, and right alignment remain caller configuration.
- Embedded Add schema layout no longer determines selection behavior: callers
  can configure the field control mode independently. Existing forms retain the
  full Edit-style pick-list interaction by default.
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
  validation message in the shared feedback area. Schema-backed text, number,
  money, date, partial-date, and single-select controls now receive focus after
  that tab is mounted, and the dialog scrolls the control into view. Extra-tab
  validators still own their focus behavior because the extra-tab contract
  does not expose a field identity.
- The shared multi-value picker now follows the pick-list dialog behavior:
  top alignment, explicit Close, and no outside-click dismissal.
- All live library Add/Edit, bulk-edit, Comic, Game, and Music multi-value
  fields now use the shared chip control. Its picker retains search and Clear;
  custom text entry and existing vocabulary-change callbacks remain connected.
- TV and Anime Genre fields now use the same multi-value chip control in Add
  and Edit. Their custom values remain kind data and do not create a managed
  vocabulary unless a kind explicitly supplies a vocabulary key.
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
  nine kinds. Movie and Book share broad catalog field definitions and typed
  person editors, but personal state, tracking, image, and link lifecycles are
  still composed separately; the other kinds also have separate catalog/entry
  compositions.
- The Add and Edit renderers still own separate submission/error lifecycles and
  controller registries. Validation policy for fields in unmounted tabs still
  needs to be made explicit. Schema-backed invalid fields now focus after tab
  navigation; a kind-owned custom tab must still provide its own focused
  validation behavior.
- Legacy custom tabs and kind-specific tab composition still have divergent
  implementations. Responsive field geometry and the basic vocabulary/text
  controls are now shared. Book Authors/Translators and Movie Cast/Crew share
  their Add/Edit row editors; date, image, selection, and other kinds' credit
  flows still need review. Runtime screenshots at matching size and text scale
  have not been reviewed.
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
| Music | Main, Details, Classical, People, Tracks, Personal, Covers, Links | Main and Details scalar catalog fields share `musicAlbumFields` and the same typed values as Edit. Add credits/tracks/links/covers and personal submission still have independent widgets and bindings. No separate entry edit dialog or caller remains in the current source. |
| Movies | Main, Edition details, Plot, Specs, Covers, Cast, Crew | Generic session/presentation renderer; catalog scalars now use the same typed field specs, values model, and embedded schema renderer as Add. Catalog and entry scopes share those metadata tabs; personal state, tracking, image, and link lifecycles remain separate. |
| TV | Main, Edition details, Plot, Specs, Covers, Cast, Crew | Main, Edition, Specs, Plot, Covers, and Characters use the same kind-owned schema in Add/Edit. The request-backed draft also retains typed media and episode editors; Cast/Crew use the shared row editor, and user links use the shared entry-local draft. |
| Anime | Main, Details, Edition details, Specs, Cover, Synopsis, Cast, Crew | Main, Details, Edition, Specs, Cover, and Synopsis use the same kind-owned field schema and renderer in Add/Edit. Characters retain matching metadata when renamed; series/episode/disc and typed credit editors remain specialized, and user links use the shared entry-local draft. |
| Books | Main, Credits, Links, Covers, Plot | Main, Links, Covers, and Plot use the same kind-owned field schema and renderer as Add. Credits use the shared typed ordered-name editor. The embedded Entry schema and shared personal-state composition remain specialized. |
| Comics | Main, Edition details, Details, Creators, Characters, Covers, Links, plus Series identity control | Generic entry editor and separately registered typed catalog editor; large custom tab/host adapter remains, with typed-draft checks and controller fallbacks removed. Add/Edit share the Comic people row models; advanced metadata parity remains to review. |
| Manga | Main, Edition details, Details, Plot, Covers, plus Series identity control | Registered routes use the shared Edit shell with typed Edition Details and Details schemas; Add/Edit expose modeled metadata in matching areas and keep distinct ISBN/Barcode and Format/Binding values. Genres/Themes share the chip picker; Format/Publisher/Imprint share Manga vocabulary definitions. Identifiers, publication dates, series group, and back cover persist independently. Managed series selection logic still overlaps Comics/Books. |
| Games | Main, Edition details, Description, Covers | Main, Edition, Description, and Covers share the kind-owned field schema and renderer with Add. The typed Entry details editor remains specialized. |
| Board Games | Main, Edition Details, Gameplay & Ratings, Description, Covers, Links | Catalog tabs share the same kind-owned field schema, typed values, and renderer with Add. Entry details and personal state remain specialized; Links use the shared table. |

The presence of a raw Flutter control is not automatically a defect. The
problem is duplicated presentation/behavior, inconsistent validation, or a
binding that cannot save the value. Specialized content editors are allowed
inside the common form lifecycle.

## 3. Confirmed shared defects and inconsistencies

### 3.1 Manual Add shell owns generic personal fields; vertical scrolling is shared

Evidence: `add/panes/library_add_manual_pane_shell.dart`.

- The shell no longer creates a Title input. Kinds provide the optional
  `identityDetails` widget and their Main schema owns its title field; the shell
  only derives the dialog header from the current draft title.
- Each tab view has one outer `EditTabShell`. Embedded `AddSchemaRenderer`
  returns an unconstrained column without a fixed height, inner vertical
  scroll view, or schema-owned padding. The shared shell owns the tab's
  vertical scroll surface.
- Personal is appended automatically when a kind has not supplied its own
  tab. Custom Fields are added when definitions exist, and My Images is always
  added. Those sections return content, not another `EditTabShell`.
- The shell currently owns the generic Personal field list (condition,
  location, purchase details, owner, tags, and notes). Move those semantic
  definitions and defaults to kind-owned personal schemas; keep shared widgets
  responsible for rendering contributed fields.
- A reorderable image strip and horizontally scrolling tag chips have their
  own bounded horizontal scrolling; they do not create a second vertical tab
  viewport. Audit any new kind-contributed tab before adding nested vertical
  scrolling.

### 3.2 Add and Edit schema renderers duplicate layout and lifecycle

Evidence: `add/schema/add_schema_renderer.dart` and
`edit/schema/edit_schema_renderer.dart`.

Both renderers use the shared field layout and control builder, but retain
separate tab composition, controller stores, and submission/error lifecycles.
Add has a standalone submit path and an embedded path. Embedded Add delegates
validation to the shell action bar's `Form`; text, number, money, and schema
fields register validators with that form. Verify validation and error routing
for fields in tabs that have not been mounted yet.

Number-field minimum, maximum, and decimal-place limits are enforced by the
shared control builder. It retains raw input in its controller and does not
write an invalid number to the draft. Continue checking that numeric drafts
distinguish blank from invalid values where a kind requires that distinction.

Text controls now use the common external-label primitive. Add select fields
also receive an external label, while specialized date, image, and selection
controls may render their own label. Some legacy custom editors still build raw
`TextFormField`s; migrate those when unifying their Add/Edit definitions.
Embedded Add selection behavior is now an explicit control-mode option,
independent of the embedded layout/lifecycle. Existing panes preserve their
full pick-list interaction through the default Edit control mode; review this
choice separately if a kind needs Add-style inline selection.

### 3.3 Remaining custom controls and dead layout helper

Evidence: `edit/fields/edit_dialog_widgets.dart`,
`ui/primitives/library_selection_fields.dart`, and the schema control builder.

`LibraryEditTextField` now composes `LibraryFormField` and the common
`LibraryTextFormControl`. Some kind-specific custom tabs still use raw
`TextFormField`s and their decoration labels. `LibraryVocabularyField` renders
multi-value vocabularies with the shared chip field and single-value
vocabularies with the labelled dropdown control. The old tag-pick-list widget
had no application caller and its implementation and barrel export have been
removed; its golden fixture remains for the final test cleanup.

The Add and Edit schema renderers still have separate lifecycle and tab
orchestration, but both delegate field geometry to shared layout primitives.
`LibraryEditDenseFields` and `LibraryEditResponsiveRow` are configuration
adapters over `LibraryResponsiveFieldLayout`. The old `EditGrid` had no
application or test callers and has been removed. Continue migrating custom
tabs to the shared responsive layout instead of adding new row/grid engines.

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
mutations notify the owning draft so the tab rebuilds after additions. Their
Add and Edit rows now render through the same list primitive as TV/Anime
credits and Comic's simpler person lists.

### P1 — Add/Edit fields and tab coverage differ

Evidence: `kinds/movie/add/movie_add_manual_pane.dart`,
`forms/movie_catalog_field_specs.dart`, `edit_dialog.dart`, and `edit/tabs/`.

- Genres now uses the managed multi-value picker in both Movie Add and Edit.
- Movie, TV, and Anime country/language/rating fields without configured
  vocabularies now use matching text controls in Add and Edit. Movie/TV audio
  and subtitle fields retain their registered vocabulary pickers. Movie Cast,
  Crew, and Characters now share their kind-owned Add/Edit editors.
- Cast and Crew now share typed, reorderable editors between Add and Edit.
  Characters expose their full supported metadata in the same editor in Add
  and Edit, including aliases, role, description, and image URL.
- Movie Add and Edit now expose `Cover Image URL` in a dedicated Covers tab,
  using the same labelled text control and the same draft value.
- Movie Main, Edition, Specs, Plot, and Cover now filter the same kind-owned
  field-spec list in Add and Edit. Title is stored in `MovieCatalogFormValues`
  in both modes, and Edit persistence no longer reads duplicate scalar text
  controllers. Partial release year/month data is preserved when the date
  input is left untouched; choosing a full date updates the matching year.
- The local-entry profile now extends the same Movie metadata tabs used by the
  catalog profile, so those fields remain editable when changing an entry.
- Empty option lists are no longer passed to Movie/TV/Anime fields as if they
  were managed pickers. Fields without an actual kind vocabulary use text
  controls; Movie Genre and Movie/TV audio and subtitle options come from their
  registered vocabularies.
- The unreachable read-only Movie `discs` tab branch and widget were removed
  after confirming neither Movie tab list registered it and there were no
  other callers. Movie media remains represented by its kind metadata; no
  separate release entity or editor was introduced.
- Kind form labels use `Sort Title`; the pinned generated metadata label still
  says `Sort title` and requires an update at its contract source/generator.

### P1 — Clearing fields and links need a save audit

Clearing Movie genres and supported optional metadata now persists an explicit
empty or null value rather than restoring the old catalog value.
The same explicit-clear behavior now applies to TV genres and Comic genres,
story arcs, creators, and characters. Empty edited lists no longer fall back
to the catalog values that were loaded when the dialog opened.

Movie, TV, and Anime previously held user-link loader/saver methods that no
active caller invoked; their controllers also derived the entry ID from the
Core catalog reference. A shared local-entry draft now loads these links using
the dispatched `LibraryEntryRef` and includes a local edit change in the normal
save transaction. The save then queues the updated personal snapshot. Link
edits are therefore isolated between locally duplicated entries. Legacy
manual links in kind metadata are used as fallback draft values for an owned
entry and are moved to its local link list on save; catalog-only edits preserve
them. Runtime verification is still pending.

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
3. Movie Edit now reads scalar catalog values from its typed shared form draft;
   TV/Anime Specs use typed draft-owned state. All eight generic edit launchers
   pass requests to the shared renderer, which creates and disposes
   request-backed drafts in `initState`/`dispose`. The unused prebuilt-draft
   constructor and Game/Board Game wrapper parameters are gone.
   Music already manages its own draft in state. Continue auditing controllers
   owned by custom fields and child editors, including Games and the Comic
   host adapter.
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
   and any remaining dead read-only media UI. The unregistered read-only discs
   tab has already been removed. Keep only genuinely specialized content.

### Phase D — Apply the conversion to every remaining kind

| Kind | Required work |
| --- | --- |
| TV | Add and Edit now render Main, Edition, Specs, Plot, Covers, and Characters from the same kind-owned schema. Cast/Crew row layout is shared across Movie/TV/Anime and Add/Edit. One typed dispatcher serves catalog and entry registrations; catalog media, episode editing/mapping, and tracking remain specialized. |
| Anime | Main, Details, Edition, Specs, Cover, and Synopsis now use the same Add/Edit schema. Cast/Crew row layout is shared with Movie/TV. Preserve kind-specific series/episode/disc editors and review the remaining Add/Edit personal lifecycle. |
| Books | Main, identifier, covers, and Plot fields now use the same schema and renderer in Add/Edit; Authors and Translators share typed ordered-name editors. Continue unifying catalog/entry and personal lifecycles, and review other credit roles. |
| Comics | Controller fallbacks have been removed from the Comic edit host; unify the generic entry and typed catalog hosts while retaining series/issue, grading, variants, and meaningful credit structures. |
| Manga | Add/Edit now expose the same modeled volume, publication, identifier, people, character, and descriptive fields. Genres/Themes use the common chip control, and Edition Format, Publisher, and Imprint use the same vocabularies in both forms. Distributor and Country / region were removed from Add because Manga metadata has no such fields. Consolidate series selection mechanics with other kinds and retain Manga-specific volume/publication semantics. |
| Games | Catalog fields now share the Add schema, typed values, and renderer across Main, Edition, Description, and Covers; the duplicate scalar controller is gone. Continue with whole-dialog submission/personal lifecycle unification and review the specialized Entry details editor. |
| Board Games | Catalog Add/Edit fields now share their schema across Main, Edition, Gameplay & Ratings, Description, and Covers, and the scalar Edit controllers are removed. Continue whole-dialog personal/entry lifecycle unification; retain players, age, play-time, components, and play tracking as typed kind features. |
| Music | Retain reference layout; converge Add/Edit credits, discs/tracks, covers, links, and personal controls. Preserve track-search highlighting in App. |

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
