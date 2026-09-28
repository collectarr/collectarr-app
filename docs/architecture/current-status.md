# Current Architecture Status

The active cross-repository target is the [Catalog Item v1 coordinated cutover](catalog-item-v1-cutover.md), with [one field ledger per kind](catalog-item-v1-field-ledgers/README.md). This file describes the current state against that target; it does not describe the old topology as the desired architecture.

## Target entity contract

```text
Catalog Item -> Owned Copy 0..N
```

Every kind's Catalog Item represents its concrete collectible edition/version/release. Series and similar data may group items, and repeated tracks, episodes, credits, variants, and components remain contained typed data. Catalog data is shared; owned-copy data is per copy.

## Current implementation gaps

- App still exposes `LibraryEntityScope.work`, `.release`, and `.copy` and has 3-level library entity refs. Its Drift schema remains v6 with the old kind tables, provider tables, and upgrade history alongside the new Owned Copy cache.
- Legacy kind modules still split workspace and edit schemas across work/release/copy. The active library route for all nine kinds now uses the Catalog Item v1 workspace, but the broader local persistence, sync, and non-library workflows have not been cut over.
- Core still stores most kinds using per-kind work/release/edition graphs. Provider integrations were removed from Core during the preceding architecture change; they remain owned by App.
- The active Admin catalog views and corrections use Catalog Item v1. Legacy Add, proposal, provider-adapter, and kind-specific import code remains in the App source and still targets the superseded APIs or Work/Release graph; it is not part of the active Catalog Item Add flow.
- The Music field ledger records the supplied saved CLZ page. Other kind ledgers are explicitly provisional and cannot certify full CLZ parity.
- The all-kind typed Catalog Item v1 contract is exported by Core and pinned in `tool/core_contracts/`; App generates Dart transport classes. Active library pages, metadata search, barcode lookup, detail hydration, Admin catalog search/read, and Admin catalog corrections use the v1 item contract. The shared Add flow searches Core, supports barcode-to-identifier search, and writes Owned Copies locally. The old Add implementation and provider adapters remain, while legacy per-kind API methods and Work/Release persistence remain outside the active library route.
- The new App client now requires `CatalogItemRef` for Catalog Item reads and updates, checks that returned identity matches the requested kind and ID, and checks the kind returned by creates. The active Music Add/Edit form sends the album-contained tracklist through the Catalog Item contract. The old Music release-group/release models and local persistence still remain in legacy modules.
- Provider search results and provider identities no longer carry generic `work/release/copy` scopes. Search results use provider record roles, and Music Add search emits concrete release results without a selectable release-group parent. This remains legacy provider code; the active Add flow is source-neutral and searches Core directly.

## Required close-out

All nine kinds must use `CatalogItemRef(kind, id)` and `OwnedCopyRef(kind, itemId, copyId)`, one Catalog Add/Edit form, a separate Owned Copy form, typed contained child data, and field definitions shared by forms and workspace projections. Core and App must switch together to clean v1 schemas and pinned generated contracts. Old references, tables, APIs, compatibility paths, and migrations are removed as part of that one cutover; they are not retained as aliases.

See the cutover document for ordered gates, database reset implications, and deployment restrictions.
