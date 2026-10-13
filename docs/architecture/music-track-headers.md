# Music track headers

Core and App preserve the complete ordered `discs[].tracks[]` row list.
A row contains `is_header`, `parent_header_id`, and `indent_level`, alongside
its identity, title, and `position_order`. No additional database table is needed.

- A header has no display position, artist, or duration.
- Playable track positions remain unique within each disc; headers may all use
  an empty position.
- Each parent must be an active preceding header in the same disc. Indentation
  is 0?8, with child depth exactly one greater than the parent's depth.
- Root rows have depth zero and no parent. The hierarchy prevents dangling
  references, cross-disc parents, forward references, and cycles.
- Header rows do not contribute to playable track counts or duration totals.
- Manual Add, proposals, and Edit preserve header/component UUIDs and derive
  row order from the current ordered list.

App-owned storage placement, condition, purchases, listening events, and local
file details remain outside the Core catalog document.
