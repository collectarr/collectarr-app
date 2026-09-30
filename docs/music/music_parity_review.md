# Music Catalog Item parity review

This review describes the flattened App Music path. The field-level CLZ
decisions are recorded in [music-catalog-field-inventory.md](../architecture/music-catalog-field-inventory.md).

## Implemented

- Search and manual Add represent one concrete album edition as one Music
  Catalog Item. Search results do not expose a parent album group or nested
  selectable release list.
- Manual Add and Edit share the edit dialog scaffold. The Music editor presents
  the album title and artist in its header and keeps its kind-owned fields,
  vocabulary controls, credits, discs, tracks, covers, personal images, and
  links in Music tabs.
- The App mapper, local repository, and workspace project one Catalog Item with
  contained disc and track data. There is no Music Release Group model or
  separate Release workspace scope.
- Copy-specific condition, purchase details, location, notes, personal images,
  and per-copy storage placement remain in Owned Copy data. Listening events
  target the Catalog Item and can optionally name the copy used.
- Matrix numbers on catalog discs are shared pressing data; observed matrix
  runouts and storage placement on an individual physical copy remain personal
  Owned Copy details.

## Remaining naming and cutover work

- Some App domain and Drift identifiers retain historical `Release` names even
  though the row represents the root Music Catalog Item. They do not create a
  separate catalog level. A rename must update the local schema and all direct
  callers together.
- The generic workspace still calls the root scope `work` for the eight kinds
  that retain Work/Release. Music has no Release scope selector; the broader
  shared scope contract remains until those kinds are cut over.
- The coordinated nine-kind cutover is still in progress. Do not infer its
  completion from the Music-only flattening.

## Verification

The implementation was statically analyzed during this change. No Flutter or
Dart test suite was run.
