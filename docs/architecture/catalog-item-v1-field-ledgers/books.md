# Books Catalog Item v1 Field Ledger

**Status:** provisional. CLZ publicly describes ISBN lookup and title, author, publisher, genres, subjects, and cover data. Its feature material and release notes also mention original-title/translator details, format, publication data, and series/box-set support, but do not establish every current Edit field or tab. This is not a complete CLZ field list.

**Catalog Item:** one specific edition or printing. **Owned Copy:** one copy with its own location, condition, and purchase details. Contributors and identifiers may repeat; reading sessions are App activity linked to the item and optionally a copy.

| CLZ label / key | Type | CLZ form location | Target | Repeats | Core / App v1 key | Evidence |
|---|---|---|---|---|---|---|
| Title / `title` | Text | Unconfirmed | Catalog Item | No | `title` | Publicly described |
| Sort Title / `sort_title` | Text | Unconfirmed | Catalog Item | No | `sort_title` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Author / `author` | Person reference | Unconfirmed | Catalog Item | Yes | `contributors[]` | Publicly described |
| Publisher / `publisher` | Organization reference | Unconfirmed | Catalog Item | No | `publisher` | Publicly described |
| ISBN / `isbn` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Publicly described |
| Publication Date / `publication_date` | Date/partial date | Unconfirmed | Catalog Item | No | `publication_date` | Publicly described through edition metadata; exact label unconfirmed |
| Edition / `edition` | Text/vocabulary | Unconfirmed | Catalog Item | No | `edition` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Format / `format` | Vocabulary | Unconfirmed | Catalog Item | No | `format` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Genres / `genres` | Vocabulary list | Unconfirmed | Catalog Item | Yes | `genres[]` | Publicly described |
| Subjects / `subjects` | Subject/vocabulary list | Unconfirmed | Catalog Item | Yes | `subjects[]` | Publicly described |
| Original Title / `original_title` | Text | Unconfirmed | Catalog Item | No | `original_title` | Public feature/release-note evidence |
| Translator / `translator` | Person reference | Unconfirmed | Catalog Item | Yes | `contributors[]` | Public feature/release-note evidence |
| Series / `series` | Series reference plus position | Unconfirmed | Catalog Item | No | `series_membership` | Existing Collectarr inventory; exact CLZ shape unconfirmed |
| Cover images / `images` | Image reference | Unconfirmed | Catalog Item | Yes | `images[]` | Publicly described |
| Location / `location` | Location reference | Unconfirmed | Owned Copy | No | `location` | Public feature descriptions/user documentation |
| Condition / `condition` | Vocabulary | Unconfirmed | Owned Copy | No | `condition` | Public feature descriptions |
| Purchase Date / `purchase_date` | Date | Unconfirmed | Owned Copy | No | `purchase_date` | Public feature descriptions/user reports |
| Purchase Price / `purchase_price` | Money | Unconfirmed | Owned Copy | No | `purchase_price` | Public feature descriptions/user reports |
| Purchase Store / `purchase_store` | Text/organization | Unconfirmed | Owned Copy | No | `purchase_store` | Public feature descriptions/user reports |
| Notes / `notes` | Text | Unconfirmed | Owned Copy | No | `notes` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Rating / `rating` | Numeric/star rating | Unconfirmed | Owned Copy | No | `rating` | Existing Collectarr inventory; CLZ detail unconfirmed |
| **Collectarr-only:** reading sessions / `reading_sessions` | Repeating dated activity | Collectarr activity UI | App activity (copy optional) | Yes | `reading_sessions[]` | Not claimed as CLZ parity |
| **Collectarr-only:** synopsis / `synopsis` | Text | Collectarr catalog UI | Catalog Item | No | `synopsis` | Not claimed as CLZ parity |

**Source:** [CLZ Books overview](https://clz.com/books/book-collection), [CLZ Books field additions](https://clz.com/books/web/whatsnew/2023/01/16/v8-0-7-new-data-fields-2). Exact CLZ keys and locations remain unverified.
