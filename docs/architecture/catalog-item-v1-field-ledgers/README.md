# Catalog Item v1 Field Ledgers

These ledgers are the field inventory for the coordinated Catalog Item v1 cutover. They distinguish catalog facts from owned-copy facts and keep the field set for every kind visible before the storage reset.

Only the Music ledger is based on a saved CLZ Edit form. For Comics, Books, Movies, and video Games, official CLZ feature pages establish publicly described field concepts, not every Edit tab, field type, or form location. Their rows are provisional until saved Edit-form captures are available. Manga, Anime, TV, and Board Games have no dedicated CLZ product: the ledgers name a proxy reference and explicitly mark Collectarr-only fields. None of these provisional rows should be presented as confirmed literal CLZ parity.

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
- Final field types, exact CLZ labels/keys, tab placement, and parity remain unconfirmed until the relevant saved Edit forms are captured and reconciled.
