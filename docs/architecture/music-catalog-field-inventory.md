# Music Catalog Field Inventory

> This document records the earlier Music catalog ownership audit. The
> authoritative CLZ-visible Music v1 field ledger is now
> [catalog-item-v1-field-ledgers/music.md](catalog-item-v1-field-ledgers/music.md);
> the all-kind target is described in
> [catalog-item-v1-cutover.md](catalog-item-v1-cutover.md).

This inventory is superseded by the coordinated Music Album v1 field ledger:
[music-album-v1-field-ledger.md](music-album-v1-field-ledger.md). The ledger
records each visible CLZ field, its type, its owner (`catalog` or
`owned_copy`), and the proposed v1 name. Its source is one saved album page, so
it covers every field visible in that page without claiming to enumerate
unseen optional or user-configured CLZ fields.

The pinned canonical Core contract is
[`tool/core_contracts/music-catalog-v1.json`](../../tool/core_contracts/music-catalog-v1.json).
It describes one edition-level `MusicAlbum` containing ordered tracks and
disc-title values. Track position plus `disc_number` identifies a track within
its album; neither discs nor tracks have independent catalog identities.

The App-owned copy schema is separate from Core. Each owned-copy row targets
one album and stores only that copy's collection status, index, location,
owner, condition, purchase and value data, rating, notes, tags, and personal
images. This prevents details for one copy from being applied to another.

The App Drift reset and full Music UI migration are still in progress. Do not
use this working branch to reset or deploy existing databases. The completed
cutover will start App and Core from empty v1 databases and rebuild the Core
search index.
