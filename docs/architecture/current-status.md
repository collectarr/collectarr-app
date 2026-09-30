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

## Core catalog state

Core has typed flat Catalog Item routes for all nine kinds. Music's current API,
search query, proposal creation, Admin corrections, worker index, and Admin
reindex path use the concrete `MusicItem` model with contained discs and tracks.
The older Music Release Group and Release ORM graph still exists in Core for
remaining entity-resolution and correction references, so it has not yet been
removed from the fresh database model set.

The other eight kinds still have active Work/Release models and services in
Core alongside their flat Catalog Item APIs. Their flat catalog routes do not
yet replace every existing read, admin, or indexing path.

## App persistence and workspace

The supported Drift schema version is `1`, with no upgrade chain. The current
registered table set still includes the earlier per-kind Work/Release tables;
Music in particular still stores Release Group, Release, Medium, and Track
tables. The Music workspace and Edit dialogs also still expose Release Group
and Release scopes. Other kinds continue using the shared Work/Release/Copy
workspace contracts. These are outstanding cutover work, not compatibility
paths for the new schema.

App-owned state remains separate from Core catalog facts. Owned items,
wishlist, tracking, listening sessions, loans, locations, custom fields,
images, pick lists, and personal sync remain App/Sync responsibilities. The
flattened cutover must preserve those features while moving their references to
Catalog Item or Owned Copy identities.

Music-owned copies created through Add now target the concrete Music Catalog
Item directly. The existing Release Group/Release editor path still has a
release-shaped presentation and must be consolidated before the old Music
graph can be removed.
Music lifecycle tracking records also target the Catalog Item and use the
existing personal Sync contract. Listening history still uses release-shaped
references and remains to be retargeted.

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
