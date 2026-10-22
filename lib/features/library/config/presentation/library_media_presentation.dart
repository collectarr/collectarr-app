import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

import 'library_filter_presentation.dart';
import 'library_alphabet_field.dart';
import 'library_metadata_presentation.dart';
import 'library_personal_filter_presentation.dart';
import 'library_search_presentation.dart';
import 'library_sort_presentation.dart';

typedef LibraryCardPresentationBuilder = LibraryCardPresentation Function(
  LibraryProjectionView item, {
  required bool coverFocused,
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
    this.compactBucketIcon = Icons.folder,
    this.emptyStateSummarySuffix = '',
    this.previewLabels = const LibraryMediaPreviewLabels(),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.sortFavorites = const [],
    this.defaultFolderFavorites = const [],
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.duplicateColumns,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.filterDefinitions = const [],
    this.alphabetFields = const [LibraryAlphabetField.title],
    this.referenceLabels = const LibraryPresentationLabels(),
    this.statusLabels = const LibraryPresentationLabels(),
    this.bucketLabelOverrides = const LibraryPresentationLabels(),
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final List<LibraryAlphabetField> alphabetFields;
  final LibraryPresentationLabels filterLabels;
  final LibraryPresentationLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final LibraryBucketLabelBuilder bucketLabelBuilder;
  final LibraryCardPresentationBuilder? cardPresentationBuilder;
  final LibraryQuickViewMatcher? quickViewMatcher;
  final IconData compactBucketIcon;
  final String emptyStateSummarySuffix;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final List<LibrarySortFavorite> sortFavorites;

  /// Folder favorites offered until the user saves their own; each entry
  /// lists up to three nested group mode ids.
  final List<List<String>> defaultFolderFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;

  /// Default Find Duplicates columns; the workspace defaults when null.
  final List<String>? duplicateColumns;
  final LibraryFilterOptionLabels filterOptionLabels;
  final List<LibraryFilterDefinition<Object?>> filterDefinitions;
  final LibraryPresentationLabels referenceLabels;
  final LibraryPresentationLabels statusLabels;
  final LibraryPresentationLabels bucketLabelOverrides;

  /// Builds the kind-entry card contribution for a projected item.
  ///
  /// The media presentation is the presentation boundary; the kind contributor
  /// registration remains limited to navigation and capability dispatch.
  LibraryCardPresentation buildCardPresentation(
    LibraryProjectionView item, {
    required bool coverFocused,
  }) {
    final custom = cardPresentationBuilder?.call(
      item,
      coverFocused: coverFocused,
    );
    return custom ??
        builder.buildCardPresentation(
          item,
          coverFocused: coverFocused,
        );
  }
}
