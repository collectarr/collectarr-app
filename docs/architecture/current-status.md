# Current Architecture Status

The active cross-repository target is the [Catalog Item v1 coordinated cutover](catalog-item-v1-cutover.md), with [one field ledger per kind](catalog-item-v1-field-ledgers/README.md). This file describes the current state against that target; it does not describe the old topology as the desired architecture.

## Target entity contract

```text
Catalog Item -> Owned Copy 0..N
```

Every kind's Catalog Item represents its concrete collectible edition/version/release. Series and similar data may group items, and repeated tracks, episodes, credits, variants, and components remain contained typed data. Catalog data is shared; owned-copy data is per copy.

## Current implementation gaps

- App still exposes `LibraryEntityScope.work`, `.release`, and `.copy` and has 3-level library entity refs. Its Drift schema remains v5 with the old kind tables and upgrade history.
- Most kinds still split workspace and edit schemas across work/release/copy. Music's Core model/API has an Album v1 slice, but App's local persistence and generic workspace have not been cut over.
- Core still stores most kinds using per-kind work/release/edition graphs. Provider integrations were removed from Core during the preceding architecture change; they remain owned by App.
- App Add/Admin still has callers for the removed Core provider-ingest, ingest-job, and proposal routes. Those flows must move provider mapping, provenance, and job state into App and write source-neutral `CatalogItemV1` records; until then, provider Add/Admin is incomplete end to end.
- The Music field ledger records the supplied saved CLZ page. Other kind ledgers are explicitly provisional and cannot certify full CLZ parity.
- The all-kind typed Catalog Item v1 contract is now exported by Core and pinned in `tool/core_contracts/`; App generates Dart transport classes and exposes the source-neutral read/write/search endpoints. The old Music and per-kind API paths remain active, and no Add/Edit or workspace flow has switched to the new endpoints yet.
- The new App client now requires `CatalogItemRef` for Catalog Item reads and updates, checks that returned identity matches the requested kind and ID, and checks the kind returned by creates. Music's contained-track hierarchy reads through this endpoint; its Add/Edit persistence and workspace projection still use the old graph.
- Provider search results and provider identities no longer carry generic `work/release/copy` scopes. Search results use provider record roles, and Music Add search emits concrete release results without a selectable release-group parent. This is limited to provider search; per-kind domain models, persistence, editing, and workspace still need the coordinated Catalog Item cutover.

## Required close-out

All nine kinds must use `CatalogItemRef(kind, id)` and `OwnedCopyRef(kind, itemId, copyId)`, one Catalog Add/Edit form, a separate Owned Copy form, typed contained child data, and field definitions shared by forms and workspace projections. Core and App must switch together to clean v1 schemas and pinned generated contracts. Old references, tables, APIs, compatibility paths, and migrations are removed as part of that one cutover; they are not retained as aliases.

See the cutover document for ordered gates, database reset implications, and deployment restrictions.
