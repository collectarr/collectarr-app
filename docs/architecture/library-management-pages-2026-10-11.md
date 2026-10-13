# Dedicated library management pages

Find Duplicates and Manage Custom Fields now open dedicated routes from the
drawer. They retain Collectarr's kind accent for actions and selections.
The former duplicate modal and custom-field management dialog entry point are
removed. This supersedes the corresponding modal-layout differences in the
[menu audit](music-menu-audit-2026-10-11.md).

## CLZ reference and duplicate workflow

The logged-in Music application was inspected through Opera DevTools CLI.
Inspection opened search criteria, grouped results, column favorites, the
automatic-removal confirmation, custom-field type/configuration screens and
tab settings. No remote fields, entries or preferences were changed.

The duplicate page provides explicit Find, title/title-and-creator/identifier/
index criteria, grouped tables, expand/collapse, Keep per group, individual
Remove and confirmed automatic removal. Automatic removal preserves the oldest
entry in every matching group. Keep protects the entire group. Overlapping
matches reserve survivors before deduplicating removal candidates, so a record
shared by two groups cannot remove another group's sole survivor.

Table columns come from the kind workspace registry, including canonical
personal values. The shared column chooser supplies search, ordered selection
and saved favorites; this page stores its own ordered column selection per kind.
Removals use the normal local-entry mutation pipeline and refresh the shelf.
Successful removals remain reflected even if a later removal fails.

## Custom-field workflow

The centered management page provides Add, type selection, configuration with
live preview, reorder, Edit and confirmed Delete. CLZ's fifteen observed types
are supported: Text, Text Area, Toggle, Number, Decimal, Currency, Percentage,
Weight, Size, Pick List, Multi Value Pick List, Fixed Button Bar, Fixed List,
Date and Duration. Existing Collectarr URL, contact and time controls remain.

Text is limited to 250 characters; decimal inputs use at most two decimal
places. Weight/size configure units. Dates preserve partial precision and offer
a calendar; duration accepts hours beyond 24. Fixed buttons permit four unique
values, fixed lists twenty. Fixed choices and existing value types are immutable
after creation. Editable pick lists use vocabulary management; multi-value
controls offer dropdown and checkbox presentations.

Tab settings persist a custom name and visibility in edit screens. Pick-list
plural labels and presentation choices also persist. These presentation
preferences live in SharedPreferences; definitions and item values remain in
the database. Definition deletion and reorder are transactional. Reordering a
filtered kind preserves the positions of definitions belonging to other kinds.
Deleting a definition removes its values and presentation preferences.

## Verification

Unit/widget coverage exercises matching criteria, empty identifiers, overlap
protection, oldest-entry selection, Keep, confirmed removal, route navigation,
column chooser resizing, definition CRUD, immutable fixed choices, transactional
reorder, tab preference persistence, partial dates and typed input controls.

The actual debug Web application is exercised with Playwright on disposable
IndexedDB fixtures at 1844, 900 and 480 px. This checks route and dialog sizing,
field creation/edit/reload/deletion, tab naming and duplicate removal. Native
pointer interaction and online Core writes are separate from these local flows.

The final full suite passes **848 tests with one skip**. Analysis reports no
issues; the architecture checker reports no AST violations and 372
informational complexity findings. Windows debug compilation passes.
The live duplicate fixture starts with three entries; renaming one creates a
two-entry title group. Confirmed automatic removal leaves the older entry and
the third unrelated album, and the two-entry shelf survives reload. No Flutter
framework exceptions occur in the corrected live action flows. A first script
attempt inspected an inactive Flutter text-input value and stopped before any
edit; the corrected interaction focuses the visible title field directly.

Evidence: [duplicate results](evidence/library-management-pages-2026-10-11/duplicates-results.png),
[confirmation](evidence/library-management-pages-2026-10-11/duplicates-confirm.png),
[shelf after reload](evidence/library-management-pages-2026-10-11/duplicates-reloaded.png),
[compact columns](evidence/library-management-pages-2026-10-11/columns-compact.png),
[custom-field management](evidence/library-management-pages-2026-10-11/customfields.png)
and [compact unit preview](evidence/library-management-pages-2026-10-11/weight-compact.png).

Presentation preferences are local to the device; this work does not add sync
or backup support for those settings. No canonical Music/Core contract change,
database migration or compatibility layer is introduced.
