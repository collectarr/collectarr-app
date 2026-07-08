import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/shared/comic/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart'
    as comic_presentation;
import 'package:collectarr_app/features/library/kinds/manga/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_field_definitions.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const mangaMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Manga identity',
  contextSectionTitle: 'Manga context',
  creditsSectionTitle: 'Creators & Discovery',
  creators: 'Creators',
  characters: 'Characters',
);

class MangaLibraryMediaPresentationBuilder
    extends ComicLibraryMediaPresentationBuilder {
  const MangaLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: mangaMetadataLabels,
        );
}

const mangaLibraryMediaBuilder = MangaLibraryMediaPresentationBuilder();

const mangaPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Chapters',
);

const mangaStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers',
);

const mangaLibraryGroupModes = [
  LibraryGroupMode.series,
  LibraryGroupMode.title,
  LibraryGroupMode.publisher,
  LibraryGroupMode.genre,
  LibraryGroupMode.country,
  LibraryGroupMode.language,
  LibraryGroupMode.ageRating,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.storyArc,
  LibraryGroupMode.character,
  LibraryGroupMode.creator,
  LibraryGroupMode.writer,
  LibraryGroupMode.artist,
  LibraryGroupMode.coverArtist,
  LibraryGroupMode.translator,
  LibraryGroupMode.imprint,
  LibraryGroupMode.seriesGroup,
  LibraryGroupMode.format,
  LibraryGroupMode.rawOrSlabbed,
  LibraryGroupMode.grade,
  LibraryGroupMode.condition,
  LibraryGroupMode.myRating,
  LibraryGroupMode.purchaseDate,
  LibraryGroupMode.purchaseMonth,
  LibraryGroupMode.purchaseYear,
  LibraryGroupMode.purchaseStore,
  LibraryGroupMode.location,
  LibraryGroupMode.ownership,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.tags,
];

const mangaLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    id: 'series',
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    id: 'title',
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    id: 'publisher',
    label: 'Publisher',
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.genre,
    id: 'genre',
    label: 'Genre',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.country,
    id: 'country',
    label: 'Country',
    sidebarTitle: 'Countries',
    icon: Icons.flag_outlined,
    supportsBucketManagement: true,
  ),
];

const mangaLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
  publisherMode: 'Publishers',
  genre: 'Genre',
  genrePlural: 'Genres',
);

const mangaLibraryBucketLabelOverrides = LibraryBucketLabelOverrides(
  storyArc: 'Story arc',
  character: 'Character',
);

final mangaLibraryFieldDefinitions =
    libraryWorkspaceFieldDefinitionsForKind('manga');

String mangaLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    mangaLibraryGroupLabels,
    mangaLibraryBucketLabelOverrides,
  );
}

final mangaLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Chapter / vol....',
    publisherHint: 'Publisher...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: mangaLibraryGroupLabels,
  builder: mangaLibraryMediaBuilder,
  workspaceEntryBuilder: buildMangaLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildMangaLibraryReleaseEntry,
  bucketLabelBuilder: mangaLibraryBucketLabelBuilder,
  previewLabels: mangaPreviewLabels,
  statsLabels: mangaStatsLabels,
  usesTreeProviderCandidates: true,
  externalFacetBucketIdsByMode: {
    LibraryGroupMode.storyArc: LibraryFacetId.comicStoryArc,
    LibraryGroupMode.character: LibraryFacetId.mediaCharacter,
  },
  supportsSeriesIssueJump: true,
  usesCompactTableLayout: true,
  compactBucketIcon: Icons.import_contacts_outlined,
  fieldDefinitions: mangaLibraryFieldDefinitions,
  sortColumnDefinitions: comic_presentation.comicsLibrarySortColumnDefinitions,
  groupModeDefinitions: comic_presentation.comicsLibraryGroupModeDefinitions,
  groupModes: comic_presentation.comicsLibraryGroupModes,
);
