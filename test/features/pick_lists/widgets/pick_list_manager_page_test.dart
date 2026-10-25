import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';

void main() {
  testWidgets(
      'manager renames custom vocabulary, rejects duplicate names and removes it',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = PickListRepository(db);
    await repo.addValue('music.genre', 'Audit Jazz', mediaKind: 'music');
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PickListManagerPage(
                db: db,
                registry: defaultPickListRegistry,
                initialListName: 'music.genre',
                initialMediaKind: 'music',
                // Opened from a selector, so the unused value is kept.
                onBack: (_) {}))));
    await pumpUntilSettled(tester);
    await tester.tap(find.byTooltip('Edit Audit Jazz'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'Audit Renamed');
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);
    expect(await repo.getValues('music.genre', mediaKind: 'music'),
        ['Audit Renamed']);
    await tester.tap(find.byTooltip('Edit Audit Renamed'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'Rock');
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);
    expect(find.textContaining('This name already exists'), findsOneWidget);
    expect(await repo.getValues('music.genre', mediaKind: 'music'),
        ['Audit Renamed']);
    await tester.tap(find.byTooltip('Remove Audit Renamed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Edit Audit Renamed'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Audit Renamed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await pumpUntilSettled(tester);
    expect(await repo.getValues('music.genre', mediaKind: 'music'), isEmpty);
    expect(find.byTooltip('Edit Audit Renamed'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('pick list manager shows lists and values', (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await PickListRepository(db).addValue(
      'music.condition',
      'Near Mint',
      mediaKind: 'music',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: PickListManagerPage(
              db: db,
              registry: defaultPickListRegistry,
              initialListName: 'music.condition',
              initialMediaKind: 'music',
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Manage Package/Sleeve Conditions'), findsOneWidget);
    expect(find.text('Package/Sleeve Condition list'), findsOneWidget);
    expect(find.text('Near Mint'), findsWidgets);
  });

  testWidgets('manager starts with no list selected', (tester) async {
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
            body: PickListManagerPage(
                db: db,
                registry: defaultPickListRegistry,
                initialMediaKind: 'music'))));
    await pumpUntilSettled(tester);
    expect(find.text('Manage Pick Lists'), findsOneWidget);
    expect(find.text('Select a list...'), findsOneWidget);
    expect(find.textContaining('Select a pick list to manage'), findsOneWidget);
    expect(find.byTooltip('Edit Audit Jazz'), findsNothing);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Merge Mode'))
            .onPressed,
        isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
