# Typed kind architecture

The application has nine active kinds: Comic, Manga, Book, Game, BoardGame,
Movie, TV, Anime, and Music. Each kind is rooted at
`lib/features/library/kinds/<kind>/` and owns its domain, Core mapping,
provider semantic mapping, local mapping, workspace, editing, and tracking
behavior.

The registry composes kind modules at
`lib/features/library/kinds/registry/collectarr_kind_modules.dart`. It is a
composition boundary; after dispatch, callers use the concrete kind-owned
capability or model.

## Architecture rules

- A kind owns every representation of its domain data.
- After kind dispatch, never erase the type.
- Provider owns protocol.
- Kind owns semantic provider mapping.
- Kinds never import other kinds.
- Prefer production duplication over false-common abstractions.
- Share behavioral contract tests across every applicable kind.

The current boundary is guarded by the typed registration, declarative schema,
Core DTO ownership, and final deleted-code architecture tests.

Related evidence:

- [final parity report](../typed-kind-parity-final.md)
- [semantic-vacuum audit](../typed-kind-semantic-vacuum-audit.md)
- [deleted-code proof](../typed-kind-deleted-code-proof.md)
