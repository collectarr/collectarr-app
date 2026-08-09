import 'package:flutter/foundation.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/state/library_filter_state.dart';

@immutable
final class LibraryProjectionQuery {
  const LibraryProjectionQuery({
    this.searchQuery = '',
    this.filters = const LibraryFilterState(),
    this.sortId,
    this.sortAscending = true,
    this.groupMode,
    this.selectedBucket,
    this.selectedItemId,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.bucketScopeFilters = const [],
    this.filterSelection = LibraryFilterSelection.none,
    this.linkedMetadataFilter,
    this.constrainedItemIds,
  });

  final String searchQuery;
  final LibraryFilterState filters;
  final String? sortId;
  final bool sortAscending;
  final String? groupMode;
  final String? selectedBucket;
  final String? selectedItemId;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final List<LibraryBucketScopeFilter> bucketScopeFilters;
  final LibraryFilterSelection filterSelection;
  final LibraryLinkedMetadataFilter? linkedMetadataFilter;
  final Set<String>? constrainedItemIds;
}
