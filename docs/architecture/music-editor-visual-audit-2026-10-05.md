# Music editor visual audit, 2026-10-05

## Scope and method

Compared all ten Music Edit tabs in the saved CLZ Music Web editor with the
Windows Collectarr editor at 2560 × 1417 logical pixels. CLZ was rendered
locally with its own bundled Gilroy assets. Collectarr used a populated Music
fixture in a temporary in-memory database. Both dialog widths were 1200px.
The fixtures contain different albums, so the comparison covers the layout,
control styling, labels and interaction affordances rather than identical
values or image pixels. No fixture was saved to the user's database.

The captured reference and application screenshots are in the local audit
working directory (`C:/Users/saita/Desktop/tmp/collectarr-visual-audit`).
They are not bundled with the project because the CLZ capture includes its
UI assets and album artwork.

## Reference measurements

| Part | CLZ measurement |
| --- | ---: |
| Dialog width | 1200px |
| Title | 18px, bold |
| Tab strip | 32px tall, 14px text |
| Input | 34px tall, 14px text |
| Field label | 13px, bold |
| Group legend | 16.8px, bold |
| Panel background | `#383838` |
| Input background | `#444444` |

The shared Collectarr editor already has matching width, font sizes and the
custom Collectarr Sans family. Its dark panel and input colors are close to
the CLZ reference. The orange header uses dark text for stronger contrast;
that difference is deliberate.

## Tab-by-tab findings

| Tab | Observed comparison | Work in this pass |
| --- | --- | --- |
| Main | Three independent columns, fields and status strip correspond closely. Collectarr has extra field actions and a proposal action. The initial App capture had empty space between tabs and fields. | Removed empty feedback padding from every normal edit tab. |
| Details | Packaging/Vinyl groups and the remaining two columns follow CLZ. Collectarr fields are slightly more spread vertically. | The shared padding correction moves the group and fields closer to the reference. |
| Classical | Composer, Composition, Conductor, Orchestra and Chorus match the CLZ grouping. The initial App capture started lower. | Shared padding correction. |
| People | Credits and Musicians use the same two group layout and fields. The initial App capture started lower. | Shared padding correction. |
| Tracks | App input rows were much taller than CLZ rows. A populated disc overflowed at the dialog bottom and concealed later tracks/actions. | Reduced track input and row padding; the hosted renderer now scrolls within the available body height. |
| Personal | Two columns and most CLZ fields are present. App includes Currency, Grade and local listening controls. Longer data caused a 49px bottom overflow. | The hosted renderer now scrolls within the available body height. |
| Custom Fields | Empty state follows the same basic tab and shared status/footer. The wording differs because Collectarr links to Settings. | Shared padding correction. |
| Covers | Two cover panels and edit actions follow CLZ. The temporary App fixture had no cover binaries, so artwork scaling could not be compared. An empty panel caused a 44px bottom overflow. | The hosted renderer now scrolls within the available body height. |
| My Images | App's drop target occupied almost the full dialog width; CLZ uses a small centered target with a short instruction above it. | Added the instruction and centered a 190px wide target. Upload and Paste remain available. |
| Links | URL/Description table and New Link action follow CLZ. The fixture had no links, so populated row height and drag affordances remain unchecked. | Shared padding correction. |

## Shared chrome differences

- The CLZ footer has filled Previous, Next and Cancel controls. Collectarr's
  earlier App capture made the navigation buttons blend into the footer.
  The footer now resolves its button fills from the editor palette.
- Collectarr has a **Propose to Core** action and status icons. These are
  application-specific operations and stay visible.
- Collectarr allows users to reorder tabs. The capture used a saved tab order
  with Covers before Custom Fields; CLZ's saved order is the reverse; its tab markup is also sortable.
- CLZ's populated Covers tab and blank App Covers tab are different fixture
  states. This audit does not treat the absent artwork as a layout defect.

## Verification and limits

Scoped Dart analysis of the affected editor, Music track/image and footer
files reported no issues. The reference and initial App captures cover all
ten tabs. The latest layout edits compiled to a debug kernel with the Dart
frontend server, but the restricted environment did not permit a normal
Flutter SDK build or a reliable post-change Windows capture. The overflow
correction and compact track spacing therefore still need a rendered
recheck. No save/reopen, keyboard navigation, smaller viewport or text-scale
interaction check was performed in this visual pass.


## Ordered pick-list behavior correction

The saved `full_editor.mhtml` identifies Artist, Composer, Conductor, Chorus,
Composition, Orchestra, Songwriter, Producer, Engineer, Studio and Signed By
as managed lists. Their selected values are display rows with a remove button,
not inline text inputs. The entire name row is a sortable handle. The saved
CSS uses a grab cursor and a dragged-row scale of 1.025 with a one-degree tilt.
Musicians use the same name selection plus instrument tags and a separate
instrument selection action.

Add and Edit now share ordered managed selection for these Music fields.
The plus button and empty field open the existing persistent pick-list picker;
cancelling adds no draft row. Existing local entries contribute name choices,
including values that predate the new dictionaries. New dictionary values are
saved only through the explicit New action. Selected names are read-only,
removable and reordered by dragging their name area. IDs, existing sort names,
credit references and instruments follow their rows. Studio and Signed By
retain selection order. Instrument values use selectable, removable tags.
Music name dictionaries are registered for the shared pick-list manager, with
local usage projection and merge handling.

Limits: the MHTML contains no JavaScript resources and no open name picker,
so exact picker interactions cannot be replayed from the saved file. The App
picker selects one value per opening and does not have CLZ's person dictionary
sort-name editor. Existing item sort names are preserved. Runtime drag/drop,
save/reopen and final pixel parity still require a rendered check; source
analysis does not establish these behaviors in a running Windows build.


## Multi-value tag behavior correction

Genre in the MHTML is a Bootstrap tags input: neutral 26px tags with 14px text,
an inline text entry, individual remove actions, and a separate 34px list
button. The saved CSS floats tags and lets the control grow into multiple
rows. It does not mark the Genre tag container as sortable like Artist rows.

The shared multi-value field now wraps tags, grows with its contents and keeps
the list button at the top right. Accent-colored Material chips and horizontal
scrolling have been replaced with compact neutral tags. Inline autocomplete
suggests enabled, unselected vocabulary choices. Enter selects a highlighted
suggestion or commits the entered value when custom values are allowed;
Backspace in an empty input removes the final selected tag. Duplicate additions
are ignored. Picker cancellation leaves the selection unchanged, and confirming
checkboxes retains the order of existing selected values. Parent updates now
compare value order as well as membership. Music Genre, Sound and personal Tags
inherit these changes through the existing common form renderer. Musician
instrument tags reuse the same chip presentation and multi-selection picker.

Autocomplete and keyboard details are App implementations consistent with the
saved typeahead/tag markup; the absent CLZ JavaScript prevents confirmation of
its precise key and blur rules. No runtime interaction or final screenshot
comparison was performed for this change.
