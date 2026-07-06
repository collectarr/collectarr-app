import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('pick list manager shows lists and values', (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await PickListRepository(db).addValue('condition', 'Near Mint');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: PickListManagerPage(db: db),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Condition'), findsWidgets);
    await tester.tap(find.text('Condition').first);
    await pumpUntilSettled(tester);

    expect(find.text('Add value'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('Global'), findsWidgets);
  });
}
