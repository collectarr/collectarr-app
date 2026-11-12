import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/presentation/alphabet_field.dart';
import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/generic/filters.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/layout/bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/projection_context.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class LibraryProjectionRequest {
  const LibraryProjectionRequest({
    required this.shelf,
    required this.type,
    required this.sortRules,
    required this.query,
    required this.linkedMetadataFilters,
    required this.selectedLetter,
    required this.alphabetField,
    required this.selectedBucket,
    required this.selectedItemId,
    required this.quickView,
    required this.collectionStatusScope,
    required this.groupMode,
    required this.bucketScopeFilters,
    required this.overrideBuckets,
    required this.constrainedItemIds,
    this.collectionEntryIds,
    required this.filterSelection,
    required this.customFieldValuesByItem,
    required this.customFieldValuesByDefinitionByItem,
    this.customFieldDefinitions = const [],
    required this.activeLoanLibraryEntryIds,
    required this.searchTarget,
  });

  final ShelfState shelf;
  final LibraryKindRegistration type;

  /// Only the sort rules of the view state shape the projection, so cover
  /// size or pane changes keep the cached projection.
  final List<LibrarySortRuleRuntime> sortRules;
  final String query;
  final List<LibraryLinkedMetadataFilter> linkedMetadataFilters;
  final String? selectedLetter;
  final LibraryAlphabetField alphabetField;
  final String? selectedBucket;
  final String? selectedItemId;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final String groupMode;
  final List<LibraryBucketScopeFilter> bucketScopeFilters;
  final List<LibraryBucket>? overrideBuckets;
  final Set<String>? constrainedItemIds;
  final Set<String>? collectionEntryIds;
  final LibraryFilterSelection filterSelection;
  final Map<String, List<String>> customFieldValuesByItem;
  final Map<String, Map<String, String>> customFieldValuesByDefinitionByItem;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Set<LibraryEntryRef> activeLoanLibraryEntryIds;
  final LibrarySearchTarget searchTarget;

  /// This request with no item selected. The selection does not shape the
  /// filtered, sorted and grouped library, so requests share that work.
  LibraryProjectionRequest withoutSelection() => LibraryProjectionRequest(
        shelf: shelf,
        type: type,
        sortRules: sortRules,
        query: query,
        linkedMetadataFilters: linkedMetadataFilters,
        selectedLetter: selectedLetter,
        alphabetField: alphabetField,
        selectedBucket: selectedBucket,
        selectedItemId: null,
        quickView: quickView,
        collectionStatusScope: collectionStatusScope,
        groupMode: groupMode,
        bucketScopeFilters: bucketScopeFilters,
        overrideBuckets: overrideBuckets,
        constrainedItemIds: constrainedItemIds,
        collectionEntryIds: collectionEntryIds,
        filterSelection: filterSelection,
        customFieldValuesByItem: customFieldValuesByItem,
        customFieldValuesByDefinitionByItem:
            customFieldValuesByDefinitionByItem,
        customFieldDefinitions: customFieldDefinitions,
        activeLoanLibraryEntryIds: activeLoanLibraryEntryIds,
        searchTarget: searchTarget,
      );

  @override
  bool operator ==(Object other) {
    return other is LibraryProjectionRequest &&
        shelf == other.shelf &&
        setEquals(collectionEntryIds, other.collectionEntryIds) &&
        type == other.type &&
        listEquals(sortRules, other.sortRules) &&
        query == other.query &&
        listEquals(linkedMetadataFilters, other.linkedMetadataFilters) &&
        selectedLetter == other.selectedLetter &&
        alphabetField.id == other.alphabetField.id &&
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
        setEquals(activeLoanLibraryEntryIds, other.activeLoanLibraryEntryIds) &&
        searchTarget == other.searchTarget;
  }

  @override
  int get hashCode => Object.hashAll([
        shelf,
        Object.hashAll((collectionEntryIds?.toList() ?? <String>[])..sort()),
        type,
        Object.hashAll(sortRules),
        query,
        Object.hashAll(linkedMetadataFilters),
        selectedLetter,
        alphabetField.id,
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
        Object.hashAll(activeLoanLibraryEntryIds.toList(growable: false)),
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

/// The projection of [LibraryProjectionRequest] with its item selected.
/// Selecting another item reuses the library already filtered, sorted and
/// grouped for the rest of the request.
final libraryProjectionProvider = Provider.autoDispose
    .family<LibraryProjection, LibraryProjectionRequest>((ref, request) {
  final projection = ref
      .watch(_unselectedLibraryProjectionProvider(request.withoutSelection()));
  return request.selectedItemId == null
      ? projection
      : projection.withSelectedItem(request.selectedItemId);
});

final _unselectedLibraryProjectionProvider = Provider.autoDispose
    .family<LibraryProjection, LibraryProjectionRequest>((ref, request) {
  final kind = request.type.kind.apiValue;
  // A Sort Name stored before its list stopped offering one is ignored.
  final unsortedLists = {
    for (final definition in defaultPickListRegistry.definitionsForKind(kind))
      if (!definition.hasSortName) definition.listName
  };
  final pickListSortNames = {
    for (final entry in (ref.watch(pickListSortNamesProvider(kind)).value ??
            const <String, Map<String, String>>{})
        .entries)
      if (!unsortedLists.contains(entry.key)) entry.key: entry.value
  };
  final sorting = ref.watch(uiPreferencesProvider.select((p) =>
      LibrarySortingOptions(
          useSortTitles: !p.ignoreSortTitles,
          useSortNames: !p.ignoreSortNames,
          latestFolderImages: p.latestFolderImages,
          pickListSortNames: pickListSortNames)));
  return LibraryProjection.fromShelf(
    sorting: sorting,
    shelf: request.shelf,
    type: request.type,
    sortRules: request.sortRules,
    query: request.query,
    linkedMetadataFilters: request.linkedMetadataFilters,
    selectedLetter: request.selectedLetter,
    alphabetField: request.alphabetField,
    selectedBucket: request.selectedBucket,
    selectedItemId: request.selectedItemId,
    quickView: request.quickView,
    collectionStatusScope: request.collectionStatusScope,
    groupMode: request.groupMode,
    bucketScopeFilters: request.bucketScopeFilters,
    overrideBuckets: request.overrideBuckets,
    constrainedItemIds: request.constrainedItemIds,
    collectionEntryIds: request.collectionEntryIds,
    filterSelection: request.filterSelection,
    customFieldDefinitions: request.customFieldDefinitions,
    customFieldValuesByItem: request.customFieldValuesByItem,
    customFieldValuesByDefinitionByItem:
        request.customFieldValuesByDefinitionByItem,
    activeLoanLibraryEntryIds: request.activeLoanLibraryEntryIds,
    searchTarget: request.searchTarget,
  );
});
