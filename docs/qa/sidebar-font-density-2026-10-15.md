# Sidebar font density investigation

## Why matching CSS numbers was insufficient

The reference declares Gilroy Medium as CSS weight 400 and Gilroy Bold as
CSS weight 700. These declarations were inspected without downloading the font
files. Collectarr's existing local loader uses the supplied SemiBold outlines
for its 400/500 roles and the supplied Bold outlines for 700.

Read-only inspection of the running Windows application's font controller
confirmed that the installed Light, Regular, Medium, SemiBold, Bold, ExtraBold
and Black faces were present, enabled, and registered under the local engine
alias. There was no startup error or open-font fallback.

A temporary isolated Windows Flutter raster probe loaded those user-local
faces with the production loader, using mocked preferences and no database.
Its normal and bold output matched independently registered SemiBold and Bold
faces. The problem was not an accidental Light selection.

## Measurements

Compared the reference's viewport screenshot at DPR 1 and 100% zoom with native
Flutter text rasters at 14 px on `#383838`. For each text crop, summed the
foreground coverage above the background. This measures optical density, not
just advance width or the number of fully white pixels.

| Text | Previous density relative to reference | New density relative to reference |
| --- | ---: | ---: |
| Manage Collections | -5.0% | +4.2% |
| Manage Pick Lists | -6.0% | +3.3% |
| Statistics | -3.3% | +6.1% |
| Settings | -3.4% | +7.3% |
| Find Duplicates | -5.2% | +3.9% |
| Collection header | -12.7% | -0.9% |
| Tools header | -13.3% | -1.2% |
| Customization header | -14.9% | approximately 0% |
| Maintenance header | -14.8% | -1.8% |
| Help header | -12.6% | -1.1% |

The reference and local Medium/Bold advance widths are almost identical;
rendered density is not. The observations establish an optical mismatch between
the web-font/browser path and the local-TTF/Flutter path. They do not establish
which font conversion, hinting or rasterization difference causes it.

## Scoped correction

Use one private drawer text style with weight 700 for entries and 900 for
section headings. Keep 14 px type, 20 px line height, 30 px rows, white entry
labels and the section heading's 40% opacity. This makes entries intentionally
fuller and brings heading density much closer to the reference; it does not
claim exact pixel identity for every label or display.

The correction is local to the drawer. The font loader, other UI typography,
palette and navigation behavior are unchanged. No shadow, stroke or duplicate
text layer simulates heavier type. No paid font is bundled or downloaded.

The local-font probe and its raster files are not part of the shipped test
suite or repository. The normal drawer test checks the two distinct roles and
keeps the existing geometry and color contracts.

## Final checks

The updated drawer test passes through `dart run tool/run_tests.dart`; analyzer
reports no issues. An isolated app browser session with the supplied local
faces produced no page errors or Flutter layout exceptions. In the final widget
screenshot, entry density versus the reference was -0.6% for Manage Collections,
+0.7% for Manage Pick Lists, +0.5% for Find Duplicates and +3.1% for Statistics.
These measurements also show why native and web raster results should not be
treated as identical across renderers.
