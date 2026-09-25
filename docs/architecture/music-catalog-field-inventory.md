# Music Catalog Field Inventory

This inventory compares the canonical Music graph exposed by Collectarr Core with the typed App domain and Drift persistence. It records ownership decisions so that the API contract does not absorb copy-specific or presentation-only data.

## Ownership rules

| Owner | Meaning |
| --- | --- |
| `core_catalog` | Canonical Music metadata owned and served by Core. |
| `app_personal` | User-entered data or user-defined relationships that belong to an owned copy or the local user's catalog. |
| `app_local_cache` | Local artwork paths and other device-only cache state. |
| `derived` | A value calculated from canonical fields or relationships and not stored independently. |

Core response fields are nullable unless listed as required. Collection properties are non-null arrays and default to empty arrays. Partial dates are transported as both a nullable `date` value and a nullable `{year, month, day}` object; the latter preserves precision.

## Release group

| Core model / API field | Type and nullability | App domain / Drift | Owner and decision |
| --- | --- | --- | --- |
| `id` | UUID, required | `MusicReleaseGroup.id` / `music_release_group_rows.id` | `core_catalog` |
| `title` | string, required | `title` / `title` | `core_catalog` |
| `sort_title` | string, nullable | `sortTitle` / `sort_title` | `core_catalog` |
| `original_title` | string, nullable | `originalTitle` / `original_title` | `core_catalog` |
| `artist` | string, nullable | `artist` / `artist` | `core_catalog`; compact display projection of artist credits |
| `original_release_date` and `_parts` | nullable date and nullable partial-date object | `originalReleaseDate`, `originalReleaseDateParts` / date and JSON columns | `core_catalog`; App keeps both values to avoid inventing precision |
| `recording_date` and `_parts` | nullable date and nullable partial-date object | `recordingDate`, `recordingDateParts` / date and JSON columns | `core_catalog`; App keeps both values to avoid inventing precision |
| `studio` | string, nullable | `studio` / `studio` | `core_catalog` |
| `is_live` | boolean, nullable | `isLive` / `is_live` | `core_catalog` |
| `genres` | array of strings, required | `genres` / `genres_json` | `core_catalog`; Core stores an ordered relation, App stores the same ordered values as JSON |
| `artist_credits` | array of `MusicArtistCreditResponse`, required | `artistCredits` / `music_artist_credits_rows` | `core_catalog`; relation rows preserve credited name, artist ID, join phrase, sequence, and source |
| `cover_image_url`, `cover_image_key` | nullable strings | same fields / same columns | `core_catalog`; URL/key reference Core artwork |
| `external_links` | array of open JSON objects, required | typed `MusicExternalLink` values / `external_links_json` | `core_catalog`; App keeps a typed local projection |
| `releases` | array of release summaries, required | `releases` / `music_release_rows` and relation tables | `core_catalog`; nested catalog graph |
| local front/back/thumbnail image paths | Not in Core API | `localCoverImagePath`, `localBackImagePath`, `localThumbnailImagePath` / group columns | `app_local_cache`; device paths never enter the Core contract |
| `synopsis` | Previously nullable text in Core | Absent from App domain and Drift | Remove from Music Core storage and API. Keep the shared synopsis field for other applicable kinds. Archive existing Core values before dropping the column. |

## Release

| Core model / API field | Type and nullability | App domain / Drift | Owner and decision |
| --- | --- | --- | --- |
| `id`, `release_group_id` | UUID, required | `id`, `releaseGroupId` / release row keys | `core_catalog` |
| `title` | string, required | `title` / `title` | `core_catalog` |
| `sort_title`, `subtitle`, `release_type`, `release_status` | nullable strings | same camel-case fields / same columns | `core_catalog` |
| `release_date` and `_parts` | nullable date and nullable partial-date object | `releaseDate`, `releaseDateParts` / date and JSON columns | `core_catalog`; partial precision preserved |
| `publisher`, `upc`, `catalog_number`, `barcode`, `country_code`, `language`, `packaging` | nullable strings | same semantic fields / same columns | `core_catalog` |
| `cover_image_url`, `cover_image_key` | nullable strings | same fields / same columns | `core_catalog` |
| `mediums` | array of medium responses, required | `mediums` / `music_medium_rows` | `core_catalog`; nested catalog graph |
| `contributions` | array of contributor responses, required | `contributions` / `music_release_contributions_rows` | `core_catalog` |
| `artist_credits` | array of artist-credit responses, required | `artistCredits` / `music_artist_credits_rows` | `core_catalog` |
| `labels` | array of release-label responses, required | `labels` / `music_release_labels_rows` | `core_catalog` |
| `identifiers` | array of identifier responses, required | `identifiers` / `music_release_identifiers_rows` | `core_catalog` |
| release external links | Not currently in the typed Core response | typed links / `music_release_external_links_rows` | `core_catalog` relation currently represented in App storage; include it in the Music response contract |
| `box_set` membership | Not currently in Core's typed Music response | `boxSetMembership` / `music_release_box_set_membership_rows` | `app_personal`; a locally managed relationship to a box-set reference, not a Core catalog field |
| `box_set_name` | Not in Core | currently a release property and release-row column | `app_personal`; display label for the local box-set relationship. Move it beside that relationship instead of storing it in the canonical release row. |
| `physical_format` | Not in Core | currently stored beside release metadata | `derived`; derive the release-level value from its ordered `medium_type` values. Do not persist a duplicate release field. |
| `physical_format_label` | Not in Core | currently stored beside release metadata | `derived`; derive from the format value and its presentation vocabulary. Do not persist a duplicate release field. |
| created/updated timestamps | SQLAlchemy mixin fields; not part of the typed response | App timestamps / local columns | Local synchronization metadata; not part of the catalog DTO field mapping. |

## Medium

| Core model / API field | Type and nullability | App domain / Drift | Owner and decision |
| --- | --- | --- | --- |
| `id`, `release_id` | UUID, required | `id`, `releaseId` / medium row keys | `core_catalog` |
| `medium_number` | integer, required | `mediumNumber` / `medium_number` | `core_catalog` |
| `medium_type`, `title` | nullable strings | same fields / same columns | `core_catalog` |
| `track_count`, `expected_track_count`, `missing_track_count` | nullable integers | same fields / same columns | `core_catalog` |
| `missing_track_positions` | array of strings, required | `missingTrackPositions` / `missing_track_positions_json` | `core_catalog`; relation rows in Core flatten to an ordered array in the API, App stores the same values as JSON |
| `toc`, `cddb_id`, `leadout_offset`, `bp_disc_id` | nullable string/integer/string/string | same fields / same columns | `core_catalog` |
| `sound_type`, `vinyl_color`, `vinyl_weight`, `rpm`, `spars` | nullable string/string/string/integer/string | same fields / same columns | `core_catalog` |
| `media_condition` | Previously nullable string in Core and App medium | User-owned medium detail in `MusicOwnedMediumDetails.mediaCondition` / `music_owned_items_rows.medium_details_json` | `app_personal`; remove it from the canonical medium model, API, and Drift medium row. Migrate saved App values to matching owned copies by release and medium number. |
| `tracks` | array of track responses, required | `tracks` / `music_track_rows` | `core_catalog`; nested catalog graph |

## Track

| Core model / API field | Type and nullability | App domain / Drift | Owner and decision |
| --- | --- | --- | --- |
| `id`, `medium_id` | UUID, required | `id`, `mediumId` / track row keys | `core_catalog` |
| `position`, `title` | string, required | same fields / same columns | `core_catalog` |
| `artist` | nullable string | `artist` / `artist` | `core_catalog` |
| `is_header`, `indent_level`, `parent_header_id` | required boolean/integer and nullable string | same fields / same columns | `core_catalog`; structural track-list metadata |
| `duration_ms`, `offset_ms`, `bitrate_kbps`, `file_size_bytes` | nullable integers | same fields / same columns | `core_catalog` |
| `track_hash`, `instrument`, `composition` | nullable strings | same fields / same columns | `core_catalog` |
| `recording_id` | Missing from Core model and API | `recordingId` / `recording_id` | `core_catalog`; add to Core's normalized track, database model, Music response, and ingestion/update mappings |

## Nested release relations

| Relation | Core/API fields | App field and Drift storage | Owner |
| --- | --- | --- | --- |
| Artist credit | `id`, `artist_id`, `credited_name`, `join_phrase`, `sequence`, `source` | `MusicArtistCredit` / `music_artist_credits_rows` | `core_catalog` |
| Contributor | `person_id`, `name`, `role`, `sequence`, `image_url`, `role_id` | `MusicReleaseContribution` / `music_release_contributions_rows` | `core_catalog` |
| Label | `id`, `label_id`, `label_name`, `catalog_number`, `sequence`, `source` | `MusicReleaseLabel` / `music_release_labels_rows` | `core_catalog` |
| Identifier | `id`, `identifier_type`, `value`, `normalized_value`, `is_primary`, `source_provider` | `MusicReleaseIdentifier` / `music_release_identifiers_rows` | `core_catalog` |
| Release box-set membership | App-only reference and sequence | `MusicBoxSetMembership` / `music_release_box_set_membership_rows` | `app_personal`; kept separate from canonical release rows |

## Contract and persistence expectations

- `music-catalog-v1.json` is generated from the Pydantic response schemas and is the pinned App input for Music DTO generation.
- App may use JSON columns for ordered collections where Core uses relation tables, provided the field meaning, order, nullability, and values match.
- The App ownership manifest maps every canonical contract field to a domain property and persistence location, or records an explicit reason when it is intentionally not persisted.
- Core's synopsis and media-condition columns require an explicit PostgreSQL migration because `bootstrap_schema` only creates missing tables and columns; it does not remove columns.
- The App SQLite migration transfers medium condition values into matching owned-copy medium details before removing the old medium column.
