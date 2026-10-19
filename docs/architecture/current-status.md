# Current Architecture Status

Last reviewed: 2026-10-15. Run `dart run tool/run_tests.dart` and the
architecture checker for current findings; this page records structure, not
test counts. UI differences from the reference app live in
[CLZ parity](../clz-parity.md).

## Release scope

Music and Game are released, through the UI, capability registrations and
pinned Core contracts. The other kinds (Comic, Manga, Book, Board Game, Movie,
TV, Anime) remain isolated source modules under `lib/features/library/kinds/`;
a fresh database creates shared, Music and Game tables only. Releasing another kind means its own tables, an explicit migration and
its own verification.

## Local data

The Drift root is `lib/core/db/local_database.dart`, schema version 3, stored
as `collectarr-library.sqlite` in application support. Version 1 is the first
baseline: previous database and backup formats are not read. Version 2 added
borrower contact details and version 3 the Game tables. From here on every
schema change is an explicit, ordered, data-preserving migration; a database is
never reset to make an upgrade work. See [local persistence](local-persistence.md).

## Catalog and entries

- Core owns source-neutral Catalog Items: one concrete edition per item. App
  owns personal data and user proposals. See the
  [Catalog Item baseline](flattened-catalog-baseline.md).
- A local entry has its own `LibraryEntryRef`; an optional `sourceCatalogRef`
  records Core provenance. Local identity is never converted into a Catalog
  Item reference, and corrections require an explicit Catalog Item reference.
- Runtime navigation uses the sealed `LibraryTargetRef` union
  (`CatalogTargetRef` or `EntryTargetRef`).
- Workspace rows compose a `WorkspaceItem` and a `PersonalOverlay`; kind
  projectors receive both owners separately.
- Edit dialog Save commits catalog data, entry metadata, personal data,
  tracking, images, custom fields and the sync outbox in one transaction.
- Smart Lists use the strict v3 contract with explicit targets and kind lists.

## Music model

Album edition data stays at the root; discs own physical, technical and
recording data, and tracks are contained in discs. Each non-null disc format
has an explicit format family (Core contract 2.2.0); format-aware capabilities
decide which disc fields apply. Album and disc credits have optional stable
contributor IDs, role vocabularies and instruments, edited in one Credits tab.
Partial dates have one canonical representation. `is_live` is a many-valued
boolean with Live/Studio display labels.

`MusicWorkspaceData` builds derived facts once per album. Grouping and filters
use deduplicated contained values; summaries are separate derived fields. The
Music grouping menu declares the reference's 62 folder choices, defaulting to
Artist. See the [field inventory](music-catalog-field-inventory.md),
[Catalog contract](music-catalog-contract.md),
[track headers](music-track-headers.md) and
[grouping choices](music-workspace-grouping-clz.md).

## Imports, exports and sync

Guided importers are kind-owned (Discogs CSV, Music Collector XML, CLZ Music
Web XML, Delicious Library 2 XML) and stage a review before saving; manual CSV
mapping requires a Title. Collectarr CSV is the complete backup format. Cloud
sharing publishes explicit snapshots through Sync. See
[import/export](../import-export.md).

## UI conventions

Kind accents mark library identity. Shared blue marks utility actions, input
focus, item/folder selection, settings labels and links. Collection status
colors are fixed. Fonts: bundled OFL Plus Jakarta Sans, optionally a
user-supplied local font (see [local font loading](local-font-loading.md));
Gilroy is never bundled.

## Guards

- `tool/check_library_kind_boundaries.dart`: AST ownership rules; kinds never
  import other kinds, and shared code holds no kind rules.
- `tool/check_music_catalog_contract.dart` and the pinned Core contract bundle.
- Test ownership and kind selection: [testing](../testing.md),
  [test suite ownership](test-suite-ownership.md),
  [contract testing](testing-contracts.md).
- Kind registration and generated artifacts:
  [kind registration](kind-registration-codegen.md).

## Known limits

- Standalone activity controls (outside the editor) are separate commands
  without a shared busy/error/repeat-submit pass.
- Field parity with CLZ is verified for Music only. The CLZ Games Edit form
  is captured in the [Game ledger](catalog-item-field-ledgers/game.md) with its
  gaps; the other kinds' ledgers in `catalog-item-field-ledgers/` are
  provisional.
- Native pointer-driven comparison with the reference is done on Web; Windows
  rendering is checked separately.
- With `--kinds=all`, two unreleased-kind tests fail: the Manga preferences
  isolation test needs the unregistered Comic kind, and the TV watch-session
  sync test does not persist. Released-kind runs are unaffected.
