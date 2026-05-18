# Collectarr App Implementation Plan

App owns the Flutter client, local Drift database, offline-first library UI,
CSV/CLZ import-export, barcode UX, sync client UX, and user-facing collection
workflows. It consumes Core metadata and optional Sync state, but it does not
own the canonical catalog or provider ingestion.

## Done

- Split from the original monorepo into `collectarr/collectarr-app`.
- CI runs Flutter analyze/test.
- Local Drift database stores catalog snapshots, owned items, wishlist rows,
  sync queue data, and user preferences.
- CLZ-style library shell exists with media library top navigation, accent
  colors, resizable panes, view controls, table/grid/card modes, sidebars, and
  inspectors.
- Comics has the richest add/search flow: series/issue/barcode/pull-list modes,
  provider fallback, issue/variant grouping, multi-select, keyboard shortcuts,
  compact bottom bar, and metadata preview.
- Add Comics sends structured provider search context (`series`, issue number,
  and year) to Core so Add Series and Add Issue can follow different server-side
  provider strategies.
- Generic add dialog and generic library workspaces exist for manga, anime,
  books, games, board games, movies, TV, and music.
- Settings includes grouped tabs, auto-save behavior, connection settings,
  account/admin visibility, nav preferences, and reduced-motion control.
- CSV/CLZ import-export wizard supports media-aware headers, media type,
  edition title, physical format, and barcode matching.

## MVP Priorities

1. UI consistency
   - Reuse the same Add shell and bottom bar styling across all libraries.
   - Keep top nav, bottom nav, Shelf, Settings, and Admin entry points themed by
     the active library accent.
   - Make every non-comics library follow the Comics workspace model: toolbar,
     group/filter controls, sidebar, empty state, detail panel, stats chips,
     quick views, and resizable panes.
   - Keep reduced-motion respected by transitions and animated gradients.

2. Provider-backed add/search flows
   - Let Core choose provider routing; App should show provider status but not
     make users choose providers directly.
   - Make Core miss -> provider candidate -> local draft/proposal/ingest job ->
     Core search hit understandable in UI.
   - Keep barcode fallback automatic for physical editions and variants.
   - Ensure provider-unavailable, provider-rate-limited, and auth-required states
     are explicit and non-spammy.

3. Comics MVP polish
   - Make Add Series and Add Issue semantically different: series tree for full
     runs, flat issue list when issue number is required.
   - Improve issue/variant tree density and selection, including whole-series
     selection and multi-issue selection.
   - Verify real cover behavior for GCD + ComicVine variant enrichment and show
     generated fallbacks only when no usable cover exists.
   - Keep list rows compact; rich metadata belongs in the preview pane.

4. Media-specific collection forms
   - Add richer edit/import fields where each media type needs them:
     ISBN/barcode for books, platform/edition for games, physical format for
     movies/TV, release/album fields for music, and publisher/volume fields for
     manga/anime where useful.
   - Preserve local snapshot fields needed for offline browsing without
     rehydrating from Core.

5. Sync and device UX
   - Pairing flow should be clear with copyable code and QR rendering.
   - Conflict panel should show local payload vs service payload with actions:
     keep service, retry local, dismiss.
   - Settings should explain backup/restore responsibilities for local Drift and
     optional Sync SQLite.

6. Platform smoke
   - Web: sqlite3 WASM load, Core connection, Add dialog, import/export, sync
     settings, and covers.
   - Windows: local DB, resizable panes, keyboard shortcuts, barcode manual
     fallback, import/export.
   - Android: camera scanner if available, manual fallback, connection presets,
     layout at narrow widths.

## Post-MVP

- QR scanning for pairing, not just QR rendering.
- ComicInfo.xml/CBZ import/export compatibility.
- Generated thumbnails or local image bytes when App needs fully offline cover
  storage.
- Rich per-media dashboards and collection analytics.
- Packaged release installers and app store/play store preparation.
