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
- Multiple listen events are stored against a Music Catalog Item, with an
  optional Owned Copy reference. Derived per-item summaries feed Music stats;
  there is no release-group listening breakdown.
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
- Listening summaries are enriched into typed Music workspace DTO rows and
  consumed by Music stats from the Catalog Item identity.
- The previous monolithic edit runtime has been removed. The unscoped catalog
  editor is a typed Group/Release/Links composition, while structural nodes
  dispatch to their dedicated dialogs.

## Verification

- `flutter analyze --fatal-warnings --fatal-infos`: green.
- Targeted Music/domain/config/UI tests: green (`115` passed, `3` skipped).
- `git diff --check`: required before the final commit.
- Full repository test status is documented in the baseline: `30` unrelated
  UI/fixture failures remain outside this Music implementation slice.
