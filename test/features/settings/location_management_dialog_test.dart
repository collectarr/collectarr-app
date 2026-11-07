import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/settings/location_management_dialog.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<LocalDatabase> pumpDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.runAsync(() => db.batch((batch) {
          batch.insertAll(db.locationsCache, [
            LocationsCacheCompanion.insert(
                id: 'room', name: 'Room', sortOrder: const Value(1)),
            LocationsCacheCompanion.insert(
                id: 'shelf',
                name: 'Shelf',
                parentId: const Value('room'),
                sortOrder: const Value(2)),
          ]);
        }));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: LocationManagementDialog(db: db)),
    ));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    return db;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('lists locations by full path', (tester) async {
    await pumpDialog(tester);

    expect(find.text('Manage Locations'), findsOneWidget);
    expect(find.text('Room › Shelf'), findsOneWidget);
  });

  testWidgets('New Location creates a location with the name typed',
      (tester) async {
    final db = await pumpDialog(tester);

    await tester.tap(find.text('New Location'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(1), 'Attic');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    final names = await tester.runAsync(() => LocationRepository(db).getAll());
    expect(names!.map((location) => location.name), contains('Attic'));
  });

  testWidgets('a row edits its location', (tester) async {
    final db = await pumpDialog(tester);

    await tester.tap(find.byTooltip('Edit Room › Shelf'));
    await settle(tester);
    expect(find.text('Edit Location'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Short Box 1');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    final updated =
        await tester.runAsync(() => LocationRepository(db).getById('shelf'));
    expect(updated!.name, 'Short Box 1');
    expect(updated.parentId, 'room');
  });

  testWidgets('deleting a location makes its children top level',
      (tester) async {
    final db = await pumpDialog(tester);

    await tester.tap(find.byTooltip('Remove Room'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    final repository = LocationRepository(db);
    expect(await tester.runAsync(() => repository.getById('room')), isNull);
    final child = await tester.runAsync(() => repository.getById('shelf'));
    expect(child, isNotNull);
    expect(child!.parentId, isNull);
  });
}
