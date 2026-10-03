# Catalog Item and Local Entry Baseline

## Ownership model

Core owns source-neutral canonical Catalog Items and reviews user proposals.
App owns one complete local record for each independently editable collectible
in a user's library. The local `LibraryEntryRecord` contains kind-specific
`catalog_data`, `personal_data`, optional `source_catalog_ref`, and timestamps.
`source_catalog_ref` records provenance only and does not make the local record
a child of a Core item.

Repeated information such as Music discs and tracks, credits, TV seasons, or
episodes remains contained kind data. It does not create an editable Work or
Release identity. Personal state and kind metadata are both editable on the
local record; they remain separate maps so the App can keep user data out of
Core's canonical catalog.

## Add, edit, duplication, and import

Manual Add and Edit use the same kind-owned catalog field definitions. A user
can submit catalog values to Core as a proposal. Proposals contain the same
catalog fields as Add/Edit and exclude personal values, provider payloads, and
provider identities.

Duplicating an entry assigns a new local ID and copies its full catalog and
personal maps. Entry images, custom fields, and user external links receive
independent identities. Historical activity, loans, folder membership, and
reading queue position remain attached to the source entry because they
describe its history or local organization. The duplicate keeps Core
provenance only when the source had provenance.

CSV v1 import/export uses complete entry envelopes. Imports validate the
envelope before writing, assign local IDs, and restore attachments with the
entry. Old CSV and backup shapes are unsupported.

## Sync boundary

Sync mirrors App-owned personal state. An entry snapshot includes its catalog
and personal maps, provenance, timestamps, images, custom fields, loans,
folder membership, reading queue position, and user external links. Other
entry-owned lifecycle data uses the local `library_entry_ref`. Folder
definitions, locations, wishlist items, and pick-list values use their
explicit user-owned protocol entities. Core canonical Catalog Items are not
stored in Sync.

Watch sessions and tracking records belong to a local entry; kind-specific
season/episode/chapter coordinates are part of their payload. Wishlist may
refer to a Core Catalog Item before a local entry has been created. A few
tracking storage projections still retain a derived Catalog Item ref beside
the local entry key; this is redundant internal state scheduled for removal,
not a second owner identity.

## Database baseline and fresh setup

App supports Drift schema version `1` without an upgrade chain. Native builds
create `collectarr-library.sqlite` in the application's documents directory;
web uses `collectarr-library-sqlite3`. Core schema v1 must be created from an
empty PostgreSQL database. Sync protocol/schema v1 must use an empty Sync
database path. Old App, Core, Sync, CSV, and backup data are not migrated by
this cutover.

For development, stop all three services, retain the old files outside their
active data directories, and configure fresh empty paths/profiles for the v1
instances. Do not delete or overwrite existing user data as part of
implementation. The App can use the normal platform documents directory when
it is already empty; otherwise select a fresh app data profile.

## Field decisions and limits

Keep the nine kind field ledgers as the field ownership source. Music is based
on the saved CLZ Music Edit form. Exact CLZ parity for Comics, Books, Movies,
and Games is unverified until their Edit-form captures are provided. Manga,
Anime, TV, and Board Games do not have a dedicated CLZ product form in the
available references; their ledger fields remain explicitly provisional.
