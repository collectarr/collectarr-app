# Remaining Cleanup Audit and Implementation Plan

Audit date: 2026-10-02. Source baseline: App commit `89e460717`.
The working tree was clean at the final source snapshot, before this report was
added. Earlier staged changes were committed during inspection. This report
describes the current source, not the removed September v1 workspace.

> Status note (2026-10-05): this is a historical audit, not the current list
> of open findings. App has since removed the Work/Release reference types,
> per-field workspace entity scopes, Anime/TV/Manga legacy projections, and
> Music's redundant tracking lookup scope. It now declares a fresh Drift v1
> baseline without upgrade or repair hooks. Core-side registry cleanup is
> outside this App repository and is tracked in `current-status.md`.

## Scope and verification

Inspected the App composition root, all nine kind registrations, catalog
transport/cache, Add/Edit, workspace/inspector, personal mutations, Sync
boundaries, persistence/backup, forms, generated contracts, CI, and active
documentation. Core and Sync implementation repositories were not fully audited
in this pass; their coordinated changes below are requirements to verify there.

| Check | Observed result |
| --- | --- |
| `flutter analyze --no-pub` and machine-readable analyzer output | 338 diagnostics: 143 errors, 171 warnings, 24 info. All errors are under `test/`; no compile errors were reported in `lib/`. |
| `dart run tool/check_library_kind_boundaries.dart` | Fails: 178 findings, including 147 stale baseline entries and 31 other findings requiring review. Also reports 343 complexity budget warnings. These counts are not 178 independent product defects. |
| `dart run tool/check_kind_duplication.dart` | Passes: no repeated clusters covered by this checker. This does not establish that forwarding wrappers and form definitions are unique. |
| `dart run tool/check_music_catalog_contract.dart` | Fails on `artist`; the check searches for `json['artist']`, whereas the decoder uses `catalogJson['artist']`. This particular failure is a checker defect, distinct from the real serialization defects below. |
| `dart run tool/generate_catalog_item_v1_fields.dart --check` | Fails: generated field definitions are stale. |
| CI command existence | `tests.yml` invokes missing `tool/generate_music_catalog_dto.dart` and `tool/check_music_catalog_field_ownership.dart`. |
| Read-only import graph and folder scan | 1,629 Dart files under `lib/`; 1,519 reached by the main import/export/part graph, including conditional imports. Reachability is at file level, not executable symbol level. Fifty empty leaf directories remain. |

Unit/widget tests and platform builds were not run in this audit. UI findings
are based on active source and the reference implementation; pixel parity and
runtime layout behavior still require paired screenshots and interaction checks.
The reference commit `6949fb4f00e6fdd5828e21474b74fa448e793fe9` exists locally.

## Changes already completed

- All kinds use the generic workspace base and shared dialog chrome.
- All nine catalog codecs implement `CatalogSharedCachePrimaryStore`; the shared
  cache is the active catalog persistence source.
- Drift is already schema version 1, without the former upgrade chain.
- Provider implementation files have been removed from `features/providers`;
  the remaining directories there are empty.
- Collection Items have independent identities and reference concrete catalog
  records. Wishlist and current wire references already use the flat shape in
  several paths.
- Music workspace search still exposes Albums & Tracks, Albums, and Tracks.
- Comic and Book extra routes are currently mounted by `app_router.dart`. They
  are entity detail pages, not proof of a separate workspace implementation;
  do not delete them based on the previous audit's routing finding.
- Domain IDs already share `LibraryEntityId`; distinct kind/child ID subclasses
  are legitimate type boundaries, not candidates for replacement with strings.

## Findings ordered by impact

### A. Active correctness and data integrity

**A1 — Music response serialization is not reversible. Priority: immediate.**
`kinds/music/data/remote/catalog_music_item_dto.dart` implements response
`toJson()` and search `toSearchJson()` through `toProposalData()`. Disc/track
`toJson()` omit IDs; the corresponding decoders require those IDs. Track order
and root revision are also omitted. `artist` becomes proposal artist credits
rather than retaining the response field. Date-part objects can become the
value of a string date field, which the response decoder ignores.
`searchMusicCatalogItems` and `buildMusicManualCandidate` use these serializers,
so this affects real search/manual/cache paths with children, not just export.
Provide separate response and proposal serialization. A response must retain
child IDs, order, revision, scalar artist, and each date representation.

**A2 — Music Format edits are ignored or erased. Priority: immediate.**
The field specs write `MusicAlbumFormValues.physicalFormat` and
`physicalFormatLabel`, but `MusicAlbumFormAdapter.create/update` do not apply
either value and do not preserve `mediumTypesSummary`. For an item without full
disc rows, an unrelated edit can erase its format summary. For an item with
discs, the root format field does not update their format-derived state. Keep
the contract's `format` as an explicit root fact and define child behavior.

**A3 — Manual Add personal images construct an invalid reference. Priority: immediate.**
`LibraryAddDialog._applyManualImageEdits` calls
`CollectionItemRef.fromKey('${kind}:draft:draft')`. The parser requires exactly
two colon-separated parts, so the new-image branch throws. Draft images should
have a draft model without a fabricated persisted Collection Item reference;
bind their owner only when the item is committed.

**A4 — Private manual records have no explicit origin or Sync exclusion. Priority: high.**
All nine manual candidate builders fabricate `manual-<kind>-<timestamp>` IDs
and store those entries in the same cache used for Core items.
`CollectionItemMutations.addCollectionItem` enqueues the associated collection
row unconditionally. The queue retains the Catalog Item reference, not the
private catalog metadata. Another device cannot hydrate that ID from Core.
Introduce explicit local/shared origin, robust local identity generation,
repository lookup and search behavior, and a centralized Sync eligibility
policy. Apply it to copies, wishlist, tracking, sessions and related personal
entities. Preserve the agreed behavior: viewers can add private items and
submit proposals, while shared Core writes require editor/admin permissions.
The active manual submission path currently does not branch into shared Core
creation for editors/admins; wire that explicitly if Add is meant to offer it.

**A5 — Add is split across multiple commits and retries can duplicate entries. Priority: high.**
`LibraryAddSubmissionService.submit` commits cache, collection row, personal
details callback and tracking separately. A late tracking failure reports
overall failure after the copy already exists. Retrying can add another copy.
The personal-details callback catches failures, shows an error toast and still
allows the dialog to close. Put local item/copy/personal/tracking/queue changes
in one transaction or return explicit partial outcomes with retry identities.
`LibraryAddCoordinator` has a second orchestration path with the same concern.

**A6 — Single and checked-result Add have different behavior. Priority: high.**
Single submit uses `state.selectedItem`, which can contain hydrated metadata;
batch submit selects the original `state.search.results`. Hydration lives in
the preview map and does not itself update the cache. The batch coordinator
also applies digital-format defaults that single submit does not. Use one
submission pipeline, resolving each candidate to the necessary completeness
and applying the same defaults for one or many items.

**A7 — Search can downgrade a complete cached item. Priority: high.**
`searchAndCacheLibraryMetadata` persists search projections, and
`CatalogItemCacheRepository.upsert` replaces the entire payload without
completeness or revision ordering. For kinds with partial search results, a
later search can overwrite details obtained through item hydration. Define
summary/detail cache policy and reject stale responses. Single Add currently
skips upsert of its hydrated candidate, leaving the search projection cached.

**A8 — Schema-dialog Save allows overlapping submissions. Priority: high.**
`LibraryEditSchemaDialog` always exposes the scaffold Save callback. The
renderer tracks `_isSaving`, but public `save()`/`_save()` have no reentry guard
and the shell does not observe the busy state. Disable Save/navigation as
appropriate, share the busy state, and reject a second save in the controller.

**A9 — Music Covers narrow layout has an invalid flex arrangement. Priority: high.**
`music_album_images_tabs.dart` constructs `Expanded` cover children for a Row
and reuses them in a Column below 680 px. This content is used inside scrolling
edit surfaces. Build non-flex children for the vertical arrangement and add
flex wrappers only to the horizontal branch. Reproduce at the actual supported
narrow window size before marking the fix verified.

**A10 — Music back cover and personal image targets are inconsistent. Priority: high.**
The Back Cover editor receives null Core URLs despite the domain carrying
`backCoverImageUrl`. Album images, including `purpose: personal`, are stored by
album ID in `MusicAlbumImagesRows`, while generic personal images are stored by
Collection Item reference. The catalog editor and collection editor therefore
have two different My Images destinations. Use per-copy ownership for personal
images and document any intentional local catalog-cover override separately.

**A11 — Music Edit and Add still use different field models. Priority: high.**
Add owns its own `MusicAddManualDraft`, field definitions and partial-date
controls. Edit uses `MusicAlbumFormValues`, separate field specs and DateTime
controls, and still exposes fields such as original title, language, release
type/status and UPC that are not represented equally in the pinned flat Music
contract. Centralize typed catalog values, partial dates, validation and field
definitions. Resolve each extra field against the contract rather than silently
keeping an editable value that the mapper cannot persist.

**A12 — Music mapper replaces contained identities and loses ordering. Priority: high.**
`MusicCatalogMapper._fromTypedDto` synthesizes disc IDs from disc number instead
of retaining `disc.id`, and ignores `track.positionOrder`. Its inverse derives
order from a printed position or index. Preserve IDs/order through load, edit,
disc reorder and serialization, especially where personal disc details must
follow an existing disc. Review credit identity conversions in the same pass.

### B. Remaining domain and architecture cleanup

**B1 — The Work/Release hierarchy still exists in active in-memory adapters.**
`LibraryEntityScope.release`, `LibraryReleaseRef`, workspace release summaries,
release-aware edit/transfer/action branches and detail pages remain. TV/Anime
catalog projections still contain Work metadata and Release arrays; their
calendar contributors iterate release arrays, and presentation builders read
`primaryRelease`. Book/Manga retain release-aware presentation helpers and
obsolete dedicated media editors. Finish root flattening in domain projections,
forms, calendar, duplicates and presentation before deleting shared branches.
Keep real contained tracks/episodes/discs, series relations and their tracking
targets; those are not separate collectible Releases.

**B2 — Three reference systems still encode one root identity.**
`CatalogItemRef` is flat, but much of App still accepts `CatalogEntityRef` with
entity type/root/parent and then wraps it in `LibraryEntityRef` nodes. Sync
canonicalizes one form and reconstructs another. Migrate catalog-root consumers
to `CatalogItemRef` and personal consumers to `CollectionItemRef`. Give real
contained targets explicit typed references, not root/parent fallbacks.
`LibraryCatalogItemNodeRef` carrying an optional collection ref also mixes
catalog and physical-copy selection identity; make selection identity explicit.

**B3 — The generic transport DTO still interprets kind fields.**
`core/api/dto/catalog/catalog_item_dto.dart` remains a large semantic facade over
maps, with field aliases, nested publishing fallbacks, editions/variants and
target-root conversion. Reduce transport to routing identity plus kind-owned
payload and explicit codecs. Obtain cross-kind labels/covers from transient
display summaries. Remove obsolete helpers after migrating their callers.

**B4 — The all-kind shared-cache transition still has a dual-write branch.**
All nine codecs now use `CatalogSharedCachePrimaryStore`, but the transport
repository retains an unconverted-kind fallback. Remove the transitional
marker/fallback if no extension requires it. Separate cache persistence from
kind-derived pick-list/serial processing and batch writes rather than starting
one transaction per item followed by another derived-data transaction.

**B5 — Generic features special-case Music and other kinds.**
`LibraryDetailHydrationService` imports and branches on Music; Sync apply/retry
and controller import Music listening types directly; database maintenance
imports several kind providers. Register kind-owned decoder, sync handler and
invalidation contributors. Keep the owning types behind those boundaries.
Of the architecture check's 31 non-stale findings, 13 are field-ownership flags;
review structural/personal fields such as `catalogItemId` and `imageData` before
classifying them as catalog leaks. Do not silence all failures with a new
allowlist or regenerate the baseline to accept new leaks.

**B6 — Registrations and pages contain forwarding duplication.**
Nine registration classes repeat the same page arguments, and most kind pages
have empty subclasses/states. Use a common page factory driven by explicit kind
registrations and capabilities. Movie/Anime currently use a drilldown state;
retain actual contained-item behavior through a capability rather than dropping
it while eliminating wrappers. Keep meaningful domain ID types.

**B7 — Some legacy UI files are outside the App import graph.**
Examples: Music's old `inspector_panel.dart`, obsolete Anime media editor,
Manga media editor, generic legacy presentation builder, release capability,
old panel chrome/scaffold, comparison/prefill helpers and some pick-list widgets.
Inspect symbol references in App, tests, scripts, generators and exports before
deletion. A file imported only by tests can be an obsolete product implementation
or a valid test utility; migration is needed to distinguish them. Git history
holds the old visual reference; duplicate live implementations are unnecessary.

**B8 — Test helpers are split between `lib/test/helpers` and `test/helpers`.**
Both contain substantial fixture code, and tests import the former through the
production package namespace. Consolidate under `test/`; if seed tooling needs
some fixture construction, move that useful production-independent portion to
a deliberate development support module rather than duplicating test factories.

**B9 — Internal names retain obsolete meanings and migration suffixes.**
Examples include `work_workspace_schema`, `media_edit`, `owned` alongside
`collection_item`, `projectWork`, and Music Work/Album inspector forwarding
functions. Rename only after the types have their final meaning. Remove internal
`V1`/`v1` class/file suffixes where there is no competing implementation; keep
real API, wire, backup and schema version metadata explicit. Do not rename
physical media/disc concepts merely because the word media appears in a name.

### C. Performance, persistence and UI consistency

**C1 — Shelf reconstruction performs per-copy and per-item work.**
`shelfProvider` loads each typed collection item individually, reads catalog data
for summaries and workspace projections separately, and loads full image blobs
for every owned item. Music enrichment calls listening summary once per item;
`CatalogWorkspaceDataRepository` awaits enrichment serially. Add batch lookup
and batch enrichment, reuse decoded catalog records, and load thumbnails or
selected-item images lazily. Measure query count and memory on representative
large fixtures before and after changing this.

**C2 — Bulk storage paths need indexes and bounded queries.**
Cache ref lookup chunks IDs, while personal image lookup sends every key in one
`isIn` query. Audit runtime parameter limits and chunk equivalent personal
lookups. Add indexes for actual collection catalog joins, image-owner lookups,
tracking/session targets and ordered queries after measuring them. Explicitly
define relationship validation and deletion behavior; JSON/key references
currently receive no automatic relational guarantees from the table declarations.

**C3 — Fresh schema 1 still opens the previous default database path.**
Native uses `Documents/collectarr.sqlite`; Web uses the existing IndexedDB name
and `/collectarr.sqlite`. Documentation requests a fresh database but the default
openers do not select a new baseline themselves. Isolate the new database or
detect a schema fingerprint and fail with an actionable fresh-baseline message.
Preserve old databases; no automatic compatibility migration was requested.

**C4 — Backup export is not a consistent snapshot.**
`DatabaseBackup.export` reads tables sequentially outside a transaction. A
concurrent mutation can put mismatched catalog/personal/queue states into one
backup. Export under one read snapshot. Existing restore validation and its
transaction are useful and should be preserved. Consider an explicit backup
format/fingerprint in addition to the Drift schema number, since the table set
is still changing while version remains 1.

**C5 — Image storage and processing remain split.**
Music cover editing and generic collection images have separate byte-loading,
crop/encode and persistence paths. `ImageDownloadService` stores downloaded bytes
per copy and does not validate decoded content or normalize dimensions/encoding;
its batch loop also requires `concurrency > 0` to terminate. Centralize processing
and storage policy while keeping catalog artwork and personal ownership explicit.
Avoid multiplying the same cached Core artwork by the number of physical copies.

**C6 — Workspace query and preference identity are inconsistent.**
The repository projects catalog nodes without the collection reference used by
the main projection builder. Copies sharing one catalog item can therefore have
the same node ID in that path. Preference keys ignore `collectionId`, although
`LibraryWorkspaceKey` equality includes it. Decide whether preferences are
per-kind or per-collection, then use one key/reader/writer contract. Review both
`LibraryWorkspacePreferences` and the newer persistence/session path; remove
duplicate state only after checking active callers.

**C7 — Music inspector highlight and some old behaviors are disconnected.**
The toolbar and inspector request still carry search target/query. The active
`MusicInspectorTrackList` receives neither and always draws normal text. The old
unmounted Music panel retains highlight, copy/print and richer sections. Restore
supported behavior through the common host and typed sections, then remove the
old panel. Compare Overview, Disc Details, Personal, Listening history, Credits
and More against actual active contributors; generic metadata is not proof of
equivalent interaction or layout.

**C8 — Manual Add and Edit share chrome but not the full form body.**
Music Edit places Title in its four-column Main schema; Manual Add injects a
full-width Title in `LibraryAddManualPaneShell`, outside that grid. Tab assembly,
field order and nested child editors are also built separately. Let the kind's
shared form layout own Title and all catalog fields, with Add/Edit differences
limited to submission actions and intentional personal panels. Keep personal
fields out of shared Core writes.

**C9 — Typography tokens exist but many active controls bypass them.**
`library_text_theme.dart` defines 13/14 px roles and shared contrast helpers are
already present. Music Add controls still use 12 px w900/w700; workspace utility
controls have similar overrides; the active track list uses heavy text and
one-line ellipsis. Adopt semantic text roles in active components first. Verify
selected, disabled, hover, focus and highlighted states across light/dark themes,
the Music orange accent and other kind accents, and 100/125/150% scaling.

**C10 — Several active files still combine multiple responsibilities.**
Large sources include group-mode menu (~1,640 lines), settings (~1,559), toolbar
auxiliary controls (~1,516), edit widgets (~1,500), toolbar sections (~1,379),
cover scanning (~1,276), sort dialog (~1,221), filter dialog (~1,158), bucket
sidebar (~1,140), and cover rendering (~1,097). Remove unreachable implementations
first; then extract cohesive controllers, menu models, sections and widgets.
Do not split files solely to satisfy a line-count budget.

### D. Documentation and filesystem

- README still names removed `ComicMedia`/`BookRelease` models and describes
  seed fixtures as media/release graphs.
- Add/Edit and schema-reorganization plans still prescribe Work/Release scopes,
  compatibility review and preference aliases, conflicting with the final flat
  model and the requested clean reset. Their completed claims also disagree
  with current Music Add/Edit field duplication.
- Current status records completed persistence work but also has stale remaining
  work statements. Replace historical narrative with current capabilities and
  an explicit remaining-work list.
- Remove empty leaf directories after deleting old modules; Git does not track
  empty directories, so this is filesystem cleanup rather than a source diff.
  Current groups include all former provider/adapters/credentials/runtime trees;
  per-kind provider/release trees; unused edit/media or edit/release directories;
  Music provider/integration MusicBrainz directories; and personal-list imports.

## Kind-specific focus

| Kind | Remaining focus |
| --- | --- |
| Music | Fix response/proposal serialization, root format, contained IDs/order, partial dates, Add/Edit unification, image ownership, inspector highlight. |
| TV | Remove Work/Release projection and form adapters; retain typed season/episode/physical contents and watch tracking; migrate calendar root date lookup. |
| Anime | Same root cleanup as TV, with Anime-owned episode semantics; remove unused media/release editor and release detail adapters. |
| Book | Remove release-node presentation helpers and obsolete editor vocabulary; preserve printings, bibliographic relationships and author detail routes. |
| Manga | Remove old media editor and release-aware projection helpers; preserve volume/chapter/series semantics. |
| Comic | Remove orphan inspector and unused release actions/labels; retain useful character/creator/story-arc detail routes on the common host. |
| Game | Remove release edit presentation forwarding and release capability labels; preserve platform facts and kind-owned copy details. |
| Board Game | Remove release forwarding/labels and empty edition directories; retain components, play sessions and completeness fields. |
| Movie | Remove remaining generic release vocabulary/branches; keep catalog discs/contents and actual detail capabilities; consolidate the page wrapper. |

## Implementation sequence for the next Codex session

### 1. Repair the verification baseline

1. Inspect the current git status and preserve unrelated work.
2. Fix the CI commands that target missing files; choose the actual maintained
   contract workflow rather than adding empty replacement scripts.
3. Refresh the generated field artifact from the pinned contract and inspect the
   semantic diff. Fix the Music checker to validate decoding behavior instead
   of an exact local variable spelling.
4. Migrate the 143 test compilation errors to the current Catalog/Collection
   model. Remove tests whose only purpose is to require deleted Release behavior;
   replace useful behavior coverage with the flat equivalent.
5. Remove the 147 stale architecture-baseline entries and classify the remaining
   findings. Keep genuine boundary failures visible while fixing them.

Exit: CI has valid commands; analyzer has no errors; contract checks run against
the current model. No compatibility constructors were added to appease old tests.

### 2. Fix active data loss and submission failures

1. Implement complete Music response serializers and separate proposal builders
   for root, disc and track DTOs. Preserve date precision, artist and revision.
2. Retain contained IDs and order in the mapper; apply root format and preserve
   format on unrelated edits. Check all exposed fields against the pinned schema.
3. Replace fabricated persisted references in draft images with typed draft data.
4. Put single/batch Add through one coordinator with consistent hydration and
   digital/default rules. Make local mutations atomic and retry-safe.
5. Prevent search from replacing complete/newer cached records with partial or
   stale results. Persist selected hydrated candidates when they are added.
6. Wire schema Save busy state and add reentry protection. Fix narrow Covers
   layout and display the actual back-cover URL.

Exit: title-only edits preserve format, dates and children; manual tracks/images
work; failed submission does not create duplicate copies on retry; repeated Save
cannot overlap. Verify these behaviors with focused regression coverage.

### 3. Make private catalog origin explicit

1. Add local/shared source metadata and typed local identity generation at the
   repository boundary. Separate private CRUD from replaceable Core cache data.
2. Make local entries searchable, editable, exportable and restorable offline.
   Show origin in Add/preview/inspector where it affects the user's action.
3. Enforce device-local eligibility centrally for private references across all
   personal Sync producers, including wishlist and sessions.
4. Verify editor/admin shared creation and viewer proposal permissions against
   the current Core API. Keep local Add available to viewers.
5. Specify and implement approved-proposal remapping as a separate explicit
   operation; keep private metadata until all local references are remapped.

Exit: private IDs never reach Core hydration or unsupported Sync payloads; the
private catalog is usable independently of server availability and role.

### 4. Finish the domain/reference cutover

1. Migrate consumers of CatalogEntityRef to flat root refs, starting with
   collection payloads and tracking, then calendar/activity, links/overrides,
   custom values/imports and workspace/Edit contracts.
2. Replace synthetic root Work/Release projections per kind. Keep typed real
   contained targets and relationships with explicit identities.
3. Remove release contributors, nodes/scopes, summary types, legacy detail paths
   and empty action branches once no consumer remains.
4. Reduce CatalogItemDto to a transport envelope; decode through kind codecs and
   derive transient display summaries at the boundary.
5. Remove dual-write scaffolding and register kind-owned hydration, Sync and
   invalidation contributors to eliminate generic Music special cases.

Exit: one Catalog Item root and one Collection Item identity on every active
root path; no Work/Release compatibility branch remains. Contained tracking and
relationship navigation retain their useful behavior.

### 5. Unify forms and restore supported UI parity

1. Give each kind one typed catalog values model, one field-spec module, one
   shared catalog tab/group layout and one codec with create/update operations.
   Keep personal Collection Item fields and submit destination separate.
2. Music is the first slice: include Title inside the common Main grid, use
   partial-date controls in both Add/Edit, reuse credits/tracks/links editors,
   and remove duplicate scalar field definitions.
3. Use one workspace page factory; express contained-item drilldown and inspector
   sections as capabilities. Remove forwarding page/state classes.
4. Pass the Music search query/target to the active track list and restore
   highlight, then supported copy/print and inspector sections on the common host.
5. Consolidate per-copy personal image editing and catalog artwork overrides.
6. Apply text/contrast roles to active toolbar, Add, Edit and inspector widgets.
7. Compare old/current screenshots at the same window size, theme, density and
   scale. Record intentional model changes separately from unresolved UI gaps.

Exit: all nine kinds use the common visual host; equal fields share definition,
validation and layout; Music search results highlight the matching tracks; both
themes and narrow windows remain readable and usable.

### 6. Remove leftovers and improve storage/performance

1. Build an AST/symbol reachability inventory including tests, generators, scripts
   and conditional imports. Delete obsolete UI/editor modules after porting
   useful behavior; do not delete dev seed fixtures because they are outside main.
2. Consolidate test fixtures, narrow broad module exports and remove unused
   imports, impossible type checks and stale declarations identified by analyzer.
3. Batch Shelf typed-copy reads and Music enrichment; reuse decoded cache data;
   load image blobs lazily; chunk personal key lookups and add measured indexes.
4. Isolate the fresh database baseline, snapshot backup reads, and centralize
   image processing and its validated concurrency/storage limits.
5. Consolidate workspace preference keys and copy selection identity. Rename
   obsolete Work/Release/internal v1 terminology after semantic migration.
6. Split remaining large active files by coherent responsibilities, then remove
   empty directories within the verified workspace boundary.

Exit: no unreachable product duplicate is kept as a fallback, no query reads all
image blobs merely to paint a shelf, backups represent consistent snapshots, and
internal names describe their actual data/behavior.

### 7. Reconcile documentation and final checks

Update README, current status, field ledgers and schema/form plans. Remove
completed plans from the active list and remove alias/migration instructions that
contradict the fresh baseline. Keep all documentation in English.

Run the maintained generators/checkers, analyzer, focused behavioral coverage,
then broader tests and platform builds justified by the changes. Verify all nine
Add/Edit/workspace registrations, role-specific behavior, offline private data,
CSV/backup round trips, Sync eligibility and paired UI states. Report unresolved
behavior and visual gaps explicitly; compilation alone is not UI parity.

## Handoff prompt

> Implement this plan in order, starting with verification and the active Music
> serialization/data-loss defects. Re-inspect source before each phase because
> the repository may have changed. Preserve existing work. Keep the flat Catalog
> Item + Collection Item model, private viewer Add, reviewed shared proposals,
> common workspace/dialog UI, and English documentation. Use each phase's exit
> criteria to report what is actually complete. Do not add legacy compatibility
> APIs or restore provider integrations to satisfy obsolete tests or UI code.
