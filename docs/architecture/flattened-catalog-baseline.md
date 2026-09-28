# Flattened Catalog Baseline (App)

This work starts from the visually established App baseline below. The UI in this revision is the preservation reference for the flattened catalog cutover.

| Repository | Branch | Baseline commit | Local database schema |
|---|---|---|---:|
| App | `codex/pre-cutover-rollback-20260929` | `6949fb4f00e6fdd5828e21474b74fa448e793fe9` | 5 |
| Core | `codex/pre-cutover-rollback-20260929` | `f57205692d34d521ab8a2091dd527dd6c5da1ca4` | See Core baseline document |
| Sync | `codex/pre-cutover-rollback-20260929` | `625d82cbb7c1c11fc2f112bde4f3510811096b59` | See Sync baseline document |

## Current identity and personal-state surfaces

- Generic library navigation uses `LibraryEntityScope`, `LibraryWorkRef`, `LibraryReleaseRef`, and `LibraryCopyRef`.
- `CatalogEntityRef` stores `kind`, `entity_type`, `id`, `root_id`, and `parent_id`; kind modules interpret the entity type and hierarchy.
- Kind-owned collection rows use `OwnedItemRef(kind, id)`. Their records also carry a catalog root reference and, where applicable, a more specific `targetRef`.
- Wishlist and metadata overrides target `CatalogEntityRef`. Loans, folders, reading queue entries, and personal images target `OwnedItemRef`.
- Music listening records require a concrete release reference, may target a medium or track, and may optionally point to an owned item. TV/Anime watch sessions target catalog entities and may carry episode coordinates.
- Smart-list criteria, custom-field values, external links, sync payloads, backup, and CSV contain additional reference encodings; each must be inventoried before its old form is removed.

## Migration invariants

- Preserve existing App UI composition, colors, spacing, controls, and navigation behavior while replacing the identity model.
- Keep genuine child records as children. Their IDs and ordering must survive the root migration.
- A personal record with an explicit concrete `targetRef` maps to that concrete root. A root-only parent with no concrete child may keep its ID as the new root.
- A personal record that points only to a parent with multiple concrete children is ambiguous. The migration must surface it for explicit resolution; it must not fan out, guess a “primary” child, or silently discard it.
- Preserve owned-item IDs and all user-entered values. Do not rewrite or reset a live database as part of implementation.
- The eventual App release has a fresh v1 schema and intentionally does not open the old schema or backup formats. Provide a separate, reviewed migration/export path before that release; do not run it against live user data.

Core's matching concrete identity path cases are in `collectarr-core/tests/fixtures/flattened_catalog/legacy_graph_migration_cases.json`. App-specific personal-reference resolution cases live beside this document. The live-feature inventory and intended destinations are in `flattened-catalog-reference-inventory.md`.
