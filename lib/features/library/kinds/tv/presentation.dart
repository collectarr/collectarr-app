import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const tvPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Episodes',
);

const tvStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Networks',
);

const tvLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Network',
  publisherPlural: 'Networks',
  unknownPublisher: 'Unknown network',
  publisherMode: 'Networks',
  genre: 'Genres',
);

const tvDefaultWorkspaceGroupMode = LibraryGroupMode.series;
const tvDefaultWorkspaceGroupPresentation = LibraryGroupPresentation.folderGrid;
const tvDefaultVideoDisplayLevel = VideoDisplayLevel.season;
const tvDefaultVideoGrouping = VideoGroupingDefault.bySeries;

const tvLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String tvLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    tvLibraryGroupLabels,
    tvLibraryBucketLabelOverrides,
  );
}

const tvLibraryGroupModes = [
  LibraryGroupMode.series,
  LibraryGroupMode.genre,
  LibraryGroupMode.country,
  LibraryGroupMode.language,
  LibraryGroupMode.ageRating,
  LibraryGroupMode.movieOrTvSeries,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.publisher,
  LibraryGroupMode.title,
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
  LibraryGroupMode.watchedWhere,
];

const tvLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.genre,
    id: 'genre',
    label: 'Genres',
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
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.language,
    id: 'language',
    label: 'Language',
    sidebarTitle: 'Languages',
    icon: Icons.translate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ageRating,
    id: 'age_rating',
    label: 'Age',
    sidebarTitle: 'Age Ratings',
    icon: Icons.verified_user_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.movieOrTvSeries,
    id: 'movie_or_tv_series',
    label: 'Movie / TV Series',
    sidebarTitle: 'Movie / TV Series',
    icon: Icons.tv_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseDate,
    id: 'release_date',
    label: 'Release Date',
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseMonth,
    id: 'release_month',
    label: 'Release Month',
    sidebarTitle: 'Release Months',
    icon: Icons.event_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseYear,
    id: 'release_year',
    label: 'Release Year',
    sidebarTitle: 'Release Years',
    icon: Icons.event_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: tvDefaultWorkspaceGroupMode,
    id: 'series',
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.tv_outlined,
    presentation: tvDefaultWorkspaceGroupPresentation,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    id: 'publisher',
    label: 'Networks',
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    id: 'title',
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ownership,
    id: 'ownership',
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedDate,
    id: 'added_date',
    label: 'Added Date',
    sidebarTitle: 'Added Dates',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedMonth,
    id: 'added_month',
    label: 'Added Month',
    sidebarTitle: 'Added Months',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedYear,
    id: 'added_year',
    label: 'Added Year',
    sidebarTitle: 'Added Years',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.collectionStatus,
    id: 'collection_status',
    label: 'Collection Status',
    sidebarTitle: 'Collection Status',
    icon: Icons.stacked_bar_chart_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedDate,
    id: 'modified_date',
    label: 'Modified Date',
    sidebarTitle: 'Modified Dates',
    icon: Icons.update_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedMonth,
    id: 'modified_month',
    label: 'Modified Month',
    sidebarTitle: 'Modified Months',
    icon: Icons.update_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.watched,
    id: 'watched',
    label: 'Watched',
    sidebarTitle: 'Watched',
    icon: Icons.visibility_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.watchDate,
    id: 'watch_date',
    label: 'Watch Date',
    sidebarTitle: 'Watch Dates',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.watchMonth,
    id: 'watch_month',
    label: 'Watch Month',
    sidebarTitle: 'Watch Months',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.watchYear,
    id: 'watch_year',
    label: 'Watch Year',
    sidebarTitle: 'Watch Years',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.watchedWhere,
    id: 'watched_where',
    label: 'Watched Where',
    sidebarTitle: 'Watched Where',
    icon: Icons.tv_outlined,
  ),
];

const tvLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
      column: LibrarySortColumn.series, label: 'Series'),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    id: 'publisher',
    label: 'Network',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.title,
    id: 'title',
    label: 'Title',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.releaseDate,
    id: 'release_date',
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.country,
    id: 'country',
    label: 'Country',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.language,
    id: 'language',
    label: 'Language',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.ageRating,
    id: 'age_rating',
    label: 'Age rating',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.collectionStatus,
    id: 'collection_status',
    label: 'Collection status',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.added,
    id: 'added',
    label: 'Added date',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.updated,
    id: 'updated',
    label: 'Updated',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
];

final tvLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter series, episode, or keyword...',
    emptySearchMessage: 'Enter a series, episode, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Episode no....',
    publisherHint: 'Network...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Network',
    anyPublisher: 'Any network',
  ),
  groupLabels: tvLibraryGroupLabels,
  builder: TvLibraryMediaPresentationBuilder(),
  // intentional shared adapter, not canonical domain path
  workspaceEntryBuilder: buildTvWorkspaceEntryFromShelf,
  // intentional shared adapter, not canonical domain path
  releaseEntryBuilder: buildTvLibraryReleaseEntry,
  bucketLabelBuilder: tvLibraryBucketLabelBuilder,
  previewLabels: tvPreviewLabels,
  statsLabels: tvStatsLabels,
  showsSeasonGroupProgress: true,
  compactBucketIcon: Icons.tv_outlined,
  emptyStateProviderSummarySuffix: ' Episodes are tracked as seasons.',
  fieldDefinitions: tvLibraryFieldDefinitions,
  sortColumnDefinitions: tvLibrarySortColumnDefinitions,
  groupModeDefinitions: tvLibraryGroupModeDefinitions,
  groupModes: tvLibraryGroupModes,
);
