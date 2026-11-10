# Book Catalog Item and Collection Item Field Ledger

**Status:** CLZ Books Edit and Add Manually were inspected read-only through the connected browser. Labels and tabs below are filled only where directly observed. The pinned Core inventory remains incomplete for CLZ Details fields; open differences live in `docs/clz-parity.md`.

**Source:** `tool/core_contracts/catalog-item-v1.json`, kind `book`. The contract is generated from Core's current kind-aware proposal validator. Regenerate this ledger after an intentional contract change and review every row against the kind's eventual Edit-form capture.

| Displayed label | Edit tab | Contract type | Target | Repeated | Core field | App field |
| --- | --- | --- | --- | --- | --- | --- |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `age_rating` | `age_rating` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `audience_rating` | `audience_rating` |
| Back Cover | Covers | string | Catalog Item | No | `back_cover_image_url` | `back_cover_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `barcode` | `barcode` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `binding` | `binding` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `catalog_number` | `catalog_number` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `characters` | `characters` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `contributors` | `contributors` |
| Country | Main | string | Catalog Item | No | `country` | `country` |
| Front Cover | Covers | string | Catalog Item | No | `cover_image_url` | `cover_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `creators` | `creators` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `description` | `description` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `dimensions` | `dimensions` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `distributor` | `distributor` |
| Edition | Details | string | Catalog Item | No | `edition_title` | `edition_title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `edition_statement` | `edition_statement` |
| URL / Description | Links | array of object | Catalog Item | Yes | `external_links` | `external_links` |
| Genre | Main | array of string | Catalog Item | Yes | `genres` | `genres` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `identifiers` | `identifiers` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `imprint` | `imprint` |
| ISBN | Main | string | Catalog Item | No | `isbn` | `isbn` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `isbn10` | `isbn10` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `isbn13` | `isbn13` |
| Issue | Main | string | Catalog Item | No | `item_number` | `item_number` |
| First Edition | Details | boolean | Catalog Item | No | `first_edition` | `first_edition` |
| Unverified; Edit-form capture required | Unverified; capture required | partial date | Catalog Item | No | `first_publication_date` | `first_publication_date` |
| Audiobook Length | Credits | integer | Catalog Item | No | `audio_length_minutes` | `audio_length_minutes` |
| Language | Main | string | Catalog Item | No | `language` | `language` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `localized_title` | `localized_title` |
| Title (Original) | Details | string | Catalog Item | No | `original_title` | `original_title` |
| Language (Original) | Details | string | Catalog Item | No | `original_language` | `original_language` |
| Publication Date (Original) | Details | partial date | Catalog Item | No | `original_publication_date` | `original_publication_date` |
| Pages | Main | integer | Catalog Item | No | `page_count` | `page_count` |
| Format | Main | string | Catalog Item | No | `physical_format` | `physical_format` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_description` | `plot_description` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_summary` | `plot_summary` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `printings` | `printings` |
| Publisher | Main | string | Catalog Item | No | `publisher` | `publisher` |
| Publication Date | Main | Unspecified by schema | Catalog Item | No | `release_date` | `release_date` |
| Unverified; Edit-form capture required | Unverified; capture required | Unspecified by schema | Catalog Item | No | `release_date_parts` | `release_date_parts` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `release_status` | `release_status` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `region` | `region` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `search_aliases` | `search_aliases` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `series_group` | `series_group` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `series_tags` | `series_tags` |
| Series | Main | string | Catalog Item | No | `series_title` | `series_title` |
| Subject | Main | array of string | Catalog Item | Yes | `subjects` | `subjects` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `sort_key` | `sort_key` |
| Subtitle | Main | string | Catalog Item | No | `subtitle` | `subtitle` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `synopsis` | `synopsis` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `thumbnail_image_url` | `thumbnail_image_url` |
| Title | Main | string | Catalog Item | No | `title` | `title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `title_extension` | `title_extension` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `variant_name` | `variant_name` |
| Volume | Main | string | Catalog Item | No | `volume_name` | `volume_name` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `volume_number` | `volume_number` |

## Ownership boundary

This file inventories catalog fields only. Collection Item fields, tracking, loans, locations, personal images, notes, custom-field values, and other user state belong to App. They must not be added to this kind's Core Catalog Item proposal payload.

## CLZ verification

Rows still marked unverified have no confirmed matching CLZ control. Catalog fields missing from the pinned contract must be modeled explicitly before they can participate in Core proposals; personal fields belong to App.

