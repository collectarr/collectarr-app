# Current Architecture Status

Last reviewed: 2026-10-09. This report reflects the current working tree and
the post-audit release evidence recorded below. The architecture guard has no
unreviewed AST violations; its exact baseline retains 44 reviewed field-leak
findings, all still observed and none stale. The checker reports 364
informational complexity findings.

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
- Smart List persistence is a strict v3 contract with an explicit target and a
  list of kinds. The UI can create and edit multi-kind lists. Kind-specific
  fields are resolved against each active kind schema, and unavailable fields
  remain visible as degraded criteria rather than being discarded. Field rules
  support equals, not-equals, text contains, and is-empty operators. For
  many-valued fields, equals matches any contained value, not-equals requires
  no contained value to match, and is-empty checks for an empty collection.
  The v3 resolver does not translate old per-field `catalog_item` or
  `library_entry` scope tokens.
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
- Music disc `is_live` remains `boolean?`, `cardinality: many`, with source
  path `discs[].is_live`. “Live” and “Studio” are display labels for grouping
  and export; they do not change the canonical value type.
- Every non-null Music disc `format` now requires an explicit non-null
  `format_family` in Core contract 2.2.0. Known presets supply the family;
  custom formats require a selection before Add or Edit can save. No canonical
  path guesses a family from format text.
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
  containment. The full Core suite now verifies the declared identifier and
  scalar indexes with PostgreSQL query plans.
- The post-audit release gate passes. Core contract/schema tests pass and the
  full Core suite passes 155 tests with PostgreSQL; `ruff check .` is clean.
  The full App suite passes 786 tests with one skip, strict Flutter analysis
  and changed-file formatting pass, and the pinned Core bundle matches
  contract 2.2.0. The architecture guard has no unreviewed AST violations.
  Windows desktop/mobile integration smoke tests pass and the Windows debug
  build succeeds.
- The App regression fixtures now match typed registries, field IDs,
  versioned preference keys, TV shared-tab composition, current Comic Drift
  tables, and strict per-kind payloads. The suite also caught and fixed Comic
  issue labels disappearing from local workspace rows, Movie CSV import
  emitting unsupported metadata keys, compact information-chip and pick-list
  header overflows, and stale widget finders for current dropdowns and scopes.
  Game CSV export cells now preserve item number and edition title separately.
- Music listening-event pull and rejected-change retry now run through a
  Music-owned sync codec registered with the kind tracking codecs. Sync and
  database-maintenance hosts dispatch kind-specific provider invalidations
  through the kind registry instead of importing Music, Anime, Board Game, or
  TV implementations. Focused sync tests and analysis pass.
- Music listening events now enforce their Music library-entry ownership in
  the Music domain model; the shared sync queue only validates the generic
  reference structure.
- TV's watch-history editor and season/episode target model now live under the
  TV kind; the generic tracking folder no longer owns that TV-only workflow.
- `tool/check_library_kind_boundaries.dart` passes with no unreviewed AST
  boundary violations. Its exact field-leak baseline retains 44 reviewed
  findings, all still observed and none stale; no new findings were added.
  The checker prints 364 complexity-budget findings as informational output.
  TK001, TK002, TK003, TK005, TK009, TK011, and TK017 have no active violations;
  TK016 has only the 44 exact baseline entries above. The full
  Core suite now passes all 155 tests against the isolated local
  `collectarr_test` database, including schema, API, correction, and index-plan
  checks; `ruff check .` passes. The global format check still reports 44
  pre-existing files outside this change set; all files changed for the final
  checkpoint pass targeted formatting checks.

- Generic metadata detail decoding and Entry creation now exchange
  `CatalogSearchCandidate`; each kind decodes its own Catalog Item transport
  through the candidate capability. The DTO-based generic callback and the
  former top-level transport summary registry were removed without aliases.
  Persisted Library Entry, tracking, admin, CSV import/export, and catalog edit
  payloads use the canonical `JsonMap` serialization boundary.

## Active Music v2 refactor

The staged field-semantics and Music v2 roadmap is tracked in
[`music-v2-refactor-plan.md`](music-v2-refactor-plan.md). Field metadata now
owns cardinality, source/path, and workspace capabilities across all nine
kinds. The strict Core Music v2 bundle is pinned in App, and the App domain has
stable album/disc credits, disc-owned recording metadata, coarse format
families, explicit format presets, and one Credits tab with Album/Disc scope in
Edit and manual Add.
The former album-level recording fields and contribution model are removed.
`MusicWorkspaceData` now constructs immutable `MusicWorkspaceFacts` once from
the canonical album and reuses them through workspace projections, grouping,
and existing disc recording filters. Checkpoint H also removed Music DTO proxy
getters, made Catalog Item and Library Entry schemas share catalog field
definitions, layered personal fields only onto Library Entry, and separated
format/storage summaries from their many-valued semantic fields. Metadata,
workspace schema, search-presentation, and export regression tests pass for
this checkpoint. Checkpoint I now splits Music group definitions into
catalog/disc/credit/personal modules, adds contained disc and credit fields to
workspace groups and filters, and keeps `is_live` a many-valued boolean while
rendering Live/Studio labels for grouping. Raw CSV/TXT export preserves the
boolean values as `true`/`false`. Checkpoint J adds scalar earliest/latest
disc recording date fields and sorts to both Music workspace schemas. Facts reduction and
sorting share one partial-date bound comparator, and sort callbacks read only
the precomputed fact values. Music reports now export format summaries
separately from raw disc formats and expose exportable disc and credit facts
through kind-owned fields. Workspace metadata now selects disc formats,
recording locations, and contributor names for multi-value search indexing,
while technical values and credit roles/instruments stay excluded. Smart List
many-value operators now match contained values with any-match semantics, and
the opt-in workspace benchmark measures 1k/5k mixed-disc collections against
the pre-facts checkpoint. Contained group switches are about 30% faster at 1k
and 23% faster at 5k. Projection pays the one-time facts cost (about 5.35 ms
at 1k and 27.56 ms at 5k); typed publisher filtering is about 1.39 ms at 1k
and 3.43 ms at 5k. The 5k default sort measured 5.35 ms versus a 4.01 ms
baseline, and that regression is recorded in the benchmark report. VM
allocation profiles and process peak-RSS increases are also recorded with
their measurement limits. Music's
schema-v1 CSV import boundary is verified. Windows debug build and
desktop/mobile integration smoke tests pass. Core correction targets
expose Music nested lists as correction-only object-list fields and validate
proposals against the canonical v2 document, preserving nested IDs.
All filterable metadata is now available in Smart List rules, including the
multi-value Board Game, Book, Comic, Game, and Manga facet fields on both
catalog and library-entry targets. Their workspace getters follow the facet
values, and Manga Character now reads the existing canonical character data.
Every Music group now has required field metadata; group IDs, labels, support,
and bucket vocabularies derive from that metadata, with no permissive fallback.
Tests assert complete group metadata and vocabulary parity.

## Local data

The local SQLite database is `collectarr-library.sqlite`. No database was
deleted, reset, or migrated as part of this work. Previous database and backup
formats are unsupported by the v1 baseline; keep old files outside the new app
data directory and create a fresh database for this build.

See [`flattened-catalog-baseline.md`](flattened-catalog-baseline.md),
[`music-catalog-field-inventory.md`](music-catalog-field-inventory.md), and the
nine kind field ledgers for field ownership and parity limits.
