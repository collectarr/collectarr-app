import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';

class LibraryProjectionEngine {
  LibraryProjectionEngine({
    LibraryProjectionIndex? index,
    LibraryFilterEngine? filterEngine,
    LibraryGroupingEngine? groupingEngine,
    LibraryFolderTreeBuilder? folderTreeBuilder,
    LibraryToolbarStatsCalculator? statsCalculator,
  })  : index = index ?? LibraryProjectionIndex(),
        filterEngine = filterEngine ?? const LibraryFilterEngine(),
        groupingEngine = groupingEngine ?? const LibraryGroupingEngine(),
        folderTreeBuilder =
            folderTreeBuilder ?? const LibraryFolderTreeBuilder(),
        statsCalculator =
            statsCalculator ?? const LibraryToolbarStatsCalculator();

  final LibraryProjectionIndex index;
  final LibraryFilterEngine filterEngine;
  final LibraryGroupingEngine groupingEngine;
  final LibraryFolderTreeBuilder folderTreeBuilder;
  final LibraryToolbarStatsCalculator statsCalculator;

  LibraryProjection execute({
    required ShelfState shelf,
    required LibraryKindRuntime type,
    required LibraryWorkspaceViewState viewState,
    required LibraryProjectionQuery query,
    LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
    String? releaseFolderTitleItemId,
    List<LibraryBucket>? overrideBuckets,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final runtime = type;
    final allItems = libraryItemsForShelf(
      shelf,
      type,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
      customFieldValuesByItem: customFieldValuesByItem,
      browserMode: browserMode,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
    );

    final scopedBucketItems = <LibraryProjectionItem>[];
    for (final item in allItems) {
      if (query.constrainedItemIds != null &&
          !query.constrainedItemIds!.contains(item.node.id)) {
        continue;
      }
      var matchesScope = true;
      for (final filter in query.bucketScopeFilters) {
        final bucket = index.getGroupBucket(
          item,
          filter.groupId,
          (it, mode) => groupingEngine.getGroupBucketForItem(it, type, mode),
        );
        if (bucket != filter.bucket) {
          matchesScope = false;
          break;
        }
      }
      if (matchesScope) {
        scopedBucketItems.add(item);
      }
    }

    final filteredItems = <LibraryProjectionItem>[];
    for (final item in scopedBucketItems) {
      final searchDoc = index.getSearchDocument(
        item,
        customFieldValuesByItem,
      );
      if (filterEngine.matches(
        item: item,
        query: query,
        searchDoc: searchDoc,
        type: type,
        index: index,
        activeLoanOwnedItemIds: activeLoanOwnedItemIds,
        customFieldValuesByDefinitionByItem:
            customFieldValuesByDefinitionByItem,
      )) {
        filteredItems.add(item);
      }
    }

    filteredItems.sort((a, b) => runtime.compareEntriesByRules(
          a,
          b,
          viewState.sortRules,
        ));

    final counts = statsCalculator.calculate(
      allItems: allItems,
      shownCount: filteredItems.length,
      type: type,
    );

    final groupId = query.groupId ??
        runtime.fields.defaultGroup ??
        runtime.fields.groups.first.id;
    final buckets = overrideBuckets ??
        groupingEngine.buildBuckets(
          scopedBucketItems,
          type,
          groupId,
          index: index,
        );

    return LibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets: buckets,
      selectedItem: librarySelectedItem(filteredItems, query.selectedItemId),
      counts: counts,
    );
  }
}
