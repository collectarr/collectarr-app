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
The separate legacy Movie Edit and local persistence paths still remain.

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
the eight non-Music kinds. Music no longer has a Release Group model, serializer,
edit dialog, workspace projection, or Release browse scope. Its active mapper
turns each flat Music Catalog Item DTO into one root item with contained discs
and tracks. Some Music Dart and Drift symbols still use historical `Release`
names, but those rows now represent the root Catalog Item and do not form a
second catalog level.

Movie's active workspace now projects one concrete Movie Catalog Item and its
Owned Copies, with no Release workspace or drilldown. Catalog Item and Owned
Copy actions now use the shared Edit dialog and separate presentation tabs;
Movie no longer routes Owned Copy editing through the old Media edit dialog.
The older MovieMedia/MovieRelease domain, local tables, and remote source still
exist, so Movie persistence has not completed the cutover.

App-owned state remains separate from Core catalog facts. Owned items,
wishlist, tracking, listening sessions, loans, locations, custom fields,
images, pick lists, and personal sync remain App/Sync responsibilities. The
flattened cutover must preserve those features while moving their references to
Catalog Item or Owned Copy identities.

Catalog transport now writes every Core item into a shared Drift cache keyed
by `(kind, item_id)`. Snapshot reads and batched reference hydration use this
flat cache; current per-kind repositories are still dual-written because
unconverted screens depend on them. Removing those tables requires migrating
the remaining callers first.

Music-owned copies created through Add target the concrete Music Catalog Item
directly and persist only that `catalog_ref`; they do not carry a redundant
`target_ref` alias. The Music workspace's scope selector is hidden because this
kind has no child Release scope. Movie's root workspace also hides the selector,
but its older copy and catalog persistence still use the Work/Release graph.
The remaining App cutover covers Movie persistence and editing, plus the seven
other non-Music kinds' workspace hierarchies and all non-Music Work/Release
storage paths.
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
