import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'library_filter_engine.dart';
import 'library_grouping_engine.dart';
import 'library_projection_index.dart';
import 'library_projection_query.dart';
import 'library_toolbar_stats_calculator.dart';

class LibraryProjectionEngine {
  LibraryProjectionEngine({
    LibraryProjectionIndex? index,
    LibraryFilterEngine? filterEngine,
    LibraryGroupingEngine? groupingEngine,
    LibraryToolbarStatsCalculator? statsCalculator,
  })  : index = index ?? LibraryProjectionIndex(),
        filterEngine = filterEngine ?? const LibraryFilterEngine(),
        groupingEngine = groupingEngine ?? const LibraryGroupingEngine(),
        statsCalculator =
            statsCalculator ?? const LibraryToolbarStatsCalculator();

  final LibraryProjectionIndex index;
  final LibraryFilterEngine filterEngine;
  final LibraryGroupingEngine groupingEngine;
  final LibraryToolbarStatsCalculator statsCalculator;

  LibraryProjection execute({
    required ShelfState shelf,
    required LibraryTypeConfig type,
    required LibraryMediaAdapter adapter,
    required LibraryWorkspaceViewState viewState,
    required LibraryProjectionQuery query,
  }) {
    final allItems = libraryItemsForShelf(shelf, type);
    final filteredItems = <LibraryProjectionItem>[];

    for (final item in allItems) {
      final searchDoc = index.getSearchDocument(
        item,
        () => item.source.catalogItem?.title ?? item.node.id,
      );
      if (filterEngine.matches(
        item: item,
        query: query,
        searchDoc: searchDoc,
        adapter: adapter,
      )) {
        filteredItems.add(item);
      }
    }

    filteredItems.sort((a, b) => adapter.compareEntriesByRules(
          a,
          b,
          viewState.sortRules,
        ));

    final counts = statsCalculator.calculate(
      totalAllItems: allItems.length,
      shownCount: filteredItems.length,
    );

    return LibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets: groupingEngine.buildBuckets(
        filteredItems,
        type,
        query.groupMode ?? '',
      ),
      selectedItem: librarySelectedItem(filteredItems, query.selectedItemId),
      counts: counts,
    );
  }
}
