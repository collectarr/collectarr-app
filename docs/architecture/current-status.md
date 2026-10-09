# Current Architecture Status

Last reviewed: 2026-10-09. This report describes the current working tree; it
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
- Edit dialog Save commits catalog transport, entry metadata and personal data,
  tracking state, images, custom fields, wishlist changes, and the entry sync
  outbox in one local transaction. Nested mutation calls join the same unit of
  work; sync scheduling and projection invalidation run after commit.
- Add search consumes the paged Core search contract (`items`, `next_offset`,
  `has_more`). Music keeps its detailed disc and track payload while using the
  same page shape.
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

- Standalone activity controls remain separate commands and transactions.
  Edit-dialog Save is atomic, but busy/error, cancel, and repeat-submit
  handling still need a separate UI pass.
- App's Drift source now defines schema version 1 with only `onCreate`; there is
  no upgrade chain or external-links repair hook. This build intentionally
  does not support the previous database or backup formats. Existing database
  files were not opened, reset, migrated, or deleted during this work. Keep any
  previous file and backups separately, then start this baseline with a new,
  empty app data directory so `collectarr-library.sqlite` is created fresh.
- Core's kind registry now composes routes, documents, models, response schemas,
  proposal writers, and kind-owned field declarations. Its field-schema wire
  shape no longer exposes redundant root ownership metadata. The Core bundle
  and App pin were regenerated together after this contract change.
- Core catalog search now pages shared and kind-specific endpoints with stable
  ordering. Identifier predicates use indexed scalar columns or JSONB
  containment. PostgreSQL planner verification remains deferred to the final
  checks.
- Architecture guards, the Windows build, and tests remain deferred until
  implementation work is complete, as requested.

## Active Music v2 refactor

The staged field-semantics and Music v2 roadmap is tracked in
[`music-v2-refactor-plan.md`](music-v2-refactor-plan.md). Field metadata now
owns cardinality, source/path, and workspace capabilities across all nine
kinds. The strict Core Music v2 bundle is pinned in App, and the App domain has
stable album/disc credits, disc-owned recording metadata, coarse format
families, explicit format presets, and a shared Credits editor for Add/Edit.
The former album-level recording fields and contribution model are removed.
The next checkpoint builds immutable `MusicWorkspaceFacts` once per projection;
disc/credit groups, many-value filters, reducer sorts, export/search, and final
performance verification remain open.

## Local data

The local SQLite database is `collectarr-library.sqlite`. No database was
deleted, reset, or migrated as part of this work. Previous database and backup
formats are unsupported by the v1 baseline; keep old files outside the new app
data directory and create a fresh database for this build.

See [`flattened-catalog-baseline.md`](flattened-catalog-baseline.md),
[`music-catalog-field-inventory.md`](music-catalog-field-inventory.md), and the
nine kind field ledgers for field ownership and parity limits.
