# Music main execution baseline

Captured from the local checkout before the first implementation package.

- Branch: `main`
- HEAD: `8dc80214ade6de7ceaae0985f079ccdf5cbee36c`
- Working tree: already contained local Music changes in persistence, listening,
  inspector and workspace projection files. Those changes were preserved.
- Dependencies: `flutter pub get --enforce-lockfile` passed.
- Analyzer: `flutter analyze --fatal-warnings --fatal-infos` passed with no issues.
- Targeted Music tests: latest combined Music/domain/config run passed (`81`
  tests).
- Full test suite: not green; the latest full run reported `42` failures and
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

## Remaining work

- Group listening aggregates are derived for the Group inspector; async
  aggregate values are not yet injected into workspace rows or stats.
- The older combined `music_fields.dart` compatibility definitions remain
  internally unused and are a cleanup candidate.
- Track Artist, structural Track Headers and track-level export are now
  present; the final unified edit-session cleanup remains open.

## Implementation progress

Current implementation status: M2-M8, M14-M16, M20-M22 and the relevant
M13/M23 slices are represented in the checkout; the remaining plan phases are
still open.

M1 enforces the Music Copy→Release invariant at typed creation, update and
persistence boundaries, then adds regression coverage. Existing legacy rows
are not silently attached to an arbitrary pressing; migration remains an
explicit follow-up as required by the implementation plan. This baseline now
also records the later Music work packages listed above.
