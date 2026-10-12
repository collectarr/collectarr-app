# CLZ Music comparison after UI boundary cleanup

Audited on 2026-10-12 against Collectarr `81a2c33b7`. This supersedes the
remaining-work table in [the October 11 audit](2026-10-11-clz-mhtml-ui-audit.md).
The architectural cleanup is complete; the visual differences below remain.

## Method and coverage

Opera CLI connected to the authenticated live CLZ Music session. Opened and
cancelled the reference album editor, inspected Main, Details, Tracks,
Personal, Covers, My Images and Links, then opened sort/column field choosers.
Inspected the navigation drawer and Settings. No CLZ album was saved.

Collectarr was exercised in Playwright with the isolated populated reference
collection. Captured the corresponding editor tabs, Credits, navigation,
Settings, list view and field choosers. Widened the inspector to approximately
1080px before comparing its layout; its initially narrow stored width is not
itself a parity defect. Resized the application to 1000px and 700px.

CLZ computed styles and dimensions are runtime evidence. Collectarr style
roles come from Dart plus live screenshots and Flutter semantics geometry;
its canvas rendering cannot be audited by reading CSS on semantics elements.
Network responses also establish which font assets the web build loads.

Local evidence, deliberately excluded from git:

- `%TEMP%/collectarr-browser-compare/parity/post-cleanup-audit/`: fresh CLZ
  computed-style JSON, native Opera editor Main/My Images/columns screenshots,
  Collectarr list/chooser/inspector/responsive screenshots and errors/font log.
- `%TEMP%/collectarr-browser-compare/parity/mhtml-audit/app-*.png`: fresh
  Collectarr common editor tabs, drawer and Settings captures.
- The supplied CLZ MHTML and older assembled archives supplement these states.
  Offline missing images and JavaScript-disabled banners are archive artifacts.

Viewport was 1844 × 945 for the matched library/editor/chooser captures.
Settings was remeasured at that viewport. Opera screenshot calls occasionally
expired; fresh Settings/Covers computed styles are available even where a
fresh native screenshot could not be obtained. Motion durations below are
configured CSS/widget values, not measurements of playback curves.
This pass does not certify every dedicated sidebar page or all write flows.

## Confirmed remaining differences

| Priority | Surface | CLZ | Collectarr / implication |
| --- | --- | --- | --- |
| P0 | Actual web font | Live text resolves to Gilroy; published faces include 400/700/900 | The web build requests Plus Jakarta Sans faces, with no Gilroy asset. `SystemFontLoader` only loads Gilroy on Windows. Browser glyph geometry therefore differs even though `fontFamily` names Gilroy. Verify Windows separately; do not compensate for a different face by globally increasing weight. |
| P0 | Editor input values | Main values are 14px/400 | `editDialogTheme` body roles and `controlText` use 14px/600. Values look heavier; a single increase to all labels cannot fix this. |
| P0 | Editor external labels | Main labels are 13px/700, white, line height 18.56px | `LibraryFormField` uses 12px/700, muted text, a 20px label box. The size, color and baseline differ. |
| P0 | Common edit tab text | 14px/400, 32px tab height | Shared tab label is 13px/700. Backgrounds and height already match, but the text is smaller and heavier. |
| P0 | Collection Status field | Text with a distinct arrow segment; no cyan check in the field value | Ours includes a cyan check, and the arrow shares the value surface. Remove the unintended cyan treatment while retaining kind-accent selection behavior. |
| P1 | Main vertical geometry | Title input y=125.56, height 34; local strip starts around y=435; dialog is 548.38px tall | Our Title input starts around y=128 and is about 32px tall; local strip starts around y=466 and dialog is about 573px tall. Row rhythm and extra space before local fields differ independently of content. |
| P1 | Local field strip | Dark #232323 band distinct from the #383838 editor body | Ours uses raised #383838 with a conspicuous #606060 divider from the editor palette. Local-field padding also differs: CLZ columns start x=337/633/781/929; ours roughly 332/630/787/943. |
| P1 | Main picker buttons | Font Awesome list-style manage glyph and separate compact action segments | Label/Location/Genre manage actions use a different boxed-list glyph; arrows and suffix segment widths differ. |
| P1 | Covers action order and glyphs | Find Online → Upload → Remove; Crop / Rotate uses a pencil/edit silhouette | Ours starts Upload → Find Online and uses Material image-search/upload-outline/crop-rotate glyphs. Restore is an additional Collectarr action and should retain its semantics. |
| P1 | Covers text | Cover labels 13px/700, actions 14px/400 | Own cover labels are larger; toolbar action text is visibly heavier. No outer cover-card border should be reintroduced. |
| P1 | My Images intake | 164×300 tile; instruction 18px/700, #666666; body-colored background | Ours is approximately 166×302 with 14px instruction and a lighter #444444 fill. Existing populated tiles are not evidence of a missing CLZ feature. |
| P1 | My Images helper copy | 14px/400 compact sentence above intake | Ours is heavier and includes different punctuation/spacing. Compare this role separately from the bold intake instruction. |
| P1 | Tracks table typography | Inspected track values/header labels are 14px | Our structure editor still mixes 12/13px labels and 600/700/800 weights. Track/disc models stay kind-owned; normalize table and action roles. |
| P1 | Inspector title and body | Album title 24px/700; ordinary credit/track values commonly 14px/400 | Ours title is 26px/700; credit/track values use heavier roles. Artist 20px/700 already agrees. |
| P1 | Inspector spacing/separators | Compact box-set member table, restrained row separators, details/credits columns at wide panel sizes | Ours has larger box-set spacing, a different member-list treatment and broad section blocks. Compare at matched pane widths. Keep generic Credits and disc-owned recording metadata rather than restoring CLZ's People/Classical model. |
| P1 | Settings organization | Common groups occupy one centered two-column page; first cards begin near y=92 | Ours adds a top category bar and a second appearance tab bar; first cards begin near y=180. Equivalent preferences require more navigation and common settings are less dense. Keep Collectarr-only preferences. |
| P1 | Settings field surfaces/density | Select fill #444444, 34px controls; compact checkbox lines roughly 25px apart | Own selects are almost black (#101010), use floating labels, and checkbox lines are much farther apart. Card/canvas colors already use the matching #383838/#252525 vocabulary. |
| P1 | Column preset-name input | Filled 34px input at the top of the chooser | Ours allocates 34px but the visible decorated input is about 20px high inside it. Match actual field paint/baseline, not only its parent height. |
| P1 | Column chooser grouping | Back/Front Cover live under Images along with Has Back/Has Front | Ours Images has only availability flags; Cover is in Main. This is an exposed-field/organization difference, distinct from intentional Format Summary and reducer field semantics. |
| P2 | Chooser footer and hover | Cancel/Save 14px/400; available rows use declared CSS transitions | Shared own chooser buttons are 14px/600, gray uses #464950, Save text is dark on the accent fill, and available rows use Material InkWell. Selected reorder rows already have the shared 100ms hover treatment. |
| P2 | Spreadsheet typography/top spacing | Header 14px/700; ordinary cells 14px/400; header begins y=114 | Own headers are 14px/800 and cells 14px/500; header begins around y=124. Shell/band heights and top padding account for the visible offset. Borders and fixed headers already work. |
| P2 | Shell background | Flat accent top bar | Ours uses a gradient. Keep Music accent and COLLECTARR MUSIC identity; the gradient is a separate paint choice. |
| P2 | Navigation density/icons | Compact menu rows; Font Awesome action silhouettes | Own rows are about 34px with 500-weight text, versus CLZ's compact 30px/400 role. Drawer background and 320px width agree. Audit equivalent actions individually: extra Admin/Calendar/Core functions are intentional. |
| P2 | Mixed icon systems | Most equivalent controls use Font Awesome Pro silhouettes | Own editor tabs largely match, but Covers, Settings sub-tabs, some search/layout arrows and picker actions mix Material outlines and Font Awesome Free. Links uses a chain icon here versus CLZ's globe. The already-fixed Previous/Next chevrons are not an outstanding item. |

## Motion configuration

| Interaction | CLZ configured behavior | Current Collectarr |
| --- | --- | --- |
| Common edit-tab hover | 250ms | 250ms present; easing trajectory needs a live recording to certify equivalence. |
| Edit-tab drag release | Runtime horizontal sortable: clone helper, axis x, revert 250 | Flutter reorder lift/drop uses 250ms. Equal duration does not establish equal proxy movement or easing. |
| Selected chooser-row hover | 100ms linear transform/background | 100ms linear already present. |
| Chooser-row drop | Runtime sortable revert 100 | Explicit 100ms return now implemented; ours uses easeOutQuad. CLZ's actual interpolation was not measured. |
| Dialog / backdrop fade | CSS opacity 200ms linear / 100ms linear | Shared AppDialogRoute now matches those configured durations; no longer the old 150ms/easeOutQuad route. Not every native popup uses this route. |
| Previous/Next hover | Button transition 250ms | Explicit 250ms treatment now present. Other Material action buttons still require per-surface review. |
| Drawer | CSS slide 200ms linear | Native Scaffold drawer uses Flutter's 246ms behavior. |
| Drawer subsection chevron | CSS 100ms linear | 150ms easeInOut. Section collapse uses 300ms easeInOut; equivalent CLZ content timing was not measured. |
| Inspector cover arrows | CSS opacity transition 100ms | Still needs an equivalent multi-image hover/playback capture; do not call the animation missing based on one static frame. |

## Corrections to previous findings and completed matches

- **Genre is in the right half in the current live CLZ editor**, exactly like
  Collectarr. The previous full-width-row recommendation is withdrawn.
- Edit dialog top is fixed at y=10 and width 1200 in both matched states.
  Outer corners are now 6px; Previous/Next are filled 100×32 with chevrons.
  One-entry disabled buttons are a fixture state, not missing navigation.
- Common tab backgrounds #131313/#383838 and 32px tab height agree.
- Folder background is #383838 in both; darkened modal screenshots are not
  evidence of different underlying folder colors.
- Workspace panel seams and five grip marks remain present. Spreadsheet
  headers are fixed and the 1px dark column boundaries are implemented.
- Kind-accent Save, selections, favorites and caret remain intentional.
  CLZ blue/cyan should not be copied into these roles.
- Credits, disc recording data, derived Format Summary/reducer fields,
  Propose to Core, Restore, the padding slider and application-specific
  preferences remain intentional functionality differences.

## Exception fixed during this audit

After widening the inspector, resizing 1844→1000px produced a horizontal
RenderFlex overflow of 340px. AnimatedSwitcher retained the old right-hand
Row while the new compact layout appeared; its animated pane still used the
previous large width. The corresponding bottom layout had the same risk.

Commit `81a2c33b7` bounds both animated panes using their current available
constraints, including outgoing children. It keeps stored sizes for later
expansion. Regression tests cover both orientation changes and intermediate
frames, and verify that resizing does not persist a smaller preference.

Validation: 11 workspace chrome tests pass; analyzer has no issues; Web debug
and Windows debug builds pass. Playwright repeated the widened-inspector,
list/chooser and 1000/700px resize flow after the fix with no exceptions.
The common editor/sidebar/Settings capture also reported no exceptions.

## Follow-up order

1. Actual font availability per platform, then semantic label/value/tab weights.
2. Common field geometry and local strip; chooser input paint.
3. Inspector row/section spacing and separators at matched widths.
4. Covers/My Images glyphs, intake and action typography.
5. Compact Settings composition, then remaining menu motion/hover differences.

Before declaring full parity, repeat dedicated Manage Collections, duplicate,
custom-field, loan/statistics/transfer/index pages and transactional image
flows. Opening their menu items does not establish their save behavior.
