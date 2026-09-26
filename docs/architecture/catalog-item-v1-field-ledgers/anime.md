# Anime Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate Anime product. The explicitly selected reference is **CLZ Movies**, used only for home-video edition, barcode, image, and owned-copy concepts. Anime season/part semantics are Collectarr-specific until captured and approved; public CLZ movie pages do not define an Anime Edit form.

**Catalog Item:** one specific season, part, or box-set release. Episodes and episode ordering are contained data; there is no separate editable Work/Release chain. **Owned Copy:** one owned release copy.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Movies form, exact tab unconfirmed | Catalog Item | No | `title` | Proxy concept |
| Year / Release Date / `release_date` | Year/date | CLZ Movies form unconfirmed | Catalog Item | No | `release_date` | Proxy concept; exact split unconfirmed |
| Studio / `studio` | Organization reference | CLZ Movies form unconfirmed | Catalog Item | Yes | `studios[]` | Proxy concept |
| Genre / `genres` | Vocabulary list | CLZ Movies form unconfirmed | Catalog Item | Yes | `genres[]` | Proxy concept |
| Credits / `credits` | Person plus role | CLZ Movies form unconfirmed | Catalog Item | Yes | `credits[]` | Proxy concept |
| Barcode / `barcode` | Identifier text | CLZ Movies form unconfirmed | Catalog Item | Yes | `identifiers[]` | Proxy concept |
| Format / Region / `edition` | Vocabulary/code | CLZ Movies form unconfirmed | Catalog Item | No | `format`, `region` | Proxy concepts; exact fields unconfirmed |
| Season / Part / Box Set / `release_title` | Text/number | Collectarr form | Catalog Item | No | `edition_title` | **Collectarr-only** until confirmed |
| Episodes / `episodes` | Ordered episode records | Collectarr form | Catalog Item | Yes | `episodes[]` | **Collectarr-only**; contained child data |
| Cover / `cover` | Image reference | CLZ Movies form unconfirmed | Catalog Item | Yes | `images[]` | Proxy concept |
| Condition / Location / `owned_details` | Vocabulary / location | CLZ Movies form unconfirmed | Owned Copy | No | `condition`, `location` | Proxy concepts |
| Purchase Date/Price / `purchase_*` | Date / money | CLZ Movies form unconfirmed | Owned Copy | No | `purchase_date`, `purchase_price` | Proxy concepts |
| **Collectarr-only:** watch progress / `watch_progress` | Episode activity | Collectarr tracking UI | App activity (copy optional) | Yes | `watch_progress[]` | Not claimed as CLZ parity |

**Reference:** [CLZ Movies features](https://app.clz.com/movies). Exact CLZ field list and Anime fields remain unconfirmed.
