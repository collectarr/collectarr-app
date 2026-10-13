# Local Persistence Architecture

## Database file and baseline

`lib/core/db/local_database.dart` is the Drift composition root. The supported
schema version is `1` and has no upgrade chain. Native platforms create
`collectarr-library.sqlite` in the application's documents directory. Web
uses the `collectarr-library-sqlite3` database name. Older database and backup
formats are unsupported; implementation work must not reset or overwrite an
existing database.

For a fresh development profile, stop the App and point it at an empty
application data directory. Keep the old database and its backup files
untouched. When registered tables change, regenerate the kind registry and
Drift output:

```powershell
dart run tool/generate_kind_registries.dart
dart run build_runner build --delete-conflicting-outputs
```

## Local record

`LibraryEntryRecord` is keyed by `(kind, id)` and contains the complete local
record: `catalog_data`, `personal_data`, optional `source_catalog_ref`, and
timestamps. Its local ID is the identity for edits, duplication, deletion,
personal attachments, and entry-owned activity. `source_catalog_ref` records
metadata provenance only; it is never a parent key. Manually created entries
can omit it.

The `CatalogItemsCache` table stores remote Core snapshots and private local
catalog data for offline search and Add. Its `origin` marks the source. Personal
values are stored only on the local entry and are never written to Core's
canonical catalog.

## Personal records and attachments

Record-owned data uses the local `LibraryEntryRef`:

- item images and custom-field values;
- loans, folder membership, and reading queue position;
- user-created external links;
- watch sessions and kind-owned tracking associated with that entry.

These attachments are included in the full `library_entry` Sync snapshot.
Wishlist items may target a Core Catalog Item before a local entry exists.
Locations, folder definitions, and pick-list values are user-owned Sync
entities. Kind-specific progress and repeated contents stay in their owning
kind model.

Tracking summaries use `LibraryEntryRef` as their only local owner. A Catalog
Item reference appears only when an operation explicitly targets canonical
catalog data, such as a wishlist item or optional source provenance.

## Kind-owned data

Kind-owned models, forms, field schemas, and projections define the semantic
meaning of each kind's catalog and personal values. The generic entry table is
the persistence source of truth. Repeated content such as Music discs/tracks or
TV/Anime episodes is contained kind data, not another editable Work/Release
level.

The nine field ledgers are the source of field ownership and naming. The Music
ledger uses the saved CLZ Music Edit form. Exact CLZ parity for the other eight
kinds is unverified until the relevant Edit-form captures and reference
decisions are available.
