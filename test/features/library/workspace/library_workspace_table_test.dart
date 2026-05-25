import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DecoratedBox _rowDecorationForText(WidgetTester tester, String text) {
  return tester.widget<DecoratedBox>(
    find.ancestor(
      of: find.text(text),
      matching: find.byType(DecoratedBox),
    ).first,
  );
}

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
              sortRules: const [
                LibrarySortRule(
                  column: LibrarySortColumn.title,
                  ascending: true,
                ),
                LibrarySortRule(
                  column: LibrarySortColumn.issue,
                  ascending: false,
                ),
              ],
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
    expect(find.byKey(const ValueKey('sort-priority-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('sort-priority-issue')), findsOneWidget);
  });

  testWidgets('workspace table highlights selected row after tap',
      (tester) async {
    var selectedEntry = 'Spider-Man';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
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
                  columnIsNumeric: (column) =>
                      column == LibraryTableColumn.issue,
                  cellBuilder: (entry, column) => Text(
                    column == LibraryTableColumn.title ? entry : '#1',
                  ),
                  isSelected: (entry) => entry == selectedEntry,
                  onEntryTap: (entry) => setState(() => selectedEntry = entry),
                  onSortChanged: (_) {},
                  onColumnWidthChanged: (_, __) {},
                ),
              );
            },
          ),
        ),
      ),
    );

    final beforeTapDecoration = _rowDecorationForText(tester, 'Batman');
    final beforeTapBox = beforeTapDecoration.decoration as BoxDecoration;
    expect(beforeTapBox.boxShadow, isNull);

    await tester.tap(find.text('Batman'));
    await tester.pumpAndSettle();

    final afterTapDecoration = _rowDecorationForText(tester, 'Batman');
    final afterTapBox = afterTapDecoration.decoration as BoxDecoration;
    final afterTapBorder = afterTapBox.border! as Border;
    final expectedSelectedColor = Color.alphaBlend(
      const Color(0xFF075F75).withValues(alpha: 0.9),
      const Color(0xFF202428),
    );

    expect(afterTapBox.color, expectedSelectedColor);
    expect(afterTapBox.boxShadow, isNotEmpty);
    expect(afterTapBorder.left.color, const Color(0xFFFFD400));
    expect(afterTapBorder.left.width, 3);
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

  testWidgets('workspace table scrollbar hover stays attached to its list view',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: LibraryWorkspaceTable<String>(
              entries: List.generate(20, (index) => 'Row $index'),
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
              isSelected: (_) => false,
              onEntryTap: (_) {},
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(
      tester.getTopRight(find.byType(Scrollbar).first) - const Offset(2, -24),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
