import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sidebar facets alias matches group mode categories', () {
    const modes = [
      LibraryGroupMode.series,
      LibraryGroupMode.grade,
      LibraryGroupMode.publisher,
    ];

    final adapter = comicsLibraryConfig.kindUiAdapter;
    final categories = adapter.groupModeCategories(comicsLibraryConfig, modes);
    final facets = adapter.sidebarFacets(comicsLibraryConfig, modes);

    expect(facets.map((category) => category.label), [
      for (final category in categories) category.label,
    ]);
  });

  test('comic-only toolbar actions stay in the kind adapter', () {
    final adapter = comicsLibraryConfig.kindUiAdapter;

    expect(
      adapter.supportsReportAction(comicsLibraryConfig),
      isTrue,
    );
    expect(
      adapter.supportsReportAction(moviesLibraryConfig),
      isFalse,
    );
  });

  test('browser mode resolution stays in the kind adapter', () {
    final adapter = booksLibraryConfig.kindUiAdapter;
    final state = LibraryWorkspaceViewState(
      viewMode: LibraryViewMode.grid,
      detailsLayout: LibraryDetailsLayout.bottom,
      isSidebarVisible: true,
      sortColumn: booksLibraryConfig.workspace.defaultSortColumn,
      sortAscending: true,
      coverSize: 180,
      sidebarWidth: 320,
      detailsWidth: 420,
      detailsHeight: 260,
      visibleColumns: Set.of(booksLibraryConfig.workspace.defaultVisibleColumns),
      columnWidths: const {},
    );

    expect(
      adapter.browserModeForViewState(booksLibraryConfig, state),
      equals(booksLibraryConfig.browserModeForViewState(state)),
    );
  });

  test('issue jump gating stays in the kind adapter', () {
    final adapter = comicsLibraryConfig.kindUiAdapter;
    expect(
      adapter.canJumpToSelectedEntry(
        comicsLibraryConfig,
        null,
        activeGroupMode: LibraryGroupMode.series,
        selectedBucket: 'Series A',
      ),
      isFalse,
    );
  });

  test('release folder labels stay in the kind adapter', () {
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: LibraryMetadataItem.fromCatalogItem(
        CatalogItem(
          id: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          title: 'Alpha',
        ),
      ),
    );
    final item = LibraryProjectionItem.fromShelf(source, comicsLibraryConfig);
    final projection = LibraryProjection(
      allItems: [item],
      filteredItems: [item],
      buckets: const [],
      selectedItem: item,
      counts: const LibraryToolbarCounts(),
    );

    expect(
      comicsLibraryConfig.kindUiAdapter.releaseFolderLabelForProjection(
        comicsLibraryConfig,
        projection,
        releaseFolderTitleItemId: 'comic-1',
      ),
      'Alpha',
    );
  });
}
