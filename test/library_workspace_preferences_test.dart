import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = LibraryWorkspaceConfig(
    kind: 'comic',
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('library workspace preferences persist reusable view settings',
      () async {
    const store = LibraryWorkspacePreferences(config);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        sortColumn: LibrarySortColumn.grade,
        sortAscending: false,
        coverSize: 144,
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
    expect(restored.coverSize, 144);
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
}
