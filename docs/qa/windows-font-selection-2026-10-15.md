# Windows font selection investigation

## Reproduction

The user reported thinner text even after a clean startup of `deb1f45af`.
This was a code defect, not a failure to restart the app.

A separate native Flutter Windows project imported the production loader,
discovered the complete local family including Light 300, and measured the
same text with both the mixed family and aliases containing one face each.
It did not open the Collectarr database or change its font preferences.

At 14 px, `Vertical Cards` measured:

| Native selection | Width |
| --- | ---: |
| Isolated local Light | 90.902023 |
| Isolated local SemiBold | 91.391983 |
| Previous controller, requested 400 | 90.902023 |
| Previous controller, requested 500 | 90.902023 |
| Corrected controller, requested 400 | 91.391983 |
| Corrected controller, requested 500 | 91.391983 |

Thus the previous loader reported the intended face but actually rendered
Light. Availability and an `activeFamily` value do not prove correct selection.
Earlier six-face probes omitted Light; mocked registration tests inspected
only the numeric OS/2 weight. Neither covered this failure condition.

## Cause and correction

`fontBytesAtWeight` previously changed only OS/2 `usWeightClass`. Copies intended
for slots 400 and 500 retained a `SemiBold` typographic subfamily name (name ID
17). DirectWrite's resulting style classification did not match those slots.
With Light present, normal text selected the lighter face.

Controlled native variants established the cause: changing font identity names
alone did not fix selection; synchronizing subfamily names did. Registration
now updates subfamily IDs 2 and 17 along with the numeric weight, rebuilds the
SFNT directory and checksums, and leaves glyph tables and original user files
unchanged. Other names and format-1 language tags retain their stored values.

The normal UI policy remains local SemiBold, then Medium, then Regular. The
fix makes the native engine select the intended outlines. It does not download
fonts, change UI dimensions, or pretend that equal CSS weights guarantee
identical rasterization between Chromium and Flutter.

## Regression and validation

`integration_test/font_rendering_test.dart` uses bundled OFL Plus Jakarta Sans
faces. It compares isolated SemiBold with normal slots in a family containing
a competing Light face. It needs neither user fonts nor a database.

An isolated checkout ran this native Windows test twice:

- Before the correction: **fails** (expected width 340.759857, actual 333.858002).
- After the correction: **passes**; both normal slots select the intended face.

Windows CI runs this test explicitly; Linux includes it in the native flow
loop. Unit tests also cover subfamily updates, longer names, Unicode/Mac name
encodings, format-1 language tags, alignment, checksums and unchanged originals.

Engine context: Flutter loads dynamic fonts through the platform font manager
and subsequently matches styles within the registered family. See
[Flutter font registration](https://github.com/flutter/engine/blob/main/lib/ui/text/font_collection.cc)
and [Skia DirectWrite font manager](https://github.com/google/skia/blob/main/src/ports/SkFontMgr_win_dw.cpp).
