# Flattened Catalog Reference Inventory (App)

Last reviewed: 2026-10-05. This inventory records the active App ownership
boundaries and remaining cleanup. It does not claim that the complete cutover
has passed a build or test run.

The pinned kind-owned Catalog Item field contract is
`tool/core_contracts/catalog-item-v2.json`. After updating it from Core with
`tool/update_core_contracts.ps1`, regenerate App's field-name projection with
`dart run tool/generate_catalog_item_v2_fields.dart`.

The Music ledger is `music-catalog-field-inventory.md`. The provisional
ledgers for Anime, Board Game, Book, Comic, Game, Manga, Movie, and TV are in
`catalog-item-field-ledgers/`. Their keys and types are recorded, but displayed
labels, edit tabs, repeat behavior, and CLZ parity remain unverified until the
corresponding Edit-form captures are available.

| Feature | Current identity and owner | Remaining decision or cleanup |
|---|---|---|
| Library workspace, details, edit, and selection | `CatalogItemRef` identifies Core data; `LibraryEntryRef` identifies an independent local record. `LibraryTargetRef` is the runtime union. An entry's optional `sourceCatalogRef` is provenance. | Mixed-kind consumers use a `LibraryWorkspaceContext` composed only from `WorkspaceItem` and `PersonalOverlay`. |
| Global activity | Activity is assembled from local entries, tracking, sessions, wishlist, loans, and purchases. | Keep every event's owner explicit and consistent with its repository and Sync payload. Canonical facts target the Catalog Item; personal events target their local entry. |
| Calendar | Release dates are kind-owned catalog metadata; loans and purchase dates belong to personal state; watch events have local-entry ownership and contained episode coordinates. | Review each calendar projection and ensure it does not reconstruct Work or Release identities. |
| Tracking and sessions | Tracking and sessions use local entry identity; kind-owned season, episode, chapter, or track coordinates remain in their payloads. Music listening events are Music-owned. | Remove any redundant Catalog Item reference from tracking payload/storage only after all active readers have moved to local entry identity. |
| Loans | `LoansCache.libraryEntryRefKey` and `LoanRepository`. | No Work/Release identity is needed; preserve borrower, dates, and notes. |
| Smart Lists | Strict v2 `SmartListCriteria` stores `target`, `kinds`, filters, sorts, and search. The UI can create/edit a list across kinds. | Keep field resolution against each kind-owned schema. Preserve unavailable criteria as degraded values rather than mapping unrelated same-named fields across kinds. |
| User folders and reading queue | `UserFolderItemsCache` and `ReadingQueueCache` use `LibraryEntryRef`. | Keep organization personal to the local entry. |
| Locations | `LocationsCache` and `StorageLocation` are App-owned reference data; personal entry data stores the chosen location ID. | None of these parent IDs represent a Catalog Item parent; they describe nested storage locations. |
| Custom fields | App-owned definitions and values target a Catalog Item or local entry explicitly. | Continue to validate target kind and identity at the persistence boundary. |
| Images and covers | Catalog covers use Catalog Item identity; personal images use local entry identity. | Keep upload and editing flows distinct by ownership and avoid local entry IDs in Core image routes. |
| Pick lists | App-owned vocabularies scoped by kind/list. | Keep user-created entries and usage cleanup independent from Catalog Item identity. |
| Bulk actions | Commands select either Catalog Items or local entries through `LibraryTargetRef`. | Remove only actions that require a Work/Release parent; preserve duplicate and quantity behavior. |
| Settings and Home | Settings own locations, vocabularies, local database maintenance, and other App preferences. | Provider ingestion and credentials are not part of the intended product flow. Audit any remaining provider-only control before removal. |
| Backup | Backup captures the local Drift database and its App-owned state. | Define and document the final versioned format and its old-format error behavior. Do not delete the old database during implementation. |
| CSV import/export | CSV v1 works with full local entry envelopes and kind-owned projections. | Preserve kind metadata, personal values, dates, contained children, attachments, and `quantity` where present. Imports assign independent local IDs. |
| Search and offline visibility | Core search returns flat Catalog Items; locally owned entries remain visible without Core hydration. Contained child search is kind-owned. | Keep catalog identity and local-entry identity distinct in results and inspector navigation. |
| Export integrations | User exports choose kind-owned metadata and personal entry values explicitly. | Remove only provider-only exports; keep supported integrations that do not require provider ingest. |
| Proposals and corrections | User proposals use the same kind-owned catalog fields as Add/Edit. A correction requires an explicit `CatalogItemRef`. | Keep personal values and provider payloads out of Core proposals. |

Workspace field callbacks and kind projectors receive `WorkspaceItem`,
`PersonalOverlay`, and the typed kind DTO directly. Mixed-kind row actions use
`LibraryWorkspaceContext`, which stores only the item and personal overlay.

## Reference contract

The active runtime references are `CatalogItemRef` for a concrete Core item and
`LibraryEntryRef` for a local record. `LibraryTargetRef` is only their sealed
navigation union; it does not add another identity namespace. Provenance is an
optional `sourceCatalogRef` stored on a local entry.

Each local entry has its own ID and complete kind metadata plus personal data.
Duplicating creates an independent entry with a new ID. Preserve `quantity`
where the kind uses it; quantity is not a substitute for entry identity.
Contained tracks, episodes, and similar data retain kind-owned child IDs and
do not create editable Work or Release nodes.

Smart List v2 rejects the old scope-based JSON format. Workspace runtime no
longer uses `LibraryEntityScope`, `LibraryEntityRef`, or `CatalogEntityRef`.
Drift now declares a v1 fresh-database baseline with no upgrade or repair
hooks. Existing database files have not been modified; start the v1 App from
an empty application data directory.
