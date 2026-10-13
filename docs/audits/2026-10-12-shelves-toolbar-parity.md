# Shelves and toolbar comparison — 2026-10-12

Inspected authenticated CLZ Music Shelves in Opera, screenshot and computed DOM/CSS. CLZ uses a warm timber image background with repeated shelf bands. Its View trigger is icon + angle-down, approximately 45.75px wide and 30px high; toolbar content begins directly with View, without a leading separator. The active folder stays in the sidebar rather than gaining a duplicate group chip.

Collectarr now draws its own warm timber backdrop and shelf plank/highlight tones in code. It does not ship CLZ shelf image assets. The texture is an approximation, not a pixel-identical copy. The shared icon-only View/Layout triggers include a chevron and are 46px wide; the secondary toolbar's leading separator is removed.

Group preset chips and selected-group-bucket chips are removed. Inspector hyperlinks retain their dismissible filter chip through an explicit linkedMetadataFilterLabel, separate from selectedBucket. Sidebar grouping, management and bucket coordinators remain intact. The now-unused preset-chip class was deleted; the shared scope chip remains for linked filters.

Validation: focused toolbar/view suite (22 tests) and updated group-versus-linked-filter regression (8 tests in that file); clean analysis; no AST architecture violations (365 unchanged informational complexity reports); Windows and Web debug builds. Private Playwright capture uses fictional Music data, selects Shelves, selects a group bucket (no chip), follows Indie Rock in the inspector (one chip), dismisses it and checks the resulting route. No browser/Flutter exceptions or overflow diagnostics. Visual captures at desktop and responsive widths were compared with the reference.
