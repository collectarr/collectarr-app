# Help navigation and drawer review

Reference: the signed-in CLZ Music Web navigation menu, inspected through its
visible UI and computed presentation values on 2026-10-15. No reference code,
fonts or proprietary icon assets were imported.

## Destinations

Help lists Manual, Community, Contact Support and What's New? in that order.
Collectarr's Keyboard Shortcuts follows them. Calendar remains available under
Tools. All four external destinations preserve the current library route.

- Manual retains the active kind's chapter in the shared manual.
- Community opens `collectarr/collectarr-app` GitHub Discussions, enabled with
  Q&A, Ideas, Announcements and Show and tell categories.
- Contact Support opens the website support guide, with public Q&A and
  App/Core/Sync issue tracker links. It does not promise private email support.
- What's New? checks the installed package version's `v<version>` release.
  Build numbers are excluded. Missing/unverified releases, development versions
  and unavailable GitHub responses fall back to `/releases/latest`.

The updater and Help share repository coordinates under core configuration.
The issue chooser also links to community Q&A and the manual.

## Drawer presentation

- Background: `#383838` in dark mode.
- Option labels: 14 px, 20 px line height, white. The reference declares CSS
  weight 400; the drawer uses Flutter weight 700 after optical calibration.
- Section labels: 14 px, 20 px line height; the reference's white
  at 40% opacity explains its muted appearance. Chevrons use the same tone.
- Rows and headers: 30 px tall. Remove the extra initial 6 px padding.
- Icons: 14 px within a 17.5 px slot; align the labels with the reference's
  icon margins and text spacing.
- Manual uses a solid document-with-lines icon. What's New? uses a solid
  question circle; support uses an envelope. Community uses an independently
  drawn SVG with two outlined square conversation bubbles.
- Find Duplicates, Loan Manager and Clear Database use the reference's solid
  rather than outline icon styles.

The CSS weight values initially matched, but a subsequent native raster review
showed that this did not match optical density. Sections now use weight 900 in
the drawer. See [the density investigation](sidebar-font-density-2026-10-15.md).
No global weight remapping was introduced. Visual review used only the user's
locally supplied font faces; devices without them retain the open-font fallback.

## Verification

- All 995 correctness tests passed through `dart run tool/run_tests.dart`.
- Focused Help/drawer checks cover link ordering, action dispatch, 30 px header
  geometry, header opacity, installed release/build handling and API failures.
- Analyzer reports no issues.
- Isolated browser checks at 1844 x 945 and 390 x 844: all four destinations
  open correctly, Help collapses and expands, no Flutter/page exceptions.
- The installed 1.0.0 build opened `/releases/tag/v1.0.0` in the browser.
- The website production build and local-link checks passed; support is deployed.

Screenshots and temporary font state stay outside the repository.
