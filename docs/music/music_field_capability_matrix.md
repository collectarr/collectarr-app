# Music field capability matrix

This matrix describes ownership and active App/Core boundaries for the flat
Music Catalog Item. It replaces the former Release Group/Release graph audit.
Use [the Music field ledger](../architecture/music-catalog-field-inventory.md)
for the CLZ labels and v1 field names.

| Data | Target | Meaning | Owner |
| --- | --- | --- | --- |
| Album title, artist, dates, label, format, barcode, Cat No, genres | Catalog Item | Facts shared by copies of this concrete edition | Core catalog |
| Covers and source-neutral links | Catalog Item | Shared album artwork and references | Core catalog |
| Credits | Catalog Item | People and classical credits for the album | Core catalog |
| Discs, disc titles, matrix sides | Contained Catalog Item data | Ordered album content and pressing identifiers | Core catalog |
| Tracks and track credits | Contained disc data | Ordered track list; not a separate workspace entity | Core catalog |
| Status, condition, purchase/value data, location, notes, rating, tags | Collection Item | Personal facts for one distinguishable copy | App and Sync |
| Storage device, slot, observed runouts, personal images | Collection Item | Physical details and images for one copy | App and Sync |
| Listening events | Catalog Item, optional Collection Item | User activity for an album; copy is recorded only when known | App and Sync |

## Boundaries

- One search result represents one concrete album edition and has its own
  Catalog Item identity. Search does not return an album-group parent with
  nested selectable releases.
- Add, Edit, local persistence, and workspace read the flat item payload.
  Discs and tracks remain Music-owned child data.
- No Music Release Group model, Release workspace projection, or Release scope
  selector remains active in App. Some local Dart and Drift symbols retain
  historical `Release` names for the root Catalog Item.
- Providers, provider IDs, provider ingest, and canonical catalog payloads are
  outside personal Sync. Sync carries Collection Items and personal activity.
- Music is grounded in the saved CLZ Music Edit form. Exact CLZ parity for the
  other eight kinds remains unverified until their Edit-form captures are
  available.
