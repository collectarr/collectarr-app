# Music Catalog Contract

Core exposes one `CatalogMusicItemResponse` for each concrete album edition at `/api/v1/metadata/music/items`. The response contains the edition fields and its discs and tracks. Search and detail reads do not expose a Release Group → Release hierarchy.

Core response models in `app/schemas/catalog_music_item.py` define the wire schema. `scripts/export_contract_bundle.py` exports them as `contracts/music-catalog-v1.json` and pins the artifact hash in the contract manifest. App copies the bundle with `tool/update_core_contracts.ps1`; the pinned file is `tool/core_contracts/music-catalog-v1.json`.

Music owns its transport types in `lib/features/library/kinds/music/data/remote/catalog_music_item_dto.dart`. Shared API code uses `RawTypedMetadataResponse` only where a generic consumer needs common fields and the untouched JSON. Run the contract check after refreshing the Core bundle:

```powershell
dart run tool/check_music_catalog_contract.dart
```

The check verifies the pinned hash and that each item, disc, and track contract field is represented and decoded by its kind-owned DTO. Updating Core does not silently update App's pinned input; copying the new bundle is an explicit App change.

## Ownership

- Core owns canonical album edition fields, disc and track content, credits, identifiers, and catalog links.
- App and Sync own owned-copy details, condition, storage, personal images, listening history, and other personal state.
- Music has no synopsis field. Synopsis remains available for kinds that define it.
- Each concrete edition has its own catalog identity, including editions with the same title.

The supported App database is a fresh version 1 baseline. There is no upgrade path from earlier SQLite layouts. Core also requires a new, empty PostgreSQL database for its current schema baseline. Keep existing databases and backups separately; these steps do not rewrite or reset them.
