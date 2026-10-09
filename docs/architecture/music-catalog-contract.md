# Music Catalog Contract

Core exposes one `CatalogMusicItemResponse` for each concrete album edition
at `/api/v1/metadata/music/items/{id}`. Search returns pages of the same
edition-level item shape. There is no Release Group to Release hierarchy.

The canonical Music v2 item contains edition metadata, `artist_credits`,
album-level `credits`, `external_links`, artwork, and `discs`. Each disc owns
its format family and format, sound and physical properties, recording date,
recording locations, live/studio state, SPARS code, credits, and tracks. Each
track owns its composition and track-specific data. Album release dates,
label, country, barcode, catalog number, packaging, genres, box-set state, and
artwork remain edition-level fields.

Music credits have stable IDs, a name and optional sort name, a role and
optional role ID, `instruments[]`, a sequence, and an optional `contributor_id`
that is present only when a real catalog contributor reference exists.
`artist_credits` remain separate because their credited-name, join-phrase, and
sequence semantics differ. Composition is track metadata, not a credit.

Disc format family is intentionally coarse: `vinyl`, `opticalDisc`, `tape`,
`digital`, or `other`. The format string carries the detailed format such as
CD, SACD, SHM-CD, cassette, 12-inch vinyl, or FLAC. Known Music presets assign
their family; custom formats require the user to choose one. The canonical
contract never infers family from a format string.

Core response models in `app/schemas/catalog_music_item.py` define the strict
wire schema. Core exports `contracts/music-catalog-v2.json` and pins its hash
in the contract manifest. App pins that bundle under `tool/core_contracts/`
and generates the API client and Music field inventory from the v2 artifacts.
Run the App contract check after refreshing the bundle:

```powershell
dart run tool/check_music_catalog_contract.dart
```

Both Core and App reject unknown fields. The v2 contract does not accept the
former album-level recording fields or role-specific root arrays, and App has
no v1 decoding or migration path. Reordering discs, tracks, or credits keeps
their stable IDs and does not change their identities.

Canonical correction targets expose `artist_credits`, album `credits`, and
`discs` as correction-only object-list fields. They are omitted from the normal
metadata and Add schemas. Core validates each proposed Music change together
with the complete current item against the strict v2 document before storing or
applying it, so nested IDs and ordering remain part of the proposed values.

## Ownership

- Core owns canonical edition metadata, artist credits, album and disc credits,
  discs, tracks, identifiers, and catalog links.
- App stores one local Music entry with a `MusicAlbum` catalog document and
  separate personal data. Condition, storage, personal images, listening
  history, and other personal state remain entry-owned.
- Album release dates describe the edition. Recording date, recording
  locations, live/studio state, and SPARS describe a disc.
- App workspace facts are derived from canonical Music data, immutable for a
  projection, and never persisted.
- Music has no synopsis field. Synopsis remains available for kinds that define
  it.
- Each concrete edition has its own catalog identity, including editions with
  the same title.

The supported App database is a fresh version 1 baseline. Core also requires a
new, empty PostgreSQL database for its current schema baseline. No earlier
database or contract format is migrated or silently accepted.
