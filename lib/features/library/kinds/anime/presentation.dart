import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/shared/movie/presentation.dart'
    as movie_presentation;
import 'package:collectarr_app/features/library/kinds/anime/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/shared/movie/presentation_builder.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_field_definitions.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const animeMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Anime identity',
  contextSectionTitle: 'Anime context',
  creditsSectionTitle: 'Cast & Discovery',
  creators: 'Cast & Crew',
  characters: 'Characters',
);

class AnimeLibraryMediaPresentationBuilder
    extends VideoLibraryMediaPresentationBuilder {
  const AnimeLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: animeMetadataLabels,
        );
}

const animeLibraryMediaBuilder = AnimeLibraryMediaPresentationBuilder();

const animePreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Episodes',
);

const animeStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Studios',
);

final animeLibraryFieldDefinitions =
    libraryWorkspaceFieldDefinitionsForKind('anime');

const animeLibraryGroupModes = [
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
  LibraryGroupMode.ownership,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.watched,
  LibraryGroupMode.watchDate,
  LibraryGroupMode.watchMonth,
  LibraryGroupMode.watchYear,
];

const animeLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.tv_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Studio',
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.genre,
    label: 'Genres',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.country,
    label: 'Country',
    sidebarTitle: 'Countries',
    icon: Icons.flag_outlined,
    supportsBucketManagement: true,
  ),
];

const animeLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Studio',
  publisherPlural: 'Studios',
  unknownPublisher: 'Unknown studio',
  publisherMode: 'Studios',
  genre: 'Genres',
  genrePlural: 'Genres',
);

const animeLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String animeLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    animeLibraryGroupLabels,
    animeLibraryBucketLabelOverrides,
  );
}

final animeLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Episode / season....',
    publisherHint: 'Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Studio',
    anyPublisher: 'Any studio',
  ),
  groupLabels: animeLibraryGroupLabels,
  builder: animeLibraryMediaBuilder,
  workspaceEntryBuilder: buildAnimeLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildAnimeLibraryReleaseEntry,
  bucketLabelBuilder: animeLibraryBucketLabelBuilder,
  previewLabels: animePreviewLabels,
  statsLabels: animeStatsLabels,
  usesTreeProviderCandidates: true,
  supportsSeriesIssueJump: true,
  usesCompactTableLayout: true,
  compactBucketIcon: Icons.tv_outlined,
  fieldDefinitions: animeLibraryFieldDefinitions,
  sortColumnDefinitions: movie_presentation.moviesLibrarySortColumnDefinitions,
  groupModeDefinitions: movie_presentation.moviesLibraryGroupModeDefinitions,
  groupModes: movie_presentation.moviesLibraryGroupModes,
);
