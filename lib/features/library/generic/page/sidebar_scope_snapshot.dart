import 'package:collectarr_app/features/library/generic/filters.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/foundation.dart';

class LibrarySidebarScopeSnapshot {
  const LibrarySidebarScopeSnapshot({
    required this.groupMode,
    this.selectedBucket,
    this.selectedLetter,
    this.linkedMetadataFilters = const [],
    this.collectionStatusScope = kDefaultCollectionStatusScope,
    this.bucketCompletionScope = LibraryBucketCompletionScope.all,
    this.quickView,
    this.filterSelection = LibraryFilterSelection.none,
    this.activeSmartListId,
    this.activeSmartListName,
    this.searchQuery = '',
  });

  final String groupMode;
  final String? selectedBucket;
  final String? selectedLetter;
  final List<LibraryLinkedMetadataFilter> linkedMetadataFilters;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryBucketCompletionScope bucketCompletionScope;
  final LibraryQuickView? quickView;
  final LibraryFilterSelection filterSelection;
  final String? activeSmartListId;
  final String? activeSmartListName;
  final String searchQuery;

  LibrarySidebarScopeSnapshot withSelectedBucket(String? bucket) =>
      LibrarySidebarScopeSnapshot(
        groupMode: groupMode,
        selectedBucket: bucket,
        selectedLetter: selectedLetter,
        linkedMetadataFilters: linkedMetadataFilters,
        collectionStatusScope: collectionStatusScope,
        bucketCompletionScope: bucketCompletionScope,
        quickView: quickView,
        filterSelection: filterSelection,
        activeSmartListId: activeSmartListId,
        activeSmartListName: activeSmartListName,
        searchQuery: searchQuery,
      );

  bool get isRootScope =>
      selectedBucket == null &&
      selectedLetter == null &&
      linkedMetadataFilters.isEmpty &&
      collectionStatusScope == kDefaultCollectionStatusScope &&
      bucketCompletionScope == LibraryBucketCompletionScope.all &&
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
        listEquals(other.linkedMetadataFilters, linkedMetadataFilters) &&
        other.collectionStatusScope == collectionStatusScope &&
        other.bucketCompletionScope == bucketCompletionScope &&
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
        Object.hashAll(linkedMetadataFilters),
        collectionStatusScope,
        bucketCompletionScope,
        quickView,
        filterSelection,
        activeSmartListId,
        activeSmartListName,
        searchQuery,
      );
}
