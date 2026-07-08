import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/shared/movie/presentation_builder.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
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
  sortColumnDefinitions: animeLibrarySortColumnDefinitions,
  groupModeDefinitions: animeLibraryGroupModeDefinitions,
  groupModes: animeLibraryGroupModes,
);
