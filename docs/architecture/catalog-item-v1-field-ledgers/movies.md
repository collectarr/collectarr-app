# Movies Catalog Item v1 Field Ledger

**Status:** provisional. CLZ Movies publicly describes title, year, studio, genre, plot, rating, cast/crew, barcode lookup, cover/backdrop images, and trailer information. These public feature pages do not establish the complete Edit form, exact labels, or tab placement.

**Catalog Item:** one physical or digital edition. Disc/cut/extras are contained edition data. **Owned Copy:** one separately owned copy; condition, location, and purchase facts stay per copy.

| CLZ label / key | Type | CLZ form location | Target | Repeats | Core / App v1 key | Evidence |
|---|---|---|---|---|---|---|
| Title / `title` | Text | Unconfirmed | Catalog Item | No | `title` | Publicly described |
| Sort Title / `sort_title` | Text | Collectarr form | Catalog Item | No | `sort_title` | Collectarr-only; CLZ field unconfirmed |
| Subtitle / `subtitle` | Text | Collectarr form | Catalog Item | No | `subtitle` | Collectarr-only; CLZ field unconfirmed |
| Year / `year` | Year or partial date | Unconfirmed | Catalog Item | No | `release_year` | Publicly described |
| Edition Release Date / `release_date` | Partial date | Collectarr form | Catalog Item | No | `release_date` | Collectarr-only; date of the specific physical/digital edition |
| Studio / `studio` | Organization reference | Unconfirmed | Catalog Item | Yes | `studios[]` | Publicly described |
| Genre / `genre` | Vocabulary list | Unconfirmed | Catalog Item | Yes | `genres[]` | Publicly described |
| Plot / `plot` | Text | Unconfirmed | Catalog Item | No | `plot` | Publicly described |
| Rating / `rating` | Rating scale | Unconfirmed | Catalog Item | No | `audience_rating` | Publicly described; exact rating source/type unconfirmed |
| Cast and Crew / `cast_crew` | Person plus role | Unconfirmed | Catalog Item | Yes | `credits[]` | Publicly described |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Publicly described lookup |
| Format / `format` | Vocabulary | Unconfirmed | Catalog Item | No | `format` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Region / `region` | Region code/vocabulary | Unconfirmed | Catalog Item | No | `region` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Release Date / `release_date` | Date/partial date | Unconfirmed | Catalog Item | No | `release_date` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Runtime / `runtime` | Duration | Unconfirmed | Catalog Item | No | `runtime_minutes` | Existing Collectarr inventory; public pages describe movie details generally |
| Cover / Backdrop / `images` | Image reference | Unconfirmed | Catalog Item | Yes | `images[]` | Publicly described |
| Audio/Subtitles / `media_tracks` | Repeating typed media data | Unconfirmed | Catalog Item | Yes | `media_tracks[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Location / `location` | Location reference | Unconfirmed | Owned Copy | Unconfirmed | `location_id` | Product purpose is collection tracking; exact field unconfirmed |
| Condition / `condition` | Vocabulary | Unconfirmed | Owned Copy | No | `condition` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Purchase Date / `purchase_date` | Date | Unconfirmed | Owned Copy | No | `purchase_date` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Purchase Price / `purchase_price` | Money | Unconfirmed | Owned Copy | No | `purchase_price` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Notes / `notes` | Text | Unconfirmed | Owned Copy | No | `notes` | Existing Collectarr inventory; CLZ detail unconfirmed |
| **Collectarr-only:** watch status / `watch_status` | Enum | Collectarr tracking UI | App activity (copy optional) | No | `watch_status` | Not claimed as CLZ parity |
| **Collectarr-only:** box set name / `box_set_name` | Related-item/text | Collectarr UI | Catalog Item | No | `box_set` | Not claimed as CLZ parity |

Common App-owned fields use the shared Owned Copy v1 set in the [ledger index](README.md). Watching history is activity data and references the Catalog Item, with an optional Owned Copy reference.

**Source:** [CLZ Movies Web features](https://app.clz.com/movies). Exact CLZ keys and locations remain unverified.

## Legacy field disposition

The v1 contract retains common title/sort title/subtitle/release date/identifiers/images, release year, studios, genres, plot, audience rating, credits, format, region, runtime, media tracks, and box-set name. It excludes original title, age rating, country and language fields, trailer URLs, physical-format label, publisher, packaging, distributor, HDR summary, variant, item number, series identity, loose `video` map, duplicate audio/subtitle/color/disc-count/screen-ratio/layer fields outside `media_tracks[]`, and provider edition/release/link/raw-payload lists. The old release's typed disc/audio/subtitle data maps to `media_tracks[]`; the concrete physical or digital edition itself is the Catalog Item.
