# Library Media/Release Architecture

> Historical proposal: this document describes a broader restructuring pass,
> not the current implementation contract. As of 2026-05-31 the app already has
> anchor-aware add/edit flows, bundle-release support, and a six-kind shipped
> registry (`comic`, `book`, `game`, `boardgame`, `movie`, `music`), but this
> full architecture rewrite is not an active roadmap item.

> Treat the sections below as background design notes. Re-validate them against
> current shared library surfaces before using them as implementation guidance.

## Current Architecture Direction

The active library cleanup is not following the original "make generic smarter"
direction. The current rule is simpler:

- keep shared code for interfaces, adapters, and a narrow set of genuinely
	common helpers
- move concrete builders, bucket logic, page entrypoints, and shell behavior
	into `lib/features/library/kinds/*`
- prefer obvious local ownership over another indirection layer, even when that
	means controlled copy-paste between kinds

What that means in practice today:

- `home_page.dart` dispatches through concrete kind pages instead of
	instantiating the old generic page directly
- the old shared page surface is now explicitly named `GenericLibraryPage`
- workspace/release entry normalization lives in per-kind
	`workspace_entry_builder.dart` files
- simple bucket-label builders now live in the kind or generic presentation
	files that use them
- `BookLibraryPageState` is the first concrete kind state hook and already owns
	the drilldown decision locally

Remaining work is implementation-detail cleanup, not a fresh architecture
proposal: keep moving behavior out of `generic/page.dart` into kind-local page
states until the fallback shell is only a thin shared baseline.

## Why This Needs A Restructure

The generic library stack currently mixes three different scopes in the same surfaces:

- media scope: title, series, year, studio/publisher, synopsis, tracking summary
- release scope: edition, variant, barcode, region, packaging, physical format
- copy scope: condition, purchase price, storage, notes, loans, local images

That flattening makes the list view hard to reason about, especially for TV, movies, anime, comics, and manga where a single title can have multiple physical releases and sometimes container content.

The backend already exposes a stronger hierarchy:

- `Series -> Volume -> Item -> Edition -> Variant`
- `BundleRelease -> BundleReleaseItem[]`

The app should lean into that instead of pushing more personal-copy fields into title-level list views.

## Recommended Mental Model

### 1. Media scope

Represents the collectible/work itself.

Examples:

- movie title
- TV show title
- comic issue
- manga volume
- omnibus as a catalog item

Primary fields:

- title
- series / volume / season label
- release year / original air year
- studio / publisher
- country / language / age rating
- owned count / wishlist / tracked summary

### 2. Release scope

Represents a purchasable or identifiable release package.

Examples:

- Blu-ray edition
- steelbook variant
- comic variant cover / printing
- omnibus hardcover printing
- TV season box set
- anime collector's edition

Primary fields:

- edition title
- variant name
- barcode / SKU / ISBN / UPC
- physical format / packaging / region
- release date
- content summary

### 3. Copy scope

Represents the user's owned or wished instance.

Primary fields:

- condition / grade
- quantity
- price paid / purchase date
- storage location
- personal notes / loans / photos

## Double-Click / Drilldown Rules

### Generic rule

- single click selects
- double click drills down or opens the next meaningful scope

### Video

- show or movie title -> open hierarchy browser
- TV show -> seasons first
- season -> releases for that season
- movie -> releases directly
- release -> copies / release details

### Comics

- single issue -> releases / variants first
- omnibus / trade / hardcover collection -> contents first
- release row -> copies / personal details

### Manga

- volume -> releases first when no explicit contents are known
- omnibus / collector edition / box set -> contents first

## List View Rules

List view should default to the scope the page currently represents.

### Media-level list defaults for video

- status
- cover
- title
- publisher
- release date
- country
- language
- age rating
- wishlist
- updated

Not default at media level:

- condition
- price
- location
- barcode

Those belong to release or copy surfaces.

## Kind-Specific Navigation Proposal

### TV

Target flow:

- Show -> Seasons -> Releases -> Copies

Notes:

- use `Volume` as the season-level browse node when available
- use `BundleRelease` as the physical season/set surface
- allow a season release to contain one or more season volumes

### Movies

Target flow:

- Movie -> Releases -> Copies

### Anime

Target flow:

- Title -> Seasons or Parts -> Releases -> Copies

### Comics

Target flow:

- Issue -> Releases -> Copies
- Omnibus/collection -> Contents -> Releases -> Copies

### Manga

Target flow:

- Volume -> Releases -> Copies
- Collection/box set -> Contents -> Releases -> Copies

## What Already Exists

The app already has useful primitives that should be reused instead of replaced:

- personal anchors for `item`, `edition`, `variant`, `bundle_release`
- item season and volume API calls
- bundle release detail models
- series detail and relation routes
- video release browser/detail surface

The missing piece is a generic hierarchy browser that decides which scope is the next drilldown target for each kind.

## Feature Backlog

### Phase 1: UX parity

- list view double-click parity with grid/card/flow
- video list defaults stay media-level
- explicit `Open releases` / `Open contents` / `Open details` actions in context menus

### Phase 2: Hierarchy browser

- add a generic browser surface for `media -> child scope`
- TV seasons browser powered by item seasons/volumes
- comics contents browser for omnibus / collected editions
- release browser should expose barcode, packaging, format, region, content summary

### Phase 3: Copy separation

- keep copy-only fields out of media list defaults
- add release-level inspector sections separate from copy details
- batch actions should understand the active scope

### Phase 4: Smart rules by kind

- per-kind double-click policy
- per-kind default column presets
- per-kind `contents` vs `releases` priority

## Open Questions

- whether every TV season should be a canonical `Volume` in Core, or whether provider-only seasons can remain ephemeral until ingestion
- whether omnibus membership should be modeled only through `BundleReleaseItem`, or whether collected editions need a first-class `contents` view even without a bundle release
- whether release-level tracking should be separate from media-level tracking or just act as an anchor on the same tracking summary