# Catalog Item v1 Coordinated Cutover

## Target

Every library kind has one catalog root representing the specific collectible edition, version, issue variant, or release, and zero or more owned-copy records:

```text
Catalog Item
└── Owned Copy 0..N
```

Repeated contents (music discs/tracks/credits, TV seasons/episodes, comic creators/characters, and similar data) are contained children of the Catalog Item. A series may be a grouping/reference, but must not require a separate editable Work node. Owned-copy fields never live on a shared Catalog Item.

The v1 field inventory is maintained in [Catalog Item field ledgers](catalog-item-v1-field-ledgers/README.md). The Catalog Item field set is frozen by those ledgers and the exported typed contract. Music is grounded in its saved CLZ form. The other eight ledgers use an explicitly selected proxy or Collectarr's existing fields where no dedicated CLZ form is available; they define the v1 field decisions but do not claim literal CLZ parity. Exact CLZ labels, form locations, and parity remain unconfirmed until saved Edit-form captures are available. No legacy model may be removed until every field in it has a documented v1 destination or an explicit exclusion.

## Cross-repository ownership

- Core owns the canonical, source-neutral `CatalogItemV1` contract and catalog read/write/search operations.
- Core Catalog Item writes are restricted to authenticated catalog editors and administrators. Viewers can search and read shared catalog data, then save their own copies locally.
- App uses Core for Catalog Item search and canonical writes. The target App contains no provider subsystem, provider credentials, provider IDs, import provenance, or provider-specific UI. Barcode scanning only supplies an identifier to Catalog Item search.
- App owns Owned Copies, personal fields, tracking, and local-only images/activity.
- App pins and generates transport types from Core's exported v1 contract. Kind-specific details are typed; no provider envelope is part of a canonical write.
- `CatalogItemRef(kind, id)` and `OwnedCopyRef(kind, itemId, copyId)` are the shared reference shapes. There is no generic Work/Release/Copy scope.

The API response wraps `id`, typed `details`, and timestamps. Music write tracks are album-contained inputs; Core supplies each response track's `album_id` from the containing Catalog Item ID. The App validates this relationship at its Music mapping boundary. The pinned App contract is `tool/core_contracts/catalog-item-v1.json`. Sync it from Core with `tool/update_core_contracts.ps1`, then regenerate or verify its Dart transport part with `dart run tool/generate_catalog_item_v1_dto.dart` and `dart run tool/generate_catalog_item_v1_dto.dart --check`. CI checks the generated part against the pinned contract hash.

## Cutover gates

1. **Field freeze:** finish each ledger against saved forms where available. Mark any non-CLZ fields explicitly. Decide whether to keep, rename, or remove every existing field before modeling it.
2. **Contract and ownership:** define the shared Catalog Item contract, typed per-kind details, and child collections in Core. Define `OwnedCopyV1` as an App-only contract with typed per-kind details. Generate App Catalog Item transport code and field definitions from the pinned Core contract.
3. **Core storage/API:** store one canonical Catalog Item per edition. Replace work/release endpoint graphs with Catalog Item operations and contained child data. Keep owned-copy and provider data out of Core.
4. **App persistence and references:** reset App's database to v1 with final catalog and owned-copy tables; replace entity scopes, refs, candidate/write paths, routes, and preference keys. Remove the provider subsystem and all dependent Add/Admin/Settings flows. No old scope or provider API is kept as a compatibility alias.
5. **All-kind UI and projections:** each kind has one Catalog Add/Edit form and a separate Owned Copy form. The same field definitions drive forms, workspace columns, sort/group, search and exports. Track/episode/credit editors remain typed kind-specific child editors.
6. **Coordinated reset:** Core's schema and every redesigned wire contract use v1; App's Drift schema uses v1. Existing old-format databases/backups do not open under this baseline. Deployment instructions must require fresh databases and a rebuilt search index. No live database is deleted by this repository change.
7. **Close-out:** remove obsolete model/route/DTO/migration/preference paths only after all nine kinds use the new structure. A mixed Work/Release and Catalog Item architecture is not a release state.

## Current state

This cutover is in progress. Core exports the typed all-kind Catalog Item contract and source-neutral CRUD/search endpoints. App pins the contract, generates strict DTO decoders, and has separate Owned Copy domain, local persistence, Add operations, and workspace-read services. All nine kind page registrations now open the shared Catalog Item + Owned Copy workspace. The library switcher, accent resolution, settings navigation, and offline kind catalog use a small v1 identity registry instead of initializing legacy per-kind Add, provider, and Work/Release capability composition. Its Add flow searches Core or creates a Catalog Item for editors/admins, then saves Owned Copies locally; Catalog Item editing uses the same pinned kind schemas, and copy editing uses the shared Owned Copy form. Repeated object fields such as tracks, episodes, credits, images, and identifiers render as editable schema-driven rows instead of free-form JSON; partial dates keep independent year, month, and day values. Workspace rows show edition details and support text search across Catalog Item fields and Owned Copy notes. Sorting is available by title, release date, active-copy count, and most recently updated Catalog Item; grouping options are derived from scalar fields in each kind's pinned schema. Configurable columns and v1 import/export remain cutover gates. Adding a copy for an already selected Catalog Item does not require Core to be reachable. Catalog search, create, and item editing still require Core. The global Shelf now includes rows backed by v1 Owned Copies and can return to the matching kind workspace.

The v1 workspace route does not yet remove the legacy modules: App still contains `LibraryEntityScope.work/release/copy`, a Drift schema v6 with the old upgrade chain and tables, and legacy workspace/edit contributions. The main router no longer registers the generic Work/Release detail route or legacy kind-specific detail routes, and the v1 library navigation no longer initializes the legacy kind capability registry. Provider, proposal, and ingest panels are no longer exposed in Admin or Settings, and the Admin dashboard no longer requests removed Core provider endpoints; their old Add implementation, API methods, DTOs, and other provider adapters remain to be deleted. Core still has per-kind work/edition/release canonical graphs for most kinds alongside the new Catalog Item API. The new route uses an Owned Copy cache and fetches canonical item details from Core; the global Shelf now loads v1 copies independently of the legacy Shelf, so a failure in the legacy data path no longer hides v1-owned records. The v1 workspace supports text search, schema-derived grouping, and sorting by title, release date, active-copy count, and most recently updated Catalog Item. A full reset still requires migrating all remaining references, sync/backup/smart-list behavior, and Core's legacy graphs before removing the old schema and modules. The current v1 tables and services are implementation scaffolding inside the in-progress branch, not a deployable mixed baseline.

The active collection mutation runner no longer initializes provider accounts or mirrors local tracking and wishlist changes to provider links. Provider classes remain in the App source because the old Add and hierarchy modules have not yet been removed.

Do not reset or deploy either database until the all-kind v1 implementation is complete. No live database is deleted by this repository work.

## Implementation rules

- Do not infer CLZ parity from Collectarr's current field inventory.
- Do not silently drop existing user-entered or canonical fields. Each one needs a ledger decision before v1 is frozen.
- Do not ship a compatibility graph, alias, decoder fallback, or preference migration for the old topology; the planned baseline is a coordinated reset.
- Do not include App-owned `OwnedCopyV1` in Core's contract.
