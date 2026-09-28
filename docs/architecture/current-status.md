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
- Core's active ORM registry, metadata API, image ownership, and search projection now use Catalog Item v1 for all nine kinds. The old Core Work/Release/Edition/Variant graph and provider ingestion stack have been removed. Existing Core databases still require the documented reset before deployment.
- The active Admin catalog views and corrections use Catalog Item v1. CSV Shelf/Settings entry points use the v1 importer and exporter. The former shared Add dialog entrypoint and launcher have been removed; the old kind-specific Add/provider implementation files and old Work/Release persistence still remain in App and are not part of the active v1 Add flow.
- The Music field ledger records the supplied saved CLZ page. Other kind ledgers are explicitly provisional and cannot certify full CLZ parity.
- The all-kind typed Catalog Item v1 contract is exported by Core and pinned in `tool/core_contracts/`; App generates Dart transport classes. Active library pages, metadata search, barcode lookup, detail hydration, Admin catalog search/read, and Admin catalog corrections use the v1 item contract. The shared Add flow searches Core, supports barcode-to-identifier search, and writes Owned Copies locally. Old kind-specific Add implementation files and provider adapters remain in App, while legacy per-kind API methods and Work/Release persistence remain outside the active library route.
- The new App client now requires `CatalogItemRef` for Catalog Item reads and updates, checks that returned identity matches the requested kind and ID, and checks the kind returned by creates. The active Music Add/Edit form sends the album-contained tracklist through the Catalog Item contract. The old Music release-group/release models and local persistence still remain in legacy modules.
- Provider search results and provider identities no longer carry generic `work/release/copy` scopes. Search results use provider record roles, and Music Add search emits concrete release results without a selectable release-group parent. This remains legacy provider code; the active Add flow is source-neutral and searches Core directly.
- The v1 Shelf reads Catalog Item and Owned Copy v1 repositories only, with a separate v1 wishlist and wishlist, overdue-loan, and notes filters. Owned Copy changes and wishlist changes are queued for personal sync with tombstones. The shared Owned Copy form uses location and existing-owner selectors, typed custom fields, and personal-image picker/crop/rotate controls rather than raw JSON fields.
- Catalog Item covers can be uploaded, cropped, rotated, and edited as Core Image Assets attached to `catalog_item` references. The v1 workspace persists configurable per-kind catalog columns selected from the pinned contract. The Drift schema is still v6 and legacy Work/Release tables and services remain, so this does not complete the coordinated schema reset or legacy removal.

## Required close-out

All nine kinds must use `CatalogItemRef(kind, id)` and `OwnedCopyRef(kind, itemId, copyId)`, one Catalog Add/Edit form, a separate Owned Copy form, typed contained child data, and field definitions shared by forms and workspace projections. Core and App must switch together to clean v1 schemas and pinned generated contracts. Old references, tables, APIs, compatibility paths, and migrations are removed as part of that one cutover; they are not retained as aliases.

See the cutover document for ordered gates, database reset implications, and deployment restrictions.
