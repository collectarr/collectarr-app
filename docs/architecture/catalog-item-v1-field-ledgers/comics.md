# Comics Catalog Item v1 Field Ledger

**Status:** provisional. CLZ publicly describes series, issue number, variant, publisher, dates, plot, creator and character information, cover images, and personal grading/purchase details. The public page does not establish the complete Edit form, exact types, or tab placement. The source uses the CLZ Comics mobile feature page; obtain a saved Edit form before calling this parity-complete.

**Catalog Item:** one specific issue variant or collected edition. **Owned Copy:** one separately owned physical/digital copy. Repeating creators, characters, story arcs, and external links are contained lists.

| CLZ label / key | Type | CLZ form location | Target | Repeats | Core / App v1 key | Evidence |
|---|---|---|---|---|---|---|
| Series / `series` | Series reference | Unconfirmed | Catalog Item | No | `series` | Publicly described |
| Issue Number / `issue_number` | Text or structured number; exact type unconfirmed | Unconfirmed | Catalog Item | No | `issue_number` | Publicly described |
| Variant / `variant` | Text/reference; exact type unconfirmed | Unconfirmed | Catalog Item | No | `variant` | Publicly described |
| Publisher / `publisher` | Organization reference | Unconfirmed | Catalog Item | No | `publisher` | Publicly described |
| Release/Cover Date / `release_date` | Date or partial date; exact field split unconfirmed | Unconfirmed | Catalog Item | No | `release_date` | Publicly described |
| Plot / `plot` | Text | Unconfirmed | Catalog Item | No | `plot` | Publicly described |
| Creators / `creators` | Person plus role | Unconfirmed | Catalog Item | Yes | `creators[]` | Publicly described |
| Characters / `characters` | Character reference/name | Unconfirmed | Catalog Item | Yes | `characters[]` | Publicly described |
| Cover images / `images` | Image reference | Unconfirmed | Catalog Item | Yes | `images[]` | Publicly described; front/back noted |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Storage Box / `storage_box` | Location/reference | Unconfirmed | Owned Copy | No | `location` | Publicly described personal detail |
| Grade / `grade` | Grade value | Unconfirmed | Owned Copy | No | `grade` | Publicly described personal detail |
| Grading Company / `grading_company` | Vocabulary/reference | Unconfirmed | Owned Copy | No | `grading_company` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Purchase Price / `purchase_price` | Money | Unconfirmed | Owned Copy | No | `purchase_price` | Publicly described personal detail |
| Purchase Store / `purchase_store` | Text/organization | Unconfirmed | Owned Copy | No | `purchase_store` | Publicly described personal detail |
| Purchase Date / `purchase_date` | Date | Unconfirmed | Owned Copy | No | `purchase_date` | Publicly described personal detail |
| Notes / `notes` | Text | Unconfirmed | Owned Copy | No | `notes` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Current Value / `current_value` | Money | Unconfirmed | Owned Copy | No | `current_value` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Key issue / `key_issue` | Boolean/category | Unconfirmed | Catalog Item | No | `key_issue` | Publicly described key comic information |
| Story Arc / `story_arcs` | Story-arc reference | Unconfirmed | Catalog Item | Yes | `story_arcs[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| **Collectarr-only:** reading status / `reading_status` | Enum | Collectarr Edit UI | Owned Copy | No | `reading_status` | Not claimed as CLZ parity |
| **Collectarr-only:** custom label / `custom_label` | Text | Collectarr Edit UI | Owned Copy | No | `custom_label` | Not claimed as CLZ parity |

**Source:** [CLZ Comics features](https://clz.com/comics/mobile). Exact CLZ keys and locations remain unverified.
