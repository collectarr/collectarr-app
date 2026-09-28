# TV Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate TV product. The explicitly selected reference is **CLZ Movies**, used for edition/box-set, video metadata, barcode, and personal collection concepts. TV season-set-specific fields are Collectarr-specific until captured and approved; this proxy does not establish literal CLZ TV parity.

**Catalog Item:** one specific season release or box set. Included seasons and episodes are contained data. **Owned Copy:** one separately owned release copy.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Movies form, exact tab unconfirmed | Catalog Item | No | `title` | Proxy concept |
| Sort Title / `sort_title` | Text | Collectarr form | Catalog Item | No | `sort_title` | Collectarr-only; CLZ field unconfirmed |
| Subtitle / `subtitle` | Text | Collectarr form | Catalog Item | No | `subtitle` | Collectarr-only; CLZ field unconfirmed |
| Studio/Network / `studio` | Organization reference | Unconfirmed | Catalog Item | Yes | `studios[]` | Proxy concept; network distinction is Collectarr-specific |
| Genre / `genres` | Vocabulary list | Unconfirmed | Catalog Item | Yes | `genres[]` | Proxy concept |
| Credits / `credits` | Person plus role | Unconfirmed | Catalog Item | Yes | `credits[]` | Proxy concept |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Proxy concept |
| Format / Region / `edition` | Vocabulary/code | Unconfirmed | Catalog Item | No | `format`, `region` | Proxy concept |
| Release Date / `release_date` | Date/partial date | Unconfirmed | Catalog Item | No | `release_date` | Proxy concept |
| Season Set / Box Set / `release_title` | Text/number | Collectarr form | Catalog Item | No | `edition_title` | **Collectarr-only** until confirmed |
| Included Seasons / `seasons` | Ordered season data | Collectarr form | Catalog Item | Yes | `seasons[]` | **Collectarr-only**; contained data |
| Episodes / `episodes` | Ordered episode records nested under a season | Collectarr form | Catalog Item | Yes | `seasons[].episodes[]` | **Collectarr-only**; contained data; season number is supplied by the parent season |
| Cover / `cover` | Image reference | Unconfirmed | Catalog Item | Yes | `images[]` | Proxy concept |
| Condition / Location / `owned_details` | Vocabulary / location | Unconfirmed | Owned Copy | No | `condition`, `location_id` | Proxy concept |
| Purchase Date/Price / `purchase_*` | Date / money | Unconfirmed | Owned Copy | No | `purchase_date`, `purchase_price` | Proxy concept |
| **Collectarr-only:** watch status / `watch_status` | Enum | Collectarr tracking UI | App activity (copy optional) | No | `watch_status` | Not claimed as CLZ parity |

**Reference:** [CLZ Movies features](https://app.clz.com/movies). Exact CLZ field list and TV-specific fields remain unconfirmed.

Common App-owned fields use the shared Owned Copy v1 set in the [ledger index](README.md). Watching history is activity data and references the Catalog Item, with an optional Owned Copy reference.

## Legacy field disposition

The v1 contract retains common title/sort title/subtitle/release date/identifiers/images, studios, genres, credits, format, region, edition title, seasons, and episodes nested under each season. It excludes original title and synopsis; first/last air dates; show status; network and streaming-service fields; country and original language; content rating; separate season/episode count and runtime summaries; series identity; episode/item numbers that duplicate contained episode data; physical-format labels, publisher, packaging, distributor, screen ratio, flat audio/subtitle summaries, variant; provider release/edition/link lists and raw provider payload. Season number belongs only to its parent season; per-episode air date, runtime, description, episode numbering, and title remain on the contained episode record. The concrete season release or box set is the Catalog Item; the old TV series and physical-release graph is removed.
