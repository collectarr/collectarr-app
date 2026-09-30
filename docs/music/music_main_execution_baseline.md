# Music Catalog Flattening Status

This document records the current Music cutover state. The active plan is the
repository's flattened catalog plan; the notes below describe code that still
needs migration and must not be read as a compatibility contract.

## Current boundaries

- Core serves one concrete Music Catalog Item per album edition, with discs
  and tracks contained by that item.
- App manual Add builds the same flat Music item payload and uses the shared
  Add/Edit dialog shell. User proposals contain kind-owned Music catalog data.
- New Music Owned Copies target the Catalog Item directly. Per-disc condition
  and storage placement remain personal copy details; matrix numbers remain
  catalog pressing identifiers shared by copies of the same item.
- App persistence, workspace projections, and catalog editing still contain
  Release Group and Release types. Those structures are not the target model
  and must be removed as each consumer moves to the flat item.
- Music tracking and listening history still use release-shaped references.
  They are App-owned personal activity and must be retargeted to the Catalog
  Item while keeping their existing history and Sync behavior.
- Music's edit surface still has separate Release Group and Release dialogs.
  Consolidate their catalog fields into one item editor without changing the
  visible controls or the separate Owned Copy form.

## Cutover rules

- Treat a concrete album edition as one Catalog Item. It has no parent album
  group or synthetic release child.
- Keep discs, ordered tracks, credits, and external links as Music-owned
  catalog data.
- Keep condition, location, purchase details, notes, per-disc storage, matrix
  runouts, images, and listening history in App-owned personal data.
- Personal Sync continues to carry Owned Copies and personal activity. Core
  Catalog Item data never enters Sync.
- The final App baseline is a fresh schema v1. Old Work/Release databases and
  backups are unsupported; do not add compatibility decoding or upgrade paths.
- Music's field ledger is based on the saved CLZ Music Edit form. Exact CLZ
  parity for the other kinds remains unverified until their Edit captures are
  available.

## Verification policy

Do not claim the Music cutover is complete until active Add/Edit, persistence,
workspace, owned-copy, tracking/listening, backup, export, and personal Sync
paths use the flat Catalog Item identity and no Music Release Group or Release
identity is reachable from the app.
