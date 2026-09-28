# Board Games Catalog Item v1 Field Ledger

**Status:** provisional; CLZ has no separate Board Games product. The explicitly selected reference is **CLZ Games for owned-copy inventory fields only** (location, owner, purchase data, tags, and completeness-style tracking). It is not a board-game catalog parity reference. All board-game catalog fields below are Collectarr-specific pending a separately approved source/field set.

**Catalog Item:** one specific edition or printing. Mechanics, categories, designers, components, and expansion links are contained metadata/relationships. **Owned Copy:** one physical copy, with its own completeness, condition, and storage.

| Reference label / key | Type | Reference form location | Target | Repeats | Core / App v1 key | Evidence/status |
|---|---|---|---|---|---|---|
| Title / `title` | Text | CLZ Games proxy; exact field unconfirmed | Catalog Item | No | `title` | **Collectarr-specific** catalog field |
| Sort Title / `sort_title` | Text | Collectarr form | Catalog Item | No | `sort_title` | Collectarr-only; CLZ field unconfirmed |
| Subtitle / `subtitle` | Text | Collectarr form | Catalog Item | No | `subtitle` | Collectarr-only; CLZ field unconfirmed |
| Release Date / `release_date` | Partial date | Collectarr form | Catalog Item | No | `release_date` | Collectarr-only; CLZ Board Games form unavailable |
| Edition / `edition` | Text/vocabulary | CLZ Games proxy; unconfirmed | Catalog Item | No | `edition` | **Collectarr-specific** |
| Publisher / `publisher` | Organization reference | Unconfirmed | Catalog Item | Yes | `publishers[]` | **Collectarr-specific** |
| Designers / `designers` | Person references | Unconfirmed | Catalog Item | Yes | `designers[]` | **Collectarr-specific** |
| Mechanics / `mechanics` | Vocabulary/reference list | Unconfirmed | Catalog Item | Yes | `mechanics[]` | **Collectarr-specific** |
| Categories / `categories` | Vocabulary/reference list | Unconfirmed | Catalog Item | Yes | `categories[]` | **Collectarr-specific** |
| Minimum Players / `min_players` | Positive integer | Collectarr form | Catalog Item | No | `min_players` | Collectarr-specific field set |
| Maximum Players / `max_players` | Positive integer | Collectarr form | Catalog Item | No | `max_players` | Collectarr-specific field set |
| Recommended Players / `recommended_players` | List of positive integers | Collectarr form | Catalog Item | Yes | `recommended_players[]` | Collectarr-specific field set |
| Best Players / `best_players` | List of positive integers | Collectarr form | Catalog Item | Yes | `best_players[]` | Collectarr-specific field set |
| Play Time / `play_time` | Duration/range | Unconfirmed | Catalog Item | No | `play_time_minutes` | **Collectarr-specific** |
| Components / `components` | Ordered component list | Unconfirmed | Catalog Item | Yes | `components[]` | **Collectarr-specific**; contained data |
| Expansion / `expansion_for` | Catalog Item relationship | Unconfirmed | Catalog Item | Yes | `related_items[]` | **Collectarr-specific** |
| Barcode / `barcode` | Identifier text | Unconfirmed | Catalog Item | Yes | `identifiers[]` | Existing Collectarr inventory; not verified against CLZ |
| Cover / `cover` | Image reference | Collectarr form | Catalog Item | Yes | `images[]` | Collectarr-only; CLZ Board Games form unavailable |
| Completeness / `completeness` | User vocabulary | CLZ Games pre-fill proxy | Owned Copy | No | `kind_details.completeness` | Games ownership proxy only |
| Condition / `condition` | Vocabulary | CLZ Games proxy; exact field unconfirmed | Owned Copy | No | `condition` | Existing Collectarr inventory |
| Location / `location` | Location reference | CLZ Games pre-fill proxy | Owned Copy | No | `location_id` | Proxy concept |
| Purchase Date/Price/Store / `purchase_*` | Date / money / text | CLZ Games pre-fill proxy | Owned Copy | No | `purchase_date`, `purchase_price`, `purchase_store` | Proxy concepts |
| Sleeves / `has_sleeves` | Boolean | Collectarr form | Owned Copy | No | `kind_details.has_sleeves` | **Collectarr-only** |
| Painted Miniatures / `painted_miniatures` | Boolean | Collectarr form | Owned Copy | No | `kind_details.painted_miniatures` | **Collectarr-only** |

**Reference:** [CLZ Games ownership pre-fill](https://clz.com/games/mobile/whatsnew/2020). This ledger does not claim a CLZ Board Games form exists.

Common App-owned fields use the shared Owned Copy v1 set in the [ledger index](README.md). Board game plays are activity records, not Owned Copy state.

## Legacy field disposition

The v1 contract retains edition, publishers, designers, mechanics, categories, minimum/maximum/recommended/best player counts, play time, components, related-item links, identifiers, and images. It deliberately excludes original title, synopsis, minimum/maximum play-time range, minimum age, complexity weight, artists, families, themes, languages, BGG rating/count/rank, series identity, item number, physical-format labels, variant, free-form creator payload, provider links, and raw provider payload. These fields were exposed by the old provider-shaped metadata model but are outside the selected Board Games v1 field set. Expansion names/targets are represented only by `related_items[]`; no separate expansion tree remains.
