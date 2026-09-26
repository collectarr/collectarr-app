# Music Album v1 Field Ledger

This ledger freezes the Music Album v1 field set from the supplied saved CLZ Music album page, `My Albums - CLZ Music Web.html`. It records the form fields present in that page, including fields whose saved value is empty. The source is one rendered album page; this ledger is exhaustive for the visible controls and track structure in that snapshot, but it is not a claim that the snapshot exposes every optional CLZ feature or every user-configured custom field.

`catalog` fields describe the edition represented by one album record. `owned_copy` fields describe one user's distinguishable physical or digital copy. A copy-specific value must never be stored on the album because another copy can have a different value.

## Main and Details

| CLZ tab | CLZ label | CLZ key | Type | Ownership | Music Album v1 name |
| --- | --- | --- | --- | --- | --- |
| Main | Title | `title` | text, required | catalog | `title` |
| Main | Sort Title | `sorttitle` | text | catalog | `sort_title` |
| Main | Subtitle | `subtitle` | text | catalog | `subtitle` |
| Main | Artist | `artist` | ordered person reference with credited name and sort name | catalog | `artists` |
| Main | Release Date | `releasedate` | partial date | catalog | `release_date` |
| Main | Original Release Date | `originalreleasedate` | partial date | catalog | `original_release_date` |
| Main | Label | `label` | ordered organization reference/name | catalog | `labels` |
| Main | Recording Date | `recordingdate` | partial date | catalog | `recording_date` |
| Main | Format | `format` | vocabulary string | catalog | `format` |
| Main | Barcode | `barcode` | text | catalog | `barcode` |
| Main | Cat No | `catnr` | text | catalog | `catalog_number` |
| Main | Genre | `genre` | ordered string list | catalog | `genres` |
| Details | Packaging | `packaging` | vocabulary string | catalog | `packaging` |
| Details | Package/Sleeve Condition | `condition` | vocabulary string | owned_copy | `package_condition` |
| Details | Media Condition | `mediacondition` | vocabulary string | owned_copy | `media_condition` |
| Details | Studio | `studio` | ordered string/person/organization credits | catalog | `studios` |
| Details | Country | `country` | country code/name | catalog | `country` |
| Details | Is Live | `islive` | boolean | catalog | `is_live` |
| Details | Sound | `soundtype` | ordered vocabulary list | catalog | `sound_types` |
| Details | Vinyl Color | `vinylcolor` | vocabulary string | catalog | `vinyl_color` |
| Details | Vinyl Weight | `vinylweight` | number with unit defined by the UI | catalog | `vinyl_weight` |
| Details | RPM | `rpm` | enum (`N/A`, 33, 45, 78) | catalog | `rpm` |
| Details | Extra | `extra` | ordered string/vocabulary list | catalog | `extras` |
| Details | SPARS | `sparscode` | vocabulary string | catalog | `spars_code` |
| Details | Box Set | `boxset` | optional box-set reference/name | catalog | `box_set` |

## Credits

Credits are ordered role-specific lists. The role belongs to the credit entry; a person may occur under more than one role.

| CLZ tab | CLZ label | CLZ key | Type | Ownership | Music Album v1 name |
| --- | --- | --- | --- | --- | --- |
| Classical | Composer | `composer` | ordered person credits | catalog | `credits` with role `composer` |
| Classical | Conductor | `conductor` | ordered person credits | catalog | `credits` with role `conductor` |
| Classical | Chorus | `chorus` | ordered person credits | catalog | `credits` with role `chorus` |
| Classical | Composition | `composition` | ordered work/title credits | catalog | `credits` with role `composition` |
| Classical | Orchestra | `orchestra` | ordered ensemble credits | catalog | `credits` with role `orchestra` |
| People | Songwriter | `songwriter` | ordered person credits | catalog | `credits` with role `songwriter` |
| People | Producer | `producer` | ordered person credits | catalog | `credits` with role `producer` |
| People | Engineer | `engineer` | ordered person credits | catalog | `credits` with role `engineer` |
| People | Musician | `musician` | ordered person credits, including instrument text when supplied | catalog | `credits` with role `musician` and optional `instrument` |

## Discs and Tracks

The snapshot contains two disc forms. A disc is contained album data, not a separately addressable entity. `disc_number` is a one-based position within the album; disc titles are optional values keyed by that number. Every track is an album child with an album ID, disc number, and position.

| CLZ tab | CLZ label/key | Type | Ownership | Music Album v1 name |
| --- | --- | --- | --- | --- |
| Tracks | Disc Title (`disctitle`) | text, optional, one per disc | catalog | `disc_titles[].title` with `disc_number` |
| Tracks | Track position (rendered rank) | positive integer position within a disc | catalog | `tracks[].position` |
| Tracks | Track Title (`tracks[][title]`) | text, required | catalog | `tracks[].title` |
| Tracks | Track Artist (`tracks[][artist]`) | text | catalog | `tracks[].artist` |
| Tracks | Length (`tracks[][length]`) | duration text in `m:ss` or `h:mm:ss` form | catalog | `tracks[].duration_ms` |
| Tracks | Matrix No. Side A (`matrix_number_side_a`) | text | catalog | `matrix_number_side_a` |
| Tracks | Matrix No. Side B (`matrix_number_side_b`) | text | catalog | `matrix_number_side_b` |
| Tracks | Storage Device (`storagedevice`) | vocabulary string | owned_copy | `disc_storage[].storage_device` |
| Tracks | Slot (`storagedeviceslot`) | text | owned_copy | `disc_storage[].slot` |

CLZ's rendered `hash`, `header-hash`, and `toc` inputs are transport/UI implementation values rather than user catalog fields, so they are not part of v1. Track headers and artificial grouping rows are likewise not album tracks.

## Personal and Collection Fields

Each row in `OwnedCopyV1` represents one distinguishable copy. These values are stored on that row, never on `MusicAlbum`.

| CLZ tab / area | CLZ label | CLZ key | Type | Ownership | OwnedCopy v1 name |
| --- | --- | --- | --- | --- | --- |
| Personal | Purchase Date | `purchased` | partial date | owned_copy | `purchase_date` |
| Personal | Purchase Price | `purchaseprice` | decimal money and currency | owned_copy | `purchase_price` |
| Personal | Purchase Store | `purchasestore` | optional organization/name | owned_copy | `purchase_store` |
| Personal | Current Value | `currentvalue` | decimal money and currency | owned_copy | `current_value` |
| Personal | Last Cleaned Date | `lastcleaneddate` | partial date | owned_copy | `last_cleaned_date` |
| Personal | Signed by | `signees` | ordered person/name list | owned_copy | `signed_by` |
| Personal | Owner | `owner` | user/name reference | owned_copy | `owner` |
| Personal | My Rating | `rating` | integer rating | owned_copy | `rating` |
| Personal | Notes | `notes` | text | owned_copy | `notes` |
| Personal | Tags | `tags` | ordered string list | owned_copy | `tags` |
| Collection footer | Collection Status | `status` | status enum | owned_copy | `status` |
| Collection footer | Index | `indexnr` | integer | owned_copy | `index_number` |
| Collection footer | Quantity | `quantity` | positive integer; retained as copy quantity only when those units are indistinguishable | owned_copy | `quantity` |
| Collection footer | Location | `location` | optional location reference/name | owned_copy | `location` |
| Tracks | Storage Device and Slot | `storagedevice`, `storagedeviceslot` | per-disc storage details | owned_copy | `disc_storage` |
| Details | Package/Sleeve Condition | `condition` | vocabulary string | owned_copy | `package_condition` |
| Details | Media Condition | `mediacondition` | vocabulary string | owned_copy | `media_condition` |

Played History is activity, not a catalog level or an album-owned attribute. Its rows belong to App activity data and reference `album_id`, with optional `owned_copy_id`; each event may contain listened/started/finished dates, location, and notes.

## Images, Links, and User-Defined Fields

| CLZ tab | CLZ label/key | Type | Ownership | Music Album v1 name |
| --- | --- | --- | --- | --- |
| Covers | Front Cover (`frontCover`) | catalog cover image with optional user override | catalog | `cover_image_url` and App's catalog image cache |
| Covers | Back Cover (`backCover`) | catalog cover image with optional user override | catalog | `back_cover_image_url` and App's catalog image cache |
| My Images | Image | image, maximum five in the observed UI | owned_copy | `personal_images[]` |
| My Images | Description (`description`) | text | owned_copy | `personal_images[].description` |
| Links | URL (`url`) | URL | catalog | `links[].url` |
| Links | Title | text | catalog | `links[].title` |
| Links | Description | text | catalog | `links[].description` |
| Custom Fields | User-configured fields (`udfs`) | value type defined by the user's field schema | owned_copy | `custom_fields` in App's separate OwnedCopyV1 extension |

The page includes separate core-front/core-back image references and the ability to upload/override those catalog covers. These belong to the edition. Only the images under My Images are per-copy personal images. Crop, rotate, upload, remove, and restore controls are UI operations rather than additional album fields.

## v1 Boundary

The new catalog contract contains only the catalog-owned rows above. Purchase/value, status, index, location, owner, conditions, rating, notes, tags, played-history events, personal images, and custom values are App-owned data and must not be added to Core's album contract. Provider IDs, provider envelopes, source snapshots, and import history are also not album fields; App owns that provenance separately.

The old Collectarr Music-only fields with no matching CLZ field in this ledger (including provider-internal recording IDs, file hashes/bitrates, TOC/CDDB data, missing-track bookkeeping, and app-only box-set membership projections) are not carried into the new catalog contract by default. Any later addition needs an explicit field-ledger decision.
