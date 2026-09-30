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

The other eight kinds still have active Work/Release models and services in
Core alongside their flat Catalog Item APIs. Their flat catalog routes do not
yet replace every existing read, admin, or indexing path.

The App's generic library-detail cache hydration, Admin item refresh, and
metadata comparison now read the flat per-kind Catalog Item detail routes.
Kind-owned Add, workspace hierarchy, and remote-source consumers still call
some of the older Work/Release routes and remain part of the cutover.

## App persistence and workspace

The supported Drift schema version is `1`, with no upgrade chain. The current
registered table set still includes earlier per-kind Work/Release tables for
Comic and TV, alongside
Music-owned image, copy, tracking, and listening tables. Music has no Release
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
flat cache. Anime, Board Game, Book, Game, Manga, Movie, and Music use it as
their only active catalog store. Comic and TV still have per-kind catalog
stores because unconverted screens depend on them. Book, Game, and Manga
catalog facts no longer have per-kind media or release tables; their owned-copy
and tracking data stays in App-owned tables while the broader personal-data
cutover proceeds. Manga's title/number lookup, calendar, series hierarchy, and
Shelf grouping now read the shared cache; chapters remain contained beneath
each volume Catalog Item. Board Game's catalog tables are also removed; Add
lookup, calendar dates, pick-list counts, and offline reads use the cache, while
owned copies and play sessions remain in App-owned tables. Anime's media,
episode, and release tables are removed; the shared cache now holds each Anime
Catalog Item with its contained episode and release data. Owned copies,
tracking, watch sessions, custom episodes, and tracking-unit state remain in
their App-owned tables.
Book calendar events now read each concrete item's release date from this cache
instead of loading a `BookMedia` row from the old per-kind table. The Book
barcode/ISBN lookup also reads root identifiers and contained printing ISBNs
from the cache. The Book workspace now exposes one combined Catalog Item field
and column schema; it no longer registers a separate Release workspace or
fetches nested volumes for browsing. The generic workspace registry still maps
that root through its transitional `work` scope. Book's Edit adapters still
contain legacy `BookMedia` and `BookRelease` models, while owned-copy and
tracking state continue to use separate App-owned tables. The Book field
ledger remains provisional until its Edit-form capture is available.

Music-owned copies created through Add target the concrete Music Catalog Item
directly and persist only that `catalog_ref`; they do not carry a redundant
`target_ref` alias. The Music workspace's scope selector is hidden because this
kind has no child Release scope. Movie's root workspace also hides the selector.
Board Game, Book, Game, Manga, Music, and Movie catalog lookups, summaries, and
offline root reads use the flat Catalog Item cache. The remaining App cutover
covers Music image ownership, Comic/TV per-kind stores, and remaining
Work/Release domain and Edit paths, including legacy Book, Board Game, Game, and
Manga Edit adapters.
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
