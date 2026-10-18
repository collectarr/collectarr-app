import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
    theme: buildLibraryTheme(),
    home: Scaffold(
        body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 300, child: child))));

void main() {
  testWidgets('a group collapses with an animation and shows its check state',
      (tester) async {
    var expanded = true;
    late StateSetter update;
    var toggledAll = 0;
    await tester.pumpWidget(_host(StatefulBuilder(builder: (context, setState) {
      update = setState;
      return LibraryFieldSelectionCategory(
          title: 'Main',
          expanded: expanded,
          onToggle: () => update(() => expanded = !expanded),
          check: LibraryFieldCheckState.some,
          onToggleAll: () => toggledAll++,
          children: [
            LibraryFieldSelectionCheckbox(
                label: 'Artist', selected: true, onTap: () {}),
          ]);
    })));
    final full = tester.getSize(find.byType(LibraryFieldSelectionCategory));
    await tester.tap(find.byType(LibraryFieldCheckbox).first);
    expect(toggledAll, 1);
    expect(expanded, isTrue);
    await tester.tap(find.text('Main'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final mid = tester.getSize(find.byType(LibraryFieldSelectionCategory));
    expect(mid.height, lessThan(full.height));
    expect(mid.height, greaterThan(28 + 10));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(find.byType(LibraryFieldSelectionCategory)).height,
        28 + 1 + 10);
    expect(find.text('Artist'), findsNothing);
  });

  testWidgets('the ASC/DESC switch slides between its labels and removes',
      (tester) async {
    var ascending = true;
    var removed = false;
    late StateSetter update;
    await tester.pumpWidget(_host(StatefulBuilder(builder: (context, setState) {
      update = setState;
      return LibrarySelectedFieldRow(
          label: 'Artist',
          ascending: ascending,
          onToggleDirection: () => update(() => ascending = !ascending),
          onRemove: () => removed = true,
          removeTooltip: 'Remove');
    })));
    final asc = find.text('ASC');
    expect(tester.getTopLeft(asc).dx, lessThan(300));
    final before = tester.getTopLeft(find.text('DESC')).dx;
    await tester.tap(asc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = tester.getTopLeft(find.text('DESC')).dx;
    await tester.pump(const Duration(milliseconds: 200));
    final end = tester.getTopLeft(find.text('DESC')).dx;
    expect(ascending, isFalse);
    expect(before, lessThan(mid));
    expect(mid, lessThan(end));
    expect(end - before, closeTo(41, 0.5));
    await tester.tap(find.byTooltip('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('search shows a white disc to clear the text', (tester) async {
    final controller = TextEditingController(text: 'abc');
    addTearDown(controller.dispose);
    var query = 'abc';
    await tester.pumpWidget(_host(LibraryFieldSelectionSearch(
        controller: controller, onChanged: (value) => query = value)));
    expect(tester.widget<TextField>(find.byType(TextField)).cursorColor,
        Colors.white);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(query, isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
