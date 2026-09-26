# Video Games Catalog Item v1 Field Ledger

**Status:** provisional. CLZ Games is the direct product reference. Public material confirms platform-based cataloging and regional version selection; CLZ describes personal completeness, box/manual, location, owner, purchase date/store/price, quantity, and tags. The public sources do not expose a complete Edit form or all catalog fields.

**Catalog Item:** one specific platform, region, and edition combination. **Owned Copy:** one physical/digital copy with its own completeness, condition, and purchase/location data. DLC/bundle links remain contained relationships, not workspace roots.

| CLZ label / key | Type | CLZ form location | Target | Repeats | Core / App v1 key | Evidence |
|---|---|---|---|---|---|---|
| Title / `title` | Text | Unconfirmed | Catalog Item | No | `title` | Publicly implied by product/catalog |
| Platform / `platform` | Platform reference | Unconfirmed | Catalog Item | No | `platform` | Publicly described |
| Region / `region` | Region code/vocabulary | Unconfirmed | Catalog Item | No | `region` | Publicly described version selector |
| Edition / `edition` | Text/vocabulary | Unconfirmed | Catalog Item | No | `edition` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Publisher / `publisher` | Organization reference | Unconfirmed | Catalog Item | No | `publisher` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Release Date / `release_date` | Date/partial date | Unconfirmed | Catalog Item | No | `release_date` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Cover / `cover` | Image reference | Unconfirmed | Catalog Item | Yes | `images[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| DLC / `dlc` | Related catalog item | Unconfirmed | Catalog Item | Yes | `related_items[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Bundle / `bundle` | Related catalog item/reference | Unconfirmed | Catalog Item | Yes | `related_items[]` | Existing Collectarr inventory; CLZ detail unconfirmed |
| Completeness / `completeness` | Enum (for example Loose/CIB/New) | Add pre-fill | Owned Copy | No | `completeness` | Publicly described |
| Box / `box` | Boolean or condition; exact type unconfirmed | Add pre-fill | Owned Copy | No | `has_box` | Publicly described |
| Manual / `manual` | Boolean or condition; exact type unconfirmed | Add pre-fill | Owned Copy | No | `has_manual` | Publicly described |
| Location / `location` | Location reference | Add pre-fill | Owned Copy | No | `location` | Publicly described |
| Owner / `owner` | User/name reference | Add pre-fill | Owned Copy | No | `owner` | Publicly described |
| Purchase Date / `purchase_date` | Date | Add pre-fill | Owned Copy | No | `purchase_date` | Publicly described |
| Purchase Store / `purchase_store` | Text/organization | Add pre-fill | Owned Copy | No | `purchase_store` | Publicly described |
| Purchase Price / `purchase_price` | Money | Add pre-fill | Owned Copy | No | `purchase_price` | Publicly described |
| Quantity / `quantity` | Positive integer | Add pre-fill | Owned Copy | No | `quantity` | Publicly described; v1 ownership cardinality still uses distinct copy records |
| Tags / `tags` | Vocabulary list | Add pre-fill | Owned Copy | Yes | `tags[]` | Publicly described |
| **Collectarr-only:** play status / `play_status` | Enum | Collectarr UI | Owned Copy | No | `play_status` | Not claimed as CLZ parity |

**Source:** [CLZ Games platform and regional selection](https://clz.com/games/mobile/whatsnew/2020), [CLZ Games pre-fill fields](https://clz.com/games/mobile/whatsnew/2020). Exact CLZ keys and full form placement remain unverified.
