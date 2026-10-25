import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('artist picker stays open for several picks and saves them once',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    var values = const [
      LibraryNamedValue(id: 'a', name: 'Sabaton'),
      LibraryNamedValue(id: 'b', name: 'Lordi'),
    ];
    var changes = 0;

    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => LibraryOrderedPickListField(
              label: 'Artist',
              listName: 'artist',
              mediaKind: 'music',
              values: values,
              options: const ['Powerwolf', 'Gloryhammer'],
              onChanged: (next) => setState(() {
                changes++;
                values = next;
              }),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.byTooltip('Add Artist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Powerwolf').first);
    await tester.pump();
    expect(find.text('Select Artists'), findsOneWidget);
    await tester.tap(find.text('Gloryhammer').first);
    await tester.pump();
    await tester.tap(find
        .descendant(of: find.byType(Dialog), matching: find.text('Lordi'))
        .first);
    await tester.pump();
    expect(find.byIcon(Icons.check_box), findsNWidgets(3));
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(changes, 1);
    expect([for (final value in values) value.name],
        ['Sabaton', 'Powerwolf', 'Gloryhammer']);
    expect(values.first.id, 'a');
  });
}
