# External import verification - 2026-10-15

## Scope and provenance

The branch already had no lib/test tree or root-level stray tests, and Music's
benchmark was outside the correctness suite. Only Music sources were registered;
Goodreads, Calibre, ComicRack and DVD Profiler were not active sources.

Four guided formats now own actual parsers: Discogs Collection CSV, Music
Collector desktop XML, CLZ Music Web XML, and Delicious Library 2 XML plist.
The [manifest](../../test/fixtures/imports/manifest.json) distinguishes observed
XML layouts sanitized with fictional values from documented Discogs CSV headers
with synthetic values. No third-party implementation code or assets were copied.

CATraxx, OrangeCD and CDpedia lacked a verified export fixture, so their metadata
and unused logos were removed from the advertised sources. Delicious TXT is not
presented as supported. Real exports are required before adding those formats.
Unreleased kinds were not re-exposed.

## Behavior checks

- Parser tests cover valid minimal exports, Unicode/entities/quotes/multiline,
  multiple values, absent optional fields, truncated/mismatched files and strict
  invalid records. Track titles cannot become album records.
- Partial XML dates with unknown years retain their precision. Known disc formats
  use explicit Music presets, including DVDr; unknown families are not guessed.
- Parser-to-orchestrator tests use in-memory SQLite, inspect complete saved
  metadata and sync changes, and verify repeat imports preserve local identity.
- UI tests separate source navigation from parsing. File selection produces a
  review before writes; bad files disable import and a replacement clears stale
  errors. Manual CSV requires a Title mapping and explicit confirmation.
- File decoding covers UTF-8 BOM and both UTF-16 BOM byte orders.

## Browser evidence

Playwright ran Collectarr Web with isolated storage. A fresh authenticated CLZ
Music Web export was generated through the reference UI and used only for
read-only preview. All 40 albums parsed. The run exposed actual /MM/DD partial
dates and DVDr values, which were added to the relevant import rules/tests.
A truncated XML produced a zero-record diagnostic; replacing it showed the
sanitized two-album review. Desktop and 640px screens had no Flutter exceptions
or overflows. The mapped CSV review and shared Loan Manager frame were also
checked in the browser. A transient DDC error during an in-flight recompilation
was absent after restarting the owned development server and rerunning both
browser checks with a stable build. The real collection was never imported into live or browser storage.

Screenshots and the original export remain outside the repository. Fixture
values in the repository are fictional. Import remains a supported-field
conversion, not a lossless restoration of third-party artwork, loans and custom
fields. See [current format support](../import-export.md).

## Verification

- `dart run tool/run_tests.dart`: 983 passed; final review-label checks also passed.
- `flutter analyze --no-pub`: no issues.
- `dart run tool/check_library_kind_boundaries.dart`: no AST boundary violations.

The test suite includes a registration contract: each advertised guided
kind/source pair has an importer and fixture manifest. Shared contracts remain
active when kind-specific tests are disabled.
