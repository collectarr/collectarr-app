# Typography comparison: Collectarr and CLZ Music

Audit date: 2026-10-15. Collectarr baseline: `36a44c386` (`ui-improvements`).
The tables record the original measurements. The implementation follow-up below
records the corrections made after this audit.

## Method

- Read computed browser styles from the authenticated CLZ Music UI, including every edit tab.
- Capture effective Flutter `Text` and `EditableText` styles from the real Music editor, under the application theme and a real personal edit scope. Use the complete reference fixture and an in-memory database.
- Inspect the application in Playwright with a 1844 x 945 viewport and locally supplied Gilroy faces loaded through the existing font loader. No CLZ font or proprietary asset was downloaded or bundled.
- Distinguish declared weight from the font face actually selected. Compare CSS pixels with Flutter logical pixels, without application zoom.

`size / weight` below means pixels and numeric font weight. The label and input measurements include the Personal tab and the persistent Collection Status / Index / Quantity / Location strip.

## Music edit dialog

| Element | Collectarr, effective style | CLZ, computed style | Finding |
| --- | --- | --- | --- |
| Album / artist header | 18 / 700, line 18 | 18 / 700, line 18 | Matches |
| Main tab strip | 14 / 400, line 20 | 14 / 400, line 20 | Matches |
| Main and Details field labels | 12 / 700, line 20 | 13 / 700, line 18.57 | Our labels are smaller despite a taller line box |
| Personal field labels | 12 / 700 | 13 / 700 | Same shared label discrepancy |
| Persistent footer field labels | 12 / 700 | 13 / 700 | Same discrepancy for all four labels |
| Ordinary input values | 14 / 400, line 20 | 14 / 400, line 20 | Matches |
| Partial-date values | 14 / 400 | 14 / 400 | Matches |
| Artist credit name | 13 / 700 | 14 / 400 | Smaller and genuinely heavier |
| Genre tag values | 14 / 500 | 14 / 400 | Numeric difference; see font-face mapping below |
| Format summary / selected format | 13 / 500 | 14 / 400 | Smaller. Our derived summary and their editable field have different semantics |
| Group legends, e.g. Packaging | 16.8 / 700 | 16.8 / 700 | Matches |
| Track-table column headings | 13 / 700 | 14 / 700 | Smaller |
| Editable disc title / track title / artist / duration | 13 / 400, line 18.57 | 14 / 400, line 20 | Smaller and denser |
| Links URL / Description headings | 11 / 700 | 14 / 700 | Largest table-heading discrepancy |
| Link input values | 14 / 400 | 14 / 400 | Matches |
| Front Cover / Back Cover headings | 14 / 700 | 13 / 700 | Larger |
| Covers Upload / Crop actions | 14 / 700 | 14 / 400 | Heavier |
| My Images main upload invitation | 14 / 400 | 18 / 700 | Smaller and weaker |
| Previous | 14 / 400, line 20 | 14 / 400, line 20 | Matches; checked in the library editor with navigation available |
| Next | 14 / 400, line 20 | 14 / 400, line 20 | Matches |
| Cancel | 14 / 400, line 20 | 14 / 400, line 20 | Matches |
| Save | 14 / 400, line 20 | 14 / 400, line 20 | Matches |

The unified Credits table has no direct CLZ counterpart: CLZ separates People and Classical forms. Our column labels resolve to 14 / 500. Treat consistency with our other table headings separately from parity; do not restore the old role-specific UI.

Propose to Core is an application-specific footer action and resolves to 14 / 700, while the other footer actions use 14 / 400. This is an internal consistency decision, not a measured CLZ counterpart.

## Other panels and shared primitives

| Surface | Comparison |
| --- | --- |
| Shared dialog headers | 18 / 700 matches CLZ management dialogs |
| Secondary page headers and Back | 14 / 700 titles and 14 / 400 Back text match the reference |
| Settings section titles | 22 / 700 matches |
| Import CSV/TXT heading and steps | 22 / 700 heading and 16 / 700 steps match |
| Manage Collections rows | 14 / 400 matches |
| Select Sort Fields / Select Column Fields | 18 / 700 headings and 14 / 700 field choices match. Their search inputs also use 14 / 700; do not change those to the ordinary input role |
| Column Favorites inner pane title | Our pane title uses 14 / 700; CLZ uses an 18 / 700 section heading. The outer dialog header is a separate role |
| Manage Column Favorites names | CLZ uses 14 / 700. Our inactive names use 14 / 600; active names already use 700 |
| Column Favorite field summaries | CLZ uses 12 / 400. Our `bodySmall` resolves to 13 / 400 |
| Shared manager action buttons | CLZ Edit / Close / Merge Mode use 14 / 400. `pickListButtonStyle` uses 14 / 600 for non-footer actions; individual overrides, including Folder Favorites Edit, already use 400 |
| Custom-field chooser names | 14 / 700 matches |
| Custom-field chooser descriptions | Our 12 / 400 is very close to CLZ 11.9 / 400 |
| Custom-field definition labels and Text preview | Explicit 13 / 700 labels, 14 / 400 values and 18 / 700 Preview heading match |
| Custom-field dialog actions | CLZ Cancel / Add use 14 / 400; our custom dialog theme requests 14 / 700 |
| Ordinary dropdown rows | CLZ regular rows use 14 / 400. Our shared menu-row default requests 14 / 500; View overrides it to 400 correctly. Keep intentional 700-weight Group By and field-selection rows distinct |
| Drawer navigation | Ordinary destinations match at 14 / 400. Our selected destination switches to 700; sampled CLZ destinations remain 400 |
| Tooltip | CLZ Settings tooltip is 12 / 400, line 17.14. Our shared tooltip requests 13 / 400 and the wrong family token |
| Statistics | Sampled CLZ section headings are 22 / 700; Music statistics uses the same size for section headings. Cards and chart annotations have separate roles, not one universal heading size |
| Loans, Find Duplicates and batch linking | Main page chrome follows the shared 14 / 700 and 14 / 400 roles. This pass sampled their rendered pages, not every row action or confirmation state |

## Font-face mapping matters

The loaded CLZ faces are CSS weights 400, 700 and 900. Its resource names identify Gilroy Medium, Bold and Black respectively. Thus CLZ `400` means Medium, not Gilroy Regular.

The current Collectarr loader already registers a locally supplied Medium face in its 400 slot and retains Medium in slot 500. Consequently 400 versus 500 can select the same glyph outlines when Gilroy is active. A numeric 500 difference alone is lower priority than a 12-versus-13 pixel difference or using Bold where the reference uses Medium.

The effective-style widget probe runs independently of native font discovery. A separate browser pass used locally installed font files. This audit does not assert the active font of the user's existing native process: its previously supplied VM endpoint was no longer available.

### Tooltip family defect

`buildAppTooltipTheme` uses `kAppFontFamily` (the literal `Gilroy`), while the font loader registers the active faces under a dynamic engine alias returned by `appFontFamily`. The literal family does not select that registered alias. Depending on platform it may select a system face or fall back, explaining a different tooltip appearance even after sharing the theme.

## Main implementation locations

- `lib/features/library/ui/primitives/library_form_controls.dart`: common external labels and group legends.
- `lib/features/library/edit/fields/edit_dialog_widgets.dart`: editor theme and compact controls.
- `lib/features/library/kinds/music/edit/music_album_structure_tabs.dart`: track controls and headings.
- `lib/features/library/edit/fields/library_external_links_table.dart`: Links table headings.
- `lib/features/library/kinds/music/edit/music_album_images_tabs.dart`: Covers actions.
- `lib/features/library/edit/shell/library_edit_scaffold.dart`: editor header and navigation/footer actions.
- `lib/features/settings/custom_field_dialog.dart`: custom-field action button weight.
- `lib/features/pick_lists/widgets/pick_list_chrome.dart`: shared manager action weights.
- `lib/features/library/workspace/table/library_column_chooser.dart`: favorite name and summary styles.
- `lib/ui/theme/theme_primitives.dart`: tooltip family and size.
- `lib/core/fonts/local_font_controller.dart`: local font registration and the Medium-to-400 mapping.

## Boundaries and remaining checks

No catalog records, definitions or favorites were saved in CLZ. Application probes used isolated storage. The normal correctness suite passed alongside the temporary probe, and the populated personal-scope probe also passed separately.

Live measurements cover all ten CLZ edit tabs and the corresponding Music editor surfaces, collections, sorting and column editors/managers, pick lists, custom-field chooser/Text editor/preview, Settings, Import, Statistics, Loans, Duplicates and batch linking. Credits remains a deliberate structural difference.

The reference screenshot operation subsequently blocked the browser connector. Transfer Field Data, Reassign Index, calendar popup typography and all custom-field subtype/validation states are not signed off as live 1:1 comparisons in this report. Do not infer their parity from shared styles alone.

## Implementation follow-up

Applied the measured differences without changing catalog, personal-data or
Credits semantics:

- Common external and compact floating labels now use 13 / 700. External label
  text uses an 18.57 px line inside its existing 20 px alignment slot.
- Artist names, vocabulary chips and derived Format text use 14 / 400.
- Disc-title and track inputs use 14 / 400 with a 20 px line; track, credit and
  Links column headings use 14 / 700.
- Cover headings use 13 / 700, cover actions use 14 / 400, and the image-intake
  invitation uses 18 / 700. Supporting image instructions remain 14 / 400.
- Editor footer actions keep 14 / 400 and explicitly select the active font
  family. Propose to Core now follows the same role. The explicit button styles
  previously omitted the family even when their numeric size and weight matched.
- Column Favorites pane headings use 18 / 700, names 14 / 700 and summaries
  12 / 400. Manager actions, custom-field actions and ordinary menu rows use
  14 / 400. Selected drawer destinations keep their accent with regular text.
- Tooltips use 12 / 400 and the active loader alias, including fallback when no
  user-supplied font is available.

Validation: `flutter analyze` is clean; `dart run tool/run_tests.dart` passed all
932 correctness tests. The footer test also passed separately after adding
assertions for the effective family, size and weight of Previous, Next, Cancel
and Save. The tooltip regression checks that controls and tooltips share the
active family.

Playwright used isolated browser storage and locally supplied fonts to inspect
Main, Tracks, Credits, Covers, My Images, Links, Personal and Custom Fields.
Tracks was also inspected at 1000 x 760; no overflow or runtime exceptions were
observed in those passes. The unverified reference states listed above remain
unverified; this patch does not claim new live measurements for them.
