# UI boundary cleanup

Complete the pending editor navigation/motion alignment, then make four
reviewable commits without compatibility wrappers or speculative controllers:

1. Remove confirmed dead mobile/barrel/adaptive APIs and their obsolete tests.
   Keep AppWindowClass and the live AppPageHeader, loading/error and close UI.
2. Make viewport classes, constraint-based form breakpoints, library density
   geometry and shell header heights explicit. Remove kClz runtime aliases;
   retain the user-installed Gilroy detection and bundled fallback. Consolidate
   animation durations and resolve shared UI colors through the active palette.
3. Keep AppShell as composition/state. Extract app bar, declarative drawer
   destinations/rendering and plain action dispatch. Move kind shelf projection
   next to collection projection. Preserve route/back/selection semantics.
4. Remove impossible picker branches; share popup measurement/placement only.
   Keep searchable and free-text controls separate; remove hardcoded dropdown
   colors and obsolete helper files after their consumers have been updated.

Validate each commit with analyzer and relevant tests. Check current editor
and shell visually after meaningful changes; finish with a Windows debug build.
Raw viewport-independent defaults belong to LibraryMetrics; component column
thresholds describe available constraints, not additional device classes.

Stage 1 complete: deleted mobile_ux.dart and ui.dart; removed AdaptiveLayout,
fromConstraints and maybeOf. Kept AppPageHeader after confirming production
consumers. Analyzer clean; 11 adaptive/desktop/mobile navigation checks pass.

Stage 2: shell app bar 40, secondary/drawer header 38 now share named chrome
geometry. AppWindowClass is the viewport authority; unused density breakpoints
are removed, while form constraints retain explicit 560/860 column thresholds.
LibraryMetrics owns the 34px comfortable field default. Runtime kClz aliases
are removed; Gilroy registration is preserved. Named dialog/backdrop/control/
reorder motion contracts coexist with the general animation speed presets.
Analyzer clean; 88 UI/library geometry/navigation checks pass.

Stage 3 complete: AppShell is 154 lines and delegates app bar, declarative
navigation rendering/model and plain action dispatch. Kind shelf aggregation
is now ShelfKindProjection.forKind under collection/projection. Route and modal
classification retains current behavior, including modal XML export. Seven
navigation/metadata/statistics checks pass; analyzer clean; web traversal and
sidebar capture show no app errors.

Stage 4 complete: anchored popup bounds/placement are shared by searchable and
editable selectors, preserving their separate interactions. Bounds exclude
keyboard/safe areas and switch above the anchor when needed. A widget regression
found and fixed follower sizing that previously painted options off-screen.
Removed the impossible suffix branch and app_dropdown_menu.dart after updating
all consumers to palette surface/divider/radius. Picker button height follows
density; chrome actions stay white and popup search carets follow kind accent.

Final verification: 98 UI/navigation/geometry/picker/transfer checks pass, plus
eight focused checks after the final caret change. Analyze is clean; Windows
and web debug builds pass. Live editor/sidebar/settings/transfer popup traversal
reports no captured app exceptions. Architecture scan reports no AST boundary
violations; existing complexity reports remain informational (365 entries).

Palette audit found no direct kAppPanel/kAppSurface/kAppText runtime references
in app/ or ui/ outside palette/theme definitions. Measured editor state colors
and semantic status colors remain deliberate surface/domain contributions.
The existing 6px clipped dialog shell is retained. Edit-tab reorder release uses
Flutter's existing 250ms controller, matching the observed CLZ sortable option.
Scaffold drawer opening retains its native swipe/navigation behavior.
