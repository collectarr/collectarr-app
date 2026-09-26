# Catalog Item v1 Coordinated Cutover

## Target

Every library kind has one catalog root representing the specific collectible edition, version, issue variant, or release, and zero or more owned-copy records:

```text
Catalog Item
└── Owned Copy 0..N
```

Repeated contents (music discs/tracks/credits, TV seasons/episodes, comic creators/characters, and similar data) are contained children of the Catalog Item. A series may be a grouping/reference, but must not require a separate editable Work node. Owned-copy fields never live on a shared Catalog Item.

The v1 field inventory is maintained in [Catalog Item field ledgers](catalog-item-v1-field-ledgers/README.md). Music is grounded in its saved CLZ form. The other eight ledgers are provisional: public product pages establish examples, not a complete Edit field list. They explicitly identify proxy forms and Collectarr-only fields. Exact field parity remains unconfirmed until saved Edit-form captures are available.

## Cross-repository ownership

- Core owns the canonical, source-neutral `CatalogItemV1` contract and catalog read/write/search operations.
- App owns provider search, credentials, rate limits, provider IDs and mappings, import provenance, owned copies, personal fields, tracking, and local-only images/activity.
- App pins and generates transport types from Core's exported v1 contract. Kind-specific details are typed; no provider envelope is part of a canonical write.
- `CatalogItemRef(kind, id)` and `OwnedCopyRef(kind, itemId, copyId)` are the shared reference shapes. There is no generic Work/Release/Copy scope.

The API response wraps `id`, typed `details`, and timestamps. Music write tracks are album-contained inputs; Core supplies each response track's `album_id` from the containing Catalog Item ID. The App validates this relationship at its Music mapping boundary. The pinned App contract is `tool/core_contracts/catalog-item-v1.json`. Sync it from Core with `tool/update_core_contracts.ps1`, then regenerate or verify its Dart transport part with `dart run tool/generate_catalog_item_v1_dto.dart` and `dart run tool/generate_catalog_item_v1_dto.dart --check`. CI checks the generated part against the pinned contract hash.

## Cutover gates

1. **Field freeze:** finish each ledger against saved forms where available. Mark any non-CLZ fields explicitly. Decide whether to keep, rename, or remove every existing field before modeling it.
2. **Contract and ownership:** define the shared Catalog Item / Owned Copy contracts, typed per-kind details, and child collections. Generate App transport code and field definitions from the pinned Core contract.
3. **Core storage/API:** store one canonical Catalog Item per edition. Replace work/release endpoint graphs with Catalog Item operations and contained child data. Keep owned-copy and provider data out of Core.
4. **App persistence and references:** reset App's database to v1 with final catalog and owned-copy tables; replace entity scopes, refs, candidate/write paths, routes, and preference keys. No old scope is kept as a compatibility alias.
5. **All-kind UI and projections:** each kind has one Catalog Add/Edit form and a separate Owned Copy form. The same field definitions drive forms, workspace columns, sort/group, search and exports. Track/episode/credit editors remain typed kind-specific child editors.
6. **Coordinated reset:** Core's schema and every redesigned wire contract use v1; App's Drift schema uses v1. Existing old-format databases/backups do not open under this baseline. Deployment instructions must require fresh databases and a rebuilt search index. No live database is deleted by this repository change.
7. **Close-out:** remove obsolete model/route/DTO/migration/preference paths only after all nine kinds use the new structure. A mixed Work/Release and Catalog Item architecture is not a release state.

## Current state

This cutover is in progress. Core now exports a typed all-kind contract and has initial source-neutral catalog item storage and CRUD/search endpoints. App pins that contract, generates typed DTOs, and exposes a client for those endpoints. These endpoints are not populated by the existing Add/Edit or workspace flows yet. App still uses `LibraryEntityScope.work/release/copy`, a schema v5 Drift database, and split work/release workspace and edit contributions. Core still has per-kind work/edition/release canonical graphs for most kinds. Do not reset or deploy either database until the all-kind v1 implementation is complete.

Provider search transport no longer carries `entity_scope`; its role now describes a provider record (`catalog_item`, `series`, `season`, `episode`, `issue`, `variant`, `volume`, or `edition`). Music provider Add search maps each concrete edition to `MusicAlbum` and does not expose its release-group ID as a selectable parent. The current local catalog persistence adapter still translates flattened album details into the old Music aggregate, and the other kind domains, local tables, and workspace still require the coordinated cutover above.

## Implementation rules

- Do not infer CLZ parity from Collectarr's current field inventory.
- Do not silently drop existing user-entered or canonical fields. Each one needs a ledger decision before v1 is frozen.
- Do not ship a compatibility graph, alias, decoder fallback, or preference migration for the old topology; the planned baseline is a coordinated reset.
- Do not include App-owned `OwnedCopyV1` in Core's contract.
