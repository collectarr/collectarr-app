# Sidebar, Print to PDF and color roles

Reference: authenticated CLZ Music pages, computed styles and screenshots on
2026-10-15. Application checks use isolated browser storage and user-local fonts.
No reference records were saved or changed.

## Sidebar

- Reference entries use 14 px regular text with a 20 px line; section labels use
  14 px bold white text. Our translucent gray section labels made them appear
  weaker. Labels are now opaque, and entry rows use the measured 30 px geometry.
- Closing used to remove the children before animating the section's height.
  Both directions now retain and clip the content until the transition ends.
  Closing sections stop accepting pointer input. A regression covers closing,
  reopening and reversing the animation midway.
- Libraries is removed from the drawer model and action dispatch. Page Back
  navigation and the library kind selector still provide the existing home flow.

## Shared colors

The dark reference uses these distinct roles, rather than the Music accent for
every highlighted element:

| Role | Measured reference | Application use |
| --- | --- | --- |
| Utility action | `#5EB1DE` | Save, management actions, PDF/export actions, settings |
| Detail heading | `#71AFD9` | Inspector album title and section headings |
| External link | `#06B3F1` | Inspector external links and eBay link |

The palette owns these roles and supplies darker variants for light mode.
Kind identity, library selection and collection-status colors remain separate.
The shared detail-heading API no longer accepts a kind accent; unused forwarding
arguments were also removed. AGENTS.md reflects the revised color preference.

## Print to PDF

- Centered 960 px body, flat panels, selection on the left and stacked
  Columns/Sort summaries on the right; controls stack at narrower widths.
- Reference section headings are 16 px bold. Manage, More settings and ordinary
  controls use 14 px regular; subset/mode choices use 14 px bold and neutral
  selection backgrounds. Column summaries use 12 px regular text.
- Dark form fields use `#444444`, neutral native-style choice controls and the
  blue Generate action. The actual document retains its chosen print font.
- Columns use the shared chooser, including ordering; preview and PDF output
  both honor that order. Sorting uses the shared selection primitives while
  retaining the report's existing single-field sorting semantics.
- Search-controller ownership follows the dialog widget lifetime, including its
  closing animation. Save applies report selections; Cancel discards edits.
- Common page headers and Back explicitly use the active font-loader alias.

## Verification

`flutter analyze` and the architecture boundary checker pass. The correctness
suite passes 934 tests via `dart run tool/run_tests.dart`; this includes the new
motion and report-dialog regressions and the PDF generation test. The editor
footer regression also passed separately after its Save color changed to blue.

Playwright checks cover the drawer's absence of Libraries, closing/opening and
mid-transition reversal; Print, expanded settings, Columns and Sort dialogs;
Cancel; narrow layout at 650 x 900; successful PDF generation; Settings and the
inspector. No runtime or overflow exceptions were observed. Reference snapshots
and comparison screenshots remain private QA artifacts, not bundled assets.
