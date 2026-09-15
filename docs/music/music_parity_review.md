# Music parity review

Reviewed against the updated Music implementation plan after the typed graph,
entity split, release edit flow, listening history, ownership integrity and
workspace schema work.

## Complete in this checkout

- Release Group -> Release -> Medium -> Track is the canonical catalog graph.
- Owned Music items require a concrete Release target.
- Release Group, Release and Owned Copy workspace schemas are selected by
  structural node/scope.
- Release editing is separate from Group editing and includes independent
  Owned Copies and Release tracking sections.
- Track artist and track headers survive the typed graph, local storage and
  inspector/export paths.
- Per-medium storage and per-side matrix/runout data are retained during copy
  edits, including untouched media entries.
- Multiple listen events and derived Group listening summaries are available;
  Group listening remains read-only.
- Box-set membership is typed, mapped through Core/provider/catalog/local
  boundaries, editable on a Release, visible in the inspector, and groupable
  in the Release workspace.
- Generic item images support front/back plus booklet/disc/label/other roles
  without a second Music image store.
- Manual Add exposes Music release fields including catalog number, barcode,
  date, label, country, format and packaging.

## Partial by design

- Workspace rows still expose one structural `ownedSummary`; quantity remains
  the aggregate for a copy row. The Release editor is the authoritative view
  for enumerating multiple physical copies.
- Async listening aggregates are not injected into generic workspace DTO rows;
  they are queried by the Music inspector where event history is actionable.
- The old combined edit implementation remains as a copy-scoped compatibility
  path. Group and Release nodes dispatch to their dedicated dialogs.

## Verification

- `flutter analyze --fatal-warnings --fatal-infos`: green.
- Targeted Music/domain/config tests: green in the latest run.
- `git diff --check`: required before the final commit.
- Full repository test status is documented in the baseline because unrelated
  UI/fixture failures remain outside this Music implementation slice.
