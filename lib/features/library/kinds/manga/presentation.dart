import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/shared/comic/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
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
    'comic.story_arc': LibraryFacetId.comicStoryArc,
    'comic.character': LibraryFacetId.mediaCharacter,
  },
  supportsSeriesIssueJump: true,
  usesCompactTableLayout: true,
  compactBucketIcon: Icons.import_contacts_outlined,
  fieldDefinitions: mangaLibraryFieldDefinitions,
  sortDefinitions: mangaLibrarySortDefinitions,
  groupDefinitions: mangaLibraryGroupDefinitions,
  columnDefinitions: mangaLibraryColumnDefinitions,
  defaultVisibleColumnIds: mangaLibraryDefaultVisibleColumnIds,
  defaultSortId: mangaDefaultSortId,
  defaultGroupId: mangaDefaultGroupId,
);
