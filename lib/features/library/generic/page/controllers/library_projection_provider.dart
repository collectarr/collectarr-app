import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class LibraryProjectionRequest {
  const LibraryProjectionRequest({
    required this.shelf,
    required this.type,
    required this.viewState,
    required this.browserMode,
    required this.releaseFolderWorkId,
    required this.query,
    required this.linkedMetadataFilter,
    required this.selectedBucket,
    required this.selectedItemId,
    required this.quickView,
    required this.collectionStatusScope,
    required this.groupMode,
    required this.bucketScopeFilters,
    required this.overrideBuckets,
    required this.constrainedItemIds,
    required this.filterSelection,
    required this.customFieldValuesByItem,
    required this.customFieldValuesByDefinitionByItem,
    this.customFieldDefinitions = const [],
    required this.activeLoanOwnedItemIds,
    required this.searchTarget,
  });

  final ShelfState shelf;
  final LibraryKindRegistration type;
  final LibraryWorkspaceViewState viewState;
  final LibraryWorkspaceBrowserMode browserMode;
  final String? releaseFolderWorkId;
  final String query;
  final LibraryLinkedMetadataFilter? linkedMetadataFilter;
  final String? selectedBucket;
  final String? selectedItemId;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final String groupMode;
  final List<LibraryBucketScopeFilter> bucketScopeFilters;
  final List<LibraryBucket>? overrideBuckets;
  final Set<String>? constrainedItemIds;
  final LibraryFilterSelection filterSelection;
  final Map<String, List<String>> customFieldValuesByItem;
  final Map<String, Map<String, String>> customFieldValuesByDefinitionByItem;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Set<OwnedItemRef> activeLoanOwnedItemIds;
  final LibrarySearchTarget searchTarget;

  @override
  bool operator ==(Object other) {
    return other is LibraryProjectionRequest &&
        shelf == other.shelf &&
        type == other.type &&
        viewState == other.viewState &&
        browserMode == other.browserMode &&
        releaseFolderWorkId == other.releaseFolderWorkId &&
        query == other.query &&
        linkedMetadataFilter == other.linkedMetadataFilter &&
        selectedBucket == other.selectedBucket &&
        selectedItemId == other.selectedItemId &&
        quickView == other.quickView &&
        collectionStatusScope == other.collectionStatusScope &&
        groupMode == other.groupMode &&
        listEquals(bucketScopeFilters, other.bucketScopeFilters) &&
        listEquals(overrideBuckets, other.overrideBuckets) &&
        setEquals(constrainedItemIds, other.constrainedItemIds) &&
        filterSelection == other.filterSelection &&
        _stringListMapEquals(
          customFieldValuesByItem,
          other.customFieldValuesByItem,
        ) &&
        _stringNestedMapEquals(
          customFieldValuesByDefinitionByItem,
          other.customFieldValuesByDefinitionByItem,
        ) &&
        listEquals(customFieldDefinitions, other.customFieldDefinitions) &&
        setEquals(activeLoanOwnedItemIds, other.activeLoanOwnedItemIds) &&
        searchTarget == other.searchTarget;
  }

  @override
  int get hashCode => Object.hashAll([
        shelf,
        type,
        viewState,
        browserMode,
        releaseFolderWorkId,
        query,
        linkedMetadataFilter,
        selectedBucket,
        selectedItemId,
        quickView,
        collectionStatusScope,
        groupMode,
        Object.hashAll(bucketScopeFilters),
        Object.hashAll(overrideBuckets ?? const <Object>[]),
        Object.hashAll(constrainedItemIds?.toList(growable: false) ?? const []),
        filterSelection,
        _stringListMapHash(customFieldValuesByItem),
        _stringNestedMapHash(customFieldValuesByDefinitionByItem),
        Object.hashAll(customFieldDefinitions),
        Object.hashAll(activeLoanOwnedItemIds.toList(growable: false)),
        searchTarget,
      ]);
}

bool _stringListMapEquals(
  Map<String, List<String>> left,
  Map<String, List<String>> right,
) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    final other = right[entry.key];
    if (other == null || !listEquals(entry.value, other)) {
      return false;
    }
  }

  return true;
}

int _stringListMapHash(Map<String, List<String>> value) {
  final keys = value.keys.toList(growable: false)..sort();
  return Object.hashAll([
    for (final key in keys) key,
    for (final key in keys) Object.hashAll(value[key] ?? const <String>[]),
  ]);
}

bool _stringNestedMapEquals(
  Map<String, Map<String, String>> left,
  Map<String, Map<String, String>> right,
) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    final other = right[entry.key];
    if (other == null || other.length != entry.value.length) {
      return false;
    }
    for (final nested in entry.value.entries) {
      if (other[nested.key] != nested.value) {
        return false;
      }
    }
  }
  return true;
}

int _stringNestedMapHash(Map<String, Map<String, String>> value) {
  final keys = value.keys.toList(growable: false)..sort();
  return Object.hashAll([
    for (final key in keys) key,
    for (final key in keys)
      _hashStringMap(value[key] ?? const <String, String>{}),
  ]);
}

int _hashStringMap(Map<String, String> value) {
  final keys = value.keys.toList(growable: false)..sort();
  return Object.hashAll([
    for (final key in keys) key,
    for (final key in keys) value[key],
  ]);
}

final libraryProjectionProvider = Provider.autoDispose
    .family<LibraryProjection, LibraryProjectionRequest>((ref, request) {
  return LibraryProjection.fromShelf(
    shelf: request.shelf,
    type: request.type,
    viewState: request.viewState,
    browserMode: request.browserMode,
    releaseFolderWorkId: request.releaseFolderWorkId,
    query: request.query,
    linkedMetadataFilter: request.linkedMetadataFilter,
    selectedBucket: request.selectedBucket,
    selectedItemId: request.selectedItemId,
    quickView: request.quickView,
    collectionStatusScope: request.collectionStatusScope,
    groupMode: request.groupMode,
    bucketScopeFilters: request.bucketScopeFilters,
    overrideBuckets: request.overrideBuckets,
    constrainedItemIds: request.constrainedItemIds,
    filterSelection: request.filterSelection,
    customFieldDefinitions: request.customFieldDefinitions,
    customFieldValuesByItem: request.customFieldValuesByItem,
    customFieldValuesByDefinitionByItem:
        request.customFieldValuesByDefinitionByItem,
    activeLoanOwnedItemIds: request.activeLoanOwnedItemIds,
    searchTarget: request.searchTarget,
  );
});
