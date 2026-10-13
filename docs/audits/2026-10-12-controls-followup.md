# Controls follow-up — 2026-10-12

This records the user's later changes to the chrome/column audit. Headers now
use gradients again; the earlier flat-header requirement is superseded.

## Verified reference behavior

- CLZ's inline Manage control uses `far fa-list`, while the main navigation
  destination uses `far fa-list-alt`. The former is represented by an original
  small SVG of square bullets and horizontal lines; the navigation glyph stays
  unchanged. Both are exposed through AppIcons.
- The folder toolbar uses `justify-content: space-between`: the natural-width
  selector is left aligned and Manage stays at the right edge. The header Manage
  target is 30x30px with a 16px icon and no field-divider border. Integrated form
  buttons retain their 14px glyph and field-edge treatment.
- The bucket coordinator, management dialog, callback wiring and tests are
  retained. No bucket-management functionality was removed.
- CLZ's main navigation uses a 200ms linear horizontal slide. The new navigation
  route uses that motion, with barrier/back dismissal and swipe-to-close. The
  test verifies a 320px drawer is halfway offscreen at 100ms of closing.
- The supplied MHTML defines the range track as 8px, gray `#717171`, rounded,
  with a white 20px thumb. The slider container is 100px wide with 7px horizontal
  inset. Cover size and Item spacing now share this geometry and retain icons.
- Item spacing changes inter-item gaps and table row height. Outer grid padding
  is fixed; shelf item gaps are separate from cover padding.
- Density options are removed from the desktop controls, shared view controls
  and compact organization sheet. The old density preference is neither read
  nor written. Internal geometry profiles remain available to layout code.
- The main Collection Status popup is a flat list with icons and All, with no
  category headings. The editor popup has category headings, text-only entries
  and no All. Both open immediately, matching the reference dropdown behavior.

## Verification

295 generic-library/shared-UI tests passed. After the popup animation adjustment,
11 focused status/picker tests also passed. Flutter analyze has no issues, and
Web and Windows debug builds succeeded.

Playwright exercised both status popups, the editor, navigation open/close and
viewport widths 1844, 1000, 700 and 390px without collected Flutter exceptions
or page errors. It also verified the retained Manage button opens its dialog.
Screenshots were reviewed for the header/control layout, list glyph, gradients,
slider geometry and the two distinct status menus.
