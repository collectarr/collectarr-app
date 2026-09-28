# Owned Copy v1

`OwnedCopyV1` is an App-owned record for one distinguishable copy of one Core Catalog Item. Catalog fields never appear in this model. Core does not receive ownership status, condition, location, purchases, personal images, or custom fields.

## Identity and JSON shape

The App stores the Catalog Item and copy identities together. A bulk Add operation creates one copy record per requested quantity; quantity is never stored on a copy.

```json
{
  "id": "copy-id",
  "catalog_item": { "kind": "music", "id": "album-id" },
  "status": "in_collection",
  "created_at": "2026-09-28T12:00:00.000Z",
  "updated_at": "2026-09-28T12:00:00.000Z",
  "index_number": 1,
  "location_id": null,
  "owner": { "id": "owner-id", "label": "Owner name" },
  "loaned_to": null,
  "loan_due_date": null,
  "is_digital": false,
  "condition": null,
  "purchase_date": null,
  "purchase_price": null,
  "purchase_store": null,
  "current_value": null,
  "sold_at": null,
  "sold_to": null,
  "sale_price": null,
  "rating": null,
  "notes": null,
  "tags": [],
  "personal_images": [],
  "custom_fields": [],
  "kind_details": {
    "package_condition": null,
    "media_condition": null,
    "last_cleaned_date": null,
    "signed_by": [],
    "disc_storage": []
  }
}
```

Money uses integer cents and a currency code. Dates use the shared partial-date object (`year`, `month`, `day`). `owner` is a typed `{id, label}` reference. Loan borrower and due date belong to this specific copy; due dates must include year, month, and day. Status is a closed v1 enum: `in_collection`, `loaned`, or `sold`.

## Kind-specific copy fields

Kind-specific values are represented by a typed `kind_details` union. The decoder rejects properties that are not defined for the copy's kind.

| Kind | `kind_details` fields |
|---|---|
| Anime | Empty object |
| Board Game | `completeness`, `has_sleeves`, `painted_miniatures` |
| Book | Empty object |
| Comic | `grade`, `grading_company`, `custom_label` |
| Game | `completeness`, `has_box`, `has_manual` |
| Manga | Empty object |
| Movie | Empty object |
| Music | `package_condition`, `media_condition`, `last_cleaned_date`, `signed_by[]`, `disc_storage[]` |
| TV | Empty object |

Each Music disc-storage entry has a positive `disc_number` and optional `storage_device` and `slot`. A copy may have at most one storage entry per disc.

Custom fields are typed by their App field definition. Values are represented by text, number, boolean, string-list, partial-date, or money value classes. Personal image data is local to the copy and is not sent in Catalog Item requests.

The shared Owned Copy form uses configured Storage Locations and owners already present on other copies. Custom fields are rendered from definitions scoped to the selected kind and Owned Copy. Personal images can be selected, cropped or rotated, described, and assigned an image type; the form accepts up to five images. Their stored position preserves the order in which they were added. The form does not expose raw JSON editors or require users to enter local IDs.

## Persistence and lifecycle

`OwnedCopyV1Repository` stores App-owned rows separately from Core catalog data. The local cache key is `(kind, catalog_item_id, copy_id)`; its indexed identity columns must match the strict JSON payload. Deletion is a local tombstone so recovery can retain the original payload. All nine active kind workspaces use this repository for v1 Add, Edit, and delete operations; the global Shelf reads the same table and the v1 wishlist repository. The Shelf supports wishlist, overdue-loan, and copy-note filters. CSV v1 import resolves an existing Core Catalog Item or creates one when catalog editing is allowed, then writes one Owned Copy row per CSV copy; v1 export uses stable field keys. The generic database backup includes the Owned Copy table through Drift's registered table list. `owned_copy_v1` changes are queued for the optional personal sync service with a stable ID derived from the full Catalog Item and copy reference and standard upsert/delete tombstones.

Catalog covers are uploaded as Core Image Assets attached to `catalog_item` references. Users with catalog-edit permission can upload a replacement, crop or rotate a cover, and remove an uploaded cover. The v1 workspace's visible catalog detail columns are selected from the pinned per-kind Catalog Item schema and persisted per kind in local preferences.

The target Drift baseline is schema v1 with only final Catalog Item, Owned Copy, activity, and user-data tables. The current migration version and old-format tables remain transitional until all kinds have moved. Do not deploy or reset a database from this intermediate state.
