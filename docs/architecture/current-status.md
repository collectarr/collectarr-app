# Current Architecture Status

Last reviewed: 2026-10-05. This report describes the current working tree; it
does not claim that the pending implementation work has passed a build or test
run.

## Implemented

- Core Catalog Items identify concrete editions, versions, issues, and album
  releases. App keeps kind-owned metadata in its kind document and personal
  state in a separate map on the same independently editable local entry.
- A local entry has its own `LibraryEntryRef`. Its optional
  `sourceCatalogRef` records provenance to Core; local identity is never
  converted into a Catalog Item reference.
- Runtime navigation uses the sealed `LibraryTargetRef` union:
  `CatalogTargetRef(CatalogItemRef)` or `EntryTargetRef(LibraryEntryRef)`.
  `CatalogEntityRef`, `LibraryEntityRef`, and `LibraryEntityScope` are not part
  of the active library implementation.
- All nine kind workspaces expose distinct Catalog Item and local-entry
  schemas through the shared typed workspace host. Music keeps discs, tracks,
  credits, and album artwork as kind-owned contained data.
- Add, Edit, Core corrections, personal entry editing, covers, local images,
  links, CSV import/export, and the v1 Shelf are connected to the flat local
  entry model. User proposals remain available; provider ingestion is not an
  active Add flow.
- Smart List persistence is a strict v2 contract with an explicit target and a
  list of kinds. The UI can create and edit multi-kind lists. Kind-specific
  fields are resolved against each active kind schema, and unavailable fields
  remain visible as degraded criteria rather than being discarded. The v2
  resolver does not translate old per-field `catalog_item` or `library_entry`
  scope tokens.
- Target-based edit, action, inspector, and vocabulary capability types now use
  `LibraryTarget*` names. Generic workspace composition stores only
  `WorkspaceItem` and `PersonalOverlay`; it does not reconstruct local identity
  as Core identity.
- Workspace rows are composed from `WorkspaceItem` and `PersonalOverlay` in
  separate files. Kind workspace projectors receive both owners separately,
  and field callbacks receive them with their typed DTO.
  `LibraryProjectionContext` contains no adapter, hierarchy node, or third
  identity. `LibraryWorkspaceContext` is the mixed-kind row composition; it
  stores only those two owners and does not carry catalog snapshots or raw
  persisted payloads.
- Tracking lookup no longer has an exact-versus-root catalog scope. Tracking
  records use local entry identity, and contained-content coordinates remain
  in kind-owned progress records.
- Development seed validation checks contained TV seasons and episodes and
  root-level Board Game edition details. It no longer validates TV release
  graphs, Anime release arrays, or Board Game work/edition child graphs.
- Core corrections require an explicit Catalog Item reference. Editing a
  local entry uses its `sourceCatalogRef`; a local entry ID is never treated as
  a Core ID.
- The generic workspace composition no longer carries the unused hierarchy
  capability. Actual contained content such as Anime episodes and TV seasons
  remains kind-owned and available through the separate content hierarchy.
- Music field decisions are grounded in the saved CLZ Music Edit form. Exact
  CLZ field parity for Comics, Books, Movies, and Games remains unverified
  until their Edit-form captures are available. Manga, Anime, TV, and Board
  Game ledgers remain provisional because they have no dedicated CLZ product
  form.

## Remaining work and limits

- Some App edit and activity controls still write through repositories outside
  the shared entry transaction. Audit those paths and complete busy/error,
  cancel, and repeat-submit handling before claiming every edit is atomic.
- App's Drift source now defines schema version 1 with only `onCreate`; there is
  no upgrade chain or external-links repair hook. Existing database files were
  not opened, reset, migrated, or deleted during this work. Start this baseline
  with an empty app data directory.
- The Core contract snapshot still reflects Core's current export. Core-side
  registry simplification, obsolete metadata field scope removal, indexed
  identifier lookup, and paginated catalog search require changes in the Core
  repository and a regenerated pinned contract.
- Production-source analysis reports no errors. Its only warnings are in the
  generated API client/model files (`collectarr_api.client.dart` and
  `collectarr_api.models.dart`). Architecture guards, the Windows build, and
  tests remain deferred until implementation work is complete, as requested.

## Local data

The local SQLite database is `collectarr-library.sqlite`. No database was
deleted, reset, or migrated as part of this documentation update. Existing
database and backup compatibility must be described with the coordinated
release procedure before a clean schema baseline is shipped.

See [`flattened-catalog-baseline.md`](flattened-catalog-baseline.md),
[`music-catalog-field-inventory.md`](music-catalog-field-inventory.md), and the
nine kind field ledgers for field ownership and parity limits.
