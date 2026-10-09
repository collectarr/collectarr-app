# CLZ UI and collection parity

Requested scope: working online cover search; artist/title/barcode query tokens
and real image dimensions; uniform field height and typography; responsive
alphabet; aligned generic credits; real collections instead of saved views.

## Commit stages

1. Fix online cover decoding and add the query controls and image dimensions.
2. Align shared input geometry, bundled typography, Credits and A–Z behavior.
3. Introduce durable kind-owned collections and exclusive entry membership.
   Add create/rename/reorder/delete, counts, tab selection, destination picking,
   bulk moves and add-to-active-collection. Remove the collection mode from
   Smart Lists; never reinterpret saved criteria as membership.
4. Verify repository and widget semantics, architecture checks, analyzer,
   Windows debug build and real browser flows. Record remaining limits.

Collections are local library organization. Catalog data and Core corrections
do not own membership. Removing a collection moves its entries to a chosen
surviving collection; it never deletes the entries. Public publishing requires
an actual sharing service and is not represented by a cosmetic Public toggle.

## Completed implementation

- Online search explicitly decodes Apple's `text/javascript` JSON. The picker
  offers artist/title/barcode query tokens, manual queries, real decoded image
  dimensions, responsive tiles and request ordering. Barcode queries use
  MusicBrainz releases and Cover Art Archive originals over HTTPS.
- Shared controls use the bundled font, consistent weights, equal minimum
  border heights and centered carets. Credits has one header per column and
  accommodates wrapped instruments. Narrow toolbars expose the complete A-Z
  menu instead of clipping letters.
- Collections have durable IDs, ordered names, a persisted active selection
  per kind, and exclusive library-entry membership. New entries use the active
  destination; editing an existing entry preserves its membership. Transfers
  validate every entry and commit atomically. Counts and projections respect
  membership before search, filters and grouping.
- The bottom tab strip and Manage Collections support create, rename, reorder,
  select and delete with an explicit transfer destination. Single and selected
  batch entries can move through the item context menu. Smart Lists remain
  advanced saved criteria and no longer impersonate collections.
- Local image reads now observe DB changes, expire when their widgets leave,
  and take precedence over remote catalog artwork. Shelf overlays include
  stored images, so cover badges, grouping and Music cover statistics agree
  with the visible cover. Removed the unused front-cover provider alias.

## Verification

The full Flutter suite passed: 798 tests, one existing skip. Targeted checks
also passed after the final image-provider lifetime and HTTPS adjustments.
Analyzer reported no issues. Windows debug and web release builds succeeded.
Kind boundary checks reported no AST violations; duplication checks reported
no repeated kind implementation clusters. Existing complexity-budget reports
remain outside this request's scope.

Browser verification used an isolated origin, preserving the user's library
and authenticated CLZ session. Verified real online results with 600 x 600
artwork, selection/download, saved front/back covers and reload. Verified
MusicBrainz barcode responses and CAA's HTTP original-image URLs, which the
client requests over HTTPS. Verified collection creation, empty active
collection, album transfer, rename/reload, and deletion with transfer back to
Main Collection. The latest build displayed the local cover and grouped it
under Has Back = Yes. At 1000 px the alphabet becomes the complete A-Z menu.

Collections currently organize the local library; public sharing and server
membership synchronization are not implemented. Core catalog search/sync was
not exercised because the local Core service was unavailable.
