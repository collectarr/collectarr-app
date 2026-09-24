# Kind Workspace and Form Inventory

Generated from the workspace field declarations, identifier modules, scope contributions, and Add/Edit schema IDs present on 2026-09-24. This is the pre-migration ledger for `kind-schema-reorganization-plan.md`; source file links remain authoritative for callback details and UI behavior.

For workspace fields, the projected source is taken from each field callback where it is a direct DTO expression. Context-dependent callbacks are marked derived; inspect the linked declaration before moving them. Columns, sorts, groups, defaults, facets, and form IDs are listed alongside the per-scope field rows so that file extraction can preserve the whole surface.

## Comic

Sources: `[lib/features/library/kinds/comic/workspace/comic_fields.dart]`; IDs: `[lib/features/library/kinds/comic/workspace/comic_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/comic/workspace/comic_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `comic.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `series` | `comic.series` | Series | `dto.seriesTitle` | yes | yes | yes | yes |
| work | `issueNumber` | `comic.issue_number` | Issue Number | `dto.itemNumber` | yes | yes | — | yes |
| work | `cover` | `comic.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `writer` | `comic.writer` | Writer | `dto.writer` | yes | — | — | — |
| work | `artist` | `comic.artist` | Artist | `dto.artist` | yes | — | — | — |
| work | `coverArtist` | `comic.cover_artist` | Cover Artist | `dto.coverArtist` | yes | — | — | — |
| work | `imprint` | `comic.imprint` | Imprint | `dto.imprint` | yes | — | — | — |
| work | `pageCount` | `comic.page_count` | Page Count | `dto.pageCount` | — | — | — | — |
| release | `publisher` | `comic.publisher` | Publisher | `dto.publisher` | yes | yes | yes | yes |
| release | `releaseDate` | `comic.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `barcode` | `comic.barcode` | Barcode | `dto.barcode` | yes | — | — | — |
| release | `variant` | `comic.variant` | Variant | `dto.variant` | — | — | — | — |
| copy | `condition` | `comic.condition` | Condition | `_owned(context)?.condition` | yes | yes | yes | yes |
| copy | `location` | `comic.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `comic.price_paid` | Purchase Price | `_owned(context)?.pricePaidCents` | yes | yes | — | yes |
| copy | `status` | `comic.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `comic.rating` | Rating | `_owned(context)?.reading.rating` | yes | yes | — | — |
| copy | `wishlist` | `comic.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `comic.updated_at` | Updated | `context.source.updatedAt` | yes | yes | — | yes |
| copy | `addedAt` | `comic.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `grade` | `comic.grade` | Grade | `_owned(context)?.grade` | yes | — | — | yes |
| copy | `keyComic` | `comic.key_comic` | Key Comic | `_ownedDetails(context)?.keyComic == true` | yes | — | — | yes |
| copy | `keyReason` | `comic.key_reason` | Key Reason | `_ownedDetails(context)?.keyReason` | — | — | — | — |
| copy | `keyCategory` | `comic.key_category` | Key Category | `_ownedDetails(context)?.keyCategory` | — | — | — | — |
| copy | `keySeverity` | `comic.key_severity` | Key Severity | `_ownedDetails(context)?.keySeverity` | — | — | — | — |
| copy | `rawOrSlabbed` | `comic.raw_or_slabbed` | Raw / Slabbed | `_ownedDetails(context)?.rawOrSlabbed` | — | — | — | — |
| copy | `gradingCompany` | `comic.grading_company` | Grading Company | `_ownedDetails(context)?.gradingCompany` | — | — | — | — |
| copy | `graderNotes` | `comic.grader_notes` | Grader Notes | `_ownedDetails(context)?.graderNotes` | — | — | — | — |
| copy | `signedBy` | `comic.signed_by` | Signed By | `_ownedDetails(context)?.signedBy` | — | — | — | — |
| copy | `labelType` | `comic.label_type` | Label Type | `_ownedDetails(context)?.labelType` | — | — | — | — |
| copy | `customLabel` | `comic.custom_label` | Custom Label | `_ownedDetails(context)?.customLabel` | — | — | — | — |
| copy | `pageQuality` | `comic.page_quality` | Page Quality | `_ownedDetails(context)?.pageQuality` | — | — | — | — |
| copy | `certificationNumber` | `comic.certification_number` | Certification Number | `_ownedDetails(context)?.certificationNumber` | — | — | — | — |
| copy | `coverPrice` | `comic.cover_price` | Cover Price | `_ownedDetails(context)?.coverPriceCents` | — | — | — | — |
| copy | `lastBagBoardDate` | `comic.last_bag_board_date` | Last Bag & Board Date | `_ownedDetails(context)?.lastBagBoardDate` | — | — | — | — |

- Workspace sort IDs: comic.condition, comic.issue_number, comic.price_paid, comic.publisher, comic.rating, comic.release_date, comic.release_title, comic.series, comic.status, comic.title, comic.updated_at
- Workspace group IDs: comic.condition, comic.location, comic.publisher, comic.series
- Default visible column IDs by scope: work: comic.cover, comic.issue_number, comic.series, comic.title; release: comic.publisher, comic.release_date; copy: comic.condition, comic.grade, comic.key_comic, comic.location, comic.price_paid, comic.status, comic.updated_at, comic.wishlist
- Root schema defaults: sort `comic.series`; group `comic.series`. Release/Copy overrides: see `lib/features/library/kinds/comic/workspace/comic_workspace_contribution.dart`.
- Facet ID members: publisher, genre, character, storyArc, writer, artist
- Add/Edit field IDs (prefix identifies source family): add:issue, add:publication, edit:catalog_details, edit:catalog_snapshot, edit:certification_number, edit:characters, edit:collector, edit:cover, edit:cover_price, edit:creators, edit:custom_label, edit:details, edit:grader_notes, edit:grading_company, edit:key_category, edit:key_comic, edit:key_reason, edit:key_severity, edit:label_type, edit:last_bag_board_date, edit:links, edit:main, edit:owned, edit:page_quality, edit:photos, edit:preservation, edit:raw_or_slabbed, edit:release, edit:release_id, edit:release_identity, edit:release_variants, edit:signature, edit:signed_by, edit:variants, forms:age_rating, forms:barcode, forms:country, forms:cover_date, forms:cover_image_url, forms:crossover, forms:edition_title, forms:genres, forms:imprint, forms:isbn, forms:issue_number, forms:language, forms:page_count, forms:physical_format, forms:publisher, forms:release_date, forms:release_title, forms:series, forms:series_group, forms:story_arcs, forms:upc, forms:variant

## Manga

Sources: `[lib/features/library/kinds/manga/workspace/manga_fields.dart]`; IDs: `[lib/features/library/kinds/manga/workspace/manga_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/manga/workspace/manga_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `manga.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `series` | `manga.series` | Series | `dto.seriesTitle` | yes | yes | yes | yes |
| work | `volumeNumber` | `manga.volume_number` | Volume Number | `dto.itemNumber` | — | yes | — | — |
| work | `cover` | `manga.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `nativeTitle` | `manga.native_title` | Native Title | `dto.metadata?.nativeTitle` | yes | — | — | — |
| work | `romajiTitle` | `manga.romaji_title` | Romaji Title | `dto.metadata?.romajiTitle` | yes | — | — | — |
| work | `englishTitle` | `manga.english_title` | English Title | `dto.metadata?.englishTitle` | yes | — | — | — |
| work | `demographic` | `manga.demographic` | Demographic | `dto.metadata?.demographic.label` | yes | yes | yes | — |
| work | `serializationPlatform` | `manga.serialization_platform` | Serialization | `dto.metadata?.serializationPlatform` | — | — | — | — |
| work | `publicationStatus` | `manga.publication_status` | Publication Status | `dto.metadata?.publicationStatus.label` | yes | yes | yes | — |
| work | `originalPublisher` | `manga.original_publisher` | Original Publisher | `dto.metadata?.originalPublisher` | yes | — | — | — |
| work | `localizedPublisher` | `manga.localized_publisher` | Localized Publisher | `dto.metadata?.localizedPublisher` | yes | — | — | — |
| work | `totalVolumes` | `manga.total_volumes` | Total Volumes | `dto.metadata?.totalVolumes` | yes | yes | — | — |
| work | `chapterCount` | `manga.chapter_count` | Chapter Count | `dto.metadata?.chapterCount` | yes | — | — | — |
| work | `editionFormat` | `manga.edition_format` | Edition Format | `dto.metadata?.editionFormat.label` | yes | yes | yes | — |
| work | `readingDirection` | `manga.reading_direction` | Reading Direction | `dto.metadata?.readingDirection.label` | yes | — | yes | — |
| work | `translator` | `manga.translator` | Translator | `dto.metadata?.translator` | yes | — | — | — |
| release | `publisher` | `manga.publisher` | Publisher | `dto.publisher` | yes | yes | yes | yes |
| release | `releaseDate` | `manga.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `barcode` | `manga.barcode` | ISBN / Barcode | `dto.barcode` | yes | — | — | yes |
| copy | `condition` | `manga.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `manga.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `manga.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `manga.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `manga.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `manga.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `manga.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `manga.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `obiStripPresent` | `manga.obi_strip_present` | Obi Strip Present | `context.dto.ownedDetails?.obiStripPresent ?? false` | yes | — | — | — |
| copy | `slipcoverPresent` | `manga.slipcover_present` | Slipcover Present | `context.dto.ownedDetails?.slipcoverPresent ?? false` | yes | — | — | — |
| copy | `dustJacketPresent` | `manga.dust_jacket_present` | Dust Jacket Present | `context.dto.ownedDetails?.dustJacketPresent ?? false` | yes | — | — | — |
| copy | `dustJacketCondition` | `manga.dust_jacket_condition` | Dust Jacket Condition | `context.dto.ownedDetails?.dustJacketCondition` | — | — | — | — |
| copy | `boxSetOuterCondition` | `manga.box_set_outer_condition` | Box Set Outer Condition | `context.dto.ownedDetails?.boxSetOuterCondition` | — | — | — | — |
| copy | `insertsPresent` | `manga.inserts_present` | Inserts Present | `context.dto.ownedDetails?.insertsPresent ?? false` | — | — | — | — |
| copy | `printing` | `manga.printing` | Printing | `context.dto.ownedDetails?.printing` | yes | — | — | — |
| copy | `localizedEdition` | `manga.localized_edition` | Localized Edition | `context.dto.ownedDetails?.localizedEdition` | yes | — | — | — |
| copy | `signedBy` | `manga.signed_by` | Signed By | `context.dto.ownedDetails?.signedBy` | yes | — | — | — |

- Workspace sort IDs: manga.demographic, manga.edition_format, manga.publication_status, manga.publisher, manga.release_date, manga.release_title, manga.series, manga.status, manga.title, manga.total_volumes, manga.volume_number
- Workspace group IDs: manga.condition, manga.demographic, manga.edition_format, manga.location, manga.publication_status, manga.publisher, manga.reading_direction, manga.series
- Default visible column IDs by scope: work: manga.cover, manga.series, manga.title; release: manga.barcode, manga.publisher, manga.release_date; copy: manga.condition, manga.location, manga.price_paid, manga.rating, manga.status, manga.updated_at, manga.wishlist
- Root schema defaults: sort `manga.series`; group `manga.series`. Release/Copy overrides: see `lib/features/library/kinds/manga/workspace/manga_workspace_contribution.dart`.
- Facet ID members: publisher, genre, character, theme, demographic
- Add/Edit field IDs (prefix identifies source family): add:age_rating, add:authors, add:back_cover_image_url, add:characters, add:country, add:genres, add:language, add:publication, add:publication_year, add:series_group, add:synopsis, add:variant, add:volume, add:volume_number, edit:artwork, edit:box_set_outer_condition, edit:certification_number, edit:custom_label, edit:details, edit:dust_jacket_condition, edit:dust_jacket_present, edit:edition_details, edit:grader_notes, edit:grading, edit:grading_company, edit:identity, edit:inserts_present, edit:label_type, edit:localized_edition, edit:obi_strip_present, edit:owned, edit:page_quality, edit:printing, edit:publication, edit:publishing, edit:raw_or_slabbed, edit:release, edit:signature, edit:signed_by, edit:slipcover_present, edit:titles, forms:barcode, forms:binding, forms:cover_image_url, forms:description, forms:distributor, forms:first_publication_date, forms:format, forms:genres, forms:imprint, forms:isbn, forms:language, forms:original_language, forms:original_publication_date, forms:page_count, forms:publisher, forms:region, forms:release_date, forms:release_title, forms:search_aliases, forms:sort_title, forms:status, forms:subtitle, forms:title

## Anime

Sources: `[lib/features/library/kinds/anime/workspace/anime_fields.dart]`; IDs: `[lib/features/library/kinds/anime/workspace/anime_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/anime/workspace/anime_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `anime.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `studio` | `anime.studio` | Studio | `dto.studio ?? dto.publisher` | yes | yes | yes | yes |
| work | `cover` | `anime.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `nativeTitle` | `anime.native_title` | Native Title | `dto.metadata?.nativeTitle` | yes | — | — | — |
| work | `romajiTitle` | `anime.romaji_title` | Romaji Title | `dto.metadata?.romajiTitle` | yes | — | — | — |
| work | `englishTitle` | `anime.english_title` | English Title | `dto.metadata?.englishTitle` | yes | — | — | — |
| work | `format` | `anime.format` | Format | `dto.animeType` | yes | — | yes | — |
| work | `season` | `anime.season` | Season | `dto.metadata?.season?.label` | yes | — | yes | — |
| work | `seasonYear` | `anime.season_year` | Season Year | `dto.metadata?.seasonYear` | yes | yes | — | — |
| work | `episodeCount` | `anime.episode_count` | Episode Count | `dto.episodeCount` | yes | yes | — | — |
| work | `episodeRuntimeMinutes` | `anime.episode_runtime_minutes` | Episode Runtime (m) | `dto.metadata?.episodeRuntimeMinutes` | — | — | — | — |
| work | `airingStatus` | `anime.airing_status` | Airing Status | `dto.airingStatus` | yes | yes | yes | — |
| work | `sourceMaterial` | `anime.source_material` | Source Material | `dto.metadata?.sourceMaterial.label` | yes | yes | yes | — |
| release | `publisher` | `anime.publisher` | Publisher | `dto.publisher` | yes | yes | — | yes |
| release | `releaseDate` | `anime.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `releaseYear` | `anime.release_year` | Release Year | `dto.releaseDate?.year` | — | — | yes | — |
| release | `barcode` | `anime.barcode` | UPC / Barcode | `dto.barcode` | yes | — | — | yes |
| copy | `condition` | `anime.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `anime.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `anime.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `anime.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `anime.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `anime.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `anime.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `anime.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `watchStatus` | `anime.watch_status` | Watch Status | `context.dto.personal.trackingStatus` | — | — | — | — |

- Workspace sort IDs: anime.airing_status, anime.episode_count, anime.publisher, anime.release_date, anime.release_title, anime.season_year, anime.source_material, anime.status, anime.studio, anime.title
- Workspace group IDs: anime.airing_status, anime.condition, anime.format, anime.location, anime.release_year, anime.season, anime.source_material, anime.studio
- Default visible column IDs by scope: work: anime.cover, anime.studio, anime.title; release: anime.barcode, anime.publisher, anime.release_date; copy: anime.condition, anime.location, anime.price_paid, anime.rating, anime.status, anime.updated_at, anime.wishlist
- Root schema defaults: sort `anime.studio`; group `anime.studio`. Release/Copy overrides: see `lib/features/library/kinds/anime/workspace/anime_workspace_contribution.dart`.
- Facet ID members: studio, publisher, genre, format, theme, season
- Add/Edit field IDs (prefix identifies source family): add:alternate_titles, add:characters, add:country, add:creators, add:distributor, add:english_title, add:metadata, add:native_title, add:release, add:romaji_title, add:series, add:variant, edit:anime, edit:box_set_id, edit:box_set_name, edit:classification, edit:cover, edit:custom, edit:distributor, edit:features, edit:hdr_formats, edit:identity, edit:main, edit:owned, edit:packaging, edit:personal, edit:photos, edit:physical, edit:production, edit:publishing, edit:region, edit:release, edit:schedule, edit:sold, edit:synopsis, edit:value, forms:anime_type, forms:audio_tracks, forms:barcode, forms:cover_image_url, forms:description, forms:end_date, forms:episode_count, forms:episode_runtime_minutes, forms:format, forms:genres, forms:language, forms:licensors, forms:media_count, forms:original_language, forms:producers, forms:publisher, forms:region, forms:release_date, forms:season, forms:season_year, forms:sort_title, forms:source_material, forms:start_date, forms:status, forms:studios, forms:subtitles, forms:themes, forms:title

## Book

Sources: `[lib/features/library/kinds/book/workspace/book_fields.dart]`; IDs: `[lib/features/library/kinds/book/workspace/book_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/book/workspace/book_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `book.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `author` | `book.author` | Author | `dto.author` | yes | yes | yes | yes |
| work | `series` | `book.series` | Series | `dto.seriesTitle` | — | — | yes | — |
| work | `cover` | `book.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `subtitle` | `book.subtitle` | Subtitle | `dto.subtitle` | yes | — | — | — |
| work | `translator` | `book.translator` | Translator | `dto.translator` | yes | — | — | — |
| work | `editor` | `book.editor` | Editor | `dto.editor` | yes | — | — | — |
| work | `illustrator` | `book.illustrator` | Illustrator | `dto.illustrator` | yes | — | — | — |
| work | `coverArtist` | `book.cover_artist` | Cover Artist | `dto.coverArtist` | — | — | — | — |
| work | `printing` | `book.printing` | Printing | `dto.printing` | yes | — | — | — |
| work | `numberLine` | `book.number_line` | Number Line | `dto.numberLine` | yes | — | — | — |
| release | `publisher` | `book.publisher` | Publisher | `dto.publisher` | yes | — | yes | yes |
| release | `pageCount` | `book.page_count` | Page count | `dto.pageCount` | — | yes | — | — |
| release | `isbn` | `book.isbn` | ISBN | `dto.isbn ?? dto.barcode` | yes | — | — | yes |
| release | `releaseDate` | `book.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `format` | `book.format` | Format | `dto.format` | yes | — | yes | — |
| release | `firstEdition` | `book.first_edition` | First Edition | `context.dto.firstEdition` | yes | — | — | — |
| release | `dewey` | `book.dewey` | Dewey Decimal | `dto.dewey` | yes | — | — | — |
| release | `locClassification` | `book.loc_classification` | LoC Classification | `dto.locClassification` | — | — | — | — |
| copy | `condition` | `book.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `book.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `book.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `book.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `book.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `book.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `book.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `book.added_at` | Added | `context.source.addedAt` | — | — | — | — |
| copy | `readStatus` | `book.read_status` | Read Status | `context.dto.personal.trackingStatus` | yes | — | — | yes |
| copy | `signedBy` | `book.signed_by` | Signed By | `derived from projection/context` | — | — | — | — |

- Workspace sort IDs: book.author, book.page_count, book.release_date, book.status, book.title
- Workspace group IDs: book.author, book.condition, book.format, book.location, book.publisher, book.series
- Default visible column IDs by scope: work: book.author, book.cover, book.title; release: book.isbn, book.publisher, book.release_date; copy: book.condition, book.location, book.price_paid, book.rating, book.read_status, book.status, book.updated_at, book.wishlist
- Root schema defaults: sort `book.author`; group `book.author`. Release/Copy overrides: see `lib/features/library/kinds/book/workspace/book_workspace_contribution.dart`.
- Facet ID members: author, publisher, genre, format, subject, translator
- Add/Edit field IDs (prefix identifies source family): add:age_rating, add:authors, add:back_cover_image_url, add:barcode, add:characters, add:country, add:edition, add:number, add:publication, add:publication_year, add:series_group, add:variant, edit:additional_details, edit:details, edit:dust_jacket_condition, edit:dust_jacket_present, edit:edition, edit:edition_details, edit:identity, edit:owned, edit:publication, edit:publication_details, edit:signature, edit:signed_by, edit:titles, forms:audio_length_minutes, forms:binding, forms:cover_image_url, forms:description, forms:dimensions, forms:distributor, forms:edition_statement, forms:first_edition, forms:first_publication_date, forms:format, forms:genres, forms:imprint, forms:isbn, forms:language, forms:original_language, forms:original_publication_date, forms:page_count, forms:publisher, forms:region, forms:release_date, forms:release_status, forms:search_aliases, forms:sort_title, forms:subtitle, forms:thumbnail_image_url, forms:title, forms:upc

## Game

Sources: `[lib/features/library/kinds/game/workspace/game_fields.dart]`; IDs: `[lib/features/library/kinds/game/workspace/game_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/game/workspace/game_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `game.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `platform` | `game.platform` | Platform | `dto.platform` | yes | yes | yes | yes |
| work | `developer` | `game.developer` | Developer | `dto.developer` | — | — | — | — |
| work | `cover` | `game.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `franchise` | `game.franchise` | Franchise | `dto.franchise` | yes | — | yes | — |
| work | `series` | `game.series` | Series | `dto.seriesTitle` | — | — | — | — |
| work | `ageRating` | `game.age_rating` | Age Rating | `dto.ageRating` | — | — | — | — |
| work | `loosePrice` | `game.loose_price` | Loose Price | `dto.loosePrice` | yes | yes | — | — |
| work | `cibPrice` | `game.cib_price` | CIB Price | `dto.cibPrice` | yes | yes | — | — |
| work | `newPrice` | `game.new_price` | New/Sealed Price | `dto.newPrice` | — | — | — | — |
| work | `gradedPrice` | `game.graded_price` | Graded Price | `dto.gradedPrice` | — | — | — | — |
| release | `publisher` | `game.publisher` | Publisher | `dto.publisher` | yes | yes | yes | yes |
| release | `releaseDate` | `game.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `barcode` | `game.barcode` | Barcode | `dto.barcode` | yes | — | — | yes |
| release | `edition` | `game.edition` | Edition | `dto.edition` | yes | — | — | — |
| copy | `condition` | `game.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `game.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `game.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `game.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `game.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `game.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `game.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `game.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `completionStatus` | `game.completion_status` | Completion | `derived from projection/context` | — | — | — | — |
| copy | `completeness` | `game.completeness` | Completeness | `derived from projection/context` | — | — | yes | — |
| copy | `hasBox` | `game.has_box` | Has Box | `derived from projection/context` | — | — | — | — |
| copy | `hasManual` | `game.has_manual` | Has Manual | `derived from projection/context` | — | — | — | — |
| copy | `priceChartingId` | `game.pricecharting_id` | PriceCharting ID | `derived from projection/context` | — | — | — | — |
| copy | `coreRegion` | `game.core_region` | Region | `derived from projection/context` | — | — | — | — |
| copy | `valueLocked` | `game.value_locked` | Value Locked | `derived from projection/context` | — | — | — | — |

- Workspace sort IDs: game.cib_price, game.loose_price, game.platform, game.publisher, game.release_date, game.release_title, game.status, game.title
- Workspace group IDs: game.completeness, game.condition, game.franchise, game.location, game.platform, game.publisher
- Default visible column IDs by scope: work: game.cover, game.platform, game.title; release: game.barcode, game.publisher, game.release_date; copy: game.condition, game.location, game.price_paid, game.rating, game.status, game.updated_at, game.wishlist
- Root schema defaults: sort `game.platform`; group `game.platform`. Release/Copy overrides: see `lib/features/library/kinds/game/workspace/game_workspace_contribution.dart`.
- Facet ID members: platform, publisher, developer, franchise, genre, region
- Add/Edit field IDs (prefix identifies source family): add:metadata, add:release, edit:classification, edit:completeness, edit:core_region, edit:details, edit:has_box, edit:has_manual, edit:identity, edit:owned, edit:pricecharting_id, edit:publishing, edit:release, edit:titles, edit:valuation, edit:value_locked, forms:age_ratings, forms:back_cover_image_url, forms:barcode, forms:catalog_number, forms:company_roles, forms:country, forms:cover_image_url, forms:description, forms:developers, forms:format, forms:franchise, forms:genres, forms:identifiers, forms:language, forms:languages, forms:original_language, forms:platform, forms:platforms, forms:publisher, forms:region, forms:release_date, forms:release_status, forms:release_title, forms:release_year, forms:search_aliases, forms:series, forms:sort_title, forms:subtitle, forms:title, forms:variant, forms:work_release_date

## Boardgame

Sources: `[lib/features/library/kinds/boardgame/workspace/boardgame_fields.dart]`; IDs: `[lib/features/library/kinds/boardgame/workspace/boardgame_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/boardgame/workspace/boardgame_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `boardgame.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `designer` | `boardgame.designer` | Designer | `dto.metadata?.designers.firstOrNull ?? dto.publisher` | — | — | — | — |
| work | `cover` | `boardgame.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `minPlayers` | `boardgame.min_players` | Min Players | `dto.metadata?.minPlayers` | yes | — | — | — |
| work | `maxPlayers` | `boardgame.max_players` | Max Players | `dto.metadata?.maxPlayers` | yes | — | — | — |
| work | `bestPlayers` | `boardgame.best_players` | Best Players | `dto.metadata?.bestPlayers` | yes | — | yes | — |
| work | `recommendedPlayers` | `boardgame.recommended_players` | Recommended Players | `dto.metadata?.recommendedPlayers` | — | — | — | — |
| work | `minPlaytimeMinutes` | `boardgame.min_playtime_minutes` | Min Playtime (m) | `dto.metadata?.minPlaytimeMinutes` | — | — | — | — |
| work | `maxPlaytimeMinutes` | `boardgame.max_playtime_minutes` | Max Playtime (m) | `dto.metadata?.maxPlaytimeMinutes` | — | — | — | — |
| work | `complexityWeight` | `boardgame.complexity_weight` | Complexity / Weight | `dto.metadata?.complexityWeight` | yes | yes | — | — |
| work | `bggRating` | `boardgame.bgg_rating` | BGG Rating | `dto.metadata?.bggRating` | yes | yes | — | — |
| work | `bggRank` | `boardgame.bgg_rank` | BGG Rank | `dto.metadata?.bggRank` | yes | yes | — | — |
| work | `expansionFor` | `boardgame.expansion_for` | Expansion For | `dto.metadata?.expansionFor` | yes | — | — | — |
| release | `publisher` | `boardgame.publisher` | Publisher / Designer | `dto.publisher` | yes | yes | yes | yes |
| release | `releaseDate` | `boardgame.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `barcode` | `boardgame.barcode` | UPC / Barcode | `dto.barcode` | yes | — | — | yes |
| copy | `condition` | `boardgame.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `boardgame.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `boardgame.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `boardgame.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `boardgame.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `boardgame.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `boardgame.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `boardgame.added_at` | Added | `context.source.addedAt` | yes | — | — | — |

- Workspace sort IDs: boardgame.bgg_rank, boardgame.bgg_rating, boardgame.complexity_weight, boardgame.publisher, boardgame.release_date, boardgame.release_title, boardgame.status, boardgame.title
- Workspace group IDs: boardgame.best_players, boardgame.condition, boardgame.location, boardgame.publisher
- Default visible column IDs by scope: work: boardgame.cover, boardgame.title; release: boardgame.barcode, boardgame.publisher, boardgame.release_date; copy: boardgame.condition, boardgame.location, boardgame.price_paid, boardgame.rating, boardgame.status, boardgame.updated_at, boardgame.wishlist
- Root schema defaults: sort `scope contribution; see source`; group `scope contribution; see source`. Release/Copy overrides: see `lib/features/library/kinds/boardgame/workspace/boardgame_workspace_contribution.dart`.
- Facet ID members: publisher, designer, mechanic, category, family, theme
- Add/Edit field IDs (prefix identifies source family): add:edition, add:work, edit:classification, edit:component_completeness, edit:component_condition, edit:condition, edit:customization, edit:details, edit:edition, edit:edition_language, edit:edition_region, edit:has_custom_insert, edit:has_painted_miniatures, edit:identity, edit:is_sleeved, edit:missing_pieces_notes, edit:owned, edit:play_profile, edit:players, edit:publication, edit:publication_details, edit:ratings_and_media, edit:storage_notes, edit:titles, forms:age_rating, forms:artists, forms:audience_rating, forms:back_cover_image_url, forms:barcode, forms:best_players, forms:bgg_rank, forms:bgg_rating, forms:bgg_rating_count, forms:catalog_number, forms:categories, forms:characters, forms:complexity_weight, forms:contributors, forms:country, forms:cover_image_url, forms:description, forms:designers, forms:edition_title, forms:expansion_for, forms:expansions, forms:families, forms:format, forms:identifiers, forms:item_number, forms:language, forms:max_players, forms:max_playtime_minutes, forms:mechanics, forms:min_age, forms:min_players, forms:min_playtime_minutes, forms:minimum_age, forms:original_language, forms:original_title, forms:platforms, forms:playing_time_minutes, forms:publisher, forms:rankings, forms:recommended_players, forms:release_date, forms:release_status, forms:search_aliases, forms:series_title, forms:sort_title, forms:subtitle, forms:themes, forms:title, forms:variant, forms:work_release_date, forms:year_published

## Movie

Sources: `[lib/features/library/kinds/movie/workspace/movie_fields.dart]`; IDs: `[lib/features/library/kinds/movie/workspace/movie_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/movie/workspace/movie_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `movie.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `director` | `movie.director` | Director | `dto.director` | yes | yes | yes | yes |
| work | `cover` | `movie.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `runtimeMinutes` | `movie.runtime_minutes` | Runtime (min) | `dto.runtimeMinutes ?? dto.movie.technical.runtimeMinutes` | yes | yes | — | — |
| work | `genre` | `movie.genre` | Genre | `dto.genres.isNotEmpty ? dto.genres.join('` | — | — | yes | — |
| work | `audienceRating` | `movie.audience_rating` | Audience Rating | `dto.audienceRating` | — | — | yes | — |
| work | `movieOrTvSeries` | `movie.movie_or_tv_series` | Movie / TV Series | `'Movie'` | — | — | yes | — |
| work | `originalTitle` | `movie.original_title` | Original Title | `dto.originalTitle` | — | — | — | — |
| work | `writer` | `movie.writer` | Writer | `dto.writer` | yes | — | — | — |
| work | `producer` | `movie.producer` | Producer | `dto.producer` | yes | — | — | — |
| work | `ageRating` | `movie.age_rating` | Age Rating | `dto.ageRating` | — | — | — | — |
| release | `publisher` | `movie.publisher` | Studio / Publisher | `dto.studio ?? dto.publisher` | yes | yes | yes | yes |
| release | `releaseDate` | `movie.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `barcode` | `movie.barcode` | UPC / Barcode | `dto.barcode` | yes | — | — | yes |
| release | `format` | `movie.format` | Format | `dto.format` | yes | — | yes | yes |
| release | `releaseYear` | `movie.release_year` | Release Year | `dto.releaseDate?.year` | — | — | yes | — |
| release | `edition` | `movie.edition` | Edition | `dto.release?.title` | — | — | — | — |
| release | `audioTracks` | `movie.audio_tracks` | Audio Tracks | `dto.release?.videoDetails?.audioTracks ??` | — | — | yes | — |
| release | `editionReleaseDate` | `movie.edition_release_date` | Edition Release Date | `dto.release?.releaseDate` | — | — | yes | — |
| copy | `condition` | `movie.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `movie.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `movie.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `movie.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `movie.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `movie.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `movie.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `movie.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `watchStatus` | `movie.watch_status` | Watch Status | `context.dto.personal.trackingStatus` | — | — | — | — |

- Workspace sort IDs: movie.director, movie.publisher, movie.release_date, movie.release_title, movie.runtime_minutes, movie.status, movie.title
- Workspace group IDs: movie.audience_rating, movie.audio_tracks, movie.condition, movie.director, movie.edition_release_date, movie.format, movie.genre, movie.location, movie.movie_or_tv_series, movie.publisher, movie.release_year
- Default visible column IDs by scope: work: movie.cover, movie.director, movie.title; release: movie.barcode, movie.format, movie.publisher, movie.release_date; copy: movie.condition, movie.location, movie.price_paid, movie.rating, movie.status, movie.updated_at, movie.wishlist
- Root schema defaults: sort `movie.director`; group `movie.director`. Release/Copy overrides: see `lib/features/library/kinds/movie/workspace/movie_workspace_contribution.dart`.
- Facet ID members: director, publisher, genre, format, studio
- Add/Edit field IDs (prefix identifies source family): add:release, add:work, edit:box_set_id, edit:box_set_name, edit:classification, edit:distributor, edit:features, edit:hdr_formats, edit:identity, edit:media, edit:owned, edit:packaging, edit:physical, edit:publishing, edit:region, edit:release, forms:age_rating, forms:audience_rating, forms:back_cover_image_url, forms:barcode, forms:characters, forms:cover_image_url, forms:description, forms:directors, forms:distributor, forms:format, forms:genres, forms:item_number, forms:language, forms:original_language, forms:region, forms:release_date, forms:release_description, forms:release_title, forms:release_year, forms:runtime_minutes, forms:sort_title, forms:subtitle, forms:title, forms:variant, forms:work_release_date

## Tv

Sources: `[lib/features/library/kinds/tv/workspace/tv_fields.dart]`; IDs: `[lib/features/library/kinds/tv/workspace/tv_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/tv/workspace/tv_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `tv.title` | Title | `dto.title` | yes | yes | — | yes |
| work | `publisher` | `tv.network` | Network / Studio | `dto.publisher` | yes | yes | yes | yes |
| work | `series` | `tv.series` | Series | `dto.seriesTitle` | yes | yes | yes | yes |
| work | `cover` | `tv.cover` | Cover | `context.dto.coverImageUrl` | yes | — | — | yes |
| work | `firstAirDate` | `tv.first_air_date` | First Air Date | `dto.firstAirDate` | — | — | — | — |
| work | `lastAirDate` | `tv.last_air_date` | Last Air Date | `dto.lastAirDate` | — | — | — | — |
| work | `tvStatus` | `tv.tv_status` | Series Status | `dto.tvStatus` | yes | — | yes | — |
| work | `streamingService` | `tv.streaming_service` | Streamer | `dto.streamingService` | yes | — | yes | — |
| work | `contentRating` | `tv.content_rating` | Content Rating | `dto.contentRating` | yes | — | — | — |
| work | `seasonCount` | `tv.season_count` | Seasons | `dto.seasonCount` | yes | yes | — | — |
| work | `episodeCount` | `tv.episode_count` | Episodes | `dto.episodeCount` | yes | yes | — | — |
| work | `episodeRuntimeMinutes` | `tv.episode_runtime_minutes` | Episode Runtime (m) | `dto.episodeRuntimeMinutes` | — | — | — | — |
| release | `releaseDate` | `tv.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| release | `releaseYear` | `tv.release_year` | Release Year | `dto.releaseDate?.year` | — | — | yes | — |
| release | `barcode` | `tv.barcode` | UPC / Barcode | `dto.barcode` | yes | — | — | yes |
| copy | `condition` | `tv.condition` | Condition | `derived from projection/context` | yes | — | yes | yes |
| copy | `location` | `tv.location` | Location | `context.source.locationPath` | yes | — | yes | yes |
| copy | `pricePaid` | `tv.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | — | — | yes |
| copy | `status` | `tv.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `tv.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `tv.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | yes |
| copy | `updatedAt` | `tv.updated_at` | Updated | `context.source.updatedAt` | yes | — | — | yes |
| copy | `addedAt` | `tv.added_at` | Added | `context.source.addedAt` | yes | — | — | — |
| copy | `watchStatus` | `tv.watch_status` | Watch Status | `context.dto.personal.trackingStatus` | — | — | — | — |

- Workspace sort IDs: tv.episode_count, tv.release_date, tv.release_title, tv.season_count, tv.series, tv.status, tv.title
- Workspace group IDs: tv.condition, tv.location, tv.release_year, tv.series, tv.streaming_service, tv.tv_status
- Default visible column IDs by scope: work: tv.cover, tv.network, tv.series, tv.title; release: tv.barcode, tv.release_date; copy: tv.condition, tv.location, tv.price_paid, tv.rating, tv.status, tv.updated_at, tv.wishlist
- Root schema defaults: sort `tv.series`; group `tv.series`. Release/Copy overrides: see `lib/features/library/kinds/tv/workspace/tv_workspace_contribution.dart`.
- Facet ID members: network, genre, creator, streamer
- Add/Edit field IDs (prefix identifies source family): add:characters, add:creators, add:first_air_year, add:metadata, add:release, add:season_number, add:series, edit:box_set_id, edit:box_set_name, edit:broadcast, edit:classification, edit:distributor, edit:features, edit:hdr_formats, edit:identity, edit:owned, edit:packaging, edit:physical, edit:publishing, edit:region, edit:release, edit:series, forms:audio, forms:barcode, forms:case_type, forms:content_rating, forms:cover_image_url, forms:description, forms:end_date, forms:first_air_date, forms:format, forms:genres, forms:network, forms:original_language, forms:publisher, forms:region, forms:release_date, forms:sort_title, forms:status, forms:streaming_service, forms:subtitles, forms:title

## Music

Sources: `[lib/features/library/kinds/music/workspace/music_workspace_fields.dart]`; IDs: `[lib/features/library/kinds/music/workspace/music_ids.dart]`; contribution/default overrides: `[lib/features/library/kinds/music/workspace/music_workspace_contribution.dart]`. Workspace scope is recorded on each field definition. Form IDs are collected from the live Add/Edit/forms source files.

| Scope | Workspace field | Existing ID | Label | Projected source | Column | Sort | Group | Default visible |
|---|---|---|---|---|---:|---:|---:|---:|
| work | `title` | `music.title` | Title | `dto.primaryLabel` | yes | yes | — | yes |
| work | `artist` | `music.artist` | Artist | `dto.artist` | yes | yes | yes | yes |
| work | `publisher` | `music.publisher` | Label | `dto.publisher` | — | — | — | — |
| work | `genre` | `music.genre` | Genre | `dto.genre` | yes | — | yes | yes |
| work | `releaseCount` | `music.release_count` | Release count | `dto.releaseCount` | yes | yes | — | yes |
| work | `aggregateListenCount` | `music.aggregate_listen_count` | Aggregate listens | `dto.aggregateListenCount` | yes | yes | — | yes |
| work | `aggregateLastListened` | `music.aggregate_last_listened` | Last listened | `dto.aggregateLastListened` | yes | yes | — | yes |
| work | `listenedReleaseCount` | `music.listened_release_count` | Listened releases | `dto.listenedReleaseCount` | yes | yes | — | yes |
| work | `releaseDate` | `music.release_date` | Release Date | `dto.releaseDate` | yes | yes | — | yes |
| work | `trackCount` | `music.track_count` | Track count | `dto.trackCount` | yes | yes | — | yes |
| work | `cover` | `music.cover` | Cover | `context.dto.imageUrl` | yes | — | — | yes |
| release | `listenCount` | `music.listen_count` | Listen count | `dto.listenCount` | yes | yes | — | yes |
| release | `lastListened` | `music.last_listened` | Last listened | `dto.lastListened` | yes | yes | — | yes |
| release | `barcode` | `music.barcode` | Barcode | `dto.barcode` | yes | — | — | yes |
| release | `catalogNumber` | `music.catalog_number` | Catalog Number | `dto.catalogNumber` | yes | — | — | — |
| release | `format` | `music.format` | Format | `dto.format` | yes | — | yes | — |
| release | `releaseType` | `music.release_type` | Release type | `dto.releaseType` | yes | — | — | — |
| release | `releaseStatus` | `music.release_status` | Release status | `dto.releaseStatus` | yes | — | — | — |
| release | `language` | `music.language` | Language | `dto.language` | yes | — | — | — |
| release | `packaging` | `music.packaging` | Packaging | `dto.packaging` | yes | — | — | — |
| release | `boxSet` | `music.box_set` | Box set | `dto.boxSet` | yes | — | yes | yes |
| release | `country` | `music.country` | Country | `musicCountryName(dto.country)` | yes | — | yes | — |
| release | `discCount` | `music.disc_count` | Disc Count | `dto.discCount` | yes | yes | — | — |
| copy | `condition` | `music.condition` | Condition | `derived from projection/context` | yes | yes | yes | yes |
| copy | `location` | `music.location` | Location | `context.source.locationPath` | yes | yes | yes | yes |
| copy | `pricePaid` | `music.price_paid` | Purchase Price | `context.source.pricePaidCents` | yes | yes | — | yes |
| copy | `status` | `music.status` | Status | `context.source.isWishlisted` | yes | yes | — | yes |
| copy | `rating` | `music.rating` | Rating | `context.dto.personal.rating` | yes | — | — | yes |
| copy | `wishlist` | `music.wishlist` | Wishlist | `context.source.isWishlisted` | yes | — | — | — |
| copy | `updatedAt` | `music.updated_at` | Updated | `context.source.updatedAt` | yes | yes | — | yes |
| copy | `addedAt` | `music.added_at` | Added | `context.source.addedAt` | yes | yes | — | — |
| copy | `signedBy` | `music.signed_by` | Signed By | `derived from projection/context` | yes | — | — | — |
| copy | `grade` | `music.grade` | Grade | `derived from projection/context` | yes | yes | yes | yes |
| copy | `storage` | `music.storage` | Storage | `derived from projection/context` | yes | yes | yes | yes |
| copy | `purchaseDate` | `music.purchase_date` | Purchase date | `context.source.purchaseDate` | yes | yes | — | yes |
| copy | `marketValue` | `music.market_value` | Market value | `context.source.marketValueCents` | yes | yes | — | yes |
| copy | `indexNumber` | `music.index_number` | Index number | `derived from projection/context` | yes | yes | — | yes |
| copy | `lastCleaned` | `music.last_cleaned` | Last cleaned | `derived from projection/context` | yes | yes | — | — |

- Workspace sort IDs: music.added_at, music.aggregate_last_listened, music.aggregate_listen_count, music.artist, music.condition, music.disc_count, music.grade, music.index_number, music.last_cleaned, music.last_listened, music.listen_count, music.listened_release_count, music.location, music.market_value, music.price_paid, music.purchase_date, music.release_count, music.release_date, music.status, music.storage, music.title, music.track_count, music.updated_at
- Workspace group IDs: music.artist, music.box_set, music.condition, music.country, music.format, music.genre, music.grade, music.location, music.storage
- Default visible column IDs by scope: work: music.aggregate_last_listened, music.aggregate_listen_count, music.artist, music.cover, music.genre, music.listened_release_count, music.release_count, music.release_date, music.status, music.title, music.track_count; release: music.artist, music.barcode, music.box_set, music.cover, music.last_listened, music.listen_count, music.publisher, music.release_date, music.status, music.title, music.track_count; copy: music.artist, music.condition, music.cover, music.grade, music.index_number, music.location, music.market_value, music.price_paid, music.purchase_date, music.rating, music.status, music.storage, music.title, music.updated_at
- Scope defaults: work sort `music.artist` / group `music.artist`; release sort `music.artist` / group `music.artist`; copy sort `music.artist` / group `music.artist`.
- Facet ID members: artist, publisher, genre, format, country
- Add/Edit field IDs (prefix identifies source family): add:release, add:release_group, add:year, edit:collection_status, edit:condition, edit:currency, edit:current_value, edit:digital, edit:edition, edit:grade, edit:identity, edit:index_number, edit:last_cleaned, edit:listening, edit:location, edit:notes, edit:owner, edit:personal, edit:personal_notes, edit:purchase, edit:purchase_date, edit:purchase_price, edit:purchase_store, edit:quantity, edit:recording, edit:release, edit:release_group, edit:sale, edit:sell_price, edit:signed_by, edit:sold_at, edit:sold_to, edit:tags, edit:tracking, edit:tracking_notes, edit:tracking_rating, edit:tracking_status, forms:artist, forms:barcode, forms:box_set_name, forms:box_set_position, forms:box_set_ref, forms:catalog_number, forms:country, forms:cover_image_url, forms:format, forms:genres, forms:is_live, forms:language, forms:original_release_date, forms:original_title, forms:packaging, forms:record_label, forms:recording_date, forms:release_date, forms:release_status, forms:release_type, forms:sort_title, forms:studio, forms:subtitle, forms:title, forms:upc

## Persistence audit points

- Workspace settings are loaded and normalized by `LibraryWorkspacePreferences` and `library_workspace_persistence.dart`; identifiers appear in `sort_column`, `sort_rules`, `visible_columns`, `column_widths`, `group_id`, and column presets.
- Scope is selected from browser mode before decoding workspace preferences. Existing `*_preference_codec.dart` files are mostly identity codecs; preserve this routing and add aliases only for IDs that actually change.
- Each field ID may also be referenced by facets, filters, views, tests, seed fixtures, or generated kind registrations. Search all usages before deleting or renaming an identifier.
