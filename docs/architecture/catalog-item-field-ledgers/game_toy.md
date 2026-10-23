# Toys field ledger

This inventory is a concrete kind (`game_toy`), independent of Games. Its
collection type is fixed. Renames preserve that type; ordinary collection
moves cannot convert an item to another inventory.

| Scope | Fields |
| --- | --- |
| Core catalog / Main | Title, Sort Title, Barcode, partial Release Date, Series; Type; Subtype |
| Core catalog / content | Description, external links, trailers, catalog cover |
| Personal copy | Loose/New; Box; Value and lock; PriceCharting ID; Condition; purchase facts; Owner, Notes, My Rating, Tags; status, index, quantity and location |
| Images | Figure Image / Box Image; additional personal images |

Serial numbers belong to the individual hardware copy and never enter Core.
Neither inventory exposes Games completion or storage fields. PriceCharting
refresh is deferred. Native CSV carries the complete typed entry JSON; a
guided CLZ Web XML mapping is available. Human-readable CLZ CSV mapping,
image attachments, loans and custom-field import remain open.

See [the living CLZ comparison](../../clz-parity.md) for verified UI workflows
and outstanding differences. Core migration 2 creates independent catalog
tables; local entries use the existing kind-scoped storage without a schema
change or reset.
