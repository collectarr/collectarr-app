# UI reference follow-up

## Changes

- The local font loader and its native weight mapping are unchanged. Editor and
  Settings typography corrections are listed in the typography audit.
- Input focus, caret, text selection and folder/item selection use shared blue.
  Kind accents remain in library chrome and identity. Collection statuses have
  fixed colors; In Collection uses the measured #2AA4CC rather than Music orange.
- All themed surfaces share the editor's inverse tooltip appearance, active
  font family, spacing and delay. Cover Size and Item Spacing icons use white.
- Hover no longer enlarges covers or adds an accent glow. Selected rows/cards
  retain their blue fill while hovered; card clicks do not add a Material ripple. Edit controls align to the outer card's right
  edge; vertical-card selection sits at the top left, horizontal-card selection
  at the bottom left. Card selection controls integrate with the active blue
  background. Cover/Shelves keep their separate bottom-left selection control.
- Cards keep kind-owned presentation values: title, artist, year, format and
  count/duration details where that representation exposes them. No removed
  missing-metadata or entry badges were reintroduced. Flow Carousel is an App
  view, with no CLZ counterpart; its focus arrangement remains intact.
- The collection bar measures 33 px, including its 3 px top band, matching the
  reference. Tabs retain their 27 px height and attach to that band.
- Music format pies use the measured fixed red-to-green sequence. Played uses
  fixed red/blue by label, so ranking cannot change the meaning of a color.
- Export CSV/TXT uses a centered 960 px body, flat option panels, quarter-width
  file tabs, a joined Settings/Preview surface and matching text roles. Its
  column and sort choosers use the same field-selection primitives as Print.
  Export supports ordered multi-field sorts, direction changes and cancellation.
  Workspace-backed sort options respect field metadata; many-valued Disc Format
  and credit fields remain exportable without becoming implicit sort reducers.
  Artist Credits is labeled separately from the scalar Artist summary.
  Preview and generated output preserve the selected column order. Current List
  is disabled when it contains exactly the All Albums selection.
- Pre-fill uses two-column fields, common external labels, the adjacent today
  option, a right-aligned Clear All action and a 150x40 primary confirmation.
  Condition remains available; additional tags/currency can be expanded. App
  listening is event-based and is not replaced by CLZ's Played boolean.

## Reference inspection

Live CLZ inspection covered List, Vertical Cards, Horizontal Cards, Covers,
Shelves, the status selector, Pre-fill, Export and Statistics. Computed geometry,
text roles, rendered colors and the chart datasets were measured. No reference
code, font bytes or proprietary artwork were copied. Reference editors were
closed without saving.

The isolated Collectarr browser fixture contains one Music entry with two discs.
Different item counts, cover-size preferences, artwork and domain structures
mean that these checks do not establish full pixel identity of whole pages.
Populated reference Custom Fields and My Images remain outside this signoff.

## Verification

- Correctness runner: 949 tests pass, including export multi-sort/cancel,
  anchored-calendar bounds/select/dismiss, fixed status colors, cover hover
  geometry and Pre-fill persistence.
- Analyzer: no issues.
- Isolated Playwright: every editor tab, narrow Tracks, Settings Appearance and
  local-font fallback; all six browsing views in normal/hover states; Export
  CSV/TXT and Pre-fill at desktop and 640 px width. No exceptions or overflows
  in the completed browser pass. Both report choosers and Music Statistics were
  also captured. Focused checks after the final changes pass.
- Test and browser storage are isolated. Live databases and backups are untouched.
