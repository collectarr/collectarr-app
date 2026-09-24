# Kind Form and Workspace Schema Reorganization Plan

## Goal and boundaries

Organize all nine kinds by the entity that owns a value, then by the operation that uses it. Add and Edit should share a typed form field definition when they edit the same value. Workspace fields, columns, sorts, and groups should be explicit for each entity scope. The generic host continues to consume structural schemas; kind modules own field meaning, projection, validation, and mapping.

This is a source-organization and type-safety migration. It does not require changing Core DTOs, domain entity identities, Drift columns, or sync wire keys. Workspace and form identifiers *may* change when a scoped name is clearer. Persisted user preferences must be migrated when they do.

Keep these three concepts distinct:

| Concept | Responsibility | Example |
| --- | --- | --- |
| Form field spec | Input control, label, validation, value binding | Release barcode in Add/Edit |
| Workspace field | Projected value used by a view | Release barcode column/filter value |
| Domain property | Stored semantic value | `MusicRelease` barcode |

The first two may share a semantic name, but they do not need the same class or identical identifier. A projected or computed workspace field may have no editable form counterpart.

## Current starting point

- All nine kinds now have typed values and shared field definitions for their catalog Add and dedicated Edit scopes. Music keeps Release Group and Release values separate, while Owned Copy and tracking remain their own operation.
- The older combined Work edit sessions for Movie, TV, Anime, Comic, Manga, Book, Game, and Board Game still need a compatibility review against the typed catalog forms. Preserve their kind-specific relations and extra tabs while deciding which catalog fields can move.
- Music now has separate Release Group, Release, and Owned Copy field catalogs and schemas, with scope-aware preference migration for the split release date and track count IDs.
- Most non-Music kinds declare fields, columns, sorts, groups, and defaults in one large `<kind>_fields.dart` and call `forScope(...)` for Work, Release, and Copy. This hides each scope's complete surface behind a filtered aggregate.

## Target layout

Use kind-specific names for domain scopes. Create a file only when it owns a useful, independently readable unit; small sort or group lists can stay beside their scope schema.

```text
lib/features/library/kinds/<kind>/
  forms/
    <work_name>/
      <work_name>_values.dart
      <work_name>_field_specs.dart
      <work_name>_mapper.dart
    <release_name>/
      <release_name>_values.dart
      <release_name>_field_specs.dart
      <release_name>_mapper.dart
    owned_copy/                 # only for kind-specific personal fields
      owned_copy_values.dart
      owned_copy_field_specs.dart
      owned_copy_mapper.dart
  workspace/
    <work_name>/
      <work_name>_fields.dart
      <work_name>_columns.dart
      <work_name>_sorts.dart    # split when substantial
      <work_name>_groups.dart   # split when substantial
      <work_name>_schema.dart
    <release_name>/...
    owned_copy/...
    <kind>_workspace_ids.dart
    <kind>_preference_codec.dart
    <kind>_workspace_contribution.dart
```

`*_schema.dart` composes the scope's fields, columns, sorts, groups, defaults, and codec; it should contain little semantic mapping. `forms/` owns UI input values and field specs. Add and Edit assemble the required sections/tabs from these specs and use operations from a single kind-owned mapper where that is sufficient: `fromEntity`, `create`, and `update`. Separate adapter classes or files are optional, not a requirement. Create uses new identity/defaults; update retains original identity and unrelated data. Use three-state patches only for partial updates where `unchanged`, `clear`, and `set` differ.

Keep reusable formatting and simple field factories under a kind-local `workspace/shared/` only when at least two scopes use the same behavior. Do not move kind semantics into `lib/features/library/workspace/` to avoid duplication inside a kind.

## Kind-by-kind target

| Kind | Work form/workspace | Release form/workspace | Copy form/workspace | Migration focus |
| --- | --- | --- | --- | --- |
| Comic | Issue/media | Variant/release | Owned comic | Preserve series, creators, issue number, variant, image, and copy boundaries; reconcile the older combined editor. |
| Manga | Volume/work | Edition/release | Owned volume | Keep volume identity and edition metadata distinct; preserve series and contents behavior. |
| Anime | Anime work | Anime release | Owned anime | Consolidate the existing typed form pilot and older Work editor; keep episode/tracking UI separate from catalog fields. |
| Book | Book/work | Edition | Owned book | Share bibliographic Add/Edit fields while keeping ISBN/format/edition and copy condition at their owning scopes. |
| Game | Game/work | Platform release | Owned game | Keep platform, region, edition, and copy-only condition/packaging distinct. |
| Board Game | Game/work | Edition | Owned game | Introduce a declarative Add field schema or an explicit reusable form spec; preserve components and personal completeness data. |
| Movie | Movie/work | Edition/release | Owned movie | Finish the existing typed pilot; separate its combined value object and older combined Work editor where scopes differ. |
| TV | Series/work | TV release | Owned TV | Consolidate the existing typed form pilot; preserve seasons/episodes and tracking as separate nested flows. |
| Music | Release Group/work | Release | Owned Copy | Separate the three workspace field catalogs; share Add/Edit specs at the matching level while keeping mediums, discs, tracks, listening, and copy media nested. |

Use existing domain model names where they differ from these UI labels. Do not rename domain classes solely to make folder names uniform.

## Identifier design and preference migration

1. Inventory every current `FieldId`, `SortId`, `GroupId`, facet ID, Add/Edit field ID, default, and persisted consumer before renaming. Record old string, new string, scope, value type, and meaning. Distinguish a genuine rename from a semantic split.
2. Prefer scoped workspace IDs when a name has different meaning at different levels, such as `music.release_group.release_date` and `music.release.release_date`. Retain one ID across scopes only if it represents the same projected meaning and the cross-scope behavior intentionally depends on that identity. Keep form IDs stable between Add and Edit for the same semantic field.
3. Keep typed ID declarations in one small kind-owned identifier module or in scope-owned modules re-exported by one explicit entry point. Do not create duplicate string constants in fields, sorts, groups, and form specs. The selected schema must reject duplicate IDs and defaults missing from its own lists.
4. Add scope-aware legacy aliases in each kind's preference codec. Decode old IDs to the canonical ID for the *selected scope*, then write only the new ID. An ambiguous old ID must be resolved by the saved browser mode/scope; if that is impossible, use the documented scope default and retain unrelated settings.
5. Cover `sort_column`, `sort_rules`, `visible_columns`, `column_widths`, `group_id`, column presets, and any saved facet/filter or grouped-shelf references. Both `LibraryWorkspacePreferences` and `library_workspace_persistence.dart` write workspace settings. Audit both readers and writers before removing aliases.
6. Replace generic string construction such as `${kindNamespace}.title` in `LibraryWorkspacePreferences` with a schema-provided primary/default visible column. A scoped ID migration must not depend on a hardcoded spelling in the host.
7. Keep the legacy decoder only for supported persisted user state. Do not retain old field definitions, extra UI paths, or two live names for the same canonical field. Remove aliases once the product's preference migration policy allows it.

## Implementation stages

### 0. Freeze the inventory — complete

The live per-kind ledger is recorded in [kind-schema-reorganization-inventory.md](kind-schema-reorganization-inventory.md). It lists scoped workspace fields, projected sources, existing IDs, column/sort/group participation, defaults, facet IDs, Add/Edit field IDs, and persistence readers/writers. Callback-specific behavior and any derived or personal projection must still be checked in the linked source before moving that definition.

### 1. Prepare shared structural contracts — complete

`LibraryEntityWorkspaceSchema` and `LibraryFieldRegistry` now carry a validated primary column. Existing aggregate schemas select a scope's primary from its visible defaults when the work-level primary is not part of that scope; explicit schemas can declare it directly. Workspace preference normalization and column presets use that ID instead of constructing `${kind}.title`. Preference codecs receive the selected entity scope when decoding and encoding IDs, while `forScope(...)` remains for the kinds not yet migrated. Generic interfaces remain structural.

### 2. Finish existing form pilots

Catalog Add and dedicated Edit forms now use typed scope values and shared field specs for all nine kinds. Continue by reconciling the older combined Work edit sessions with these definitions. Keep owned-copy fields and tracking commands separate when their data or persistence destination differs from catalog metadata.

### 3. Make Music the explicit-workspace pilot — complete

Release Group, Release, and Owned Copy now have separate field catalogs next to their scoped schemas. Columns, sorts, and groups are composed by those scoped schema files, and the aggregate `MusicWorkspaceFieldScope`/`musicFieldForScope` catalog is deleted. Title, artist, status, and cover retain shared IDs because they have the same role in each projected entity; Release Group and Release date/track count have distinct IDs because the values differ. The Music preference codec maps the old date/count IDs according to the saved browser scope. Release Group aggregate listening stays derived and read-only; Release listening and Copy personal data stay at their own scopes.

### 4. Migrate the remaining workspace schemas

Move Book, Game, and Board Game first, then Comic and Manga, then Movie, TV, and Anime. For each kind, extract its Work, Release, and Copy fields and schema composition from the monolithic `<kind>_fields.dart`; move only meaningful custom columns, sorts, and groups. Replace `forScope(...)` at the kind contribution after all three explicit schemas exist. Keep existing projectors until a scope-specific DTO provides a demonstrated type-safety gain.

### 5. Complete Add/Edit forms for the remaining kinds

The scoped catalog forms are implemented for all nine kinds. Finish the form stage by comparing each older combined Work editor and making its overlapping Add/Edit fields use the canonical typed specs. Preserve kind-specific tabs and nested editors. Music's Release Group, Release, and Copy forms remain separate; do not flatten tracklists or copy media into a generic field array.

### 6. Remove superseded paths

After each kind is migrated, delete controller-backed draft fields, duplicated validators, old schema composition, unnecessary exports, and unused forwarding files. Update generated registries, seed fixtures, documentation, and any code that imports moved identifiers. Do not leave two maintained field catalogs for the same scope.

## Per-kind completion gate

- Every field, column, sort, and group in a scope has an explicit kind owner and a valid typed ID; defaults refer to registered definitions.
- Add and Edit use one field definition for each genuinely shared editable value; differences in workflow remain explicit.
- Create and update preserve the correct identity, unrelated metadata, nested child records, and personal data. Partial update semantics distinguish untouched from cleared values where needed.
- Saved workspace settings and presets are either migrated to canonical IDs or deliberately reset with a documented reason. Invalid or unknown IDs fall back to valid schema defaults.
- The old schema/draft path has no callers and is removed. The kind contribution exposes only the new canonical schema for each scope.
- Affected Add/Edit, workspace, preference, and kind-boundary contracts are checked before calling that kind complete. No code migration is considered complete from file moves alone.

## Cross-kind completion gate

All nine kinds use explicit scoped workspace schemas and kind-owned Add/Edit form definitions. Shared hosts contain no kind-specific field lists, sort/group rules, or ID spelling conventions. The identifier ledger, preference migration policy, README, and architecture status match the final code.
