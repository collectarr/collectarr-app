# Import And Export Formats

Collectarr keeps its canonical local backup format as Collectarr CSV. The CSV
contains the client-owned shelf snapshot and personal fields that can be synced
through `collectarr-sync`.

## Current Formats

- Collectarr CSV: canonical app backup format for owned and wishlist rows. It
  includes `kind` so imports can disambiguate comics, movies, books, games, and
  other media when local catalog matches share a title or barcode. Catalog
  snapshot columns include `edition_title`, `physical_format`, and
  `physical_format_label` so physical video editions and similar release
  variants survive backup, restore, and sync.
- CLZ-friendly CSV: compatibility export/import mapping for common CLZ column
  names. Export headers adapt to the exported media type, for example movie
  exports use Title / Edition no. / Format / Studio / UPC labels instead of
  comic Series / Issue labels. Physical format headers are included for media
  that need edition-level release data.
- TMDB CSV / JSON: import movies and TV shows from TMDB-exported CSV or JSON
  watchlist/ratings files. Entries are parsed with media type separation
  (movies vs TV), enriched via Core's batch hydration endpoint, matched against
  existing catalog snapshots, and imported into the local library.

## Flutter Workflow

The Flutter app exposes a CSV / CLZ wizard from Settings for quick local
backup, CLZ-friendly export, paste-based import preview, and matched-row import.
The Shelf screen keeps the deeper import flow for manual Core search,
unresolved row handling, metadata proposals, and conflict choices.

Import matching prefers explicit item IDs. When no item ID is present, it
matches by barcode and then by title plus item/volume/edition number. If a CSV
row has a media type, matching is scoped to that `kind`. Barcode matching
normalizes punctuation such as spaces, hyphens, and dots so CLZ exports and
scanner values can still resolve to the same local snapshot.

Rows that include a Collectarr item ID plus catalog fields can create or enrich
the local catalog snapshot during import. This is still a local-only write:
importing CSV does not create canonical Core metadata or write personal
collection state to Core.

## ComicRack Compatibility Decision

Decision: support ComicRack-compatible metadata as an optional compatibility
format after the comics MVP, but do not make it the canonical backup format.

Target schema: `ComicInfo.xml` v2.0 as documented by the Anansi Project:
https://anansi-project.github.io/docs/comicinfo/intro

Scope:

- import `ComicInfo.xml` from loose XML files or CBZ archives into the same
  staging model used by CSV import
- export sidecar `ComicInfo.xml` for selected comics
- map Collectarr fields to `Series`, `Number`, `Title`, `Summary`, `Notes`,
  `Publisher`, `Year`, `Month`, `Day`, `GTIN`, `Tags`, and `Web`
- keep personal Collectarr-only fields in Collectarr CSV and sync payloads

Out of scope for MVP:

- rewriting CBZ archives in place
- emulating the full ComicRack database
- treating `ComicInfo.xml` as the source of truth for personal sync

This keeps ComicRack/Kavita/Komga-style interoperability useful without
weakening the offline-first Collectarr data model.
