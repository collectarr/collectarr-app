# Board Games Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate Board Games product. The explicitly selected reference is **CLZ Games for owned-copy inventory fields only** (location, owner, purchase data, tags, and completeness-style tracking). It is not a board-game catalog parity reference. All board-game catalog fields below are Collectarr-specific pending a separately approved source/field set.

**Catalog Item:** one specific edition or printing. Mechanics, categories, designers, components, and expansion links are contained metadata/relationships. **Owned Copy:** one physical copy, with its own completeness, condition, and storage.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Games proxy; exact field unconfirmed | Catalog Item | No | `title` | **Collectarr-specific** catalog field |
| Edition / `edition` | Text/vocabulary | CLZ Games proxy; unconfirmed | Catalog Item | No | `edition` | **Collectarr-specific** |
| Publisher / `publisher` | Organization reference | Unconfirmed | Catalog Item | Yes | `publishers[]` | **Collectarr-specific** |
| Designers / `designers` | Person references | Unconfirmed | Catalog Item | Yes | `designers[]` | **Collectarr-specific** |
| Mechanics / `mechanics` | Vocabulary/reference list | Unconfirmed | Catalog Item | Yes | `mechanics[]` | **Collectarr-specific** |
| Categories / `categories` | Vocabulary/reference list | Unconfirmed | Catalog Item | Yes | `categories[]` | **Collectarr-specific** |
| Players / `player_count` | Integer range/recommendations | Unconfirmed | Catalog Item | Yes | `player_counts[]` | **Collectarr-specific** |
| Play Time / `play_time` | Duration/range | Unconfirmed | Catalog Item | No | `play_time_minutes` | **Collectarr-specific** |
| Components / `components` | Ordered component list | Unconfirmed | Catalog Item | Yes | `components[]` | **Collectarr-specific**; contained data |
| Expansion / `expansion_for` | Catalog Item relationship | Unconfirmed | Catalog Item | Yes | `related_items[]` | **Collectarr-specific** |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Existing Collectarr inventory; not verified against CLZ |
| Completeness / `completeness` | Enum | CLZ Games pre-fill proxy | Owned Copy | No | `completeness` | Games ownership proxy only |
| Condition / `condition` | Vocabulary | CLZ Games proxy; exact field unconfirmed | Owned Copy | No | `condition` | Existing Collectarr inventory |
| Location / `location` | Location reference | CLZ Games pre-fill proxy | Owned Copy | No | `location` | Proxy concept |
| Purchase Date/Price/Store / `purchase_*` | Date / money / text | CLZ Games pre-fill proxy | Owned Copy | No | `purchase_date`, `purchase_price`, `purchase_store` | Proxy concepts |
| Sleeved / Painted Minis / `preservation` | Boolean/details | Collectarr form | Owned Copy | No | `preservation_details` | **Collectarr-only** |

**Reference:** [CLZ Games ownership pre-fill](https://clz.com/games/mobile/whatsnew/2020). This ledger does not claim a CLZ Board Games form exists.
