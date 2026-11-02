# Current Architecture Status

Last reviewed: 2026-11-02. Run `dart run tool/run_tests.dart` and the
architecture checker for current findings; this page records structure, not
test counts. UI differences from the reference app live in
[CLZ parity](../clz-parity.md).

## Release scope

`library_release_scope.dart` activates Music, Comics and the Games family
(Game, Game Hardware, Game Toy), matching published v1.5.0. Hardware and Toys
are separate kinds with their own collections, models and Core catalogs.
Book, Board Game and Movie remain dormant source modules. Active kinds share
library entry storage and contribute their own catalog, tracking and field
contracts; a new kind must be explicitly registered and verified.

## Local data

The Drift root is `lib/core/db/local_database.dart`, schema version 6, stored
as `collectarr-library.sqlite` in application support. Published v1.5.0 uses
schema 5. The next migration starts from that released baseline and adds
user-supplied list-value images and the Comics grade cleanup. Earlier ordered
migrations retain Music/Games data and introduce Comics reading/tracking.
No intermediate unreleased schema is a migration baseline, and an upgrade
never resets a database. See [local persistence](local-persistence.md).

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
decide which disc fields apply. Album and disc credits use names, role vocabularies and instruments, edited
in one Credits tab; retired contributor IDs are removed by the schema-5 migration.
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

Async action hosts share busy, repeat-submit and error handling across action
menus, semantic inspector actions, and standalone tracking/listening controls.
Kind modules retain the operations and their domain rules.

## Guards

- `tool/check_library_kind_boundaries.dart`: AST ownership rules; kinds never
  import other kinds, and shared code holds no kind rules.
- `tool/check_music_catalog_contract.dart` and the pinned Core contract bundle.
- Test ownership and kind selection: [testing](../testing.md),
  [test suite ownership](test-suite-ownership.md),
  [contract testing](testing-contracts.md).
- Kind registration and generated artifacts:
  [kind registration](kind-registration-codegen.md).

## Native presentation boundaries

`AppPresentationPlatform` is the single native Android/iOS versus desktop/web
policy. `AppWindowClass` describes width and height only; it does not infer a
platform or prescribe navigation from width. Mobile header search, sidebar
account access, the Add method chooser, full-screen Core search and consolidated
library controls consume existing state owners. `LibraryAddMobileSearchControls`
arranges shared inputs without owning controllers or query/scan behavior. Web
and desktop retain their dense presentation at compact widths.

Library projections, selection, search and preferences belong to the existing
page session/providers. Add owns one `LibraryAddSessionController`; Edit keeps
one draft/session/validation/commit pipeline. Platform-specific chrome must
consume these owners rather than duplicate them. Shared hosts render typed
kind contributions and do not choose fields from hard-coded kind names.

MobileShell and DesktopShell consume the same auth, kind, action and theme
owners. Native primary destinations reuse the drawer model, with a bar below
840 dp and a rail above; collection selection sits above library content and
shares activation with desktop tabs.

Native item activation opens a root detail route and keeps the Library route
mounted below it; long-press selects without opening. `/detail` identifies the
kind, entry/catalog namespace and ID. Shelf hydration and cached catalog
projections reconstruct the shared inspector and existing command coordinators
without `extra`. Optional live navigation hints retain filtered neighbor order
and parent filter callbacks. Missing targets have a safe return to Library.
The detail host reuses the Library command session rather than duplicating Edit
and collection mutation pipelines. Android registers `collectarr://app/detail`;
there is no iOS runner in this repository yet.

`LibraryMobileEditorScaffold` supplies native chrome inside the same schema,
text-controller store, form, tab navigation scope and dirty guard as desktop.
Native Add Manually provides its validated Add action in the header. Native
`MobilePageHeader` scopes white text and transparent header buttons independently
of desktop chrome; Add, Edit and item details share it. Native editor tabs retain their subtrees and scroll state while keyboard insets shrink
only the content area; Save remains in the header. Collection status/index/quantity/
location controls reuse their existing draft in a native sheet rather than fixing
a second short viewport below the form. Desktop keeps dialog chrome.

Native Settings sections use `/settings?section=...&kind=...` on phones and
tablets, including cold entry and a safe return to the section index. Desktop
keeps responsive section tabs. Native collection management reuses repository
commands in a full-screen reorderable list; short name/confirmation prompts stay
dialogs. Sorting exposes kind-owned favorites directly and reuses the same
advanced multi-field rules, with touch-sized shared field selection controls. UI comparisons and unverified workflows
remain in [CLZ parity](../clz-parity.md).

`toolbar/sections.dart` composes exports rather than owning every toolbar.
`secondary.dart` binds the common kind values/actions, `desktop/filtering.dart`
owns dense filtering, `selection.dart` owns selection controls, and `compact.dart`
owns compact search/context controls. `chrome.dart` contains shared toolbar
mechanics; `mobile/actions.dart` supplies native touch geometry from immutable
colors, action widgets and count text. No toolbar presentation owns domain state.

## Known limits

- Field parity with CLZ is verified for Music only. The CLZ Games Edit form
  is captured in the [Game ledger](catalog-item-field-ledgers/game.md) with its
  gaps; the other kinds' ledgers in `catalog-item-field-ledgers/` are
  provisional.
- Web and Windows comparison covers desktop rendering. Android Comics is
  compared read-only on a Motorola Edge 70 against an isolated Collectarr
  review package; populated item flows, iOS and native tablets still need
  device checks.
- The app still imports Material from `package:flutter/material.dart`, while
  Flutter is moving it to the separate `material_ui` package (with
  `cupertino_ui`), which go_router and cached_network_image already use. The
  two packages' `MaterialApp`, `Theme` and `ThemeData` are distinct types, so
  go_router does not see this app as a Material app and would build pages
  without a transition; `appRoutePage` in `lib/core/routing/app_route_page.dart`
  builds them explicitly. Migrating to `material_ui` (`dart fix` ships its
  data) removes that helper, but waits until the packages that still use
  `flutter/material` (flutter_riverpod, printing, mobile_scanner, qr_flutter,
  image_picker_for_web, url_launcher_web, google_mlkit_text_recognition) move
  too, or their widgets lose the app theme.
