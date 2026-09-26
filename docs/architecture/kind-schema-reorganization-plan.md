# Kind Form and Workspace Schema Reorganization Plan

> **Superseded:** this plan records the former Work/Release/Copy implementation
> and is not the current target. The all-kind Catalog Item v1 cutover in
> [catalog-item-v1-cutover.md](catalog-item-v1-cutover.md) replaces its scopes,
> preference migration, and completion claims. Do not use this document as
> evidence that the Catalog Item v1 cutover is complete.

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

- Add and dedicated Edit share typed, scope-specific form field definitions for all nine kinds. The older combined Core-candidate editor remains a separate correction flow: it edits `CatalogSearchCandidate` transport values and preserves custom links, images, relations, and copy/tracking panels; the typed forms edit persisted kind entities. A field label shared across those flows does not make their values or write targets identical.
- Music now has separate Release Group, Release, and Owned Copy field catalogs and schemas, with scope-aware preference migration for the split release date and track count IDs.
- All nine kinds now expose explicit Work, Release, and Copy workspace schemas. The eight non-Music aggregate `*_fields.dart` files and the generic `forScope(...)` materializer have been removed.

## Target layout

Use kind-specific names for domain scopes. Create a file only when it owns a useful, independently readable unit; small sort or group lists can stay beside their scope schema.

```text
lib/features/library/kinds/<kind>/
  forms/
    <kind>_catalog_form_values.dart
    <kind>_catalog_field_specs.dart
    <kind>_catalog_form_adapters.dart
  workspace/
    <kind>_work_workspace_schema.dart
    <kind>_release_workspace_schema.dart
    <kind>_copy_workspace_schema.dart
    <kind>_workspace_facets.dart   # when the kind owns workspace facets
    <kind>_workspace.dart          # explicit kind-owned exports
    <kind>_ids.dart
    <kind>_preference_codec.dart
    <kind>_workspace_contribution.dart
```

Each scope schema owns that scope's field definitions, columns, sorts, groups, defaults, primary column, and preference codec. `forms/` owns UI input values and field specs. Add and dedicated Edit assemble sections/tabs from those specs and use kind-owned adapters for `fromEntity`, `create`, and `update`. Create uses new identity/defaults; update retains original identity and unrelated data. Use three-state patches only for partial updates where `unchanged`, `clear`, and `set` differ.

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

`LibraryEntityWorkspaceSchema` and `LibraryFieldRegistry` carry a validated primary column. Workspace preference normalization and column presets use that ID instead of constructing `${kind}.title`. Preference codecs receive the selected entity scope when decoding and encoding IDs. All kind contributions now register a fully composed scope schema directly; there is no aggregate-schema filtering API. Generic interfaces remain structural.

### 2. Reconcile existing form pilots — complete

Catalog Add and dedicated Edit forms use typed scope values and the same kind-owned field specs for all nine kinds. The older combined Core-candidate edit flow was reviewed kind by kind. It edits the transport candidate used for Core correction proposals and also owns legacy relations, links, images, and the combined copy/tracking shell; dedicated typed Edit forms update the persisted Work or Release domain entity. These are different models and write operations, so sharing a `LibraryFieldSpec<TDraft>` across them would require a new adapter model and would blur their persistence boundaries. Keep the Core-candidate flow kind-owned through its edit-session contract; do not add an alias or a second field catalog to the typed Add/Edit forms. Copy and tracking remain separate from catalog metadata.

### 3. Make Music the explicit-workspace pilot — complete

Release Group, Release, and Owned Copy now have separate field catalogs next to their scoped schemas. Columns, sorts, and groups are composed by those scoped schema files, and the aggregate `MusicWorkspaceFieldScope`/`musicFieldForScope` catalog is deleted. Title, artist, status, and cover retain shared IDs because they have the same role in each projected entity; Release Group and Release date/track count have distinct IDs because the values differ. The Music preference codec maps the old date/count IDs according to the saved browser scope. Release Group aggregate listening stays derived and read-only; Release listening and Copy personal data stay at their own scopes.

### 4. Migrate the remaining workspace schemas — complete

Book, Game, Board Game, Comic, Manga, Movie, TV, and Anime each now define Work, Release, and Copy fields, columns, sorts, groups, primary/default columns, and preference codecs in an explicit scope schema. Facet definitions have separate files where needed. Contributions register each scope schema directly, and the generic `forScope(...)` materializer has been deleted. The pre-migration inventory counts were checked against the new files: field, group, sort, column, and default-visible counts are preserved for all eight kinds. Existing projectors remain because a scope-specific DTO has not shown a practical type-safety gain.

### 5. Complete Add/Edit forms for the remaining kinds — complete

All nine kinds have typed catalog form values, kind-owned field specs, and adapters used by Add and dedicated Edit at matching Work/Release scopes. A source audit confirms each kind's Add schema and dedicated Edit schemas import the same `*_catalog_field_specs.dart`. The older combined Core-candidate editor stays isolated because it edits a different transport model and supports Core correction proposals; kind-specific relations and nested editors remain with their kind. Music's Release Group, Release, and Copy forms remain separate; tracklists and copy media are not flattened into a generic field array.

### 6. Remove superseded paths — complete

The eight non-Music aggregate workspace files and the `forScope(...)` composition path are deleted. Kind domain/dependency exports now point to the explicit `<kind>_workspace.dart` entry point, which exports scoped schemas, typed IDs, the preference codec, and facet catalogs. All contribution imports and affected contract-test field references use the scoped definitions. No legacy workspace alias or second live catalog remains. The independent Core-candidate edit-session contracts remain active and are not superseded workspace schemas.

## Per-kind completion gate

- Every field, column, sort, and group in a scope has an explicit kind owner and a valid typed ID; defaults refer to registered definitions.
- Add and Edit use one field definition for each genuinely shared editable value; differences in workflow remain explicit.
- Create and update preserve the correct identity, unrelated metadata, nested child records, and personal data. Partial update semantics distinguish untouched from cleared values where needed.
- Saved workspace settings and presets are either migrated to canonical IDs or deliberately reset with a documented reason. Invalid or unknown IDs fall back to valid schema defaults.
- The old aggregate workspace schema has no callers and is removed. The kind contribution exposes only the new canonical schema for each scope. The separate Core-candidate correction editor remains only through kind-owned edit sessions because its target and submission behavior differ from local typed forms.
- Affected Add/Edit, workspace, preference, and kind-boundary contracts are checked before calling that kind complete. No code migration is considered complete from file moves alone.

## Cross-kind completion gate

All nine kinds use explicit scoped workspace schemas and kind-owned Add/Edit form definitions. Shared hosts contain no kind-specific field lists, sort/group rules, or ID spelling conventions. The identifier ledger, preference migration policy, README, and architecture status match the final code.
