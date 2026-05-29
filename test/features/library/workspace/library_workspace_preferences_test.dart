import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = LibraryWorkspaceConfig(
    kind: CatalogMediaKind.comic,
    title: 'Comics',
    icon: Icons.menu_book,
    preferencePrefix: 'comics',
    defaultSortColumn: LibrarySortColumn.title,
    defaultVisibleColumns: {
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.grade,
    },
  );
  const mangaConfig = LibraryWorkspaceConfig(
    kind: CatalogMediaKind.manga,
    title: 'Manga',
    icon: Icons.auto_stories,
    preferencePrefix: 'manga',
    defaultSortColumn: LibrarySortColumn.title,
    defaultVisibleColumns: {
      LibraryTableColumn.title,
      LibraryTableColumn.publisher,
    },
  );

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('library workspace preferences persist reusable view settings',
      () async {
    const store = LibraryWorkspacePreferences(config);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: LibrarySortColumn.grade,
        sortAscending: false,
        sortRules: [
          LibrarySortRule(
            column: LibrarySortColumn.grade,
            ascending: false,
          ),
          LibrarySortRule(
            column: LibrarySortColumn.updated,
            ascending: false,
          ),
        ],
        coverSize: 144,
        sidebarWidth: 280,
        detailsWidth: 390,
        visibleColumns: {
          LibraryTableColumn.title,
          LibraryTableColumn.grade,
        },
        columnWidths: {
          LibraryTableColumn.title: 320,
          LibraryTableColumn.grade: 120,
        },
      ),
    );

    final restored = await store.read(
      defaultCoverSize: 128,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.viewMode, LibraryViewMode.list);
    expect(restored.detailsLayout, LibraryDetailsLayout.bottom);
    expect(restored.sortColumn, LibrarySortColumn.grade);
    expect(restored.sortAscending, isFalse);
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: LibrarySortColumn.grade,
        ascending: false,
      ),
      const LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 144);
    expect(restored.sidebarWidth, 280);
    expect(restored.detailsWidth, 390);
    expect(restored.visibleColumns, {
      LibraryTableColumn.title,
      LibraryTableColumn.grade,
    });
    expect(restored.visibleColumns.toList(), [
      LibraryTableColumn.title,
      LibraryTableColumn.grade,
    ]);
    expect(restored.columnWidths[LibraryTableColumn.title], 320);
    expect(restored.columnWidths[LibraryTableColumn.grade], 120);
  });

  test('workspace chrome size and position are global across libraries',
      () async {
    const comicsStore = LibraryWorkspacePreferences(config);
    const mangaStore = LibraryWorkspacePreferences(mangaConfig);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: LibrarySortColumn.grade,
        sortAscending: false,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        visibleColumns: {
          LibraryTableColumn.title,
          LibraryTableColumn.grade,
        },
        columnWidths: {
          LibraryTableColumn.title: 320,
        },
      ),
    );

    final restored = await mangaStore.read(
      defaultCoverSize: 128,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.detailsLayout, LibraryDetailsLayout.bottom);
    expect(restored.sidebarWidth, 305);
    expect(restored.detailsWidth, 430);
    expect(restored.viewMode, LibraryViewMode.grid);
    expect(restored.sortColumn, LibrarySortColumn.title);
    expect(restored.visibleColumns, {
      LibraryTableColumn.title,
      LibraryTableColumn.publisher,
    });
    expect(restored.columnWidths, isEmpty);
  });
}
