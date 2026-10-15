# Import and export

Music is the released kind. Imports create complete local albums and personal
values; they never publish metadata to Core or infer a Core link from an
external product ID.

## External Music exports

| Source | Accepted export |
| --- | --- |
| Discogs | Collection CSV with Artist, Title and release_id headers |
| Music Collector | Desktop XML: musicinfo / musiclist / music |
| CLZ Music Web | XML: collectorz / data / musicinfo / musiclist / music |
| Delicious Library 2 | XML property list with Music dictionaries |
| Text / CSV | User-mapped columns, with an explicit Title mapping |

Choose a file, inspect the parsed-record preview, then confirm Import. Changing
a file or CSV mapping clears its prepared review. Invalid, empty or truncated
exports report a diagnostic and save nothing. There is no generic XML title
scanner and no invented fallback album.

CSV supports configurable delimiters, quoting and multiple-value delimiters.
UTF-8 BOM and UTF-16 LE/BE BOM files are decoded at the file boundary. Guided CSV
validates quoting, header shape and row width; XML uses the XML parser and
source-specific record paths. Newlines become LF. Title is required per album.

Importers live under each kind's integrations/import folder. A guided source
owns its importer directly. The UI selects files, renders review and invokes
the collection orchestrator; it does not interpret a provider's format.

Music XML imports preserve album edition fields, artist credits, generic role
credits, contained discs/tracks, track composition and supported personal fields.
Recording fields from an external album apply to its imported discs, with
explicit disc values taking precedence. External creator IDs are not Core IDs.
Known format presets assign coarse families; unrecognized format labels fail with a diagnostic instead of guessing a family. Discogs ratings are converted from /5 to Music's /10 scale.

Imports have stable local identities within their source. Reimporting the same
record updates that local entry. XML disc/track IDs are derived from native IDs
when present, so reordering preserves contained identity; exports without child
IDs use their positions. Discogs exports can contain several copies of
one release; those copies keep separate identities. This does not deduplicate
records imported through different sources.

This is not a lossless converter for every field in third-party products. Local
artwork paths, loans and provider-specific custom fields are not automatically
restored by these external importers. Keep the original export. Use Collectarr
CSV with its complete entry payload for Collectarr backups.

## Sources awaiting verified exports

CATraxx XML, OrangeCD OXL and CDpedia XML are not advertised until an actual
export fixture and parser contract are verified. Delicious delimited TXT is also
not accepted. A generic parser is not substituted for these formats. Unreleased
Books/Comics/Movies import sources have not been reintroduced.

## Collectarr backup and export

Collectarr CSV remains the app's backup/interchange format, including complete
local entry metadata and personal state. CLZ-friendly CSV and the CSV/TXT report
export are separate presentation exports. A report with selected columns is not
a complete backup. Import matching and duplicate/conflict review in the existing
Collectarr CSV wizard remain distinct from external guided imports.

## Fixtures and checks

The [fixture manifest](../test/fixtures/imports/manifest.json) records provenance
and the supported kind/source pair. The XML fixtures use observed export layouts
with fictional values. The Discogs fixture uses documented column names and
fictional values; it is not represented as a captured user export.

Parser tests, isolated parser-to-database tests and UI review/confirmation tests
are separate. The registration contract requires an importer and fixture manifest
for every advertised guided source, even when kind-specific tests are disabled.
Run correctness checks with `dart run tool/run_tests.dart`.
