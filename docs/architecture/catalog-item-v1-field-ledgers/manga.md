# Manga Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate Manga product. The explicitly selected reference is **CLZ Books**, because the target collectible is a volume/edition identified by its own publication and barcode data. This is a proxy for edition and owned-copy concepts, not a claim that CLZ Books has manga-specific fields.

**Catalog Item:** one specific volume, edition, or omnibus. Series membership and included chapters are contained references/data. **Owned Copy:** one physical/digital volume with its own condition and location.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Books form, exact tab unconfirmed | Catalog Item | No | `title` | Proxy concept |
| Sort Title / `sort_title` | Text | Collectarr form | Catalog Item | No | `sort_title` | Collectarr-only; CLZ field unconfirmed |
| Subtitle / `subtitle` | Text | Collectarr form | Catalog Item | No | `subtitle` | Collectarr-only; CLZ field unconfirmed |
| ISBN / `isbn` | Identifier text | CLZ Books form, exact tab unconfirmed | Catalog Item | Yes | `identifiers[]` | Proxy concept publicly described by CLZ Books |
| Publisher / `publisher` | Organization reference | CLZ Books form, exact tab unconfirmed | Catalog Item | No | `publisher` | Proxy concept publicly described by CLZ Books |
| Publication Date / `publication_date` | Date/partial date | Unconfirmed | Catalog Item | No | `publication_date` | Proxy; exact field unconfirmed |
| Edition Release Date / `release_date` | Partial date | Collectarr form | Catalog Item | No | `release_date` | Collectarr-only; distinct from first publication date |
| Series / `series` | Series reference plus volume position | Unconfirmed | Catalog Item | No | `series_membership` | Collectarr-specific mapping; CLZ Books proxy |
| Volume Number / `volume_number` | Positive/partial number | Collectarr form | Catalog Item | No | `volume_number` | **Collectarr-only** until a CLZ form capture confirms it |
| Edition Format / `edition_format` | Vocabulary | Collectarr form | Catalog Item | No | `edition_format` | **Collectarr-only** until confirmed |
| Chapters / `chapters` | Ordered chapter titles (`string[]`; list order is position) | Collectarr form | Catalog Item | Yes | `chapters[]` | **Collectarr-only** until confirmed; contained child data |
| Translator / `translator` | Person reference | Reference form unconfirmed | Catalog Item | Yes | `contributors[]` | Proxy concept noted in CLZ Books feature material |
| Cover / `cover` | Image reference | Reference form unconfirmed | Catalog Item | Yes | `images[]` | Proxy concept publicly described |
| Condition / `condition` | Vocabulary | CLZ Books owned-copy form unconfirmed | Owned Copy | No | `condition` | Proxy only |
| Location / `location` | Location reference | CLZ Books owned-copy form unconfirmed | Owned Copy | No | `location_id` | Proxy only |
| Purchase Date/Price/Store / `purchase_*` | Date / money / text | CLZ Books form unconfirmed | Owned Copy | No | `purchase_date`, `purchase_price`, `purchase_store` | Proxy only |
| **Collectarr-only:** reading progress / `reading_progress` | Number/activity | Collectarr UI | App activity (copy optional) | Yes | `reading_progress[]` | Not claimed as CLZ parity |

**Reference:** [CLZ Books fields and edition metadata](https://clz.com/books/book-collection). Exact field list and manga-specific fields remain unconfirmed.

Common App-owned fields use the shared Owned Copy v1 set in the [ledger index](README.md). Reading progress is an activity record, not Owned Copy state.

## Legacy field disposition

The v1 contract retains common title/sort title/subtitle/release date/identifiers/images, publisher, series membership, volume number, edition format, ordered chapter titles, and contributor credits. It excludes native/romaji/English/alternate titles; demographic; serialization platform; publication status; original and localized publisher fields; total-volume and chapter-count summaries; separate original-publication date; language and country; genres and themes; reading direction; relation graph; item number and edition title; page count; imprint; physical-format labels; variant; provider edition lists, free-form creator/link payloads, and raw provider payload. Author, artist, and translator names map to `contributors[]`; ISBN and barcode map to identifiers. The former series-to-volume and Work-to-Release chain is collapsed to one volume Catalog Item with an optional series reference.
