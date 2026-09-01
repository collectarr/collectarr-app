import 'package:collectarr_app/features/library/kinds/_shared/video/video_display_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/material.dart';

import 'library_filter_presentation.dart';
import 'library_metadata_presentation.dart';
import 'library_search_presentation.dart';
import 'library_sort_presentation.dart';

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
    required this.builder,
    required this.projector,
    required this.bucketLabelBuilder,
    this.previewLabels = const LibraryMediaPreviewLabels(
      series: 'Series',
      itemCount: 'Items',
    ),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.usesTreeProviderCandidates = false,
    this.externalFacetBucketIdsByMode = const {},
    this.supportsTrackSearch = false,
    this.usesTrackListCard = false,
    this.showsSeasonGroupProgress = false,
    this.defaultVideoDisplayLevel,
    this.defaultVideoGrouping = VideoGroupingDefault.none,
    this.videoSeriesEntryTypes = const {},
    this.videoShelfDrilldownEntryTypes = const {},
    this.usesCompactTableLayout = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
    this.sortFavorites = defaultLibrarySortFavorites,
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.filterFieldDefinitions = defaultLibraryFilterFieldDefinitions,
    this.referenceLabels = const LibraryReferenceLabels(),
    this.statusLabels = const LibraryStatusLabels(),
    this.bucketLabelOverrides = const LibraryBucketLabelOverrides(),
    this.fieldDefinitions = const [],
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryMediaFilterLabels filterLabels;
  final LibraryMediaGroupLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final LibraryWorkspaceProjector<LibraryWorkspaceDto> projector;
  final LibraryBucketLabelBuilder bucketLabelBuilder;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final bool usesTreeProviderCandidates;
  final Map<String, LibraryFacetIdRuntime> externalFacetBucketIdsByMode;
  final bool supportsTrackSearch;
  final bool usesTrackListCard;
  final bool showsSeasonGroupProgress;
  final VideoDisplayLevel? defaultVideoDisplayLevel;
  final VideoGroupingDefault defaultVideoGrouping;
  final Set<String> videoSeriesEntryTypes;
  final Set<String> videoShelfDrilldownEntryTypes;
  final bool usesCompactTableLayout;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final List<LibrarySortFavorite> sortFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;
  final LibraryFilterOptionLabels filterOptionLabels;
  final List<LibraryFilterFieldDefinition> filterFieldDefinitions;
  final LibraryReferenceLabels referenceLabels;
  final LibraryStatusLabels statusLabels;
  final LibraryBucketLabelOverrides bucketLabelOverrides;
  final List<LibraryFieldDefinition<dynamic, LibraryWorkspaceDto, Object?>>
      fieldDefinitions;

  LibraryFieldDefinition<dynamic, LibraryWorkspaceDto, Object?>?
      fieldDefinitionFor(
    String id,
  ) {
    for (final definition in fieldDefinitions) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }
}
