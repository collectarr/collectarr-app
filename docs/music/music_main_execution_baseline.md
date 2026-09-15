# Music main execution baseline

Updated after the Music implementation checkpoint and the final parity pass.

- Branch: `main`
- HEAD: see the commits in this branch; implementation work is split into a
  checkpoint and focused follow-up commits.
- Working tree: Music changes are committed in the checkpoint and follow-up
  commits; unrelated repository test failures are documented below.
- Dependencies: `flutter pub get --enforce-lockfile` passed.
- Analyzer: `flutter analyze --fatal-warnings --fatal-infos` passed with no issues.
- Targeted Music tests: latest combined Music/domain/config/UI run passed
  (`115` tests, `3` skips).
- Full test suite: not green; the latest full run reported `30` failures and
  `5` skips, mainly broad UI/fixture failures outside the Music slice. The
  Music-targeted run remains green.

## Current boundaries

- Catalog model: `MusicReleaseGroup -> MusicRelease -> MusicMedium -> MusicTrack`.
- Owned model: typed Music copies require a concrete Release target rooted in
  the Release Group; root-only and cross-group targets are rejected.
- Tracking model: `MusicTrackingState` is Release-scoped and unowned; storage
  and sync reject Group/copy targets and preserve separate releases.
- Listening model: typed Music listen events require `releaseId`, retain
  optional owned-copy provenance, support multiple events, and are persisted
  separately from lifecycle tracking.
- Edit flows: Release Group and concrete Release dialogs are separate. Release
  Edit includes tracking and an Owned Copies tab with independent copy CRUD.
- Workspace: Group, Release and Owned Copy schemas are selected structurally by
  node/browser scope; Music Group also exposes genre and release count.
- DTO/projection: Music workspace projection remains concrete and artist,
  barcode/catalog-number and metadata-readiness presentation bugs are fixed.
- Copy integrity: per-disc storage and matrix edits preserve unrelated or
  unknown entries instead of dropping them during save.
- Export: Music inspector track copy/print output includes group, release,
  disc/header, track artist, duration and catalog-number context.
- Box sets: Release membership is typed as an opaque Music relationship with
  position, provider/Core/local round-trip, Release edit, inspector and
  Release workspace grouping.
- Artwork: generic owned-item image storage exposes front/back, booklet, disc,
  label and other roles while preserving captions and order.
- Stats: Music cards include artists, labels, genres, formats and signed-copy
  aggregates without moving Music semantics into generic infrastructure.

## Remaining work

- Group listening aggregates are derived for the Group inspector; async
  aggregate values are not yet injected into workspace rows or stats.
- The shared `music_fields.dart` definitions now back the three typed Music
  workspace schemas; they do not contain edit or copy semantics.
- The previous monolithic Music edit runtime has been removed. The unscoped
  catalog editor is an explicit typed composition of Group, Release and Links;
  structural Group/Release nodes still dispatch to their dedicated dialogs.

## Implementation progress

Current implementation status: the Tier 1 Music graph, ownership, tracking,
listening, per-disc copy integrity, inspector/export and scope-specific
workspace work is represented in the checkout. Tier 2 box-set and artwork
roles are also implemented. The capability matrix and parity review record
the remaining structural limitations explicitly.

M1 enforces the Music Copy→Release invariant at typed creation, update and
persistence boundaries, then adds regression coverage. Existing legacy rows
are not silently attached to an arbitrary pressing; migration remains an
explicit follow-up as required by the implementation plan. This baseline now
also records the later Music work packages listed above.
