# Music Catalog Contract

Core exposes one `CatalogMusicItemResponse` for each concrete album edition at `/api/v1/metadata/music/items`. The response contains the edition fields and its discs and tracks. Search and detail reads do not expose a Release Group → Release hierarchy.

Core response models in `app/schemas/catalog_music_item.py` define the wire schema. `scripts/export_contract_bundle.py` exports them as `contracts/music-catalog-v1.json` and pins the artifact hash in the contract manifest. App copies the bundle with `tool/update_core_contracts.ps1`; the pinned file is `tool/core_contracts/music-catalog-v1.json`.

Music owns its transport types in `lib/features/library/kinds/music/data/remote/catalog_music_item_dto.dart`. Shared API transport retains routing identity and the untouched response JSON; it does not extract title, dates, synopsis, cover, or other catalog values into a shared object. Mixed-kind UI receives only a transient `CatalogDisplaySummary` projected by the owning kind codec. Run the contract check after refreshing the Core bundle:

```powershell
dart run tool/check_music_catalog_contract.dart
```

The pinned metadata-field schema assigns Music corrections to `catalog_item`. Music Admin reads artist, label, format, dates, identifiers, and images directly from the flat item response; the kind-owned contributor edits its contained disc tracks without following a Release Group or Release reference.

The check verifies the pinned hash and that each item, disc, and track contract field is represented and decoded by its kind-owned DTO. Updating Core does not silently update App's pinned input; copying the new bundle is an explicit App change.

## Ownership

- Core owns canonical album edition fields, disc and track content, credits, identifiers, and catalog links.
- App and Sync own collection-item details, condition, storage, personal images, listening history, and other personal state.
- Music has no synopsis field. Synopsis remains available for kinds that define it.
- Each concrete edition has its own catalog identity, including editions with the same title.

The supported App database is a fresh version 1 baseline. There is no upgrade path from earlier SQLite layouts. Core also requires a new, empty PostgreSQL database for its current schema baseline. Keep existing databases and backups separately; these steps do not rewrite or reset them.
