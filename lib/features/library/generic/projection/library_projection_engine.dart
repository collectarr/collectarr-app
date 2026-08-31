import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';

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
    required LibraryTypeConfig type,
    required LibraryWorkspaceViewState viewState,
    required LibraryProjectionQuery query,
    LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
    String? releaseFolderTitleItemId,
    List<LibrarySeriesBucket>? overrideBuckets,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
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
          filter.groupMode,
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

    filteredItems.sort((a, b) => libraryKindRuntimeForType(type).compareEntriesByRules(
          a,
          b,
          viewState.sortRules,
        ));

    final counts = statsCalculator.calculate(
      allItems: allItems,
      shownCount: filteredItems.length,
    );

    final groupMode = query.groupMode ?? libraryDefaultGroupMode(type);
    final buckets = overrideBuckets ??
        groupingEngine.buildBuckets(
          scopedBucketItems,
          type,
          groupMode,
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
