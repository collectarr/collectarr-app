# Uniform application headers and My Shelf removal

Implemented on 2026-10-11 in `949808cea` using the supplied CLZ Settings screenshot
as the header reference.

## Navigation and presentation

Application pages share one persistent kind-accent bar: navigation menu, a white
kind icon, uppercase `COLLECTARR MUSIC` (or the selected kind title), library
picker, Sync and Settings. Music navigation uses the kind's title; album counts
and Add Albums actions retain the item label.

`AppShell` wraps a shared page navigator. Menu-pushed management pages, routed
settings/calendar/loan/admin pages and full-page item details retain the same
primary bar. Authentication and restoration remain separate entry screens.

`AppPageHeader` supplies the secondary 38px panel-colored row with Back, page
icon and centered title. The navigation content aligns to a 960px container;
page actions do not displace its title. Page-specific tabs appear below this
row. Compact Settings section pages use the same header. Library workspaces
retain their action/filter bars under the primary bar.

My Shelf is removed: drawer action, `/shelf` route, page, private shelf-card and
import-review orchestration, indexed branch bookkeeping and its page tests.
The shared entry repositories continue to serve the library and management
tools. There is no old-route redirect or replacement Shelf screen.

Add Albums from Core first navigates to `/libraries?kind=music`, then opens the
add dialog in the shared page navigator. Closing it leaves the library visible.
Settings, Calendar, Activity and administration navigation carry kind context
in their URLs. Reloading Settings retains the Music header, and Back returns to
the Music library.

## Verification

- Full suite: **853 passed, 1 skipped**.
- Flutter analysis: no issues.
- Architecture checker: no AST boundary violations; 370 informational complexity reports.
- Formatting: 34 changed Dart files checked, zero changes; clean whitespace check.
- Windows debug and Web debug builds succeeded.
- Navigation tests cover desktop/mobile destinations, pushed-page chrome,
  Music versus Albums labels, Core add from Settings, and direct Music Settings
  return routing.

The isolated, populated Web fixture was used for live checks at **1844, 1000,
700 and 380px** across Settings, Statistics, Loan Manager, Calendar, Print to
PDF, Export to CSV/TXT, Import Data, Find Duplicates, Manage Custom Fields,
Cloud Sync & Sharing and Link Albums. Each page retained exactly one Music
brand, navigation button and library picker. No framework exceptions were
captured in the completed run. Settings reload and the Core add destination
were also exercised in the browser; dialog close/return is covered by the
navigation test.

Evidence uses Collectarr's populated reference fixture:

- [Settings desktop](evidence/uniform-application-headers-2026-10-11/settings-1844.png)
- [Calendar at 380px](evidence/uniform-application-headers-2026-10-11/calendar-380.png)
- [Custom fields desktop](evidence/uniform-application-headers-2026-10-11/manage-custom-fields-1844.png)
- [Core add over the Music library](evidence/uniform-application-headers-2026-10-11/core-add-library.png)

This is a header/navigation change. The remaining deeper CLZ feature differences
are tracked in the [populated inspector and management report](music-inspector-management-parity-2026-10-11.md).
