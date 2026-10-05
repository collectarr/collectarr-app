# Pick-list manager alignment with CLZ Music

## Reference and scope

Reference: `My Albums - CLZ Music Web.mhtml`, saved on 2026-10-05 at 12:55.
The snapshot contains the Manage Artists modal, its manage/merge/select CSS,
32 Music dictionaries and five Artist rows. Saved markup cannot establish the
live CLZ server behavior; mutation semantics below are Collectarr's contract.

## Implemented UI

- Shared manager width is 720 px, with available-height constraints and scrolling.
- The header follows the selected dictionary and uses the App accent with its
  contrast-adjusted foreground. Header height is 38 px; its title is 18 px Bold.
  Close is a plain cross rather than an outlined square button.
- Search filters values and sort names, with integrated clear/search control.
- Standalone management shows Search on the left, a count badge in the center
  and the 200 px list selector on the right. Selection instead shows Search on
  the left and New / Manage together on the right; it has no count badge or list
  selector. Controls wrap by group on narrow windows. Technical keys, scope chips, kind sidebar and the global-values switch
  have been removed from the manager.
- One table renders manage, single-selection, multiple-selection and merge modes.
  Name, Sort Name and Count have actual ascending/descending sorting. Name and
  Count use 14 px Medium; the secondary Sort Name uses 12 px Medium. Icon columns
  are 36 px and Count is 68 px, with thin cell and row borders. The table header is 48 px, matching the snapshot's
  measured approximately 47.6 px. Rows grow with content and text scaling.
- Edit uses a muted pencil before the name; remove uses a muted cross. The name
  cell also opens editing. Icon buttons have transparent normal backgrounds.
- Merge Mode uses checkboxes, a selection instruction, Cancel and a destination
  menu containing selected values. Merge confirmation states the number of
  affected local entries. The destination action and selections use App accent.
- New-value creation remains in selection mode, matching its role in CLZ.
- Manage from a selector changes the existing dialog body, rather than opening
  another manager route. This mode hides the count and list switcher. Back is
  on the left of the footer and restores selection mode, preserving pending
  choices and applying any dictionary replacements.
- Footer padding is 10 px. Actions are 32 px high, at least 100 px wide and
  grouped with a 5 px gap. Standalone management has Merge Mode on the right;
  multiple selection has only Save on the right. Merge has a message on the
  left and neutral Cancel / accent Merge to on the right, with the destination
  menu opening upwards. Editor Cancel / Save use the same footer dimensions.
- Shared pick-list chrome defines the shell, header, grouped toolbar, counter
  and button style. Other modal headers keep their existing default title style.
- Errors have Retry and mutations disable competing actions with progress.

## Dictionaries and form wiring

Music now exposes every dictionary represented in the snapshot, including
Box Set, Extra, SPARS, Image Type and Location. Extra, Box Set and SPARS fields
use their canonical `music.*` vocabulary keys in both Add and Edit. Image Type
uses the shared managed field and persistent choices. Extra retains its current
`||` serialization and is treated as a multiple-value dictionary.

Labels match the dictionary menu: Label, Loaned To, Signee, Sound, Tag and
Purchase Store. Countries display human-readable names while retaining canonical
country values. Grade, Credit Role, Sold To and custom fields remain useful App
extensions. Collection Status is a fixed workflow state, not a user-editable
pick-list dictionary, and is omitted from this manager.

## Data contract

- Opening/searching a list never deletes or writes dictionary values. The unused
  automatic cleanup API and obsolete dictionary drag-reorder API were removed.
- Manager and selectors combine persisted choices, built-ins and existing active
  local values. Reading those values does not mutate the dictionary.
- Count means active local library entries using the value, once per entry.
  Duplicate occurrences within one entry do not increase Count. Core snapshots
  and deleted local entries are excluded. Kind contributors count in bulk.
- Music metadata mutations are field-scoped and preserve unrelated metadata,
  credit identities, discs and tracks. Scalar, multiple-value, people/classical,
  instrument, genre, storage-device and personal dictionaries are supported.
- Rename updates references and rejects a collision with another visible name;
  use Merge Mode to combine those names. Sort Name is persisted and changes to
  Music credit sort names propagate to their corresponding local credits.
- Delete confirms affected entries, removes just the selected value and suppresses
  it in composed defaults. Removing an image category clears its type while
  retaining image bytes, ordering and descriptions. Loan records are retained.
- Merge replaces only selected sources and retains the target's dictionary
  identity, Sort Name and position. Multiple-value replacements remove empty
  values and deduplicate normalized results.
- Custom-field changes address the exact definition ID, including multiple-value
  JSON. They cannot alter another field with identical text.
- Location changes address location IDs, preserve assignments on rename and
  reassign children on merge/delete. Parent-to-descendant merges avoid cycles.
  Locations are shared infrastructure and managed globally.
- Other dictionaries opened from a kind shelf apply within that kind, including
  scoped overrides of global values. Global entry points apply across kinds.
- Dictionary writes and referenced-entry changes run in one transaction. Changed
  entry snapshots are queued for sync. Open selectors receive list-scoped changes
  so their pending selections follow rename/merge operations.
- A contributor that cannot replace a referenced value causes the transaction to
  roll back; dictionary rows are never silently removed while references survive.
  This safeguard also covers non-Music contributors with narrower mutation support.

## Local persistence

`pick_list_values_cache` has nullable `sort_name` and Boolean `is_hidden` columns.
`is_hidden` represents an explicit user removal, not a legacy record. Capturing
inferred vocabulary values respects these removals; explicit New can restore a
name. Local SQLite storage version is 2 and adds these columns to version 1
without losing user data. Core document schemas remain unchanged.

## Verification and intentional differences

An isolated Web preview rendered the actual manager with the snapshot's Artist
names and usage counts (4, 12, 4, 9, 8), including a 380 px viewport. Reference
HTML/CSS were rendered locally and measured. Follow-up captures also compare
selection, management entered from a selector, the upward merge destination
menu, New, and return to pending selection via Back. No runtime exceptions
were reported during those preview interactions. The App uses Collectarr Sans and
Material icons, so glyph shapes differ from licensed Gilroy/Font Awesome. The
configured accent and contrast policy are intentional differences.

Scoped production-code analysis is the primary validation. No automated tests
were added or run. The actual manager Web preview compiles successfully. A transient rebuild failure
from concurrent Game workspace numeric-type changes was resolved before the final
preview build. Native Windows rasterization and live CLZ interactions are not
established by the saved snapshot.
