# Populated Music inspector and management comparison

Reviewed on 2026-10-11 against authenticated CLZ Music in Opera and Collectarr's
debug Web build. This is a live interaction comparison, not a claim of complete
pixel or feature identity. Library selections, favorites and Save retain the
Collectarr kind accent, as requested.

## Reference data

The new CLZ record **Collectarr Inspector Reference** (17050856) and the strict
App/Core fixture share populated edition, disc, track, contributor and personal
values. Only this new reference record and its reference values were edited in
CLZ. Original albums were left intact. See the
[reproducible seed instructions](music-inspector-comparison-seed.md).

The local seed was run against the native library and an isolated browser
fixture. Core persistence and strict schema readback were verified against
`collectarr_music_ui_reference`; no existing Core schema was migrated or
reshaped. This does not verify an online Core API transaction.

## Delivered changes

| Surface | Implemented behavior |
| --- | --- |
| Typography | Bundled Manrope with explicit regular/bold hierarchy, zero tracking and closer measured text widths; kind accents survive popup overlays. |
| Inspector | Artist/title/subtitle above the cover; stronger cover metadata; quantity/status/rating; real box-set contents; canonical track order; disc storage/matrices; complete scoped credits and personal values without truncation. |
| Settings | Centered 960px management layout, two-column panels, compact responsive tabs and persistent Appearance controls. |
| Transfer Field Data | Explicit entry scope, preview/reset, typed targets, atomic copy/move and complete sync snapshots. |
| Re-Assign Index Values | Shared sort/favorite selection, explicit scope and atomic sorted reassignment. |
| Loan Manager | Current/History, borrower filter, search, cover/creator/barcode rows, due/returned dates, detail navigation and filtered Unicode PDF export. Kind scope survives route reload. |
| Loan persistence | Create/return/delete queue complete entry snapshots including return dates. Barcode returns also work for local albums without Core cache records. |
| Statistics | Named-collection scope, quantity-aware counts and currency totals, distinct disc-format buckets, played/format pies, artist/genre bars, release-year chart and clickable activity rankings. |

Management canvases use the dark `#252525` shade and raised panels `#383838`.
Compact management workflows preserve a usable search field and wrap actions
below it rather than squeezing the input into the toolbar.

## Live verification

Settings, Statistics, Loan Manager, Transfer Field Data and Re-Assign Index
Values were opened at 1844, 1000, 700 and 380px without captured framework
exceptions. The populated inspector was inspected at matched panel widths and
scrolled through its lower fields. Disabling the back-cover option survived
reload.

Actual browser actions verified that notes copied to tags survive reload;
sorted index reassignment survives reload; returning Alex's loan moves it into
History and preserves Jane's prior return; a Statistics activity row opens the
correct local detail page. These action runs captured no framework errors.

Tests additionally cover transaction rollback, moved custom-field sync data,
responsive loan/statistics layouts, PDF bytes, local barcode returns and
quantity/distinct-format statistics.

Final code gate at `cad946702`:

- 853 tests passed; 1 skipped.
- Flutter analysis: no issues.
- Architecture checker: no AST boundary violations; 375 informational complexity reports.
- Dart formatting: 34 changed files checked, zero changes; `git diff --check` clean.
- Windows debug build and debug Web build succeeded.
- Strict Core fixture validation and persisted canonical-field readback succeeded.

## Remaining differences

- CLZ uses Gilroy. Manrope is a licensed geometric approximation; glyphs,
  wrapping and some weight differences remain. Measurements and chosen roles
  are recorded in [typography alignment](clz-typography-alignment.md).
- CLZ can place Composer above the inspector title; Collectarr keeps the
  canonical artist. Generic credits and recording data retain album/disc
  ownership instead of recreating CLZ's Classical/People or root recording model.
- CLZ's Added/Modified values are generated at edit time; the local fixture uses
  deterministic timestamps. Date presentation and some credit weights differ.
- Settings retain Collectarr's connection/data sections. CLZ-specific
  localization, sort-name/auto-capitalization and marketplace preferences are
  not all reproduced by this change.
- Borrower names, filters and histories work; CLZ's separate borrower contact
  profiles with email/address/sort-name are not implemented.
- Statistics charts display the corresponding values and support tooltips;
  CLZ's finer legend/slice interactions and exact chart geometry remain different.
- CLZ My Images was empty for this reference. The App fixture's additional
  image exercises local storage, not a matched CLZ gallery comparison. Arbitrary
  user custom-field definitions were not fabricated for the reference.
- The native Windows build passed, but the pointer-driven comparison and reload
  action matrix were performed in Web, not on the Windows executable.

## Collectarr evidence

These screenshots contain the original procedural fixture covers and Collectarr
data, without authenticated browser dumps or CLZ account screenshots:

- [Populated inspector](evidence/music-inspector-management-parity-2026-10-11/collectarr-inspector-single-final.png)
- [Lower inspector fields](evidence/music-inspector-management-parity-2026-10-11/collectarr-inspector-fields-3.png)
- [Appearance settings](evidence/music-inspector-management-parity-2026-10-11/collectarr-settings-appearance.png)
- [Statistics](evidence/music-inspector-management-parity-2026-10-11/collectarr-statistics.png)
- [Loan history after reload](evidence/music-inspector-management-parity-2026-10-11/functional-loan-history-reloaded.png)
- [Compact transfer page](evidence/music-inspector-management-parity-2026-10-11/collectarr-transfer-field-data-380.png)
- [Index reassignment after reload](evidence/music-inspector-management-parity-2026-10-11/functional-index-reloaded.png)
