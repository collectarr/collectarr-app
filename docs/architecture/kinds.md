# Typed kind architecture

The source tree has eight kinds: Comic, Book, Game, Game Hardware,
Game Toy, BoardGame, Movie, and Music. Music and the Games family
(Game, Game Hardware, Game Toy) are in the release scope
(`library_release_scope.dart`; Game through schema 3). Hardware and Toys are
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

Related evidence:

- [current architecture status](current-status.md)
- [flattened Catalog Item baseline](flattened-catalog-baseline.md)
- [Music field inventory](music-catalog-field-inventory.md)
