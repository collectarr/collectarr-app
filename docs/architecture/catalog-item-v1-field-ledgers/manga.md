# Manga Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate Manga product. The explicitly selected reference is **CLZ Books**, because the target collectible is a volume/edition identified by its own publication and barcode data. This is a proxy for edition and owned-copy concepts, not a claim that CLZ Books has manga-specific fields.

**Catalog Item:** one specific volume, edition, or omnibus. Series membership and included chapters are contained references/data. **Owned Copy:** one physical/digital volume with its own condition and location.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Books form, exact tab unconfirmed | Catalog Item | No | `title` | Proxy concept |
| ISBN / `isbn` | Identifier text | CLZ Books form, exact tab unconfirmed | Catalog Item | Yes | `identifiers[]` | Proxy concept publicly described by CLZ Books |
| Publisher / `publisher` | Organization reference | CLZ Books form, exact tab unconfirmed | Catalog Item | No | `publisher` | Proxy concept publicly described by CLZ Books |
| Publication Date / `publication_date` | Date/partial date | Unconfirmed | Catalog Item | No | `publication_date` | Proxy; exact field unconfirmed |
| Series / `series` | Series reference plus volume position | Unconfirmed | Catalog Item | No | `series_membership` | Collectarr-specific mapping; CLZ Books proxy |
| Volume Number / `volume_number` | Positive/partial number | Collectarr form | Catalog Item | No | `volume_number` | **Collectarr-only** until a CLZ form capture confirms it |
| Edition Format / `edition_format` | Vocabulary | Collectarr form | Catalog Item | No | `edition_format` | **Collectarr-only** until confirmed |
| Chapters / `chapters` | Ordered chapter records | Collectarr form | Catalog Item | Yes | `chapters[]` | **Collectarr-only** until confirmed; contained child data |
| Translator / `translator` | Person reference | Reference form unconfirmed | Catalog Item | Yes | `contributors[]` | Proxy concept noted in CLZ Books feature material |
| Cover / `cover` | Image reference | Reference form unconfirmed | Catalog Item | Yes | `images[]` | Proxy concept publicly described |
| Condition / `condition` | Vocabulary | CLZ Books owned-copy form unconfirmed | Owned Copy | No | `condition` | Proxy only |
| Location / `location` | Location reference | CLZ Books owned-copy form unconfirmed | Owned Copy | No | `location` | Proxy only |
| Purchase Date/Price/Store / `purchase_*` | Date / money / text | CLZ Books form unconfirmed | Owned Copy | No | `purchase_date`, `purchase_price`, `purchase_store` | Proxy only |
| **Collectarr-only:** reading progress / `reading_progress` | Number/activity | Collectarr UI | App activity (copy optional) | Yes | `reading_progress[]` | Not claimed as CLZ parity |

**Reference:** [CLZ Books fields and edition metadata](https://clz.com/books/book-collection). Exact field list and manga-specific fields remain unconfirmed.
