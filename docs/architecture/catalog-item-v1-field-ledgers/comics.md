# Comics Catalog Item v1 Field Ledger

**Status:** provisional. CLZ publicly describes series, issue number, variant, publisher, dates, plot, creator and character information, cover images, and personal grading/purchase details. The public page does not establish the complete Edit form, exact types, or tab placement. The source uses the CLZ Comics mobile feature page; obtain a saved Edit form before calling this parity-complete.

**Catalog Item:** one specific issue variant or collected edition. **Owned Copy:** one separately owned physical/digital copy. Repeating creators, characters, story arcs, and external links are contained lists.

| CLZ label / key | Type | CLZ form location | Target | Repeats | Core / App v1 key | Evidence |
|---|---|---|---|---|---|---|
| Title / `title` | Text | Unconfirmed | Catalog Item | No | `title` | Required Catalog Item identity |
| Sort Title / `sort_title` | Text | Collectarr form | Catalog Item | No | `sort_title` | Collectarr-only; CLZ field unconfirmed |
| Subtitle / `subtitle` | Text | Collectarr form | Catalog Item | No | `subtitle` | Collectarr-only; CLZ field unconfirmed |
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
| Storage Box / `storage_box` | Location/reference | Unconfirmed | Owned Copy | No | `location_id` | Publicly described personal detail |
| Grade / `grade` | Grade value | Unconfirmed | Owned Copy | No | `kind_details.grade` | Publicly described personal detail |
| Grading Company / `grading_company` | Vocabulary/reference | Unconfirmed | Owned Copy | No | `kind_details.grading_company` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Purchase Price / `purchase_price` | Money | Unconfirmed | Owned Copy | No | `purchase_price` | Publicly described personal detail |
| Purchase Store / `purchase_store` | Text/organization | Unconfirmed | Owned Copy | No | `purchase_store` | Publicly described personal detail |
| Purchase Date / `purchase_date` | Date | Unconfirmed | Owned Copy | No | `purchase_date` | Publicly described personal detail |
| Notes / `notes` | Text | Unconfirmed | Owned Copy | No | `notes` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Current Value / `current_value` | Money | Unconfirmed | Owned Copy | No | `current_value` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Key issue / `key_issue` | Boolean/category | Unconfirmed | Catalog Item | No | `key_issue` | Publicly described key comic information |
| Story Arc / `story_arcs` | Story-arc reference | Unconfirmed | Catalog Item | Yes | `story_arcs[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| **Collectarr-only:** reading status / `reading_status` | Enum | Collectarr tracking UI | App activity (copy optional) | No | `reading_status` | Not claimed as CLZ parity |
| **Collectarr-only:** custom label / `custom_label` | Text | Collectarr Edit UI | Owned Copy | No | `kind_details.custom_label` | Not claimed as CLZ parity |

**Source:** [CLZ Comics features](https://clz.com/comics/mobile). Exact CLZ keys and locations remain unverified.

Common App-owned fields use the shared Owned Copy v1 set in the [ledger index](README.md).

## Legacy field disposition

The v1 contract retains title/sort title/subtitle, series membership, issue number, variant, publisher, release date, plot, creator credits, characters, identifiers, images, key-issue flag, and story arcs. It excludes imprint, separate cover date, page count, country, language, age rating, crossover, genre list, search aliases, key-event taxonomy and descriptions, key-issue reason, variant description, publishing-date bundle, edition title/title extension, physical-format labels, free-form creator and character payloads, provider links, and raw provider payload. ISBN/UPC/barcode values are identifiers, and release cover data is an image. The former release and variant nodes collapse into the single concrete issue-variant Catalog Item; no nested release list remains.
