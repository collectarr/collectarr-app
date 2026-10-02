# Current Architecture Status

This document describes the implementation currently present in the repository.
The flattened catalog plan remains in progress; a schema version of `1` does not
mean every feature has completed the catalog cutover.

## Add, edit, and proposals

All nine kind-owned manual Add panes use `LibraryAddManualPaneShell`, which is
built on the same `LibraryEditDialogScaffold` used by Edit. Manual Add retains
the kind's identity fields, schema, vocabulary handling, owned/wishlist/tracking
actions, and proposal action. A manual proposal contains the kind-owned catalog
fields and is submitted to Core for review.

Add search reads Core catalog results. Its result checkmarks select multiple
Core records for batch addition; they are unrelated to search-source selection.
Provider search, preview, and ingest are not part of this Add flow.

Movie manual Add now renders one Catalog Item field section and creates a flat
Movie candidate from the pinned kind contract. It no longer fabricates a
MovieMedia parent with a nested MovieRelease solely to submit a manual item.
Movie's catalog target capability resolves directly to its Catalog Item, and
Movie Collection Items no longer store a nested Edition/Release target.

## Core catalog state

Core has typed flat Catalog Item routes for all nine kinds. Music's current API,
search query, proposal creation, Admin corrections, worker index, and Admin
reindex path use the concrete `MusicItem` model with contained discs and tracks.
The old Music Release Group and Release ORM graph has been removed from Core.
Core has removed the old Work/Release graphs and kind-specific routes for all
nine kinds. TV seasons, media, and episodes remain contained beneath a flat TV
Catalog Item.

Core's Admin catalog search, item detail, root-level correction, per-kind item
counts, and search reindex now include flat Catalog Item roots for all nine
kinds. Admin corrections update root fields, normalized identifiers, and Book
credits; structured contents such as discs and episodes remain kind-owned
child data. Core's active metadata, search, correction, indexing, and Admin
paths operate on flat Catalog Items.

The App's generic library-detail cache hydration, Admin item refresh, and
metadata comparison now read the flat per-kind Catalog Item detail routes.
TV has no remaining calls to its old Core routes. Comic Add now consumes a
flat Catalog Item and no longer calls Core's old Comic Work endpoint to expand
issue and variant children. Comic's App model and editor now represent the
concrete issue or edition directly; its nested release editor, release
workspace, target selection, and release inspector have been removed. Comic
workspace and edit registration use the shared host's `catalog_item` scope.
The registered collection-entry scope is `collection_item`. Workspace nodes
now distinguish `LibraryCatalogItemNodeRef` from
`LibraryCollectionItemNodeRef`; the legacy `LibraryReleaseRef` and some
release-specific edit adapters still remain. Game's obsolete direct
Work/Release API client and mapper have been removed. Its local catalog
model, Add proposal, transport codec, and workspace now project one concrete
Game Catalog Item; no Game Release model or Release workspace remains. The
generic reference types remain a separate part of the active cutover.

## App persistence and workspace

The supported Drift schema version is `1`, with no upgrade chain. The current
registered table set retains App-collection item, tracking, and session tables for
TV alongside Music-owned image, copy, tracking, and listening tables. TV
catalog items and their contained seasons, episodes, and physical contents now
use the shared Catalog Item cache. Music has no Release
Group model, serializer, or Release browse scope.
Its root domain model is `MusicAlbum` with
`MusicAlbumId`; discs and tracks are contained children, while `releaseDate`
remains an edition field. Music catalog reads use the shared Catalog Item
cache; user-owned image and copy state stays in the Music tables.
The Music Main form follows the saved CLZ field grouping and relative widths;
the edit tabs follow the saved CLZ order. Each new owned row represents one
physical copy, so Quantity is derived from the number of copies rather than
entered as a field. Index remains an optional collection-order number.

Movie's active workspace now projects one concrete Movie Catalog Item and its
Collection Items, with no Release workspace or drilldown. Catalog Item and Owned
Copy actions now use the shared Edit dialog and separate presentation tabs;
Movie no longer routes Collection Item editing through the old Media edit dialog.
Movie catalog metadata and manual Add now describe one concrete edition per
Catalog Item; disc rows are contained directly by that item, with no nested
Release or Edition metadata.
The unused Movie catalog repository, remote mapper, per-kind catalog Drift
tables, and MovieMedia/MovieRelease domain and edit-form adapters have been
removed. The workspace schema now composes Catalog Item identity fields and
edition details into one schema. Movie no longer has an editable Work or
Release model.
Movie calendar dates and local barcode/title lookup now read the shared flat
Catalog Item cache instead of querying the old MovieMedia/MovieRelease tables.

App-owned state remains separate from Core catalog facts. Collection items,
wishlist, tracking, listening sessions, loans, locations, custom fields,
images, pick lists, and personal sync remain App/Sync responsibilities. The
flattened cutover must preserve those features while moving their references to
Catalog Item or Collection Item identities.

Each `CollectionItemRef` identifies one user-owned physical item. Duplicating
one creates another collection row with its own personal fields; there is no
quantity field. The generic `CollectionItemSummary` no longer carries a copy of
the catalog title, subtitle, or cover. Mixed hosts obtain display labels and
images from the kind-produced `CatalogDisplaySummary`, while full metadata
remains in that kind's Catalog Item data.

Catalog transport now writes every Core item into a shared Drift cache keyed
by `(kind, item_id)`. Each cache payload has only `id`, `kind`, and
`kind_data`; title, synopsis, dates, covers, and every other catalog field stay
in that owning kind payload. It does not serialize a generic `ref` or Work
entity type. The v1 decoder rejects older envelope aliases rather than
converting them. No shared `common` catalog model or cache section exists.
Core cross-kind Search and barcode results use the same envelope, with each
search projection filtered against that kind's catalog schema. Mixed-kind
labels and covers are transient projections produced by kind codecs and are
never written back as catalog data.
Snapshot reads and batched
reference hydration use this flat cache. Anime, Board Game,
Book, Comic, Game, Manga, Movie, Music, and TV
use it as their only active catalog store. TV's typed workspace and Edit
adapters no longer register a separate Release projection, inspector, or edit
dialog, and the TV detail panel no longer browses sibling releases. The shared
host represents the TV Catalog Item through the `catalog_item` scope; the
legacy release node and kind edit adapters remain to be removed. TV manual
Add emits one flat Catalog Item; every field, including title, synopsis,
cover, and edition date, is decoded as TV-owned data, and an edition release
date is no longer misrepresented as a series first-air date. Book, Game, and Manga
catalog facts no longer have per-kind media or release tables; their collection-item
and tracking data stays in App-owned tables while the broader personal-data
cutover proceeds. Game's flat workspace combines edition title, platform,
region, publisher, release date, format, barcode, and catalog number on the
Catalog Item. Game Collection Items persist only a reference to that Catalog Item;
they do not store a nested target. Manga's title/number lookup, calendar, series hierarchy, and
Shelf grouping now read the shared cache; chapters remain contained beneath
each volume Catalog Item. Board Game now maps one flat Catalog Item per
edition. Its Add form has one Catalog Item section, its workspace has no Release
projection, and its collection items no longer store a nested target reference.
The old `BoardGameMedia`, `BoardGameEdition`, release schema, and split edit
dialogs have been removed. Add lookup, calendar dates, pick-list counts, and
offline reads use the shared cache, while collection items and play sessions remain
in App-owned tables. The generic host represents the Catalog Item through its
`catalog_item` scope. Anime's media, episode, and release
tables are removed; the shared cache now holds each Anime Catalog Item with
its root details and contained episode data. Anime edition fields are stored
directly on the Catalog Item. Anime and Manga now combine their former Release
workspace fields into the root Catalog Item schema, with no active Release
projection or editor. Anime manual Add no longer emits nested editions, and
Manga manual Add stores volume edition details directly on its Catalog Item.
Collection items,
tracking, watch sessions, custom episodes, and tracking-unit state remain in
their App-owned tables. Comic's media and release tables are also removed;
Comic catalog lookups, summaries, and offline reads use the shared cache while
collection items, reading progress, and tracking stay in App-owned tables. Its
former `ComicMedia`/`ComicRelease` model split and related edit/workspace
projections are removed; the Comic domain root is now named `ComicCatalogItem`
and carries the direct issue/edition fields.
Book calendar events and barcode/ISBN lookup read the shared Catalog Item cache;
printings remain contained by their parent item. The Book workspace and Add/Edit
forms operate on one `BookCatalogItem` root, with no BookMedia/BookRelease model
or separate Release workspace in the active Book code. Field-spec builder names
now describe Catalog Item identity, publication history, and edition fields
instead of implying Work/Release nodes. Owned-copy and tracking state remain in
App-owned tables. The Book field ledger remains provisional until its Edit-form
capture is available. The generic host uses the `catalog_item` scope for this root.

Music-collection items created through Add target the concrete Music Catalog Item
directly and persist only that `catalog_ref`; they do not carry a redundant
`target_ref` alias. The Music workspace's scope selector is hidden because this
kind has no child Release scope. Movie's root workspace also hides the selector.
Anime, Book, Manga, TV, and Comic collection rows also persist only their
Catalog Item reference. Their former `target_ref` duplicate has been removed
from the domain models, local tables, and edit payloads; episode and chapter
tracking still retains its own real catalog targets.
Add and duplicate commands now create a distinct Collection Item ID for each
physical copy and accept only its concrete Catalog Item reference. Duplicating
an entry copies its personal values into a new row, so copies can be edited
independently without a quantity field or a release-level anchor.
Board Game, Book, Game, Manga, Music, Movie, and TV catalog lookups, summaries,
and offline root reads use the flat Catalog Item cache. The remaining App
cutover covers Music image ownership and remaining Work/Release domain and Edit
paths, including legacy Book and Manga adapters. Game and Board Game no longer
have per-kind Release domain or Edit adapters; their Catalog Item roots use the
shared `catalog_item` scope.
Music lifecycle tracking records also target the Catalog Item and use the
existing personal Sync contract. Listening history targets the same Catalog
Item, may optionally identify the collection item used, and now round-trips through
the personal Sync queue as `music_listen_event` records. Local event storage,
edit UI, and workspace statistics use that item identity.
The Sync v1 wire contract identifies Catalog Items and one-copy collection
entries independently with `{kind, id}` references. The collection entry's
`catalog_ref` points to its shared Core metadata. The App queue canonicalizes
current kind-owned payloads at enqueue time, while Sync apply still adapts
Catalog Item references into the generic workspace node wrappers. Replacing
those wrappers with direct Catalog Item and Collection Item refs is part of the
active workspace and personal-data cutover.

Smart List criteria now identify `catalog_item` or `collection_item` directly with
an `entity_type` field. Sort tokens use the same target identity, and criteria
using the former `entity_scope` field are rejected rather than decoded through
a compatibility path. The active generic workspace now uses explicit
`catalog_item` and `collection_item` scopes, while its internal node types and
some kind edit adapters still retain the earlier hierarchy.

## Contracts and field confidence

The pinned Catalog Item contract is version `1` and is checked against the
generated App field projection. Keep the nine kind field ledgers as the source
for field ownership and names. Music is grounded in the saved CLZ Music Edit
form. Exact CLZ parity for the other eight kinds remains unverified until their
Edit-form captures are available.

## Visual reference

The pre-cutover App revision
`6949fb4f00e6fdd5828e21474b74fa448e793fe9` remains the visual reference for
colors, spacing, controls, navigation, and workspace behavior while data
references are flattened.
