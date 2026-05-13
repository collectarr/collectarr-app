import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workspace table renders rows and reports sort/tap changes',
      (tester) async {
    var sortedBy = LibrarySortColumn.issue;
    String? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: LibraryWorkspaceTable<String>(
              entries: const ['Spider-Man', 'Batman'],
              columns: const [
                LibraryTableColumn.title,
                LibraryTableColumn.issue,
              ],
              sortColumn: LibrarySortColumn.title,
              sortAscending: true,
              columnWidthFor: (column) =>
                  column == LibraryTableColumn.title ? 180 : 80,
              defaultColumnWidthFor: (column) =>
                  column == LibraryTableColumn.title ? 180 : 80,
              columnSortFor: (column) => switch (column) {
                LibraryTableColumn.title => LibrarySortColumn.title,
                LibraryTableColumn.issue => LibrarySortColumn.issue,
                _ => null,
              },
              columnLabelFor: (column) => column.name,
              columnIsNumeric: (column) => column == LibraryTableColumn.issue,
              cellBuilder: (entry, column) => Text(
                column == LibraryTableColumn.title ? entry : '#1',
              ),
              isSelected: (entry) => entry == 'Batman',
              onEntryTap: (entry) => tapped = entry,
              onSortChanged: (sort) => sortedBy = sort,
              onColumnWidthChanged: (_, __) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('title'));
    await tester.tap(find.text('Batman'));

    expect(sortedBy, LibrarySortColumn.title);
    expect(tapped, 'Batman');
  });
}
