import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

import 'library_filter_presentation.dart';
import 'library_metadata_presentation.dart';
import 'library_personal_filter_presentation.dart';
import 'library_search_presentation.dart';
import 'library_sort_presentation.dart';

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
    required this.builder,
    required this.bucketLabelBuilder,
    this.usesCompactTableLayout = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
    this.previewLabels = const LibraryMediaPreviewLabels(),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.sortFavorites = defaultLibrarySortFavorites,
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.filterDefinitions = const [],
    this.referenceLabels = const LibraryReferenceLabels(),
    this.statusLabels = const LibraryStatusLabels(),
    this.bucketLabelOverrides = const LibraryBucketLabelOverrides(),
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryMediaFilterLabels filterLabels;
  final LibraryMediaGroupLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final LibraryBucketLabelBuilder bucketLabelBuilder;
  final bool usesCompactTableLayout;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final List<LibrarySortFavorite> sortFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;
  final LibraryFilterOptionLabels filterOptionLabels;
  final List<LibraryFilterDefinition<dynamic>> filterDefinitions;
  final LibraryReferenceLabels referenceLabels;
  final LibraryStatusLabels statusLabels;
  final LibraryBucketLabelOverrides bucketLabelOverrides;
}
