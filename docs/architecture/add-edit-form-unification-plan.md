# Add and Edit Form Unification Plan

## Current code

Add and Edit share many fields but use separate value representations and UI construction. For example, Movie has a controller-backed `MovieAddManualDraft`, a `MovieAddDraft` used for submission, and separate Edit drafts. `LibraryFieldSpec` already provides a shared field description contract, but many manual Add panes still construct controls directly. Music also has a Release Group level, so a single form cannot be imposed on every entity level.

There is a higher-priority functional issue: only the Music contribution defines `manualCandidateBuilder`. For other kinds, manual Add can call `submitCurrentSelection()` without a selected candidate. That method can return success without submitting anything, allowing the dialog to close without saving.

## Target contract

- Define fields once per kind and scope (`work`, `release`, `copy`) and use those definitions in Add and Edit wherever the fields match. The kind owns field labels, validation, and reusable field widgets.
- Keep form values typed and independent of Flutter. `TextEditingController` and `FocusNode` belong only to a UI session that disposes them.
- Use the same field schema for Add and Edit, with separate adapters: `create(values)` for a new entity and `update(original, values)` for changes. Optional Edit fields need explicit `unchanged` / `clear` / `set` semantics; an absent value must not silently erase stored data.
- Let the shared dialog host handle layout, navigation, loading, and errors. The kind owns fields, initial values, validation, Core/provider conversion, and persistence commands.
- Compose personal ownership and tracking panels separately from catalog metadata where they have different destinations or permissions.

## Implementation sequence

1. **Fix manual Add submission.** Each kind must build an explicit command or candidate from its form values. Remove the fallback that submits the current selection when the manual form has no candidate. Make `submitCurrentSelection()` fail when no selection exists or no operation runs. Show validation errors in the dialog and preserve entered values.
2. **Classify fields.** Inventory Add/Edit fields by scope and classify each as shared, Add-only, Edit-only, derived, provider-only, or personal. Extend `LibraryFieldSpec` only for real behavior differences, without introducing another set of generic string keys.
3. **Pilot with Movie.** Move values out of the controller-backed draft into typed values and a UI session. Reuse one field description in Add and Edit while keeping separate create/update adapters and ownership controls. Compare fields and submitted values before and after migration.
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

- The manual Add host no longer falls back to the currently selected search result when a kind cannot build a manual candidate. It keeps the dialog open and displays the kind's validation or availability message.
- `submitCurrentSelection()` now reports success only when at least one Core or provider item was submitted. A cancelled provider edit and stale or empty selections return failure.
- Movie manual Add now builds its candidate from `MovieCatalogFormValues`. The values model has no Flutter imports or input controllers; Add's input controllers are owned and disposed by the schema renderer.
- Movie Add and Edit now share typed field definitions for matching work and release fields. The `MovieMedia` adapter updates the movie-level fields and the `MovieRelease` adapter updates edition-level fields while preserving unknown payload data and matched contributor/character identities.
- The older combined Movie work editor still uses `MovieEditController` through the generic edit shell. Its overlapping fields and custom tabs need a separate migration decision before removing that path.
- Other kinds without a manual candidate builder show an availability error and preserve the form. Their kind-owned candidate builders remain outstanding.

### Movie pilot field scopes

| Scope | Fields in the typed pilot | Mapping |
| --- | --- | --- |
| Work | Title, sort title, description, genres, original language, age and audience ratings, runtime, work release date, subtitle, directors, characters | `MovieMedia` |
| Release | Edition title, format, region, release year/date, distributor, language, release description, covers, barcode, item number, variant | `MovieRelease` |
| Copy / personal | Ownership, condition, location, purchase details, notes, tags | Existing ownership form and payload |

The same label can appear at two scopes with different data meaning. For example, the work's premiere date and a physical edition's release date remain separate values and fields.
