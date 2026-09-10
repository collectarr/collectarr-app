import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

import 'library_filter_presentation.dart';
import 'library_metadata_presentation.dart';
import 'library_personal_filter_presentation.dart';
import 'library_search_presentation.dart';
import 'library_sort_presentation.dart';

typedef LibraryCardPresentationBuilder = LibraryCardPresentation Function(
  LibraryProjectionView item, {
  required bool musicVertical,
});

typedef LibraryQuickViewMatcher = bool? Function(
  LibraryProjectionView item,
  LibraryQuickView view,
);

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
    required this.builder,
    required this.bucketLabelBuilder,
    this.cardPresentationBuilder,
    this.quickViewMatcher,
    this.usesCompactTableLayout = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
    this.previewLabels = const LibraryMediaPreviewLabels(),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.sortFavorites = defaultLibrarySortFavorites,
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.filterDefinitions = const [],
    this.referenceLabels = const LibraryPresentationLabels(),
    this.statusLabels = const LibraryPresentationLabels(),
    this.bucketLabelOverrides = const LibraryPresentationLabels(),
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryPresentationLabels filterLabels;
  final LibraryPresentationLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final LibraryBucketLabelBuilder bucketLabelBuilder;
  final LibraryCardPresentationBuilder? cardPresentationBuilder;
  final LibraryQuickViewMatcher? quickViewMatcher;
  final bool usesCompactTableLayout;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final List<LibrarySortFavorite> sortFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;
  final LibraryFilterOptionLabels filterOptionLabels;
  final List<LibraryFilterDefinition<dynamic>> filterDefinitions;
  final LibraryPresentationLabels referenceLabels;
  final LibraryPresentationLabels statusLabels;
  final LibraryPresentationLabels bucketLabelOverrides;

  /// Builds the kind-owned card contribution for a projected item.
  ///
  /// The media presentation is the presentation boundary; the kind module
  /// registration remains limited to navigation and capability dispatch.
  LibraryCardPresentation buildCardPresentation(
    LibraryProjectionView item, {
    required bool musicVertical,
  }) {
    return cardPresentationBuilder?.call(
          item,
          musicVertical: musicVertical,
        ) ??
        const LibraryCardPresentation();
  }
}
