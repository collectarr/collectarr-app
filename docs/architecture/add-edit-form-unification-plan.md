# Add and Edit Form Unification Plan

The [all-kind schema reorganization plan](kind-schema-reorganization-plan.md)
provides the per-kind file layout, workspace scope migration, and identifier
migration sequence. This document focuses on Add/Edit behavior and field reuse.

## Current code

Add and Edit share many fields but use separate value representations and UI construction. For example, Movie has a controller-backed `MovieAddManualDraft`, a `MovieAddDraft` used for submission, and separate Edit drafts. `LibraryFieldSpec` already provides a shared field description contract, but many manual Add panes still construct controls directly. Music also has a Release Group level, so a single form cannot be imposed on every entity level.

The manual Add submission gap has been closed: all nine kinds now define a manual candidate builder, and the Add host rejects no-op submissions. The remaining work is to consolidate overlapping Add/Edit field definitions and remove obsolete form paths as each kind migrates.

## Target contract

- Define fields once per kind and scope (`work`, `release`, `copy`) and use those definitions in Add and Edit wherever the fields match. The kind owns field labels, validation, and reusable field widgets.
- Keep form values typed and independent of Flutter. `TextEditingController` and `FocusNode` belong only to a UI session that disposes them.
- Use the same field schema and typed values for Add and Edit. A single kind-owned mapper or codec may expose both `create(values)` and `update(original, values)`; separate adapter classes or files are not required. Add must supply new identity and defaults, while Edit must preserve existing identity and unrelated data. Use explicit `unchanged` / `clear` / `set` semantics only where a partial update needs to distinguish those operations.
- Let the shared dialog host handle layout, navigation, loading, and errors. The kind owns fields, initial values, validation, Core/provider conversion, and persistence commands.
- Compose personal ownership and tracking panels separately from catalog metadata where they have different destinations or permissions.

## Implementation sequence

1. **Manual Add submission — completed.** Each kind builds a candidate from its form values. The host no longer falls back to the current search selection, and `submitCurrentSelection()` fails when no operation runs. Keep this behavior as an acceptance criterion during further migrations.
2. **Classify fields.** Inventory Add/Edit fields by scope and classify each as shared, Add-only, Edit-only, derived, provider-only, or personal. Extend `LibraryFieldSpec` only for real behavior differences, without introducing another set of generic string keys.
3. **Pilot with Movie.** Move values out of the controller-backed draft into typed values and a UI session. Reuse one field description in Add and Edit, with create and update operations in a kind-owned mapper and separate ownership controls. Compare fields and submitted values before and after migration.
4. **Extract small shared widgets.** Reuse renderers for text, number, date, enum, and sections when validation and accessibility behavior match. Keep kind-specific widgets for interactions such as release selection or Music discs.
5. **Expand by kind.** Migrate TV and Anime after Movie, then Comic, Manga, Book, Game, and Board Game. Migrate Music after the contract stabilizes, preserving distinct Release Group, Release, and Copy forms.
6. **Remove migrated paths.** Delete parallel drafts, mappers, and widgets with no callers; update imports, registry generators, and documentation. Do not retain empty compatibility wrappers solely to preserve old names.

## Completion criteria

- Manual Add persists entered data for every kind or shows an error and stays open; it cannot report success without an operation.
- A field shared by Add and Edit is defined once in its kind and has consistent validation and presentation.
- Edit preserves untouched fields and distinguishes an explicit clear from an absent value.
- No kind-specific semantic conversion moves into the shared host.
- After each kind migrates, obsolete draft/UI paths are removed and that kind's Add/Edit contracts are verified.

## Progress

- All nine kinds now provide a kind-owned manual candidate builder. Each builder maps its manual form into its typed catalog model, and the Add host no longer falls back to the current search selection.
- `submitCurrentSelection()` now reports success only when at least one Core or provider item was submitted. A cancelled provider edit and stale or empty selections return failure.
- Movie manual Add now builds its candidate from `MovieCatalogFormValues`. The values model has no Flutter imports or input controllers; Add's input controllers are owned and disposed by the schema renderer.
- Movie Add and Edit now share typed field definitions for matching work and release fields. The `MovieMedia` adapter updates the movie-level fields and the `MovieRelease` adapter updates edition-level fields while preserving unknown payload data and matched contributor/character identities.
- The older combined Movie work editor still uses `MovieEditController` through the generic edit shell. Its overlapping fields and custom tabs need a separate migration decision before removing that path.
- Manual candidate builders validate the Add schema where one exists; Board Game currently has no Add schema and maps its manual pane directly.
- TV and Anime Add forms and their dedicated catalog Edit schemas share kind-owned typed values, field specs, and create/update adapters. Their obsolete controller-backed media/release drafts were removed. Their older Work-scope generic edit routes still use kind edit sessions and remain to be migrated or removed after comparing their extra behavior.
- Comic Add and the issue/release Edit schemas now use shared typed catalog values and adapters. Its generic Work-scope `ComicEditController` remains because it also owns creator, character, link, and image editing; its overlapping catalog fields still need to be consolidated into the typed form.
- Manga Add and its Media and Release Edit schemas now share `MangaCatalogFormValues`, kind-owned field specs, and catalog adapters. The series picker now contributes its selected Core series ID to the manual candidate. The controller-backed catalog drafts were removed. The old generic Work editor remains separate; the former manual Add collector section was removed because its fields were never saved and personal ownership is handled by a separate payload.
- Book Add and its Media and Edition Edit schemas now share `BookCatalogFormValues`, kind-owned field specs, and catalog adapters. Its controller-backed catalog drafts were removed; the generic Work editor remains separate. The manual Add `Signed by` control was removed because the manual candidate did not include it and Book ownership already has a separate signed-copy field.
- Game Add and its Media and Release Edit schemas now share `GameCatalogFormValues`, kind-owned field specs, and adapters. The controller-backed manual Add, media Edit, and release Edit drafts were removed. The adapters preserve unknown payload fields and support explicit clearing of modeled values. The legacy generic Game Work editor remains separate and still needs a field-by-field migration decision.
- Board Game still needs shared typed Add/Edit catalog forms. Music remains last because it has separate Release Group, Release, and Copy scopes.
- Movie, TV, Anime, and Comic have typed shared field definitions in their dedicated catalog schemas. The full Work-scope Add/Edit field inventory and any duplicate legacy fields still need comparison before those kinds can be marked complete.

### Movie pilot field scopes

| Scope | Fields in the typed pilot | Mapping |
| --- | --- | --- |
| Work | Title, sort title, description, genres, original language, age and audience ratings, runtime, work release date, subtitle, directors, characters | `MovieMedia` |
| Release | Edition title, format, region, release year/date, distributor, language, release description, covers, barcode, item number, variant | `MovieRelease` |
| Copy / personal | Ownership, condition, location, purchase details, notes, tags | Existing ownership form and payload |

The same label can appear at two scopes with different data meaning. For example, the work's premiere date and a physical edition's release date remain separate values and fields.
