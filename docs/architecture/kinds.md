# Typed kind architecture

The source tree has eight kinds: Comic, Book, Game, Game Hardware,
Game Toy, BoardGame, Movie, and Music. Music, Comics and the Games family
(Game, Game Hardware, Game Toy) are in the release scope
(`library_release_scope.dart`; the published schema baseline is 5). Hardware and Toys are
independent kinds that share the Games collection family and tab bar but never
import the Game kind. The others stay isolated source modules without database
tables until each is released with its own migration. Each
kind is rooted at `lib/features/library/kinds/<kind>/` and owns its catalog
fields, Core mapping, local mapping, workspace, editing, and kind-specific
tracking behavior.

The manually maintained application registry at
`lib/features/library/kinds/registry/collectarr_kind_registry.dart` composes
kind modules and other explicit registrations. It is a composition boundary;
after dispatch, callers use the concrete kind-owned capability or model.

Mechanical Drift table and development seed composition is generated
separately. See [kind registration and generated artifacts](kind-registration-codegen.md).

TV, Anime and Manga have no standalone modules, kinds, registries or
persistence models. Future television and anime workflows belong to Movie and
manga workflows to Comic; that integration is not implemented by removing the
old modules.

## Architecture rules

- Name internal UI files for their responsibility, without repeating the kind
  or directory: `game_hardware/workspace/entry_schema.dart`,
  `workspace/catalog_fields.dart`, `workspace/columns/columns.dart`, and
  `game/edit/draft.dart`. Keep qualifiers that distinguish responsibilities,
  such as `catalog_columns.dart`, `personal_fields.dart`, or `album_draft.dart`.
  Shared files under `lib/features/library` follow the same rule:
  `forms/schema.dart`, `entries/store.dart`, `edit/shell/dialog.dart`. Kind
  module entry points, domain models, persistence and registration boundaries
  retain explicit names; the tools find each kind by its `<kind>_module.dart`.
  Dart symbols and persisted identifiers stay explicit and are independent of
  file naming. Configuration uses `config/configuration.dart`,
  `config/capabilities.dart` and `config/field_identities.dart` where present.
  Entry boundaries use `entries/details_codec.dart`, `entries/create_payload.dart`
  and `entries/update_payload.dart`; concrete domain/detail models keep their
  distinguishing names. Catalog adapters use `integrations/catalog/lookup.dart`;
  exported Dart classes retain their explicit kind names.
- A kind owns every representation of its domain data.
- After kind dispatch, never erase the type.
- Core owns source-neutral canonical catalog data and its API contract.
- App owns personal collection data and user-submitted catalog proposals.
- Kind modules own the meaning and mapping of their catalog fields.
- Kinds never import other kinds.
- Prefer production duplication over false-common abstractions.
- Share behavioral contract tests across every applicable kind.

The current boundary is guarded by typed registration, declarative schemas,
Core contract checks, and architecture tests.

Run `dart run tool/check_kind_duplication.dart` for an informational list of
repeated implementation bodies across kinds. It counts original source lines
and compares tokens, normalizing kind words in identifiers while preserving
their remaining names and string literals. Classes, methods, and functions
are reported separately, so groups can overlap. Review each group against
kind ownership before extracting shared code.

Related evidence:

- [current architecture status](current-status.md)
- [flattened Catalog Item baseline](flattened-catalog-baseline.md)
- [Music field inventory](music-catalog-field-inventory.md)

### Card composition

`LibraryCardPresentation` requires horizontal and vertical body builders. Each kind chooses its own renderer or explicitly selects a reusable layout from `card_templates.dart`. `LibraryWorkspaceCard` only hosts the chosen body and the shared pointer, hover, selection and edit controls; it has no fallback card layout. Comics owns its distinct card bodies in its workspace folder.

The host supplies cover loading and decorative wrapping through `buildCover`, plus the resolved pill and cover status widgets. Kind renderers position these slots without interpreting collection status or duplicating status logic. Flow, grid and shelf composition still need the same explicit renderer boundary; their existing presentation projections are not a complete implementation of that separation.

### Kind settings

Each kind exports `settings/contribution.dart` into the existing workspace composition registry. A contribution selects its settings section builders and declares typed values with stable IDs, declared defaults, validation, scope, ordering and optional specialized value editors. Shared pages render these declarations; shared controls and persistence are implemented in `features/settings`. Adding a declaration or a custom section does not require changing shared settings pages.

`kind_settings.dart` distinguishes `globalOnly`, `kindOverridable` and `kindOnly`. A missing override inherits the shared default for overridable settings, otherwise the declaration default; an explicitly present null or false is preserved. Scope does not follow navigation families: Games, Hardware and Toys have separate identities and overrides. Apply to all uses compatible declarations from enabled modules. Disabling a module hides its UI and excludes it from Apply without deleting stored choices.

Version 1 of `collectarr.kind_settings` migrates the former `collectarr.ui.show_inspector_trailers` value to the shared `inspector.trailers` default without generating overrides. The versioned document is saved before removing the old key. Existing documents are authoritative on restart; unknown versions fail without rewriting data. Writes are serialized, and effective state changes only after persistence succeeds. Trailer consumers receive the displayed item kind and never use the selected navigation kind.

Existing per-kind layout, custom field display and default Add method keys remain authoritative. The standard settings section is explicitly selected by kinds and delegates to those existing editors. eBay region/display preferences, confirmations and title sorting remain application-wide choices in `UiPreferences`; no unused per-kind settings or duplicate storage are introduced. Theme, localization, connection and sync retain their global infrastructure owners.

### Bulk command validation

`LibrarySelectionContext` represents a complete target snapshot. Eligibility requires every selected target to qualify; empty or incomplete snapshots are ineligible. Entry-only edit and duplicate commands validate the entire set before execution. Edit commands and Add-from-wishlist commands are prepared for all selected targets before mutations begin. Add uses the existing per-entry transaction to create the copy and update wishlist state, rather than removing wishlist items in a preliminary pass. Unsupported targets are rejected explicitly. Existing per-item execution and failure semantics remain in place; these commands do not promise a cross-kind transaction.

### Kind-contributed selection actions

Each kind declares its bulk actions in `selection/contribution.dart`, registered through the existing `LibraryKindToolbarModule.selectionActions`. Contributions implement the existing typed `UiAction` contract with stable IDs, labels, icons, placement, ordering, category, supported target scopes and homogeneous-selection requirements. Shared action descriptors bind the existing bulk services; kind-only commands and labels remain in kind folders. Music declares Merge Albums and Comics declares Update Key Info. Single-item `LibraryTargetActionCapability` is a separate contract.

The page coordinator resolves one list of actions. Mixed-kind selections use the intersection of supported IDs, and every selected target must meet each declaration?s scope and enabled conditions. A resolved action obtains a fresh selection and command context before invoking its handler. Async command errors propagate to the shared renderer?s error display. Primary controls and More render the same resolved list on desktop and native mobile; Flow supplies no bulk action list or selection callbacks.

`selection/commands.dart` contains the shared service command bindings, independently of UI. `selection/controls.dart` only renders resolved actions. It contains no fixed action enum, kind-name comparisons or domain labels. The former unused compact selection bar is removed; native selection uses the common toolbar band.
