# Typography follow-up after native font selection fix

Baseline: `052b51d28`. Scope: the Music editor's complete tab set, contained
disc/track controls, common popups/managers and Settings sections.

## QA inventory

- Editor: Main, Details/General, disc Details, Credits, Tracks, Personal,
  Custom Fields, Covers, My Images and Links; persistent header, tabs and footer.
- Nested controls: vocabulary picker, calendar, Collection Status, track bulk
  actions, credit role/scope, online covers and populated custom-field types.
- Other surfaces: view/sort/column/group controls, their favorites managers,
  collections, pick lists, custom-field setup and Settings tabs.
- For each surface record effective size, requested weight, line height,
  spacing, color and engine family. Verify registered face selection separately
  from declared weight. Do not infer visual equality from equal CSS numbers.
- Inspect populated/empty states and a narrower viewport. Check incomplete
  local families and disabled local fonts separately from full-family rendering.
- CLZ interactions are read-only; close editors without saving. Application
  probes use isolated storage and user-local fonts only.

Results are recorded below as checks finish. An unchecked surface is not a
claim of parity.

## Method and coverage

Fresh computed styles were collected from all ten CLZ editor tabs, its calendar
and Settings. Collectarr's effective RenderParagraph/EditableText styles were
captured from the populated mixed-disc fixture under the actual local font
controller, including all seven installed weights (Light included). The probe
used an in-memory database and mocked preferences. It collected 1,036 text
samples across 24 states. Icon font spans are not treated as body text defects.

The preceding native Windows regression proves the registration mapping with
Light present; equal requested weights alone still do not prove pixel parity.
The reference uses Medium in CSS slot 400; Collectarr intentionally uses local
SemiBold outlines in its normal slots. Numbers below are requested UI weights.

| Editor surface | Confirmed matches | Remaining differences |
| --- | --- | --- |
| Shared header, tabs and footer | Header 18/700; tabs and Previous/Next/Cancel/Save 14/400; active local family | Inactive tab text is #C8C8C8 instead of reference white |
| Main | Labels 13/700; values and date parts 14/400 | Labels #B8B8B8 instead of white, including persistent footer labels |
| Details / General | Group legend 16.8/700; normal field roles | Additional General/disc subtab controls are 13 px, with 700 selected / 500 inactive; Add Disc is 14/700. The reference's disc navigation/action role is 14/400, in Tracks. These are different layout compositions |
| Disc Details: Vinyl, CD, FLAC | Inputs 14/400, labels 13/700; correct family across recording and personal fields | Same muted labels. Studio/Live and RPM button bars are 14/700; they are App controls, not equivalent reference widgets |
| Credits | Table headings 14/700; values 14/400; correct active family | Add credit inherits 14/700. No direct 1:1 Credits tab exists in CLZ; People/Classical remain intentional structural differences |
| Tracks / selected tracks | Disc labels 14/500, headers 14/700, inputs and Add Disc/Header/Track 14/400 | Track position is 13/700 versus reference 14/700; selection count is a compact 12/700. Current local 400/500 aliases select identical outlines |
| Personal | Ordinary labels 13/700 and values 14/400 | Played History legend is 16.8/700 versus 13/700; rating counter 12/400 versus reference's 13/700 label; Mark as listened inherits 14/700. Labels are muted instead of white |
| Custom Fields | All 18 local field types inspected; ordinary external labels 13/700, values 14/400 | Time's floating label is 14/700 while other labels are 13/700. Pick time inherits 14/700. Reference album has no active custom fields, so all subtype states are not signed off against live CLZ |
| Covers | Headings 13/700, actions 14/400, correct family | Local empty and reference populated covers are different states; disabled-action contrast must not be called a font defect |
| My Images: empty / populated | Empty invitation 18/700, helper 14/400; populated Description/Image Type 13/700 and values 14/400 | Reference has no personal image to compare the populated state 1:1 |
| Links | Column headings 14/700, values 14/400; correct family | Add Link is 14/700 versus reference New Link 14/400. App has an additional Name column |

## Other confirmed differences

| Surface | Collectarr | CLZ reference |
| --- | --- | --- |
| Calendar month title | 14/500, muted | 14/700, white |
| Calendar weekdays | 14/600, muted | 14/700, blue |
| Calendar days | 14/700 | 14/400 |
| Calendar layout/header | Separate modal with 28/700 selected-date header and Cancel/OK | Compact anchored calendar with 14/700 month header |
| Settings dropdown values | 16/700 | 14/400 |
| Settings dropdown labels | 16/400 | 14/700 |
| Settings customization/eBay checkbox captions | 13/400 | 14/400 |
| Settings Covers & layout captions | 16/400 | Most are App-specific options; internally inconsistent with the 13 px captions above |
| View menu rows | 14/400 | 14/400; no new family-selection defect found |
| Layout menu selected row | 14/700 | 14/400 |
| Layout menu other rows | 14/500 | 14/400; identical outlines locally today, different requested semantic weight |

Settings section headings are 22/700 in both applications. Appearance category
tabs and Typography management controls have no direct CLZ equivalents.

## Loading defects corrected during this audit

Explicit ButtonStyle text overrides replaced inherited text styles and omitted
the active font family. Rendered paragraph styles confirmed the omission in:

- Generic dialog Cancel/Save.
- Add outlined/filled action styles.
- Add to Collection and workspace Add Albums.
- Calendar Cancel/OK (also missing explicit text size).

These now retain the active family/fallback and their existing text roles.
Calendar actions use 14/400, consistent with other dialog actions. The same
incomplete override was corrected in Add mode actions and selection-toolbar
actions. Plain editor popup items now use the complete shared popup text style
rather than a color-only override. Widget regressions check the effective
rendered text, not just theme declarations.

No global weight increase or size change was applied to the remaining visual
differences listed above. White versus muted labels is a contrast discrepancy,
not evidence of another font-face loading failure.

## Fixture correction

The mixed comparison fixture assigned a matrix number to its digital FLAC
disc, which strict Music validation rejects. That invalid field was removed
and a fixture-decoding regression added. No live database or backup was changed.

## Verification

- `dart run tool/run_tests.dart`: all 946 correctness tests pass after removing
  the temporary machine-local audit probe.
- `dart analyze`: no issues.
- The populated widget probe confirms all six audited shared action labels
  and calendar actions now select the active local alias with explicit sizes.
- Playwright checks use separate browser storage containing all seven
  user-local faces. All nine editor tabs, the date picker and Tracks at
  1000x760 were captured; Appearance's four subtab states were also captured.
- Disabling local fonts in Typography switches to Plus Jakarta Sans; enabling
  them again restores local fonts without page or layout exceptions in that
  browser pass.
- Production fixes: `e9d1c8f1f` (action text family), `853e0b39` (strict fixture).

The remaining table entries are findings, not changes already applied. The next
visual pass should prioritize label/tab contrast, Settings control roles and
the calendar, rather than increasing the global font weight again.

## Limits

Custom-field subtype reference previews, populated reference My Images, every
favorites-manager state and unrelated App-only Settings pages were not freshly
compared in this pass. Prior audit data does not turn these into new signoffs.
Native font selection was checked by the preceding native regression; this
pass's complete UI captures use isolated Flutter web and widget probes.
