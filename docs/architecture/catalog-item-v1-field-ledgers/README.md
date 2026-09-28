# Catalog Item v1 Field Ledgers

These ledgers are the field inventory for the coordinated Catalog Item v1 cutover. They distinguish catalog facts from owned-copy facts and keep the field set for every kind visible before the storage reset.

Only the Music ledger is based on a saved CLZ Edit form. For Comics, Books, Movies, and video Games, official CLZ feature pages establish publicly described field concepts, not every Edit tab, field type, or form location. Their **v1 field choices are frozen for implementation**, while exact CLZ parity remains unconfirmed until saved Edit-form captures are available. Manga, Anime, TV, and Board Games have no dedicated CLZ product: their ledgers use a named proxy or an explicit Collectarr field set and mark Collectarr-only fields. None of these ledgers claims confirmed literal CLZ parity.

The `Core / App v1 key` column records the proposed shared catalog contract key for catalog fields and the App-only key for owned-copy fields. Existing model names and screens are evidence for inventory only; they do not grandfather old storage fields into v1.

## Ledgers

| Kind | Ledger | Evidence status | Reference |
|---|---|---|---|
| Music | [music](music.md) | Captured form inventory; visible fields confirmed | Saved CLZ Music album HTML |
| Comics | [comics](comics.md) | Provisional; public features only | CLZ Comics |
| Books | [books](books.md) | Provisional; public features only | CLZ Books |
| Movies | [movies](movies.md) | Provisional; public features only | CLZ Movies |
| Games | [games](games.md) | Provisional; public features only | CLZ Games |
| Manga | [manga](manga.md) | Provisional; Books is the proxy form | CLZ Books |
| Anime | [anime](anime.md) | Provisional; Movies is the proxy form | CLZ Movies |
| TV | [tv](tv.md) | Provisional; Movies is the proxy form | CLZ Movies |
| Board Games | [board-games](board-games.md) | Provisional; Games is the proxy form for ownership only | CLZ Games |

## Ledger rules

- One Catalog Item represents one collectible edition, version, issue variant, or release. Repeated tracks, discs, episodes, credits, and similar contents are contained data, not additional workspace roots.
- Each distinguishable owned copy has its own `OwnedCopyV1` record. A value that can differ between two copies belongs there.
- `repeats` describes whether the field is a list or repeatable child record. It does not create another top-level catalog entity.
- A `Collectarr-only` row is explicitly not a CLZ parity claim.
- The v1 key, type, ownership, and repetition decisions in each ledger define the implementation contract. Exact CLZ labels/keys, tab placement, and parity remain unconfirmed until the relevant saved Edit forms are captured and reconciled; captures may inform a later reviewed contract revision.
- Before removing any legacy model, account for every field it exposes with a v1 mapping or an explicit exclusion. Do not infer that an unlisted legacy field belongs in v1.

## Shared Owned Copy v1 fields

These App-only fields apply across the nine kinds. Each ledger adds any kind-specific copy details. Optional values remain absent when a copy has no value for them.

| Field | Type | Target | Repeats | App v1 key |
|---|---|---|---|---|
| Copy identity and Catalog Item reference | `OwnedCopyRef` plus `CatalogItemRef` | Owned Copy | No | `id`, `catalog_item` |
| Collection status | Closed enum (`in_collection`, `loaned`, `sold`) | Owned Copy | No | `status` |
| Added / Modified | Generated UTC timestamps | Owned Copy | No | `created_at`, `updated_at` |
| Index | Integer | Owned Copy | No | `index_number` |
| Location | Location reference | Owned Copy | No | `location_id` |
| Owner | `OwnedCopyOwnerV1` (`id`, `label`) | Owned Copy | No | `owner` |
| Digital | Boolean | Owned Copy | No | `is_digital` |
| Condition | Kind-specific vocabulary/value | Owned Copy | No | `condition` or the kind-specific details field |
| Purchase Date | Partial date | Owned Copy | No | `purchase_date` |
| Purchase Price | Decimal money plus currency | Owned Copy | No | `purchase_price` |
| Purchase Store | Text/organization | Owned Copy | No | `purchase_store` |
| Current Value | Decimal money plus currency | Owned Copy | No | `current_value` |
| Sale Date / Buyer / Price | Partial date / text / money | Owned Copy | No | `sold_at`, `sold_to`, `sale_price` |
| Rating | Integer | Owned Copy | No | `rating` |
| Notes | Text | Owned Copy | No | `notes` |
| Tags | Ordered string list | Owned Copy | Yes | `tags[]` |
| Personal Images | Image data and description | Owned Copy | Yes | `personal_images[]` |
| Custom Fields | Typed values defined by the user's custom-field schema | Owned Copy | Yes | `custom_fields[]` |

There is no `quantity` field on an Owned Copy. A bulk quantity at Add time creates that many rows, one per copy. Wishlist entries remain Catalog Item references without an Owned Copy. Tracking, reading, viewing, and listening events are App activity and reference a Catalog Item, with an optional Owned Copy reference. Activity and wishlist state are not stored in an Owned Copy's `status`.
