# Custom Fields comparison and implementation — 2026-10-12

Reference: the logged-in CLZ Music Custom Fields page, inspected through Opera.
Screenshots, serialized DOM with current form values, computed styles and
DOM/CSS MHTML archives were collected separately for the chooser, all 15 field
types, numeric configuration, all four multi-value controls and tab settings.
The archives are local audit artifacts under `%TEMP%/collectarr-browser-compare/parity/mhtml-audit`.
CLZ archives bundle inspected DOM and reference CSS; they are not native CDP
snapshots. Collectarr screenshots accompany native `Page.captureSnapshot` MHTML
because Flutter paints its controls rather than representing their geometry in CSS.

## Changes

- Original `custom-fields.svg` artwork depicts a pencil over an input field.
  AppIcons owns the asset; navigation and page headers render it with the same
  active/neutral color behavior. No Font Awesome Pro asset is shipped.
- The management page uses the reference-width content area, header divider,
  help/settings actions and compact Add button. Definition rows are 50px with
  drag handle, type icon, name/type text and Edit/Delete actions. Hover uses the
  reference 100ms linear scale/rotation and offset shadow.
- The chooser uses three columns of outlined cards, 15px gaps and the measured
  121/104px row heights. Collectarr's additional Time, URL and Person types are
  retained behind More field types. Hover uses the current kind accent.
- Custom-field dialogs share a 600px maximum width, 30px top inset, 38px header,
  15px content insets and 100x32px footer buttons. Headers retain the requested
  gradient; Save/Add use the kind accent. The dialog theme fixes compact visual
  density shrinking nominal 34px inputs and uses the measured control/preview
  colors, external labels and segmented dropdowns.
- Definitions start with the rich Field Type selector, then Field Name.
  Pick Lists have plural labels; multi-value definitions have Check List,
  Name List, Person List and Tag List plus Separator/List display settings.
- Numeric configuration requires Number/Decimal storage before preview.
  Measured fields then require a unit. The supported canonical unit lists are
  shared by UI and repository validation: g/kg/lb/oz and cm/in/mm. Currency fields
  expose a persisted currency choice, including SGD.
- Fixed values are individual rows with Add/Remove and reorder, rather than
  comma-separated text. Empty, duplicate and excessive choices are rejected;
  values remain locked once the field exists. Existing types hide the disabled
  dropdown arrow.
- Preview is a separate gray surface with an inset form, disposable examples
  and the actual editing controls. It excludes pointer and keyboard interaction,
  does not read/write the database and never becomes a saved field value.
- Toggle and fixed-button fields use flat equal-width segments. Duration uses
  hours/minutes inputs while retaining the existing hours:minutes wire value.
- Tab settings use the same dialog geometry and No/Yes selector. Inspector
  refreshes the tab name, currency presentation and multi-value display after
  settings changes, without restarting the application.

## Reference limits

The CLZ account had no saved custom fields. Existing-field edit appearance was
checked against its inspected CSS, while create/edit/delete, fixed-value locking,
kind scope and persistence were exercised in Collectarr's isolated database tests.
The original glyph, kind accents/gradients, extra field types and local help are
intentional Collectarr choices. This is close visual/behavioral parity, not a
claim of a pixel-identical licensed icon or identical backend data models.

## Verification

- Flutter analyze: no issues.
- Broad settings/shared-UI/generic-library regression run: 351 tests passed.
- Final focused settings/navigation run: 60 tests passed, including clearing a
  corrected configuration error, isolated previews, all supported measured units,
  storage/currency/display preferences and inspector refresh.
- Web and Windows debug builds succeeded.
- Playwright captured all 18 Collectarr types, all four multi-value variants,
  configured numeric fields and tab settings, plus 1000/700/390px layouts. No
  collected Flutter exceptions, overflows or page errors.
- Browser create/edit/delete on an isolated database succeeded. The field kept
  its fixed values while its name changed; deletion left no test field behind.
- The architecture checker reported no AST boundary violations. Existing
  complexity-budget reports remain documented by the checker; this is not a
  claim that the entire repository meets every complexity budget.
- Direct icon inventory regenerated: 1645 occurrences, 445 distinct references,
  332 source files. SVG assets remain separately owned by AppIcons.
