import 'package:collectarr_app/features/library/workspace/layout/library_reveal.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/table/library_workspace_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final items = [for (var i = 0; i < 200; i++) 'item-$i'];

  Future<void> pumpRevealed(WidgetTester tester,
      LibraryRevealController controller, Widget view) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryRevealScope(controller: controller, child: view))));
    expect(find.text('item-150'), findsNothing);
    controller.reveal('item-150');
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a reveal request scrolls the grid to the item', (tester) async {
    final controller = LibraryRevealController();
    addTearDown(controller.dispose);
    await pumpRevealed(
        tester,
        controller,
        LibraryWorkspaceGrid<String>(
          items: items,
          itemIdOf: (item) => item,
          maxCrossAxisExtent: 120,
          mainAxisExtent: 120,
          emptyBuilder: (_) => const SizedBox(),
          itemBuilder: (_, item) => Text(item),
        ));
    expect(find.text('item-150'), findsOneWidget);
  });

  testWidgets('a reveal request scrolls the list to the item', (tester) async {
    final controller = LibraryRevealController();
    addTearDown(controller.dispose);
    await pumpRevealed(
        tester,
        controller,
        LibraryWorkspaceTable<String>(
          entries: items,
          entryIdOf: (item) => item,
          columns: const ['title'],
          sortColumn: 'title',
          sortAscending: true,
          columnWidthFor: (_) => 200,
          defaultColumnWidthFor: (_) => 200,
          columnSortFor: (id) => id,
          columnLabelFor: (id) => id,
          columnIsNumeric: (_) => false,
          cellBuilder: (item, _) => Text(item),
          isSelected: (_) => false,
          onEntryTap: (_) {},
          onSortChanged: (_) {},
          onColumnWidthChanged: (_, __) {},
        ));
    expect(find.text('item-150'), findsOneWidget);
  });
}
