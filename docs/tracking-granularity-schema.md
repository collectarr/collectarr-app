# Tracking Granularity Schema Proposal

> Historical proposal: this document captures an exploratory tracking design,
> not an active implementation plan. As of 2026-05-31 the app still uses the
> existing summary `TrackingEntry` model, and the shipped in-app library
> registry is `comic`, `book`, `game`, `boardgame`, `movie`, `music`.

> Keep this file as background design context only. If work resumes here,
> re-audit the proposal against the current app/runtime model before treating
> any section below as current direction.

## Problem Statement

`TrackingEntry` is currently a single summary row with optional:

- `rating`
- `status`
- `progressCurrent`
- `progressTotal`
- `seasonNumber`
- `episodeNumber`

That works for simple states like:

- reading chapter 12 of 50
- watched season 2 episode 4

It does not work for:

- mark episode 1, 2, 4 as watched but not 3
- mark a whole season watched while keeping partial progress in another season
- rate an individual season separately from the parent show
- store rewatches or multiple completion passes cleanly

## Target Model

Keep the existing `TrackingEntry` as the aggregate summary row.

Add a granular child table for units of progress.

## Proposed Local App Tables

### `tracking_entries`

Keep current role:

- summary status for an item or anchored release
- top-level rating
- aggregate progress numbers for quick display and search

### New: `tracking_units`

Suggested fields:

- `id`
- `tracking_entry_id`
- `item_id`
- `anchor_type`
- `edition_id`
- `variant_id`
- `bundle_release_id`
- `unit_type` (`season`, `episode`, `volume`, `chapter`, `issue`)
- `parent_unit_key` nullable
- `season_number` nullable
- `episode_number` nullable
- `volume_number` nullable
- `chapter_number` nullable
- `issue_number` nullable
- `status` nullable
- `rating` nullable
- `started_at` nullable
- `finished_at` nullable
- `completed_at` nullable
- `progress_current` nullable
- `progress_total` nullable
- `notes` nullable
- `updated_at`
- `deleted_at` nullable

### Optional later: `tracking_events`

If history becomes first-class, add an append-only events table for:

- started
- resumed
- completed
- rewound
- rated
- status changed

That table is not required for the first granular rollout.

## Why Summary + Units Is Better

- existing UI can keep using the summary row while granular UIs are built incrementally
- filters and badges can stay fast off the summary table
- detailed views can compute season/episode state without overloading one row
- sync can evolve without breaking old clients immediately

## UI Impact

### TV

Add tracking surfaces in this order:

- show summary tracking
- season checklist/progress row
- episode checklist or watched toggles

Desired actions:

- mark episode watched/unwatched
- mark season watched
- set current episode
- set current season + episode

### Comics / Manga / Books

Use the same table with different unit types:

- issue
- chapter
- volume

This keeps the model unified while allowing per-kind UI.

## Sync Impact

The sync protocol currently treats tracking as a single entity row.

To support granular tracking safely:

### Phase A

- keep syncing `TrackingEntry` exactly as today
- add local-only `tracking_units` support behind feature flags
- derive summary fields from units in app only

### Phase B

- introduce synced `tracking_unit` entity type in collectarr-sync
- include tombstones and `updated_at` conflict resolution just like other personal entities
- keep summary row as denormalized companion data for compatibility and search

### Phase C

- let the server or sync layer understand recomputation rules for aggregate summary fields

## Migration Strategy

### App DB

- add `tracking_units` table in Drift
- keep `TrackingEntriesCache` unchanged initially
- backfill no rows at first; existing entries remain valid summaries

### Backfill rules

- if a video summary has `seasonNumber` and `episodeNumber`, create one seed `episode` unit when the user first edits granular progress
- if a book/comic has only summary progress, leave it summary-only until converted by user interaction

This avoids risky synthetic history creation.

## API / Contract Considerations

App-side work can start without immediate Core changes because tracking is personal data.

Core should only be involved where catalog context is needed:

- resolving season lists
- resolving episode lists
- resolving contents for omnibus / bundles

The app already has season and volume endpoints; those should feed the granular tracking UI.

## Recommended Implementation Order

1. Keep `TrackingEntry` as the aggregate row.
2. Add `tracking_units` locally.
3. Build TV season/episode UI on top of `itemSeasonsProvider`.
4. Add `mark watched` / `mark season watched` actions.
5. Derive summary progress from units.
6. Extend sync once the local UX is stable.

## Risks

- duplicating truth between summary and units unless recomputation rules are explicit
- sync conflicts if two devices edit different episodes before `tracking_units` is a first-class synced entity
- ambiguous mappings when provider season data exists but canonical catalog volumes are incomplete

## Recommendation

Do not replace `TrackingEntry` yet.

Add granular tracking as a second layer and let the existing row remain the compatibility and summary surface. That gives the app a path to episode-by-episode and season-by-season tracking without a disruptive rewrite.