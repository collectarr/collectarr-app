# Library Workspace Layout

All nine library kinds use `standardMediaWorkspaceViewProfile` as the single source for workspace defaults, view presets, cover sizing, details placement, table column sizing, and initial sort direction. Kind modules provide their workspace schemas and UI policy; they do not build parallel layout profiles.

The standard profile uses a 128 px default cover, a 96–275 px cover range, and bottom details. Cover, Card, List, and Details presets also place details below the collection. Music keeps its square cover ratio through its UI policy, which is an input to the shared profile factory.

`LibraryWorkspaceViewProfile.load()` passes profile values into preference loading. This keeps the first rendered state and the state loaded from storage aligned when a user has no saved preference. Saved choices still take precedence, including moving details to the right.

## Shared collection density

Tables use the same spacing, horizontal margin, and selection rail for every kind. Each kind continues to define its available columns, labels, and values through its workspace schema. Card geometry is provided by the shared card renderer; kind presentations supply opaque semantic facts and optional cover overlays.

Music uses the shared card renderer like the other kinds. Its artist, label, release date, format, track count, and duration are passed as presentation values. Comic and Manga can continue to supply cover overlays for their kind-specific visual information without replacing the shared card layout.

## Favorite migration

Comic uses the same built-in sort and column favorites as the other kinds. When stored pinned favorite IDs are loaded, unavailable built-in IDs are removed and written back. Saved column favorites are retained. This cleans up former Comic-only pins such as `series_issue`, `publisher_date`, `Ownership`, `Value`, and `Full` while preserving user-created presets.
