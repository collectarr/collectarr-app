import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workspace table renders rows and reports sort/tap changes',
      (tester) async {
    var sortedBy = LibrarySortColumn.issue;
    String? tapped;
    (LibraryTableColumn, LibraryTableColumn?)? reordered;

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
              onColumnReordered: (column, beforeColumn) {
                reordered = (column, beforeColumn);
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('title'));
    await tester.tap(find.text('Batman'));
    await tester.drag(
      find.byIcon(Icons.drag_indicator).last,
      const Offset(-140, 0),
    );
    await tester.pumpAndSettle();

    expect(sortedBy, LibrarySortColumn.title);
    expect(tapped, 'Batman');
    expect(reordered, (LibraryTableColumn.issue, LibraryTableColumn.title));
  });

  testWidgets('workspace table can reorder a column to the end',
      (tester) async {
    (LibraryTableColumn, LibraryTableColumn?)? reordered;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: LibraryWorkspaceTable<String>(
              entries: const ['Spider-Man'],
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
              columnLabelFor: (column) =>
                  column == LibraryTableColumn.title ? '' : column.name,
              columnIsNumeric: (column) => column == LibraryTableColumn.issue,
              cellBuilder: (entry, column) => Text(
                column == LibraryTableColumn.title ? entry : '#1',
              ),
              isSelected: (_) => false,
              onEntryTap: (_) {},
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
              onColumnReordered: (column, beforeColumn) {
                reordered = (column, beforeColumn);
              },
            ),
          ),
        ),
      ),
    );

    final start = tester.getCenter(find.byIcon(Icons.drag_indicator).first);
    final issueHeader = tester.getCenter(find.text('issue'));
    await tester.dragFrom(
      start,
      Offset(issueHeader.dx - start.dx + 30, 0),
    );
    await tester.pumpAndSettle();

    expect(reordered, (LibraryTableColumn.title, null));
  });
}
