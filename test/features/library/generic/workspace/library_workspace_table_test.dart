import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/table/library_workspace_table.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_constants.dart';

DecoratedBox _rowDecorationForText(WidgetTester tester, String text) {
  final candidates = tester.widgetList<DecoratedBox>(
    find.ancestor(
      of: find.text(text),
      matching: find.byType(DecoratedBox),
    ),
  );
  return candidates.firstWhere((box) {
    final decoration = box.decoration;
    if (decoration is! BoxDecoration) return false;
    final border = decoration.border;
    return border is Border && border.left.width == 3;
  });
}

void main() {
  testWidgets('workspace table renders rows and reports sort/tap changes',
      (tester) async {
    Object sortedBy = 'issue';
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
                'title',
                'issue',
              ],
              sortColumn: 'title',
              sortAscending: true,
              sortRules: const [
                LibrarySortRule(
                  column: 'title',
                  ascending: true,
                ),
                LibrarySortRule(
                  column: 'issue',
                  ascending: false,
                ),
              ],
              columnWidthFor: (column) => column == 'title' ? 180 : 80,
              defaultColumnWidthFor: (column) => column == 'title' ? 180 : 80,
              columnSortFor: (column) => switch (column) {
                'title' => 'title',
                'issue' => 'issue',
                _ => null,
              },
              columnLabelFor: (column) => column,
              columnIsNumeric: (column) => column == 'issue',
              cellBuilder: (entry, column) => Text(
                column == 'title' ? entry : '#1',
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
    await pumpUntilSettled(tester);

    expect(sortedBy, 'title');
    expect(tapped, 'Batman');
    expect(find.byIcon(Icons.drag_indicator), findsNothing);
    expect(find.byKey(const ValueKey('sort-priority-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('sort-priority-issue')), findsOneWidget);
  });

  testWidgets('workspace table reports row double taps', (tester) async {
    String? opened;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: LibraryWorkspaceTable<String>(
              entries: const ['Spider-Man', 'Batman'],
              columns: const [
                'title',
                'issue',
              ],
              sortColumn: 'title',
              sortAscending: true,
              columnWidthFor: (column) => column == 'title' ? 180 : 80,
              defaultColumnWidthFor: (column) => column == 'title' ? 180 : 80,
              columnSortFor: (column) => switch (column) {
                'title' => 'title',
                'issue' => 'issue',
                _ => null,
              },
              columnLabelFor: (column) => column,
              columnIsNumeric: (column) => column == 'issue',
              cellBuilder: (entry, column) => Text(
                column == 'title' ? entry : '#1',
              ),
              isSelected: (_) => false,
              onEntryTap: (_) {},
              onEntryDoubleTap: (entry) => opened = entry,
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Batman'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Batman'));
    await pumpUntilSettled(tester);

    expect(opened, 'Batman');
  });

  testWidgets(
      'workspace table header hides secondary sort chrome in narrow columns',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 120,
            child: LibraryWorkspaceTable<String>(
              entries: const ['Batman'],
              columns: const [
                'issue',
              ],
              sortColumn: 'issue',
              sortAscending: true,
              sortRules: const [
                LibrarySortRule(
                  column: 'issue',
                  ascending: true,
                ),
              ],
              columnWidthFor: (_) => 56,
              defaultColumnWidthFor: (_) => 56,
              columnSortFor: (_) => 'issue',
              columnLabelFor: (_) => 'Issue',
              columnIsNumeric: (_) => true,
              cellBuilder: (_, __) => const Text('#1'),
              isSelected: (_) => false,
              onEntryTap: (_) {},
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
              onColumnReordered: (_, __) {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('sort-priority-issue')), findsNothing);
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
                    'title',
                    'issue',
                  ],
                  sortColumn: 'title',
                  sortAscending: true,
                  columnWidthFor: (column) => column == 'title' ? 180 : 80,
                  defaultColumnWidthFor: (column) =>
                      column == 'title' ? 180 : 80,
                  columnSortFor: (column) => switch (column) {
                    'title' => 'title',
                    'issue' => 'issue',
                    _ => null,
                  },
                  columnLabelFor: (column) => column,
                  columnIsNumeric: (column) => column == 'issue',
                  cellBuilder: (entry, column) => Text(
                    column == 'title' ? entry : '#1',
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
    await pumpUntilSettled(tester);

    final afterTapDecoration = _rowDecorationForText(tester, 'Batman');
    final afterTapBox = afterTapDecoration.decoration as BoxDecoration;
    final afterTapBorder = afterTapBox.border! as Border;
    expect(afterTapBox.color, isNot(beforeTapBox.color));
    expect(afterTapBox.boxShadow, isNull);
    expect(afterTapBorder.left.color, kAppAccent);
    expect(afterTapBorder.left.width, 3);
  });

  testWidgets('workspace table column header does not render drag handles',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: LibraryWorkspaceTable<String>(
              entries: const ['Spider-Man'],
              columns: const [
                'title',
                'issue',
              ],
              sortColumn: 'title',
              sortAscending: true,
              columnWidthFor: (column) => column == 'title' ? 180 : 80,
              defaultColumnWidthFor: (column) => column == 'title' ? 180 : 80,
              columnSortFor: (column) => switch (column) {
                'title' => 'title',
                'issue' => 'issue',
                _ => null,
              },
              columnLabelFor: (column) => column == 'title' ? 'Title' : 'Issue',
              columnIsNumeric: (column) => column == 'issue',
              cellBuilder: (entry, column) => Text(
                column == 'title' ? entry : '#1',
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

    expect(find.byIcon(Icons.drag_indicator), findsNothing);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Issue'), findsOneWidget);
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
                'title',
                'issue',
              ],
              sortColumn: 'title',
              sortAscending: true,
              columnWidthFor: (column) => column == 'title' ? 180 : 80,
              defaultColumnWidthFor: (column) => column == 'title' ? 180 : 80,
              columnSortFor: (column) => switch (column) {
                'title' => 'title',
                'issue' => 'issue',
                _ => null,
              },
              columnLabelFor: (column) => column,
              columnIsNumeric: (column) => column == 'issue',
              cellBuilder: (entry, column) => Text(
                column == 'title' ? entry : '#1',
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
    await pumpUntilSettled(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'workspace table renders checkbox, status, and edit action and responds to callbacks',
      (tester) async {
    final checkedEntries = <String>{'Spider-Man'};
    bool? allCheckedVal;
    String? editedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 200,
            child: StatefulBuilder(
              builder: (context, setState) {
                return LibraryWorkspaceTable<String>(
                  entries: const ['Spider-Man', 'Batman'],
                  columns: const ['title'],
                  sortColumn: 'title',
                  sortAscending: true,
                  columnWidthFor: (_) => 150,
                  defaultColumnWidthFor: (_) => 150,
                  columnSortFor: (_) => 'title',
                  columnLabelFor: (_) => 'Title',
                  columnIsNumeric: (_) => false,
                  cellBuilder: (entry, _) => Text(entry),
                  isSelected: (_) => false,
                  onEntryTap: (_) {},
                  onSortChanged: (_) {},
                  onColumnWidthChanged: (_, __) {},
                  showCheckbox: true,
                  isEntryChecked: (entry) => checkedEntries.contains(entry),
                  onToggleEntryCheck: (entry) {
                    setState(() {
                      if (checkedEntries.contains(entry)) {
                        checkedEntries.remove(entry);
                      } else {
                        checkedEntries.add(entry);
                      }
                    });
                  },
                  allChecked: checkedEntries.length == 2,
                  hasPartialCheck: checkedEntries.isNotEmpty,
                  onToggleAllChecked: (selectAll) {
                    allCheckedVal = selectAll;
                  },
                  showStatus: true,
                  statusBuilder: (entry) => Icon(
                    entry == 'Spider-Man'
                        ? Icons.check_circle
                        : Icons.bookmark,
                    key: ValueKey('status-$entry'),
                    size: 16,
                  ),
                  showEdit: true,
                  onEditEntry: (entry) => editedEntry = entry,
                );
              },
            ),
          ),
        ),
      ),
    );

    // Verify status icons rendered
    expect(find.byKey(const ValueKey('status-Spider-Man')), findsOneWidget);
    expect(find.byKey(const ValueKey('status-Batman')), findsOneWidget);

    // Verify edit icons rendered (2 rows)
    final editIcons = find.byIcon(Icons.edit_outlined);
    expect(editIcons, findsNWidgets(2));

    // Tap edit icon on Batman (second row)
    await tester.tap(editIcons.last);
    await pumpUntilSettled(tester);
    expect(editedEntry, 'Batman');

    // Tap row checkbox for Batman to toggle it
    // First checkbox in header, then Spider-Man, then Batman
    final checkableBoxes = find.byType(InkWell);
    // Tap header select-all checkbox
    await tester.tap(checkableBoxes.first);
    await pumpUntilSettled(tester);
    expect(allCheckedVal, isTrue);

    // Tap Batman's checkbox directly
    await tester.tap(find.text('Batman'));
  });
}
