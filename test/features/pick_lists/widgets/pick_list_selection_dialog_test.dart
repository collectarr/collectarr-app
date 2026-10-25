import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_selection_dialog.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';

void main() {
  testWidgets('Manage replaces the list without showing a spinner',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await PickListRepository(db)
        .addValue('music.genre', 'Audit Jazz', mediaKind: 'music');
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PickListSelectionDialog(
                label: 'Genre',
                options: const [],
                selectedValues: const [],
                multiple: true,
                listName: 'music.genre',
                mediaKind: 'music',
                db: db))));
    await pumpUntilSettled(tester);
    expect(find.text('Audit Jazz'), findsWidgets);

    await tester.tap(find.text('Manage Genres'));
    for (var frame = 0; frame < 20; frame++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Audit Jazz'), findsWidgets);
    }
    expect(find.byTooltip('Edit Audit Jazz'), findsOneWidget);
    expect(find.text('Select Genres'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
