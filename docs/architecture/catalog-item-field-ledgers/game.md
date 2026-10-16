# Game Catalog Item and Collection Item Field Ledger

**Status:** The CLZ Games Edit form was captured read-only on 2026-10-16 (see
[CLZ Games reference](#clz-games-reference) below). The Core table that follows
still lists the pinned Core Catalog Item v1 fields; the reference section maps
each CLZ label to them and names the gaps.

**Source:** `tool/core_contracts/catalog-item-v1.json`, kind `game`. The contract is generated from Core's current kind-aware proposal validator. Regenerate this ledger after an intentional contract change and review every row against the kind's eventual Edit-form capture.

| Displayed label | Edit tab | Contract type | Target | Repeated | Core field | App field |
| --- | --- | --- | --- | --- | --- | --- |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `age_rating` | `age_rating` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `audience_rating` | `audience_rating` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `barcode` | `barcode` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `catalog_number` | `catalog_number` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `company_roles` | `company_roles` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `contributors` | `contributors` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `country` | `country` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `cover_image_url` | `cover_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `creators` | `creators` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `description` | `description` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `developers` | `developers` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `edition_title` | `edition_title` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `external_links` | `external_links` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `genres` | `genres` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string or object | Catalog Item | Yes | `identifiers` | `identifiers` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `item_number` | `item_number` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `language` | `language` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `localized_title` | `localized_title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `original_title` | `original_title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `physical_format` | `physical_format` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `platforms` | `platforms` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_description` | `plot_description` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `plot_summary` | `plot_summary` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `publisher` | `publisher` |
| Unverified; Edit-form capture required | Unverified; capture required | Unspecified by schema | Catalog Item | No | `release_date` | `release_date` |
| Unverified; Edit-form capture required | Unverified; capture required | Unspecified by schema | Catalog Item | No | `release_date_parts` | `release_date_parts` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `release_region` | `release_region` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `release_status` | `release_status` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `search_aliases` | `search_aliases` |
| Unverified; Edit-form capture required | Unverified; capture required | array of string | Catalog Item | Yes | `series_tags` | `series_tags` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `series_title` | `series_title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `sort_key` | `sort_key` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `subtitle` | `subtitle` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `synopsis` | `synopsis` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `thumbnail_image_url` | `thumbnail_image_url` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `title` | `title` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `title_extension` | `title_extension` |
| Unverified; Edit-form capture required | Unverified; capture required | array of object | Catalog Item | Yes | `trailer_urls` | `trailer_urls` |
| Unverified; Edit-form capture required | Unverified; capture required | string | Catalog Item | No | `variant_name` | `variant_name` |

## Ownership boundary

This file inventories catalog fields only. Collection Item fields, tracking, loans, locations, personal images, notes, custom-field values, and other user state belong to App. They must not be added to this kind's Core Catalog Item proposal payload.

## CLZ Games reference

Captured from signed-in CLZ Games Web (light theme, 1844 × 945) on 2026-10-16
by opening the editor and pressing Cancel. App columns name the current Game
module field; **gap** marks a difference to resolve before Game is released.

CLZ Games keeps three collections: **Games**, **Hardware** and **Toys**, shown as
tabs at the bottom of the window. Each has its own Add button and editor.

### Games editor

Tabs: Main, Value, Personal, Custom Fields, Covers, My Images, Description,
Links. Collection Status, Index, Quantity and Location sit in a footer shown
under every tab.

| Tab | CLZ label | CLZ control | Owner | App field |
| --- | --- | --- | --- | --- |
| Main | Title | text with capitalisation button | Catalog | `title` |
| Main | Sort Title | text | Catalog | `sort_key` |
| Main | Platform | single pick list | Catalog | `platforms` (list; **gap**: CLZ has one platform per item) |
| Main | Release Date | partial date YYYY/MM/DD | Catalog | `release_date_parts` |
| Main | Developer | repeated pick list (+) | Catalog | `developers` |
| Main | Publisher | repeated pick list (+) | Catalog | `publisher` (single; **gap**) |
| Main | Series | single pick list | Catalog | `series_title` |
| Main | Barcode | text | Catalog | `barcode` |
| Main | Format | single pick list (e.g. Blu-ray Disc) | Catalog | `physical_format` |
| Main | Edition | text | Catalog | `edition_title` |
| Main | Region | single pick list | Catalog | `release_region` |
| Main | Audience Rating | single pick list (e.g. Mature) | Catalog | `audience_rating` |
| Main | Genre | multi-value pick list | Catalog | `genres` |
| Value | Completeness | segmented N/A, Loose, CIB, New, Graded | Personal | `game_completeness` |
| Value | Box, Manual | checkboxes | Personal | `game_has_box`, `game_has_manual` |
| Value | Value | currency with lock | Personal | `market_value_cents`, `game_value_is_locked` |
| Value | Condition | single pick list | Personal | `condition` |
| Value | Purchase Price | currency | Personal | `price_paid_cents` |
| Value | Purchase Store | single pick list | Personal | `purchase_store` |
| Value | Purchase Date | partial date | Personal | `purchase_date` (full date; **gap**) |
| Value | PriceCharting ID | text with refresh | Personal | `game_pricecharting_id` |
| Value | Core Region | segmented US, EU | Personal | `game_core_region` |
| Value | Values from PriceCharting | bar chart: Loose, Loose + Box, Loose + Manual, CIB, New, Graded | Personal | `game_valuations` |
| Personal | Owner | single pick list | Personal | `owner_label` |
| Personal | Storage Device | single pick list | Personal | **gap** |
| Personal | Storage Slot | text | Personal | **gap** |
| Personal | Notes | multi-line text | Personal | `personal_notes` |
| Personal | Completed | segmented No, Yes | Personal | tracking status (**gap**: CLZ has a yes/no flag, the app a play lifecycle) |
| Personal | Completed Date | partial date | Personal | tracking `finished_at` |
| Personal | My Rating | ten stars | Personal | tracking `rating` |
| Personal | Tags | multi-value pick list | Personal | `tags` (one string; **gap**) |
| Footer | Collection Status, Index, Quantity, Location | pick list, number, number, pick list | Personal | shared entry fields |
| Covers | Front Cover, Back Cover | Find Online, Upload, Remove, Crop / Rotate | Personal over Catalog | shared image owners |
| Description | Description | rich text | Catalog | `description` |
| Links | Links; YouTube Trailers | URL + description rows | Catalog | `external_links`; `trailer_urls` |

Choosing a completeness level replaces the value with that tier's
PriceCharting value; Graded adds no fields.

### Toys editor

Main: Title, Sort Title, Barcode, Release Date, Series (e.g. Disney Infinity
2.0), Type (pick list), Subtype (e.g. Power Disc). Value: Completeness Loose or
New, Box, Value, Condition, Purchase Price, Purchase Store, Purchase Date,
PriceCharting ID. Personal: Owner, Notes, My Rating, Tags. Toy type and subtype
map to `toy_type` and `toy_subtype`.

### Hardware

The Hardware collection was empty, so its editor was not opened. Its sort list
adds Hardware Type and Serial No.

### Details panel

Series line above the title, title in the accent, cover, platform icon with
"Platform (Year)", Publisher and Developer headings, "Format | Audience Rating",
genres, a value badge ("CIB | $ 12.49", "Includes box & manual", "Values by
PriceCharting.com"), eBay sold listings, Description, Trailer, and a Personal
table (Value, Index, Completed, Added Date, Modified Date). Toys show the year
and a Loose/New badge instead of platform and companies.

### Workspace

Default folder Platform; default sort Platform, Title. Folder favorites:
Platform, Completeness, Platform / Completeness. Folder groups:

- Images: Has Back, Has Front, Image Type
- Main: Audience Rating, Developer, Genre, Platform, Publisher, Release Date,
  Release Month, Release Year, Series
- Value: Completeness, Condition, Purchase Date, Purchase Month, Purchase
  Store, Purchase Year, Value Locked
- Toy: Subtype, Type
- Edition: Edition, Format, Region
- Personal: Added Date, Added Month, Added Year, Collection Status, Completed,
  Completed Date, Completed Month, Completed Year, Location, Modified Date,
  Modified Month, My Rating, Owner, Storage Device, Tags

Sort fields add Back/Front Cover (named "Box Image", "Device Image" and
"Figure Image" for hardware and toys), Core GameID, Core MediaID, Sort Title,
Title, Box, Manual, PriceCharting ID, Purchase Price, Value, Hardware Type,
Serial No., Barcode, Added/Modified Date/Time, Index, Notes, Quantity, Storage
and Storage Slot. The list view adds a platform icon column. Views: List,
Vertical Cards, Horizontal Cards, Covers, Shelves.
