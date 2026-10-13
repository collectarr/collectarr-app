# Current Architecture Status

Last reviewed: 2026-10-13. The current checker reports no AST architecture
boundary violations and 359 informational complexity findings. Historical
UI audit gates below describe their dated checkpoints, not current test counts.

## Music v1 release baseline

The release exposes Music only through UI, capability registrations and pinned
Core contracts. Future kinds remain isolated source modules; fresh SQLite
creates shared and Music tables only. The current shape starts at version 1
using the generic database filename in application support; the existing
Documents database remains untouched and is never downgraded.

Current album/disc/track/credit shapes are preserved. Packages and public
contract labels start at 1.0.0/v1. Source ownership audits still include all kinds.

Current release verification passes analyze, architecture boundaries, pinned
Music contracts, 903 correctness tests with coverage and zero skips, and four
Windows native cases covering navigation, Core add and personal persistence.
The benchmark passes separately for 1k/5k albums. Test ownership and explicit
kind selection are documented in [test suite ownership](test-suite-ownership.md).
Drift/kind generators leave generated files unchanged; pinned contract checks,
whole-repository format, Windows debug and Web release builds pass.

## Implemented

Sidebar selection resolves routed destinations and tracks the lifetime of pages
opened through drawer actions. Pushed tools such as Statistics, Print to PDF,
Find Duplicates and export no longer leave Libraries highlighted merely because
the underlying router URI is `/libraries`. Sidebar page destinations replace
one another over the current-kind Library root, so a single Back returns to
Libraries. Navigation smoke tests cover Settings → Print → Duplicates → Back
without retaining earlier tool pages. Modal actions retain their parent page.
Music disc tabs and Add Disc have visible hover feedback, close controls have
independent hover feedback, and edit/disc reorder proxies have no shadow.
The CLZ font-face audit identified Gilroy Medium behind CSS weight 400; editor
tabs use Manrope Medium, with heavier field/title labels for optical parity.

The [library dropdown audit](library-dropdown-parity-2026-10-11.md) consolidates
neutral popup styling across workspace menus and edit pickers, keeps configured
accent markers across overlays, and replaces the column launcher with an icon
split control. Column categories share the grouping tree primitive and the
chooser caps its width at 600 px. The live audit also found and fixed a Form
notification during parent-driven dropdown controller synchronization. The
regression reproduces before the fix and passes after it. Verification reports
855 tests passed / 1 skipped, clean analysis and architecture checks, successful
Windows/Web builds and 14 live checks without exceptions or overflows.

The [uniform application headers](uniform-application-headers-2026-10-11.md)
keep the kind-accent bar, white kind icon, uppercase brand and three right-side
actions visible across routed and pushed pages. Page headers share Back, icon
and centered title. My Shelf and its route/private components are deleted.
Core add opens over the current kind library; Settings and other routed tools
retain kind context across reload and Back. Eleven pages passed live checks at
four widths. The gate reports 853 tests passed / 1 skipped, clean analysis,
no AST boundary violations and successful Windows and Web debug builds.

The [populated inspector and management comparison](music-inspector-management-parity-2026-10-11.md)
adds reproducible strict App/Core reference seeds, closer geometric typography,
scoped inspector values, responsive Settings panels, atomic field transfer and
sorted index reassignment, current/history loans with PDF export and complete
sync snapshots, and collection-scoped Music statistics. Live actions and reload
checks passed; five management pages were checked at four widths. The latest
gate reports 853 tests passed / 1 skipped, clean analysis, no AST boundary
violations and successful Windows and Web debug builds. The report explicitly
lists remaining typography, Settings, borrower-profile and chart differences.

The [dedicated management pages](library-management-pages-2026-10-11.md) replace
the Find Duplicates and Manage Custom Fields modals. Duplicate management uses
grouped workspace columns, shared column favorites, Keep, individual removal
and overlap-safe automatic removal preserving the oldest entry. Custom fields
offer CLZ's fifteen observed types, previews, fixed-choice limits, transactional
reorder/delete and persistent tab/control preferences. Debug Web CRUD and
duplicate removal survive reload without framework errors at three widths.
The final gate reports 848 tests passed / 1 skipped, clean analysis, no AST
boundary violations (372 informational complexity reports) and a successful
Windows debug build.

The latest [menu-by-menu live Music comparison](music-menu-audit-2026-10-11.md)
opens all 24 Collectarr drawer destinations, 19 CLZ application destinations,
workspace submenus and editor/settings/admin tabs. Debug interaction uncovered
and fixed missing Material on compact dialog routes, unbounded stacked Admin
cards, and field transfer incorrectly requiring Core provenance and passing a
dispatch wrapper to kind accessors. Copying personal data for three independent
Music entries now completes and survives reload. CSV/PDF/XML downloads and
collection creation/persistence are verified on disposable Web fixtures. The
full gate reports 836 tests passed / 1 skipped, clean analysis and architecture
boundaries, and a successful Windows debug build. Online Core transactions and
native pointer-driven comparison remain unverified; visual/workflow differences
are listed explicitly in the report.

The latest [deep live Music UI audit](music-ui-functional-deep-audit-2026-10-10.md)
covers sidebar destinations, all edit tabs, four viewport sizes and selected
functional flows. Follow-up work fixes dirty-navigation (including route Back),
contained track search, Statistics titles, and direct drawer routing for index,
transfer and XML export. UI parity and the full live action matrix remain open.

Library surfaces now share the folder canvas, CLZ-style table/header/menu shades,
continuous panel draggers and toolbar seams. Display controls persist backdrop,
back-cover layout, wrapping/auto-size, status/edit indicators and per-kind split
layout. Details template can differ from the application skin. Settings sections
use scrollable tabs on medium/desktop screens and compact section navigation,
with Appearance sub-tabs for customization, covers/layout, typography and
behaviour/links. Confirmation and eBay position/visibility preferences are wired
into actions and the inspector. eBay region and automatic/all/sold filters persist
and are applied consistently across Music inspector positions. See the deep
audit for remaining CLZ settings.

Cloud Sharing publishes explicit snapshots through Sync. Partial visibility is
public without personal fields; optional private sharing links are separate and
revocable. Collection status is library-entry-owned across all nine kinds and
excluded from public catalog field selection. The live CLZ sharing page was
rechecked through Opera DevTools CLI on 10 October; no remote settings were saved.

- Music's active inspector uses kind-owned Overview, tracks, disc metadata,
  scoped credits and personal sections. Entry context enables Duplicate, Loan,
  collection transfer and provenance unlinking; unlink preserves entry data
  and queues sync. Share uses local TXT/CSV export. See the
  [live comparison and implementation evidence](music-inspector-editor-live-audit-2026-10-10.md).
- Music editing keeps a fixed top anchor and a 1200 px desktop width, uses
  kind accents for Save and selection, and refreshes credit validation after
  role changes. Narrow alphabet navigation scrolls without wrapping All.
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
  full Core suite passes 156 tests with PostgreSQL; `ruff check .` is clean.
  The full App suite passes 787 tests with one skip, strict Flutter analysis
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
  Core suite now passes all 156 tests against the isolated local
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

## Music domain and field ownership

Field metadata owns cardinality, source/path and workspace capabilities.
Music album edition data remains at root; discs own physical, technical and
recording data. Stable album/disc credits have optional real contributor IDs,
role vocabularies and instrument lists. Add/Edit expose one Credits tab with
Album/Disc scope. Partial dates have one canonical representation.

`MusicWorkspaceData` builds immutable derived facts once per album projection.
Catalog and library-entry schemas share catalog fields; personal fields are
layered only onto entries. Group/filter values use deduplicated contained facts;
scalar earliest/latest date reducers share deterministic partial-date bounds.
`is_live` remains a many-valued boolean, with Live/Studio display labels.
Summaries are separate derived fields, never raw filter/group semantics.

Exports distinguish summaries from semantic values. Selective multi-value search
indexes disc formats, recording locations and contributors. Smart Lists apply
contained-value operators. Corrections preserve stable nested IDs and exclude
personal-only edits. These current canonical structures are labelled v1 for the
initial release; no historical schema or API rollback is involved.

## Local data

The local SQLite database is `collectarr-library.sqlite`. No database was
deleted, reset, or migrated as part of this work. Previous database and backup
formats are unsupported by the v1 baseline; keep old files outside the new app
data directory and create a fresh database for this build.

See [`flattened-catalog-baseline.md`](flattened-catalog-baseline.md),
[`music-catalog-field-inventory.md`](music-catalog-field-inventory.md), and the
nine kind field ledgers for field ownership and parity limits.
