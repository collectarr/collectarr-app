# Music workspace grouping ? CLZ parity

Reference: the local `full_editor.mhtml` saved from CLZ Music. The Music grouping
menu now declares the same 62 folder choices, with matching category, label and
order. Both catalog and entry schemas consume the same kind-owned definitions;
entry-only choices are available for local library entries.

## Menu choices

### Images (3)

| Label | Group ID |
|---|---|
| Has Back | `music.has_back` |
| Has Front | `music.has_front` |
| Image Type | `music.image_type` |

### Main (13)

| Label | Group ID |
|---|---|
| Artist | `music.artist` |
| Format | `music.format` |
| Genre | `music.genre` |
| Label | `music.publisher` |
| Original Release Date | `music.original_release_date` |
| Original Release Month | `music.original_release_month` |
| Original Release Year | `music.original_release_year` |
| Recording Date | `music.recording_date` |
| Recording Month | `music.recording_month` |
| Recording Year | `music.recording_year` |
| Release Date | `music.release_date` |
| Release Month | `music.release_month` |
| Release Year | `music.release_year` |

### Details (14)

| Label | Group ID |
|---|---|
| Box Set | `music.box_set` |
| Country | `music.country` |
| Extra | `music.extra` |
| Instrument | `music.instrument` |
| Is Live | `music.is_live` |
| Media Condition | `music.media_condition` |
| Package/Sleeve Condition | `music.condition` |
| Packaging | `music.packaging` |
| RPM | `music.rpm` |
| SPARS | `music.spars` |
| Sound | `music.sound` |
| Storage Device | `music.storage` |
| Studio | `music.studio` |
| Vinyl Color | `music.vinyl_color` |

### Classical (5)

| Label | Group ID |
|---|---|
| Chorus | `music.chorus` |
| Composer | `music.composer` |
| Composition | `music.composition` |
| Conductor | `music.conductor` |
| Orchestra | `music.orchestra` |

### People (4)

| Label | Group ID |
|---|---|
| Engineer | `music.engineer` |
| Musician | `music.musician` |
| Producer | `music.producer` |
| Songwriter | `music.songwriter` |

### Personal (23)

| Label | Group ID |
|---|---|
| Added Date | `music.added_at` |
| Added Month | `music.added_month` |
| Added Year | `music.added_year` |
| Collection Status | `music.collection_status` |
| Is Signed | `music.is_signed` |
| Last Cleaned Date | `music.last_cleaned` |
| Last Cleaned Month | `music.last_cleaned_month` |
| Last Cleaned Year | `music.last_cleaned_year` |
| Location | `music.location` |
| Modified Date | `music.updated_at` |
| Modified Month | `music.updated_month` |
| My Rating | `music.rating` |
| Owner | `music.owner` |
| Played | `music.played` |
| Played Date | `music.played_date` |
| Played Month | `music.played_month` |
| Played Year | `music.played_year` |
| Purchase Date | `music.purchase_date` |
| Purchase Month | `music.purchase_month` |
| Purchase Store | `music.purchase_store` |
| Purchase Year | `music.purchase_year` |
| Signed by | `music.signed_by` |
| Tags | `music.tags` |

## Data behavior

- Metadata groups read typed Music album fields and role-specific contributions.
- Personal groups read the complete local Music entry, resolved location path
  and listening history. Images use artwork references plus the image records
  already attached to the workspace; no extra image-byte query is introduced.
- Artist, Genre, Studio, credits, instruments, image types, storage devices,
  Signed by, Tags and played dates can place one album in several buckets.
  Shared grouping, counts, shelf entries, selection filters and nested folder
  trees accept these multiple values. Each item is counted once per bucket;
  the All count remains the number of distinct items.
- Date/year/month groups use known partial-date components. Missing months or
  days are not synthesized. Month buckets use `01 - January` through
  `12 - December` to keep calendar order.
- Group selections can be composed through the existing folder preset editor,
  including `Genre / Artist` and
  `Artist / Release Year / Original Release Month`. Existing user favorites
  are not replaced with the saved CLZ account's favorites.

## Verification limits

Scoped Dart analysis of the Music workspace, presentation builder, shared
projection engine and grouping provider reports no issues. No runtime menu,
save/reopen or nested-folder interaction check was performed. The MHTML proves
menu labels and order; its absent JavaScript does not establish precise CLZ
bucket formatting, missing-value handling or grouping semantics for all fields.
