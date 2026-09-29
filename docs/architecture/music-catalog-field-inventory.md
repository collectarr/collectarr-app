# Music Catalog Item and Owned Copy Field Ledger

This ledger is grounded in the saved CLZ Music edit form, `C:\Users\saita\Desktop\tmp\My Albums - CLZ Music Web.html`. It defines the Music v1 field boundary for the flattened Catalog Item model. Core owns shared catalog facts; App owns each user's copies, activity, and personal images.

## Ownership and multiplicity

| Target | Meaning |
| --- | --- |
| `CatalogItem` | One concrete album edition/release. Each former Core release becomes one root item. Album metadata is copied from its former release group; release-specific identifiers and disc/track contents stay with that item. |
| `OwnedCopy` | One distinguishable physical or digital copy. Copy status, condition, purchase/value data, owner, location, notes, tags, rating, and personal images never apply to another copy. |
| `MusicDisc` and `MusicTrack` | Ordered catalog children of one Music Catalog Item. A disc contains ordered tracks; neither is a generic Work or Release. |
| `MusicListeningEvent` | App activity. It references a Music Catalog Item and may reference the particular Owned Copy used. A history entry is not a catalog field or a copy attribute. |

An exact CLZ form field is identified by the displayed label and tab below. “CLZ field set” does not include implementation IDs, storage keys, derived counts, or fields that appear only in the old Collectarr model. `Quantity` is derived from the number of Owned Copies; each new copy row represents one copy.

## Catalog Item fields

| CLZ tab | Displayed label | Type / repeats | v1 field | Decision |
| --- | --- | --- | --- | --- |
| Main | Title | string | `title` | Catalog Item title. |
| Main | Sort Title | string | `sort_title` | Catalog Item sort value. |
| Main | Subtitle | string | `subtitle` | Catalog Item subtitle. |
| Main | Artist | ordered person list | `artist_credits[]` | Preserve order and credited display name. |
| Main | Release Date | partial date | `release_date` | Preserve year/month/day precision. |
| Main | Original Release Date | partial date | `original_release_date` | Preserve partial precision. |
| Main | Label | string | `label` | Release-specific label. |
| Main | Recording Date | partial date | `recording_date` | Preserve partial precision. |
| Main | Format | string | `format` | Catalog Item format, such as CD or Vinyl. |
| Main | Barcode | string | `barcode` | Exact identifier string; preserve leading zeroes. |
| Main | Cat No | string | `catalog_number` | Exact catalog number. |
| Main | Genre | ordered string list | `genres[]` | One item can have multiple genres. |
| Details | Packaging | string | `packaging` | Catalog Item packaging description. |
| Details | Studio | ordered managed name list | `studios[]` | Preserve multiple studio credits in the order entered. |
| Details | Country | string | `country` | Full country name. |
| Details | Is Live | boolean | `is_live` | Explicit Yes/No value. |
| Details | Sound | ordered string list | `sound_types[]` | Preserve multiple selected values. |
| Details | Vinyl Color | string | `vinyl_color` | Catalog Item pressing detail. |
| Details | Vinyl Weight | string | `vinyl_weight` | Preserve the displayed value. |
| Details | RPM | integer | `rpm` | Rotational speed when applicable. |
| Details | Extra | string | `extra` | CLZ catalog field; do not conflate it with App annotations. |
| Details | SPARS | string | `spars` | Catalog Item production code. |
| Details | Box Set | string/reference | `box_set` | A source-neutral Catalog Item grouping label/reference. It is shared catalog organization, not per-copy condition or purchase data. |
| Classical | Composer | ordered person list | `composers[]` | Classical credit. |
| Classical | Conductor | ordered person list | `conductors[]` | Classical credit. |
| Classical | Chorus | ordered name list | `choruses[]` | Classical credit. |
| Classical | Composition | ordered name list | `compositions[]` | Classical work credit. |
| Classical | Orchestra | ordered name list | `orchestras[]` | Classical credit. |
| People | Songwriter | ordered person list | `songwriters[]` | Person credit. |
| People | Producer | ordered person list | `producers[]` | Person credit. |
| People | Engineer | ordered person list | `engineers[]` | Person credit. |
| People | Musician | ordered person list | `musicians[]` | Person credit; instrument data belongs to the credit when supplied. |
| Tracks | Disc Title | string per disc | `discs[].title` | A disc is an ordered child; its title is shared catalog content. |
| Tracks | Track Title | string per track | `discs[].tracks[].title` | Track order is represented by `position`. |
| Tracks | Artist | string per track | `discs[].tracks[].artist` | Optional track-level credit. |
| Tracks | Length | duration per track | `discs[].tracks[].duration_ms` | Store a normalized duration while preserving displayed time on presentation. |
| Tracks | Matrix No. Side A | string per disc | `discs[].matrix_number_side_a` | Pressing identifier, shared by copies of the same Catalog Item. |
| Tracks | Matrix No. Side B | string per disc | `discs[].matrix_number_side_b` | Pressing identifier, shared by copies of the same Catalog Item. |
| Covers | Front Cover | image asset | `cover_image_url` | Core-owned Catalog Item artwork. |
| Covers | Back Cover | image asset | `back_cover_image_url` | Core-owned Catalog Item artwork. |
| Links | Links | ordered external-link list | `external_links[]` | Source-neutral links belong to the Catalog Item and may be proposed with its other catalog fields. |

## Owned Copy fields

| CLZ tab | Displayed label | Type / repeats | v1 field | Decision |
| --- | --- | --- | --- | --- |
| Details | Package/Sleeve Condition | vocabulary value | `condition` | App-owned condition for this copy. |
| Details | Media Condition | vocabulary value | `media_condition` | App-owned condition for this copy's media, not a Catalog Disc property. |
| Personal | Collection Status | status | `collection_status` | Status of this copy. Wishlist is represented by its own personal record. |
| Personal | Index | integer | `index_number` | App's copy index. |
| Personal | Location | location reference | `location_id` | App-owned location. |
| Personal | Owner | string/reference | `owner_id` | App-owned owner value. |
| Personal | Purchase Date | partial date | `purchase_date` | Copy-specific purchase date. |
| Personal | Purchase Price | money | `purchase_price` | Copy-specific amount and currency. |
| Personal | Purchase Store | string/reference | `purchase_store` | Copy-specific purchase source. |
| Personal | Current Value | money | `current_value` | User valuation for this copy. |
| Personal | Tags | string list | `tags[]` | Personal organization. |
| Personal | Last Cleaned Date | date | `last_cleaned_date` | Copy-specific maintenance date. |
| Personal | Signed by | ordered person/name list | `signed_by[]` | Copy-specific signatures. |
| Personal | My Rating | rating | `rating` | User rating for this copy. |
| Personal | Notes | text | `notes` | Private copy notes. |
| Tracks | Storage Device | string/reference per disc | `disc_details[].storage_device` | App-owned storage placement for the physical copy. |
| Tracks | Slot | string per disc | `disc_details[].slot` | App-owned position within the selected storage device. |
| My Images | User images, maximum five | image list with description and image type | `personal_images[]` | App-owned images attached to this copy; local paths remain device cache data. |
| Personal | Played History | ordered activity list | `MusicListeningEvent[]` | Activity targets the Catalog Item and optionally this copy; do not collapse history into one mutable copy field. |
| Any | Custom Fields | user-defined values | `custom_field_values[]` | App-owned values target either a Catalog Item or one Owned Copy according to the field definition. |

## Migration and legacy-only fields

- A former release becomes one Music Catalog Item and keeps its release ID. The former release-group metadata is copied onto each concrete release item. A release group with no release becomes one item using the group ID. If one old release title conflicts with the group title, preserve the Catalog Item title from the group and report the differing release title for review; do not silently overwrite the user's album title or place the value into CLZ Subtitle.
- A parent-only personal reference to a release group with multiple releases is ambiguous. Emit it for explicit resolution; do not duplicate it across releases or choose a “primary” release.
- Medium condition moves to the matching Owned Copy's disc details. Storage Device and Slot are also copy-specific. Matrix numbers remain shared catalog pressing identifiers.
- `physical_format` is derived from the Catalog Item format and its ordered discs; do not persist a duplicate label.
- Remove Music `synopsis`, provider/source IDs (including MusicBrainz recording IDs), and the old Release Group → Release identity from the v1 catalog contract. They are not CLZ Music edit fields. Track hashes, local file offsets, bitrates, file sizes, and device paths are local media/cache data only and must not be included in Core Catalog Item payloads.
- The saved CLZ track list has Title, Artist, and Length. Collectarr's former `is_header`, `indent_level`, and `parent_header_id` fields are not part of that form and are excluded from the v1 canonical Music track contract. If a local playback/import feature still requires them, keep them outside the shared catalog contract.

## Capture limits

The saved HTML contains one populated Music edit form, including Main, Details, Classical, People, Tracks, Personal, Covers, My Images, and Links. This ledger records that form's displayed fields. It does not establish CLZ parity for any other kind.
