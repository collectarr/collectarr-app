import 'package:collectarr_app/features/library/generic/library_folder_reorder_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drop returns to its slot before committing the order',
      (tester) async {
    final items = ['First', 'Second'];
    var moves = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: StatefulBuilder(
      builder: (context, setState) => SizedBox(
        width: 250,
        height: 180,
        child: LibraryFolderReorderList(
          itemCount: items.length,
          placeholderColor: Colors.grey,
          itemBuilder: (_, index) =>
              SizedBox(height: 40, child: Text(items[index])),
          onReorder: (from, to) => setState(() {
            items.insert(to, items.removeAt(from));
            moves++;
          }),
        ),
      ),
    ))));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('First')));
    await gesture
        .moveTo(tester.getCenter(find.text('Second')) + const Offset(0, 15));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(moves, 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(moves, 0);
    await tester.pumpAndSettle();
    expect(moves, 1);
    expect(items, ['Second', 'First']);
    expect(find.text('First'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
