# CLZ typography alignment

Reference: the saved Music Web MHTML in the local CLZ reference directory.
Its `body.app` uses Gilroy at CSS weight 400; that font-face resolves to Gilroy
Medium. CSS weight 700 resolves to Gilroy Bold. Body and controls are 14px,
external form labels are 13px, and ordinary body line height is 20px at 14px.

Collectarr uses its bundled OFL Collectarr Sans family throughout Shell and
Library. This is a visual approximation, not Gilroy or exact glyph parity.

| Role | Size | Weight |
| --- | --- | --- |
| Body, folders, menu values, controls, table cells | 14px | Medium 500 |
| Supporting text and counters | 13px | Medium 500 |
| External form labels and table headings | 13px | Bold 700 |
| Menu section headings | 14px | Bold 700 |
| Panel titles | 16px | Bold 700 |
| Dialog titles | 18px | Bold 700 |

`app_typography.dart` owns the theme baseline. Role overrides are derived from
the themed text styles, so they retain the bundled font and fallback family.
Tabs, menus, dialog title/content styles, and shell navigation use the same
family. Selected folder rows keep the ordinary Medium face; selection color
provides emphasis. Library UI no longer requests synthetic ExtraBold 800.
Monospace technical/log text and intentionally sized cover graphics retain
their separate roles.

This change aligns typography, not sidebar row geometry, badge placement,
selection colors, or icon artwork. Live pixel comparison remains outstanding.
