# Catalog Item v1 Cutover

The library has two record types: a Core Catalog Item for canonical metadata
and an App collection item for one physical copy. Every collection item has its
own ID, refers to a Catalog Item, and holds its personal fields directly. It is
not a copy child nested under the catalog item. Duplicating an entry creates
another collection item with independent personal fields and a new ID, usually
pointing to the same Catalog Item. There is no quantity aggregation. Catalog metadata stays
in the kind-owned Core contract, while personal fields stay in App. Kind-owned
children such as Music tracks or TV episodes remain nested under the Catalog
Item. App proposals use the same catalog fields as manual Add/Edit and do not
contain provider identities or personal data.

The App cutover is in progress. The Add manual dialog now reuses the Edit dialog
shell, and Core exposes typed Catalog Item routes for all nine kinds. App's
local library, workspace, and personal-state references have not all moved to
the target model yet; this document does not describe those unfinished paths as
complete.

## Database baseline

The supported App Drift database is a fresh schema version 1. The code has no
upgrade path from earlier local schemas, and old backup formats are not
supported. Preserve any existing database and backups separately. For local
development, configure the application to use a new empty database path; do not
delete or reset a user database as part of this implementation.

The version 1 schema is created from the tables registered in
`lib/core/db/local_database.dart`. Rebuild generated Drift code after changing
the table set:

```powershell
dart run tool/generate_kind_registries.dart
dart run build_runner build --delete-conflicting-outputs
```

## Field contracts

Keep the nine kind field ledgers as the source for field ownership and names.
Music is grounded in the saved CLZ Music Edit form. Exact CLZ parity for the
other eight kinds is unverified until their Edit-form captures are available.
The shared Core field contract is pinned in `tool/core_contracts/` and checked
against the generated App definitions.

## Visual reference

The pre-cutover App revision `6949fb4f00e6fdd5828e21474b74fa448e793fe9` is the
visual reference for preserving existing colors, spacing, controls, navigation,
and workspace behavior while the data model changes.
