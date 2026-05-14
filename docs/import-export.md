# Import And Export Formats

Collectarr keeps its canonical local backup format as Collectarr CSV. The CSV
contains the client-owned shelf snapshot and personal fields that can be synced
through `collectarr-sync`.

## Current Formats

- Collectarr CSV: canonical app backup format for owned and wishlist rows.
- CLZ-friendly CSV: compatibility export/import mapping for common CLZ column
  names.

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
