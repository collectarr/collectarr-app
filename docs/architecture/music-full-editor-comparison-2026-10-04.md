# Music editor comparison with CLZ — October 4, 2026

## Scope and evidence

Reference: `C:/Users/saita/Desktop/tmp/full_editor.mhtml`, including its HTML
and embedded stylesheet. This report covers Music Manual Add and Edit.
The changes below are implemented in source. Rendered pixel parity has not
been verified: there are no paired App/CLZ screenshots at a matching viewport.
No tests or application build were run.

## Implemented changes

| Area | Implementation | Shared entry points |
| --- | --- | --- |
| Main | Independent left/right columns; Title, Sort Title, Subtitle and Artist on the left; paired dates, label/recording date and format/barcode on the right, followed by Cat No and Genre | `music_main_form_section.dart`, common schema column renderer |
| Main tools | Title Autocap and partial-date calendar actions; Sort Title has no header action, matching the saved reference | Common field-header actions, `music_title_formatting.dart` |
| Details | Packaging and Vinyl groups with the same composition in Add/Edit; separate Package/Sleeve Condition and Media Condition | `music_details_form_pane.dart` |
| Managed choices | Inline choices load saved user values as well as built-ins and current selections; full picker remains available; newly entered Details values are staged for Save | `library_vocabulary_options_loader.dart`, `library_managed_vocabulary_field.dart`, common schema controls |
| Classical | Left: Composer, Conductor, Chorus. Right: Composition, Orchestra. Compact ordered name rows replace repeated cards/headings | `music_contribution_groups_field.dart`, `library_ordered_names_field.dart` |
| People | Credits and Musicians groups; compact ordered rows retain role, sort name, instrument and reordering | Same credit primitives as Classical |
| Disc navigation | Compact Disc #N tabs with Add Disc; redundant Discs and per-disc section headings removed | `music_disc_tab_button.dart` |
| Disc fields | Shared responsive geometry: expanding title, 200px Storage Device, 65px Slot and 150px matrix fields at sufficient width | `music_disc_fields_layout.dart` |
| Storage | Storage Device uses a managed list; Slot remains plain text. Values remain attached to the contained disc in the local item | Music storage vocabulary and entry details |
| Tracks | Add/Edit reuse the same disc/track editor, preserving selection, Autocap, move, removal, ordering and headers; track Artist supports multiline text | `music_album_structure_tabs.dart`, thin Add draft adapter |
| Track persistence | Stable disc/track IDs survive Manual Add; local headers, indentation and parent linkage are retained separately from the Core proposal shape | `music_manual_candidate.dart`, `music_add_manual_contents.dart` |
| Personal | Shared two-column layout: purchase data/current value/tags/last cleaned/signed by on the left; owner/rating/notes/history on the right | `music_personal_form_layout.dart` |
| Personal labels | Current Value, Owner, My Rating, Last Cleaned Date and Collection Status | Music personal-field contributor |
| Personal extras | Currency and Grade appear in Additional Personal Details | Shared Music Personal layout |
| Personal dates | Purchase Date and Last Cleaned Date preserve partial components; complete-date projections are kept consistent when purchase dates are changed through transfer/update paths | Music personal and entry-details codecs |
| Rating | One My Rating label, compact 0–10 control and clearer count text | `media_rating_field.dart` |
| Played History | Total Plays in the group title; inline date and Mark as listened; edit/delete retained; Manual Add stages history until entry creation | `music_listening_edit_draft.dart`, Music create payload/contributor |
| Listening persistence | Initial history is created transactionally with its owner. Events for private local entries stay local; Sync orders entry upserts before their activity when timestamps tie | Music entry contributor, listening mutations and Sync queue |
| Custom Fields | Consistent tab availability in Add/Edit; centered empty-state instructions point to the App's Settings → Data | Common custom-field section and Add shell |
| Covers | Shared Front/Back cover controls in Add/Edit, including upload, remove/restore, crop, reset and rotate; square preview uses the shared dark surface | `MusicCoverEditor`, `music_add_manual_covers_tab.dart` |
| My Images | Shared drop/click/paste intake, clipboard shortcut and image validation; five personal images; descriptions, types and ordering retained | `library_image_intake.dart`, Music image editor |
| Image staging | Add stages cover and personal-image changes until entry creation; clearing descriptions is supported | Add image adapter and Music image model |
| Links | URL and Description columns with New Link; repeated section framing and visible Title column removed. Existing hidden title data is retained | Common link editor's `showTitleColumn` option |
| Status strip | Collection Status, Index, Quantity, Location in Add/Edit; quantity defaults to 1 and requires a positive whole number | Music personal schema, `music_add_status_strip.dart` |
| Status menu | Common colored icons, grouped options and On Wish List label; display values map to the existing persisted status values | `library_collection_status_field.dart`, Add split button |
| Tabs | Main, Details, Classical, People, Tracks, Personal, Custom Fields, Covers, My Images, Links; common shell avoids duplicate contributed tabs | Music Add pane and common Add shell |

## Data boundaries

Quantity, rating, media condition, purchase date components, last-cleaned date
components, storage values and listening activity are personal App data.
They do not add an owned-copy entity or fields to the shared Core catalog.
Disc/track header structure remains local; Core proposals exclude header rows.
The local album and its personal data remain one independently editable item.

Image intake accepts supported image files through file selection, desktop drop
or clipboard. It validates decoding, a 20 MB file limit and an 80-megapixel
limit before staging. New native dependencies are `desktop_drop` and
`pasteboard`; a full application restart/rebuild is needed to register them.
Android FileProvider configuration was added for the clipboard plugin.

## Intentional App differences

- Provider search, import and Find Online remain removed as requested.
- Currency, Grade, proposal controls and existing track/header management
  remain available as App capabilities.
- App uses Inter; the saved CLZ reference uses Gilroy. Typeface parity is not
  established by these source changes.
- Custom-field instructions refer to the App's actual navigation.

## Verification results

- `dart format` applied to files changed for this work.
- Scoped `dart analyze` covering Music Add/Edit/forms/personal models/entry
  codecs/listening mutations and the affected shared primitives, schema,
  personal sections, image/link sections and entry contributor: **no issues**.
- Whole-`lib` analysis reported errors and lints in the concurrently changing
  workspace/projection and other areas. This does not establish a successful
  full application build. Those unrelated changes were not rewritten here.
- Native drop/clipboard, rendered layout, save/reopen and remote Sync have
  not been exercised in a running application.

## Remaining rendered and interaction review

1. Restart/rebuild App after the native plugin additions and resolve the
   workspace/projection compilation errors from the parallel refactor.
2. Capture all ten App/CLZ tabs at the same viewport, scale and comparable
   populated content. Measure header, tabs, footer, spacing, surfaces, fonts,
   focus and hover states; include smaller widths and increased text scale.
3. Check Main with several artists and many genres: right-column rows should
   stay independent of the left-column height.
4. Save/reopen partial purchase/cleaning dates, both conditions, quantity,
   custom choices and per-disc storage. Clear each value and repeat.
5. Exercise multiple discs and tracks in Add/Edit: headers, multiline artists,
   bulk actions, invalid durations and edits to several cells in succession.
6. Add listening history before creation, then cancel and confirm no entry or
   history is written; repeat with Save. Check local entries and Core-backed
   entries separately when exercising Sync.
7. Add covers and five personal images by chooser, drop and clipboard; inspect
   removal/restoration, crop/rotate, description clearing and order after Save.
   Include non-square covers and invalid files.
8. Confirm tab navigation validates hidden fields and does not silently lose
   edits when moving between tabs or Previous/Next entries.

These are outstanding runtime/visual checks, not completed verification.

## Rendered typography follow-up

The saved CLZ reference was rendered with its original fonts in a temporary
comparison environment. Measured reference sizes: title 18px, tabs and input
text 14px, labels 13px, group legends 16.8px, inputs 34px, tabs 32px and dialog
width 1200px. Shared editor primitives now align these dimensions, spacing
and dark surfaces. Standard input density prevents the compact theme from
reducing text fields below 34px.

Collectarr Sans is a distinct OFL derivative of Manrope with four static faces.
The source, generator and license are committed; no proprietary font files
are bundled. See [the font comparison](assets/collectarr-sans-comparison.png)
and [font build instructions](../../tooling/fonts/README.md). This is close
typography, not an exact Gilroy reproduction.

The font loaded in a running Windows Music Manual Add form. The latest
`flutter build bundle --debug --no-pub` completed, and scoped analysis of the
six affected shared UI/theme files reported no issues. This bundle build does
not verify a new native Windows executable or persistence/Sync behavior.
Manual Add showed saved-vocabulary loading errors in the isolated runtime;
those error messages change row heights and prevent a clean populated-form
comparison. The all-tab visual and interaction checks listed above remain
open; no full 1:1 parity is claimed.
