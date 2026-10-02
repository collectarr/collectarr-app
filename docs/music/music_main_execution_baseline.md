# Music Catalog Item Cutover Status

This document records the current App Music implementation. It does not claim
that the nine-kind Catalog Item cutover is complete.

## Active Music path

- Core exposes one flat Music Catalog Item per concrete album edition. Discs,
  ordered tracks, credits, covers, and links are contained catalog data.
- App search and manual Add use the flat kind-owned Music payload. Manual Add
  and Edit share the edit dialog scaffold, and proposals use the same Music
  catalog fields.
- App maps one Music Catalog Item to its root workspace row. The Music Release
  Group model, serializer, dialog, workspace schema, preference codec, and
  Release projection have been removed. The Music scope selector is not shown.
- App-collection items target the concrete Music Catalog Item. Copy condition,
  location, purchase data, notes, personal images, per-copy storage placement,
  and listening activity stay in App-owned storage and Sync.
- Listening events target one Music Catalog Item and may optionally identify
  the Collection Item used.

## Remaining boundaries

- The domain model and Drift table still use some historical `Release` names.
  Each row is the root Catalog Item; there is no separate editable Release
  entity in the Music catalog graph. Rename those symbols only as part of a
  coherent persistence/API update, not as compatibility aliases.
- The generic App workspace still represents root items with its `work` scope
  type because the other eight kinds have not completed the shared cutover.
  Music has no separate Release scope or selector.
- The other eight kinds still have active Work/Release paths in App. Their
  field ledgers remain provisional where CLZ Edit-form captures are missing.

## Field confidence and reset

- The Music field ledger is grounded in the saved CLZ Music Edit form.
- Exact CLZ parity for Anime, Board Game, Book, Comic, Game, Manga, Movie, and
  TV remains unverified pending their Edit-form captures.
- App's final schema is a fresh Drift v1 baseline. Old Work/Release databases
  and backups are unsupported; do not add compatibility decoding or upgrade
  paths.
- Personal Sync carries Collection Items and personal activity only. Core Catalog
  Item data never enters Sync.

## Verification policy

Do not report the coordinated nine-kind cutover complete until every active
Add/Edit, persistence, workspace, Collection Item, backup, export, and Sync path uses
Catalog Item and Collection Item references, and the old graph has no reachable
consumer.
