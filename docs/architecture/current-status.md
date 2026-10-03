# Current Architecture Status

Last reviewed: 2026-10-03. This report reflects the source tree and does not
claim completion of every cleanup item or literal CLZ parity.

## Implemented

- Core serves source-neutral Catalog Items and accepts user proposals. Provider
  search and provider ingest are not part of the App/Core product flow.
- App stores one complete, independently editable `LibraryEntryRecord` per
  local collectible. Kind metadata and personal values are separate maps on
  that same record. `source_catalog_ref` records provenance only.
- App Drift starts from schema version 1 and has no upgrade chain. The default
  native database is `collectarr-library.sqlite`; implementation work does not
  reset or overwrite an existing database.
- All nine kind workspaces use Catalog Item data and local library entries.
  Add/Edit uses kind-owned fields with the shared dialog shell. Music contains
  its discs, tracks, credits, and artwork within the album catalog data.
- Local edits, Add, duplicate, import, delete, and attachment changes use the
  mutation transaction before the final entry snapshot is queued for Sync.
- CSV v1 exports and imports complete local entry envelopes. Imports create
  independent local IDs and restore attachments with the record.
- Sync v1 carries complete `library_entry` snapshots plus personal activity
  entities. Entry images, custom-field values, loans, folder membership, read
  queue position, and user external links are carried in the snapshot's
  reserved personal attachment fields. Folder definitions are separate
  user-owned entities. Sync does not store canonical Core Catalog Items.
- Watch sessions have an explicit local-entry owner and kind-owned episode
  coordinates. Tracking entry and unit Sync payloads also identify their local
  entry. Wishlist items may refer to a Core Catalog Item before a local entry
  exists.
- Music personal editing includes managed tags, owner, purchase store, and
  signed-by values; a 0–10 rating control; currency selection; and named
  locations. Music's field inventory is grounded in the saved CLZ Edit form.

## Remaining work

- The workspace still distinguishes Core Catalog Item rows from local
  library-entry rows with `LibraryEntityScope`. This is a presentation/query
  boundary; it is not a Work → Release → Copy hierarchy. Some kind-owned
  tracking storage also retains a derived `catalog_ref` alongside its local
  entry key. Simplify these duplicate projections without changing the local
  entry identity.
- Global tracking summaries and several kind tracking aggregates still expose
  catalog references even though the Sync contract requires a local entry
  owner. Make the local-entry ownership rule explicit throughout the model,
  storage, and UI before removing those derived values.
- Catalog search and local records can both be shown in the workspace. The
  local record remains available offline when a Core catalog snapshot is
  unavailable; a canonical snapshot is a cache/provenance source, not its
  parent record.
- Shared mutation transactions cover generic edit and entry updates. A few
  kind-specific controls and standalone activity editors still persist through
  their own repositories; audit their save/cancel behavior before calling the
  whole form transactional.
- The Music form has captured CLZ reference data, but a current visual parity
  capture has not been produced. Exact CLZ field parity for Comics, Books,
  Movies, and Games requires their Edit-form captures. Manga, Anime, TV, and
  Board Games need an explicitly chosen reference; their ledgers remain
  provisional.
- Old-named workspace/schema files and some kind-owned presentation adapters
  remain. The active entity scopes are only `catalog_item` and `library_entry`;
  no Work/Release scope or identity is part of the supported local record
  model. Remove remaining files only after auditing imports and route callers.

## Verification

Tests and build checks are intentionally deferred until the implementation and
documentation changes in the current work are complete. At that point, run
code generation first, then repository checks and the Windows build.

See [`local-persistence.md`](local-persistence.md),
[`flattened-catalog-baseline.md`](flattened-catalog-baseline.md), and the nine
kind field ledgers for detailed contracts and limits.
