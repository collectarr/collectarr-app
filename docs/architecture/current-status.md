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
Movie Owned Copies no longer store a nested Edition/Release target.

## Core catalog state

Core has typed flat Catalog Item routes for all nine kinds. Music's current API,
search query, proposal creation, Admin corrections, worker index, and Admin
reindex path use the concrete `MusicItem` model with contained discs and tracks.
The old Music Release Group and Release ORM graph has been removed from Core.
Core has also removed the old Work/Release graphs for Movie, Book, Game, Board
Game, Comic, and Manga. Anime and TV still have active Work/Release models and
services alongside their flat Catalog Item APIs.

Core's Admin catalog search, item detail, root-level correction, per-kind item
counts, and search reindex now include flat Catalog Item roots for all nine
kinds. Admin corrections update root fields, normalized identifiers, and Book
credits; structured contents such as discs and episodes remain kind-owned
child data. Other old Core read, diagnostic, and administration paths still
use Work/Release models.

The App's generic library-detail cache hydration, Admin item refresh, and
metadata comparison now read the flat per-kind Catalog Item detail routes.
TV still has active callers for older Core routes. Comic Add now consumes a
flat Catalog Item and no longer calls Core's old Comic Work endpoint to expand
issue and variant children. Comic's App model and editor now represent the
concrete issue or edition directly; its nested release editor, release
workspace, target selection, and release inspector have been removed. Comic
workspace and edit registration still use the shared host's transitional root
`work` scope, but Comic no longer has a separate release scope. Game's obsolete direct
Work/Release API client and mapper have been removed. Its local catalog
model, Add proposal, transport codec, and workspace now project one concrete
Game Catalog Item; no Game Release model or Release workspace remains. The
shared library host still names its generic root scope `work`, so removing that
cross-kind scope terminology remains part of the broader cutover.

## App persistence and workspace

The supported Drift schema version is `1`, with no upgrade chain. The current
registered table set retains App-owned copy, tracking, and session tables for
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
Owned Copies, with no Release workspace or drilldown. Catalog Item and Owned
Copy actions now use the shared Edit dialog and separate presentation tabs;
Movie no longer routes Owned Copy editing through the old Media edit dialog.
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

App-owned state remains separate from Core catalog facts. Owned items,
wishlist, tracking, listening sessions, loans, locations, custom fields,
images, pick lists, and personal sync remain App/Sync responsibilities. The
flattened cutover must preserve those features while moving their references to
Catalog Item or Owned Copy identities.

Catalog transport now writes every Core item into a shared Drift cache keyed
by `(kind, item_id)`. Snapshot reads and batched reference hydration use this
flat cache. Anime, Board Game, Book, Comic, Game, Manga, Movie, and Music use it
as their only active catalog store. TV no longer has per-kind catalog tables;
its typed aggregate and older edit adapters still carry some Work/Release
assumptions that remain to be removed. Book, Game, and Manga
catalog facts no longer have per-kind media or release tables; their owned-copy
and tracking data stays in App-owned tables while the broader personal-data
cutover proceeds. Game's flat workspace combines edition title, platform,
region, publisher, release date, format, barcode, and catalog number on the
Catalog Item. Game Owned Copies persist only a reference to that Catalog Item;
they do not store a nested target. Manga's title/number lookup, calendar, series hierarchy, and
Shelf grouping now read the shared cache; chapters remain contained beneath
each volume Catalog Item. Board Game now maps one flat Catalog Item per
edition. Its Add form has one Catalog Item section, its workspace has no Release
projection, and its owned copies no longer store a nested target reference.
The old `BoardGameMedia`, `BoardGameEdition`, release schema, and split edit
dialogs have been removed. Add lookup, calendar dates, pick-list counts, and
offline reads use the shared cache, while owned copies and play sessions remain
in App-owned tables. The generic host still represents the Catalog Item
through its transitional `work` scope. Anime's media,
episode, and release tables are removed; the shared cache now holds each Anime
Catalog Item with its contained episode and release data. Owned copies,
tracking, watch sessions, custom episodes, and tracking-unit state remain in
their App-owned tables. Comic's media and release tables are also removed;
Comic catalog lookups, summaries, and offline reads use the shared cache while
owned copies, reading progress, and tracking stay in App-owned tables. Its
former `ComicMedia`/`ComicRelease` model split and related edit/workspace
projections are removed; the Comic domain root is now named `ComicCatalogItem`
and carries the direct issue/edition fields.
Book calendar events now read each concrete item's release date from this cache
instead of loading a `BookMedia` row from the old per-kind table. The Book
barcode/ISBN lookup also reads root identifiers and contained printing ISBNs
from the cache. The active flat Book projection retains printings as contained
Catalog Item data and no longer fabricates a Release when the root response has
no nested editions. The Book workspace now exposes one combined Catalog Item
field and column schema; it no longer registers a separate Release workspace or
fetches nested volumes for browsing. Book Add selects the Catalog Item directly
without a nested Edition choice. The generic workspace registry still maps
that root through its transitional `work` scope. Book's Edit adapters still
contain legacy `BookMedia` and `BookRelease` models. Book Owned Copy editing
now routes through the shared Book edit dialog so it can edit App-owned copy
state rather than opening the old `BookMedia` catalog form. The separate Book
Release edit adapter has been removed from the active edit registry and its
dialog implementation deleted. The `BookMedia` catalog model and older
BookRelease schema helpers still remain in the codebase and need to be removed
as the flat Book form and printing editor replace them. Owned-copy and tracking
state continue to use separate App-owned tables. The Book field ledger remains
provisional until its Edit-form capture is available.

Music-owned copies created through Add target the concrete Music Catalog Item
directly and persist only that `catalog_ref`; they do not carry a redundant
`target_ref` alias. The Music workspace's scope selector is hidden because this
kind has no child Release scope. Movie's root workspace also hides the selector.
Board Game, Book, Game, Manga, Music, Movie, and TV catalog lookups, summaries,
and offline root reads use the flat Catalog Item cache. The remaining App
cutover covers Music image ownership and remaining Work/Release domain and Edit
paths, including legacy Book and Manga adapters. Game and Board Game no longer
have per-kind Release domain or Edit adapters, though their Catalog Item roots
still pass through the shared transitional `work` scope.
Music lifecycle tracking records also target the Catalog Item and use the
existing personal Sync contract. Listening history targets the same Catalog
Item, may optionally identify the owned copy used, and now round-trips through
the personal Sync queue as `music_listen_event` records. Local event storage,
edit UI, and workspace statistics use that item identity.

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
