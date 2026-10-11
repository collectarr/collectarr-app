# CLZ typography alignment

Live reference: authenticated CLZ Music Web, inspected in Opera on 2026-10-11.
CLZ supplies Gilroy faces at 400, 700 and 900. Common text is 14px with a 20px
line height; actual weights vary by surface. Inspector metadata and contributor
names use stronger emphasis than ordinary form values.

Collectarr bundles the OFL Manrope family at 400/500/600/700/800. The previous
CollectarrSans assets (Montserrat) have been removed, together with their
fallback alias. Manrope is a licensed approximation, not Gilroy or identical
glyph artwork.

Measurements at 14px across ten reference strings gave mean width differences
of 11.06% for the previous Medium face and 2.07% for Manrope Regular. These
measurements inform the choice; they do not imply every glyph or weight matches.

| Role | Size | Weight |
| --- | --- | --- |
| Ordinary body, form values, menu options | 14px | Regular 400 |
| Supporting text | 13px | Regular 400 |
| Panel/menu/dialog headings | 14?22px | Bold 700 |
| Inspector artist | 20px | Bold 700 |
| Inspector album and box set title | 24px | Bold 700 |
| Inspector metadata beside cover | 14px | Bold 700 |

`app_typography.dart` owns the baseline with zero tracking and proportional
figures. Surface overrides retain the same bundled family. Technical logs
retain monospace. Popup menus resolve the library accent before entering an
overlay, so selections and favorites keep the kind color even when the parent
Navigator theme uses cyan. A widget test covers that actual overlay boundary.

Live screenshots were compared at matched inspector widths and with populated
reference metadata. Responsive page checks include 1844, 1000, 700 and 380px.
See the comparison report for the final verification and remaining differences.
