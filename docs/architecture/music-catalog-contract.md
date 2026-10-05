# Music Catalog Contract

Core exposes one `CatalogMusicItemResponse` for each concrete album edition at `/api/v1/metadata/music/items/{id}`. The search endpoint `/api/v1/metadata/music/items` returns a page (`items`, `next_offset`, `has_more`) whose items include album fields, discs, and tracks. Search and detail reads do not expose a Release Group → Release hierarchy.

Core response models in `app/schemas/catalog_music_item.py` define the wire schema. `scripts/export_contract_bundle.py` exports them as `contracts/music-catalog-v1.json` and pins the artifact hash in the contract manifest. App copies the bundle with `tool/update_core_contracts.ps1`; the pinned file is `tool/core_contracts/music-catalog-v1.json`.

Music owns the typed `MusicAlbum`, `MusicMedium`, and `MusicTrack` models under `lib/features/library/kinds/music/domain/`. The same metadata model is used at the Core boundary where the shapes agree; `MusicCatalogMapper` translates the remaining Core names and the contained `discs` list. Shared API transport retains only routing identity and the kind document. Mixed-kind UI receives a transient `CatalogDisplaySummary` projected by the owning kind codec. Run the contract check after refreshing the Core bundle:

```powershell
dart run tool/check_music_catalog_contract.dart
```

The pinned metadata-field schema assigns Music corrections to `catalog_item`. Music Admin reads artist, label, format, dates, identifiers, and images directly from the flat item response; the kind-owned contributor edits its contained disc tracks without following a Release Group or Release reference.

The check verifies the pinned hash and exact root, disc, and track field sets accepted by the Music mapper against Core's exported schemas. Updating Core does not silently update App's pinned input; copying the new bundle is an explicit App change. This check does not replace Dart static analysis of the typed model and mapper.

## Ownership

- Core owns canonical album edition fields, disc and track content, credits, identifiers, and catalog links.
- App stores one local Music entry with `MusicAlbum` metadata and `MusicPersonalData`; the values stay distinct inside that record. App owns condition, storage, personal images, listening history, and other personal state. Sync mirrors the complete local entry, and Core receives catalog metadata only.
- Music has no synopsis field. Synopsis remains available for kinds that define it.
- Each concrete edition has its own catalog identity, including editions with the same title.

The supported App database is a fresh version 1 baseline. There is no upgrade path from earlier SQLite layouts. Core also requires a new, empty PostgreSQL database for its current schema baseline. Keep existing databases and backups separately; these steps do not rewrite or reset them.
