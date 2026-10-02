# Movie Catalog Item and Collection Item Field Ledger

**Status:** Provisional Core field inventory. No saved Edit-form capture is available for this kind, so displayed CLZ labels, tab locations, exact types, and literal CLZ parity are unverified. This ledger records the current pinned Core Catalog Item v1 fields only; it is not evidence of complete product parity.

**Source:** `tool/core_contracts/catalog-item-v1.json`, kind `movie`. The contract is generated from Core's current kind-aware proposal validator. Regenerate this ledger after an intentional contract change and review every row against the kind's eventual Edit-form capture.

| Displayed label | Edit tab | Contract type | Target | Repeated | Core field | App field |
| --- | --- | --- | --- | --- | --- | --- |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `age_rating` | `age_rating` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `audience_rating` | `audience_rating` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `audio_tracks` | `audio_tracks` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `barcode` | `barcode` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `catalog_number` | `catalog_number` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `character_details` | `character_details` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `characters` | `characters` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `color` | `color` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `contributors` | `contributors` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `country` | `country` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `cover_image_url` | `cover_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `creators` | `creators` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `description` | `description` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `discs` | `discs` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `edition_title` | `edition_title` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `external_links` | `external_links` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `genres` | `genres` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `item_number` | `item_number` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `language` | `language` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `layers` | `layers` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `localized_title` | `localized_title` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `media` | `media` |
| Unverified; Edit-form capture required | Unverified; capture required | integer | Catalog Item | No | `nr_discs` | `nr_discs` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `original_title` | `original_title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `physical_format` | `physical_format` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_description` | `plot_description` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_summary` | `plot_summary` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `publisher` | `publisher` |
| Unverified; Edit-form capture required | Unverified; capture required | Unspecified by schema | Catalog Item | No | `release_date` | `release_date` |
| Unverified; Edit-form capture required | Unverified; capture required | Unspecified by schema | Catalog Item | No | `release_date_parts` | `release_date_parts` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `release_status` | `release_status` |
| Unverified; Edit-form capture required | Unverified; capture required | integer | Catalog Item | No | `runtime_minutes` | `runtime_minutes` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `screen_ratio` | `screen_ratio` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `search_aliases` | `search_aliases` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `series_tags` | `series_tags` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `sort_key` | `sort_key` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `subtitle` | `subtitle` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `subtitles` | `subtitles` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `synopsis` | `synopsis` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `thumbnail_image_url` | `thumbnail_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `title` | `title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `title_extension` | `title_extension` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `trailer_urls` | `trailer_urls` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `variant_name` | `variant_name` |

## Ownership boundary

This file inventories catalog fields only. Collection Item fields, tracking, loans, locations, personal images, notes, custom-field values, and other user state belong to App. They must not be added to this kind's Core Catalog Item proposal payload.

## CLZ verification

Do not describe this field set as CLZ parity until a saved Edit-form capture for `Movie` is reviewed and the labels, tabs, field types, and repeat behavior above are confirmed or corrected.

