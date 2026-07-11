import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';

class LibrarySidebarScopeSnapshot {
  const LibrarySidebarScopeSnapshot({
    required this.groupMode,
    this.selectedBucket,
    this.selectedLetter,
    this.linkedMetadataFilter,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.seriesCompletionScope = LibrarySeriesCompletionScope.all,
    this.quickView,
    this.filterSelection = LibraryFilterSelection.none,
    this.activeSmartListId,
    this.activeSmartListName,
    this.searchQuery = '',
  });

  final String groupMode;
  final String? selectedBucket;
  final String? selectedLetter;
  final LibraryLinkedMetadataFilter? linkedMetadataFilter;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibrarySeriesCompletionScope seriesCompletionScope;
  final LibraryQuickView? quickView;
  final LibraryFilterSelection filterSelection;
  final String? activeSmartListId;
  final String? activeSmartListName;
  final String searchQuery;

  bool get isRootScope =>
      selectedBucket == null &&
      selectedLetter == null &&
      linkedMetadataFilter == null &&
      collectionStatusScope == LibraryCollectionStatusScope.all &&
      seriesCompletionScope == LibrarySeriesCompletionScope.all &&
      quickView == null &&
      !filterSelection.hasActiveFilters &&
      activeSmartListId == null &&
      searchQuery.trim().isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is LibrarySidebarScopeSnapshot &&
        other.groupMode == groupMode &&
        other.selectedBucket == selectedBucket &&
        other.selectedLetter == selectedLetter &&
        other.linkedMetadataFilter == linkedMetadataFilter &&
        other.collectionStatusScope == collectionStatusScope &&
        other.seriesCompletionScope == seriesCompletionScope &&
        other.quickView == quickView &&
        other.filterSelection == filterSelection &&
        other.activeSmartListId == activeSmartListId &&
        other.activeSmartListName == activeSmartListName &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(
        groupMode,
        selectedBucket,
        selectedLetter,
        linkedMetadataFilter,
        collectionStatusScope,
        seriesCompletionScope,
        quickView,
        filterSelection,
        activeSmartListId,
        activeSmartListName,
        searchQuery,
      );
}