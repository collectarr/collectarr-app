# Music UI comparison with the saved CLZ reference

Date: 2026-10-02

## Scope and evidence

Reference: `C:\Users\saita\Desktop\tmp\My Albums - CLZ Music Web.html`, including its saved CSS and JavaScript assets. The saved editor contains all ten tab panels, not just the currently selected Details tab. The album in this file is **Lordi YLE TV2 Dokumentti / Lordi**.

Comparison target: the active App Music Catalog Item editor, Collection Item editor, shared field controls, shared dialog shell, and Music workspace contributors. This supplements [the project cleanup audit](cleanup-audit-2026-10-02.md).

Evidence levels:

- **Reference DOM/CSS:** exact labels, field names, grouping, controls and actions present in the saved page.
- **Reference rendering:** Main and Details rendered locally in headless Chrome, with application scripts removed from a temporary copy. Original files were untouched. Saved icon/font resources are incomplete: some icons render as missing glyphs, and the CSS declares Gilroy without proving that the font loaded. These screenshots cannot establish exact font glyph widths.
- **App source:** current active implementations and their layout/style constants. The App was not launched for this comparison. There is no paired screenshot or measured pixel diff of the current App.
- **Behavior:** App wiring was inspected; CLZ controls and local handlers were inspected without submitting changes to CLZ. The saved document does not establish every live-service behavior.

Temporary reference artifacts, outside the repository:

- `C:\Users\saita\Desktop\tmp\clz-music-main-audit.png`
- `C:\Users\saita\Desktop\tmp\clz-music-details-audit.png`
- `C:\Users\saita\Desktop\tmp\clz-audit-main-dom.html`
- `C:\Users\saita\Desktop\tmp\clz-audit-dom-metrics.html`

This is a field-by-field and structural comparison, with measured reference styles. Pixel-perfect parity remains unverified until the current App is rendered beside the reference at matching viewport and scale.

**Concurrent changes:** during this audit, uncommitted Music mapper/DTO/domain/form changes appeared in the shared working tree. The final source check shows the Format adapter now writes `format: _formFormat(values)` and initializes form values from `album.format`. The original no-op finding is therefore being addressed; its runtime round trip is not verified here. Treat the earlier cleanup report as a dated snapshot and review the in-flight serialization fixes before implementing duplicate fixes.

## Main conclusion

The Catalog Item editor already has the same default tab names/order and approximately the same desktop Main field placement. It does **not** reproduce the complete CLZ editing experience:

1. CLZ has one editor containing catalog, personal, disc and image fields. App splits these between Catalog Item and Collection Item editors.
2. CLZ always displays Collection Status, Index, Quantity and Location above the action footer. App does not supply that strip in either Music editor.
3. Details has different groups, controls and additional fields.
4. Personal in the catalog editor means listening status/rating/notes, while CLZ Personal contains ownership, purchase and listening fields together.
5. Similar-looking controls have different semantics: partial dates, multi-artist editing, people selection, rating range and image input.

One visual editor can still write to separate Catalog Item, Collection Item and user tracking stores. UI grouping does not require merging their schemas or sending personal data to Core.

## Active source map

| Responsibility | App source |
| --- | --- |
| Dispatch between catalog and collection editors | `lib/features/library/kinds/music/edit/music_edit_contribution.dart` |
| Catalog editor and extra tab assembly | `lib/features/library/kinds/music/edit/music_album_edit_dialog.dart` |
| Main/Details schema | `lib/features/library/kinds/music/edit/music_album_edit_schema.dart` |
| Catalog controls and labels | `lib/features/library/kinds/music/forms/music_catalog_field_specs.dart` |
| Catalog draft-to-model conversion | `lib/features/library/kinds/music/forms/music_catalog_form_adapters.dart` |
| Collection editor | `lib/features/library/kinds/music/edit/music_collection_item_edit_dialog.dart` |
| Personal copy schema | `lib/features/library/kinds/music/edit/music_owned_edit_schema.dart` |
| Personal disc fields | `lib/features/library/kinds/music/edit/music_collection_item_media_tab.dart` |
| Catalog Personal tab | `lib/features/library/kinds/music/edit/music_album_personal_tab.dart` |
| Classical/People | `lib/features/library/kinds/music/edit/music_album_credits_tab.dart` |
| Tracks | `lib/features/library/kinds/music/edit/music_album_structure_tabs.dart` |
| Covers/My Images | `lib/features/library/kinds/music/edit/music_album_images_tabs.dart` |
| Links | `lib/features/library/kinds/music/edit/music_album_images_links_tab.dart` |
| Shared edit host | `lib/features/library/edit/schema/library_edit_schema_dialog.dart` |
| Shared layout renderer | `lib/features/library/edit/schema/edit_schema_renderer.dart` |
| Header and action footer | `lib/features/library/edit/shell/library_edit_scaffold.dart` |
| Shared controls | `lib/features/library/schema/library_field_spec_control_builder.dart` |

## 1. Dialog chrome and layout

| Element | CLZ reference | Current App | Required parity work |
| --- | --- | --- | --- |
| Position | Centered horizontally, near top; reference measured top offset 10 px | Top-center, inset top 8 px | Match desktop positioning after paired rendering |
| Width | Measured about 1011 px at an actual inner viewport of 1424 × 805 | Standard shell max width 1100, or 1180 above viewport width 1440 | Define matching responsive width rules; a max-width constant alone is not a rendered measurement |
| Header | Orange `#F2932F`; measured height 38 px | Same Music accent; minimum height 48 px | Reduce height if exact reference proportions are required |
| Title | `Title / Artist`; CSS 18 px, weight 700 | Same title convention; 14 px, weight 700, leading kind icon | Increase title size; reference has no leading kind icon |
| Header foreground | White on orange | Contrast helper chooses light/dark foreground for accent | Preserve accessible contrast; document this deliberate departure from CLZ |
| Tab order | Main, Details, Classical, People, Tracks, Personal, Custom Fields, Covers, My Images, Links | Same default catalog order | Preserve order and reorder support |
| Tab height | Measured 32 px | Shared strip token 32 px | Already close; check padding/background/icon details visually |
| Tab font | Reference CSS 14 px | Shared styled labels 13 px, selected weight 700 / otherwise 600 | Normalize size after screenshot comparison |
| Field labels | Separate labels above inputs | Text controls use `InputDecoration.labelText` with standard floating-label behavior | Add an external-label variant to shared controls |
| Input height | Main text input measured 34 px | Shared form control minimum 40 px; decorated fields can be taller | Adopt compact desktop tokens without breaking text scaling |
| Input background | Reference `#444444` | Default edit input fill `palette.surface`, normally `#303030` | Match reference field/surface separation through palette tokens |
| Body surfaces | Reference dark gray body; header/tab/footer visually separate | Default shell/body/extra-tab surfaces use several palette levels | Use one intentional surface hierarchy for all ten tabs |
| Body spacing | Reference rows have 14 px horizontal gutters | Schema Wrap uses 12 px spacing and 16 px horizontal padding | Match with shared spacing tokens |
| Permanent personal strip | Collection Status, Index, Quantity, Location | Not provided by Music editors | Expose a shared pre-footer slot and populate it with selected-copy fields |
| Cancel/Save | 100 px wide, reference Save 32 px high; blue `#5EB1DE` | Desktop 112 px wide, 36 px token; Save uses Music orange and a save icon | Match reference action shape/color separately from kind accent |
| Previous/Next | Bottom-left labeled buttons | Labeled buttons in standard desktop shell; disabled if callback absent | Verify enabled state and continuity of tab/copy selection |
| Core proposal | No counterpart in saved CLZ footer | `Propose to Core` when correction source is supplied | Keep App-specific permission/proposal behavior; account for footer width |
| Scrolling | Tab content changes while lower ownership strip remains present | Outer schema ListView and several inner EditTabShell scroll views | Establish one bounded content scroller and fixed lower strips |

The CLZ Main layout and App schema both intend this desktop arrangement:

| Row | Left half | Right quarter | Right quarter |
| --- | --- | --- | --- |
| 1 | Title | Release Date | Original Release Date |
| 2 | Sort Title | Label | Recording Date |
| 3 | Subtitle | Format | Barcode |
| 4 | Artist | Cat No spanning the right half | |
| 5 | Empty left half | Genre spanning the right half | |

App implements this using four-column spans and a full-width right-aligned Genre slot. Below available content width 960 it changes to two columns, and below 680 to one. Verify those transitions against CLZ before claiming responsive parity.

## 2. Main: every reference field

| CLZ label | CLZ field name | App field ID / label | Difference |
| --- | --- | --- | --- |
| Title | `title` | `title` / Title | Text field exists; floating-label chrome differs; CLZ also exposes title capitalization assistance |
| Sort Title | `sorttitle` | `sort_title` / Sort Title | Label already matches; compare sort-title assistance separately |
| Subtitle | `subtitle` | `subtitle` / Subtitle | Present; chrome differs |
| Artist | Ordered editable artist list | `artist` / Artist | App is one text field; CLZ has add/remove/reorder entries and name/sort-name data |
| Release Date | `releasedate` | `release_date` / Release date | CLZ separate YYYY/MM/DD inputs; App complete-date picker; capitalization differs |
| Original Release Date | `originalreleasedate` | `original_release_date` / Original release date | Same partial-date and capitalization differences |
| Label | `label` | `record_label` / Label | CLZ inline dropdown plus management action; App Edit uses shared pick-list dialog interaction |
| Recording Date | `recordingdate` | `recording_date` / Recording date | Same partial-date and capitalization differences |
| Format | `format` | `format` / Format | Original adapter ignored edits; concurrent uncommitted changes now map values to `album.format`. Verify the complete save/reopen round trip |
| Barcode | `barcode` | `barcode` / Barcode | Present |
| Cat No | `catnr` | `catalog_number` / Cat No | Present |
| Genre | `genre` | `genres` / Genre | App multi-vocabulary control exists; compare inline chips, removal and management interaction |

**Date correctness:** the reference stores `2007-00-00` with only the year displayed. It also contains a purchase date `0000-09-22`, meaning month/day without a year. App Edit's DateTime fields cannot express these precision states. A shared partial-date control/model must explicitly define permitted components; supporting only `YYYY`, `YYYY-MM`, `YYYY-MM-DD` is insufficient for the second example.

**Format correctness:** the initial inspection found `MusicAlbumFormAdapter.create/update` did not consume `physicalFormat` or `physicalFormatLabel`. Concurrent changes now do so through `_formFormat`. Review these changes and verify authoritative catalog persistence before adjusting the visual control. Define consistency with the separate per-disc Medium type field.

## 3. Details: every reference field

CLZ has a left Packaging fieldset, then Studio, a Country/Is Live row, and Sound. The right side has a Vinyl fieldset, then Extra, SPARS and Box Set. App currently has one flat `Additional details` section.

| CLZ label | CLZ field name | App equivalent | Difference |
| --- | --- | --- | --- |
| Packaging | `packaging` | `packaging` / Packaging | Present; Packaging fieldset missing |
| Package/Sleeve Condition | `condition` | Copy editor `condition` / Condition; also a separate Grade field | Outside Details; generic Condition/Grade is not proven equivalent to sleeve condition |
| Media Condition | `mediacondition` | Copy editor Disc details / Media condition | Outside Details; per-disc ownership mapping needs explicit policy |
| Studio | Ordered list | `studios` / Studio | Present as multi-vocabulary field; list layout/actions differ |
| Country | `country` | `country` / Country | Present; layout and pick-list interaction differ |
| Is Live | `islive` | `is_live` / Recording type | CLZ No/Yes segmented buttons; App Studio recording/Live recording select |
| Sound | Ordered list | `sound_types` / Sound | Present; inline list interaction differs |
| Vinyl Color | `vinylcolor` | `vinyl_color` / Vinyl color | Present; capitalization and Vinyl fieldset differ |
| Vinyl Weight | `vinylweight` | `vinyl_weight` / Vinyl weight | CLZ numeric input; App text field |
| RPM | `rpm` | `rpm` / RPM | CLZ N/A, 33, 45, 78 segmented choices; App unrestricted number input |
| Extra | `extra` | `extra` / Extra | CLZ editable tag list; App text field |
| SPARS | `sparscode` | `spars` / SPARS | CLZ managed choices; App text field |
| Box Set | `boxset` | `box_set_ref`, `box_set_name`, `box_set_position` | App shows three fields instead of one managed Box Set selector |

App Details also exposes fields absent from this CLZ form: **Original title, Language, Release type, Release status, UPC, Cover image URL**. These are extra UI/contract surface, not missing CLZ functionality. Exact parity requires deciding their disposition against the agreed CLZ catalog baseline; do not silently delete persisted data just to rearrange a form.

App also exposes technical attributes in Disc details inside Tracks (Sound type, Vinyl color/weight, RPM, SPARS and matrix sides). Identify which are album defaults and which are genuine per-disc values before retaining multiple editable locations.

## 4. Classical and People

| CLZ group/field | App | Difference |
| --- | --- | --- |
| Classical left: Composer, Conductor, Chorus | Same role labels | Approximate two-column grouping already exists |
| Classical right: Composition, Orchestra | Same role labels | Composition is currently treated through the same person contribution editor; establish correct semantics |
| People left fieldset: Credits / Songwriter, Producer, Engineer | Same fieldset and roles | Approximate grouping already exists |
| People right fieldset: Musicians / Musician | Same fieldset and role | Approximate grouping already exists |
| Add/remove/reorder names | Role add/remove controls and credit cards | App cards expose Name and Canonical person ID; CLZ presents compact editable lists |
| Enter a person | Reference name/sort-name list workflow | App requires a manually entered canonical ID to save; this is a user-flow mismatch |

Build reusable ordered entity/name list controls. Resolve or create entity references through an explicit selection workflow where the model requires canonical entities. Preserve sorting and display names. Do not solve parity by discarding valid IDs or assigning Composition to a person without a domain decision.

## 5. Tracks and disc fields

| CLZ element | App | Difference |
| --- | --- | --- |
| Disc tabs, Add Disc, delete disc | Disc ChoiceChips with track counts; add/remove actions | Behavior present; tab/chip appearance and labels differ |
| Disc Title | Disc title | Present; capitalization differs |
| Storage Device | Copy Disc details / Storage device | In another dialog |
| Slot | Copy Disc details / Storage slot | In another dialog and renamed |
| Matrix No. Side A / Side B | Tracks expandable technical fields; copy editor also has Matrix / runout numbers | Different placement and overlapping ownership/technical representations |
| Track columns Title, Artist, Length | Same main columns, plus selection/order controls | Table capability largely present; compare row heights, drag affordances and header padding visually |
| Selection: Cancel, All, count, Autocap, Move to other disc, Remove | Corresponding bulk operations exist | Functional parity should be exercised after round-trip fixes |
| Add Header / Add Track | Both exist | Present |
| Medium type | App adds Medium type | No corresponding visible disc field in this saved CLZ editor |

A unified modal must bind personal disc fields to the selected Collection Item, even when they visually appear beside shared track metadata. Adding/removing/reordering discs must preserve the existing personal-disc remapping behavior.

## 6. Personal and the permanent lower strip

| CLZ label | CLZ field name | Current App location | Difference |
| --- | --- | --- | --- |
| Purchase Date | `purchased` | Copy Personal / Purchase date | Separate dialog; complete-date input cannot express all reference partial states |
| Purchase Price | `purchaseprice` | Copy Personal / Purchase price | Separate dialog; App has explicit Currency code field |
| Purchase Store | `purchasestore` | Copy Personal / Purchase store | Separate dialog; plain text rather than managed pick-list field |
| Current Value | `currentvalue` | Copy Personal / Current value | Separate dialog |
| Tags | `tags` | Copy Personal / Tags | Separate dialog; text rather than inline tag chips |
| Last Cleaned Date | `lastcleaneddate` | Copy Personal / Last cleaned | Separate dialog; label differs |
| Signed by | Ordered name list | Copy Personal / Signed by | Separate dialog; text rather than ordered names |
| Owner | `owner` | Copy Personal / Owner | Separate dialog; text rather than managed pick list |
| My Rating (0 /10) | `rating` | Catalog Personal / Rating | App parses integer and clamps 0–5; CLZ range is 0–10 |
| Notes | `notes` | Catalog Personal tracking notes AND Copy Personal personal notes | Two stores and meanings; choose intended binding explicitly |
| Played History / total plays | History component | Not mounted in active Music Edit | `MusicCatalogListeningTab` exists but has no mounting reference; catalog Log listen action exists elsewhere |
| Mark as listened | Button | Not in active Personal tab | Mount the catalog listening history/action in the editor |
| Collection Status | `status` | Copy Personal / Collection status | Plain text; no permanent strip or constrained status selector |
| Index | `indexnr` | Copy Personal / Index | No permanent strip |
| Quantity | `quantity` | No Music editor control | Reconcile with multiple independently stored copies; do not invent a shared catalog quantity |
| Location | `location` | Copy Personal / Location | Text/ID input rather than managed picker; no permanent strip |

App additionally shows listening Status, Copy type, Grade, Currency code and Sale details. CLZ has sale-related collection states in its status menu, but this saved Personal panel does not expose the App's Sold at/Sell price/Sold to fields.

## 7. Covers, My Images, Custom Fields and Links

| Reference feature | Current App | Difference/action |
| --- | --- | --- |
| Front and Back Cover side by side | Both editor panels exist | Back panel is passed null Core/default URLs, despite a model back-cover URL |
| Find Online | Opens `musicbrainz.org/release/{albumId}` | Stale provider behavior and invalid assumption that App catalog IDs are MusicBrainz release IDs; remove under the accepted provider-removal policy |
| Upload / Remove / Restore | Present with conditional combined action labels | CLZ separates compact toolbar actions; App uses Restore Core Cover/Remove Core Cover labels |
| Crop / Rotate, Reset, Apply | Separate crop editor exists | Verify toolbar sequence and source/default restore independently for each cover |
| Narrow cover layout | Row switches to Column below 680 | Same Expanded children are reused in a scrollable Column; correct flex constraints before parity work |
| My Images max 5, description and type | Catalog image editor implements max 5, description/type and reordering | Separate generic copy My Images also exists; choose ownership/storage target for personal images |
| Drop, paste or click image target | App displays similar text | This Music target is a Text widget; visible implementation adds files through Add image/openFile, without drop/paste handlers |
| Custom Fields | Catalog editor mounts shared custom field section | Saved CLZ has no field definitions, only instructions; populated-field parity cannot be determined from this reference |
| Links URL / Description | Shared editable links table | Main structure exists; selection, add/remove and reorder need visual/behavior review |

## 8. Workspace comparison outside Edit

The saved workspace is useful as a layout reference, but it captures one configuration, not every view mode or popup. The earlier App UI and CLZ are separate references; restoring the earlier App toolbar does not automatically produce CLZ parity.

| Area | Saved CLZ evidence | Current App evidence / remaining work |
| --- | --- | --- |
| Sidebar | Artist folders, Search artist, folder counts/list | Shared workspace sidebar/folder machinery exists; compare exact folder header and spacing in paired screenshots |
| Search target | Saved input says Search tracks; a search-type control is present | Music exposes Albums & Tracks, Albums, Tracks; verify selection, placeholder, query routing and inspector highlighting together |
| Add action | Add Albums | App manual/Core catalog Add flow should remain; CLZ provider behavior is outside the accepted App scope |
| View/sort/layout controls | Saved controls include View, Change Sorting, Sorting Favorites and Layout | Shared toolbar supports view presets, sorting, grouping and details placement; popup contents/ordering need reference states beyond the saved closed menus |
| Cover size | Saved range 110–330, current value 330; default shelf/image heights 220/175 | App has cover-size controls and small/large presets; reconcile units before copying numeric values |
| Inspector | Right-side detail surface with covers and metadata | Active Music inspector uses generic contributors and track list; earlier Music inspector file is not the active implementation |
| Track search highlighting | Saved search is tracks-specific; empty query | Current active track list lacks search-query/highlight input. This is a known earlier-App regression; this empty-query CLZ snapshot alone cannot prove CLZ highlight behavior |

Full workspace pixel comparison needs screenshots of both applications with the same data, viewport, text scale, selected item, view mode, grouping and inspector placement. Closed-menu HTML cannot establish every hidden toolbar option.

## 9. Explicit implementation sequence

### Phase 1 — Fix correctness prerequisites

1. Review the concurrent Music serialization/mapper changes against the round-trip findings in the main cleanup audit; fix any remaining ordered disc/track defects.
2. Verify the concurrent Main Format mapping persists to the authoritative flat catalog field. Define consistency with per-disc types.
3. Define lossless partial-date components, including missing-year month/day; use the same typed control/model in Add and Edit.
4. Fix Back Cover source/restore binding and narrow Covers layout.
5. Remove MusicBrainz Find Online from the active cover editor. Do not reintroduce provider import/search to reproduce CLZ.

### Phase 2 — Compose one visual Music editor

1. Extend the common edit host to accept a typed selected-copy context and persistent pre-footer content.
2. Resolve the selected Collection Item before opening the editor. With multiple copies, provide explicit copy selection; with no copy, show catalog editing with an intentional disabled/empty personal state.
3. Compose catalog, selected-copy and user-tracking drafts in a Music contribution mounted through the shared host. Reuse field/control definitions; do not copy the old entire dialog or create an alternative shell.
4. Keep the ten CLZ tabs in the existing default order. Personal and Tracks may contain fields saved to different stores.
5. Bind Collection Status, Index and Location to the selected copy in the fixed strip. Specify Quantity as collection-copy management consistent with independently editable copies.
6. Route local save, shared catalog proposals and editor/admin actions separately according to existing permissions. Viewer personal/local catalog edits must remain possible; personal values must never enter Core proposals.
7. Make draft changes cancelable. Plan cross-store save ordering and failure handling; do not persist images/history/copy edits early while presenting them as an unsaved draft.

### Phase 3 — Match field structures and controls

1. Main: ordered artists, compact managed pick lists, title/sort-title assistance, separate partial date components.
2. Details: recreate Packaging/Vinyl fieldsets and the exact row placements. Use segmented Is Live/RPM, numeric Vinyl Weight, tag-list Extra and managed SPARS/Box Set controls.
3. Classical/People: use compact ordered entity/name lists; replace manually entered canonical-ID boxes with a usable entity workflow.
4. Tracks: keep the bulk/table functions; place Disc Title, Storage Device, Slot and matrix sides as in the reference, with explicit storage ownership.
5. Personal: bind purchase/value/tags/cleaning/signature/owner fields to the selected copy; mount listening history; settle rating range and notes ownership once.
6. Images: use the chosen personal image target, implement real drop/paste/click or change the affordance text, and preserve per-side restore/crop behavior.
7. Decide disposition of App-only Details fields against the catalog contract before removing them. Avoid silently dropping stored fields in the UI layer.

### Phase 4 — Match shared visual tokens

1. Add a compact desktop external-label control variant rather than per-kind styling copies.
2. Adjust shared header/title, tab labels, input height, row spacing and footer dimensions using paired measurements.
3. Define separate kind-header and primary-action colors: CLZ uses orange header and blue Save.
4. Keep contrast selection and scalable text. CLZ's white-on-orange header is a visual reference, not an accessibility requirement.
5. Eliminate nested unbounded scrolling; keep tabs, ownership strip and actions usable at reduced viewport sizes.
6. Apply shared primitives across kinds while keeping each kind's appropriate fields and labels.

### Phase 5 — Verify parity and permissions

When implementing this plan, verify:

- Main/Details/Classical/People/Tracks/Personal/Covers/My Images/Links screenshots at matching reference viewport and scale; Custom Fields with both empty and populated definitions.
- Both light/dark themes and narrow widths, plus text scaling without clipped labels/actions.
- Add/Edit field/control consistency and manual Add availability.
- Album-only, one-copy and multi-copy editing, including distinct personal fields and personal images.
- Viewer local changes/proposals and editor/admin shared catalog edits; no personal fields in Core payloads.
- Partial dates, artist order, Format, rating, disc/track/header order, cover restore and cancel/reopen round trips.
- Save disabled while submitting, surfaced failures, and consistent Previous/Next behavior.
- Workspace search targets and active inspector highlighting; rendered comparison of toolbar/sidebar/view/group/details controls against the earlier App and available CLZ reference states.

## Completion criteria

The work is complete when one common-host Music modal exposes the agreed CLZ field/tab structure, catalog and personal values save to their correct stores, the identified no-op/broken controls are fixed, and paired screenshots establish the remaining visual differences. Source similarity or matching tab labels alone is insufficient.
