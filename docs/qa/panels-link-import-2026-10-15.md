# Panels, Core linking and imports

Reference: authenticated CLZ Music Web, inspected read-only on 2026-10-15.
Reference code, fonts and artwork were not copied. Collectarr browser checks
used isolated IndexedDB and fictional album data. User-supplied local fonts were
loaded only into the temporary browser context.

## Measured geometry and states

| Surface | Reference | Collectarr change/check |
| --- | --- | --- |
| Modal top | 30 px | Shared top inset; nested dialogs retain it |
| Back | 30 px high, compact left padding | Rectangular hover, 4 px corners; bounded text |
| Collection trigger | x=3, 30 x 30 px | Anchored overlay, without Material popup's 8 px screen margin |
| Collection menu | 30 px rows, 33 px manage row, 3 px gap above trigger | Geometry assertions; scrolls if height is constrained |
| Collection tabs | 27 px high, 3 px gaps, lower corners rounded | Retained top attachment and corrected gaps |
| Collection privacy | #D43F3A | Matching icon and label; neutral Edit hover and solid trash |
| Utility footer | 100 x 32 px actions, 5 px gap | Shared action style, including editor Save/navigation |
| Blue action hover | Darker than #5EB1DE | Darkened background; no light Material hover overlay |
| Import source cards | #262626 border, square corners, 67 px row, 30 px gap | Source picker and guided upload panels aligned |

Modal panels now use `showAppDialog` or `showAppBottomSheet`. Outside clicks
neither dismiss them nor request a system sound. Menus remain transient and
close outside. Image previews gained explicit Close controls. An architecture
check prevents reintroducing raw Material modal routes.

## Core linking

Replaced the split-list page with a centered 960 px match table, Find matches,
progress, per-row failures, score counts, Accept, manual search and explicit
bulk linking of unambiguous high matches. Search and Cancel never write data.
Linking preserves existing catalog and personal values and changes provenance
through the existing mutation service.

Music owns its score rules: title + artist + nonempty exact barcode are high;
title + artist are medium; other candidates are low. Multiple distinct high
candidates disable bulk linking for that entry. Candidate IDs are deduplicated.
Kind-projected artist/cover values are displayed for local entries; Music
catalog summaries now include the artist.

The table scrolls horizontally on small screens. Widget checks cover desktop
and 390 px layouts. Browser checks exercised manual Search/Cancel and Accept
against the local metadata server in isolated storage. Accept removed the
entry from the unlinked table. Flutter web semantics reported an outdated
vertical coordinate for the table action after dialog dismissal; the browser
check used the action's visible screenshot location instead. Normal pointer
interaction and widget taps were verified separately.

## Import coverage and remaining differences

Inspected every reference destination: CSV/TXT, Discogs, Music Label, CATraxx,
Delicious Library, OrangeCD, CDpedia, Music Collector, CLZ Music Web and the
separate Music Collector user-defined-fields import.

Collectarr's five verified pages were exercised in the browser: CSV/TXT,
Discogs, Delicious Library XML, Music Collector XML and CLZ Music Web XML.
Preview/review and invalid-file handling are retained. No placeholder records
or unimplemented import choices were added.

Still missing: Music Label XML, CATraxx XML, OrangeCD OXL, CDpedia XML and
Delicious Library delimited TXT parsers verified with authentic export
fixtures. The reference's separate user-defined-fields migration depends on
its cloud identity model; Collectarr needs an explicit local identity matching
contract before offering such an update. Existing Music Collector imports
already preserve supported custom values as part of complete record import.

Typography is not certified pixel-identical: native/local font files and web
font rendering can differ. This change does not alter the font loader or
claim that equal CSS/Flutter weight values guarantee equal raster output.

## Validation

- `dart run tool/run_tests.dart -- --timeout=90s`: 1,004 passed.
- `flutter analyze --no-pub`: no issues.
- Browser screenshots: collections dropup/manager/nested name dialog; Back
  hover; all five supported import pages; 390 px import layout; Core match
  table/manual picker and successful explicit linking.
- Silent barrier tests cover dark and transparent dialogs and mobile sheets;
  action tests cover geometry, darker hover and disabled-state precedence.
- No live databases, backups or CLZ records were modified. Browser context
  data and private reference captures remain outside the repository.
