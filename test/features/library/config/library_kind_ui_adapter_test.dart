import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
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
      adapter.supportsMissingComicsReport(comicsLibraryConfig),
      isTrue,
    );
    expect(
      adapter.supportsMissingComicsReport(moviesLibraryConfig),
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
}
