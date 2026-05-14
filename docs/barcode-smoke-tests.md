# Barcode Scanner Smoke Tests

Use this checklist before release builds and after scanner/fallback changes. It
covers the parts that cannot be fully validated by widget tests: camera
permissions, real focus/exposure behavior, web browser camera policy, and the
manual fallback path.

## Android Physical Device

Prerequisites:

- metadata API reachable from the phone, usually via the host LAN IP
- sync service optional
- at least one known barcode/UPC in the test catalog
- one unknown barcode for the no-match path

Steps:

1. Install a debug or release APK on a physical Android device.
2. Open Settings and apply the LAN endpoint preset.
3. Edit the metadata and sync hosts to the machine LAN IP, then save.
4. Open the barcode scanner from the add/search flow.
5. Accept the camera permission prompt.
6. Scan a known comic barcode.
7. Confirm the app returns the matching item and can continue into add/own.
8. Scan an unknown barcode.
9. Confirm the no-match state offers manual search/add without losing the
   scanned code.
10. Deny camera permission from Android settings and reopen the scanner.
11. Confirm the scanner shows a recoverable state and manual entry still works.
12. Rotate the device and repeat one successful scan.

Pass criteria:

- camera preview opens without layout overflow
- successful scans trigger exactly one lookup
- manual barcode entry works with camera denied or unavailable
- unknown scans do not enqueue partial collection data
- returning to the library does not leave a stuck loading indicator

## Web Browser

Prerequisites:

- Flutter web served over `localhost`, HTTPS, or another browser-approved camera
  origin
- metadata API CORS configured for the web origin

Steps:

1. Open the web build in Chrome or Edge.
2. Start the barcode scanner.
3. Accept the browser camera permission prompt.
4. Scan a known barcode and confirm the lookup result.
5. Block camera permission in the browser site settings.
6. Reload and start the scanner again.
7. Confirm manual entry is visible and works.
8. Enter a malformed value and confirm validation keeps the user in place.

Pass criteria:

- web camera policy failures do not blank the app
- fallback entry is reachable on desktop and mobile-width web layouts
- validation normalizes UPC/barcode input before lookup
- no private collection data is written until the user confirms the item action

## Regression Notes

Record the device/browser, app build, metadata URL, and scanned barcode values in
the PR or release checklist. If a provider lookup succeeds but the cover is
missing, track it as provider/image-cache behavior, not scanner behavior.
