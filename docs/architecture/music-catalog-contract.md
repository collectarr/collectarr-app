# Music Catalog Contract

Collectarr Core owns the canonical Music catalog graph. Collectarr App pins the exported contract and generates its Music API DTOs from that pinned file. App-only copy details and device-local state stay outside the Core contract.

## Sources and generated files

Core response models in `app/schemas/metadata_music.py` define the release-group, release, medium, track, and relation shapes. `scripts/export_contract_bundle.py` exports those Pydantic models as `contracts/music-catalog-v1.json` and includes the file hash in the Core contract manifest.

App copies the bundle with `tool/update_core_contracts.ps1`. The pinned input is `tool/core_contracts/music-catalog-v1.json`; its SHA-256 must match `musicCatalogHash` in `tool/core_contracts/contract-manifest.json`.

Regenerate the typed DTO part after updating the pinned bundle:

```powershell
dart run tool/generate_music_catalog_dto.dart
```

The generated output is `lib/core/api/generated/music_catalog.models.g.dart`. Check that it matches the pinned contract with:

```powershell
dart run tool/generate_music_catalog_dto.dart --check
```

The generator preserves the contract's required fields, nullable values, nested relation types, enum values, and partial-date precision. `MusicCoreMapper` performs the explicit mapping from those DTOs to the kind-owned domain model and Drift tables.

## Field ownership

`tool/music_catalog_field_ownership.json` maps each field in the pinned Music schema to its App domain representation and persistence location. It also records the shared partial-date value fields and enum values. The checker rejects missing or stale field entries, verifies the pinned hash, and checks that mapped domain members and Drift columns still exist:

```powershell
dart run tool/check_music_catalog_field_ownership.dart
```

CI runs both the DTO generator check and the field ownership check against the pinned App contract. Updating Core does not silently update the App input; copying a new Core bundle and regenerating its DTOs is an explicit App change.

## App-only fields and local migration

- `recording_id` is a canonical Music track field. App stores it on `MusicTrack` and `music_track_rows`.
- Release-level physical format is derived from the ordered `medium_type` values. App stores the summary values in `medium_types_json` when the full medium rows are not loaded; it does not store duplicate physical-format columns.
- `box_set_name` is user-managed release detail stored in `music_release_local_details_rows`. Box-set membership remains in its separate local relation table.
- `media_condition` describes an owned physical copy. It is stored in `MusicOwnedMediumDetails` within `music_owned_items_rows.medium_details_json`, not on the canonical medium.
- Release links, tracking, listening history, owned-copy fields, and device artwork paths remain in App-owned tables or caches.

App's SQLite schema version 5 migration moves old box-set names to the local details table, archives previous medium-condition values for recovery, transfers them to matching owned copies by release and medium number, and preserves the existing format by deriving summary values from medium rows or the former release format values. It then rebuilds the affected release and medium tables without the duplicate or copy-specific columns.

Core's `migrations/20260925_music_field_ownership.sql` archives existing Music synopsis and medium-condition values before removing those columns, then adds `music_tracks.recording_id`. Run this deployment migration through the Core database migration process; `bootstrap_schema` only creates missing schema objects and does not remove old columns.
