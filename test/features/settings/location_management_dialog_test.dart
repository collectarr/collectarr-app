import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/settings/location_management_dialog.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('location management dialog renames and reparents locations',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.batch((batch) {
      batch.insertAll(db.locationsCache, [
        LocationsCacheCompanion.insert(
          id: 'room',
          name: 'Room',
          sortOrder: const Value(1),
        ),
        LocationsCacheCompanion.insert(
          id: 'closet',
          name: 'Closet',
          sortOrder: const Value(2),
        ),
        LocationsCacheCompanion.insert(
          id: 'shelf',
          name: 'Shelf',
          parentId: const Value('room'),
          sortOrder: const Value(3),
        ),
      ]);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationManagementDialog(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shelf').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Location name'),
      'Short Box 1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Top shelf overflow',
    );

    final parentDropdown = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<String?>,
    );
    await tester.ensureVisible(parentDropdown);
    await tester.tap(parentDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Closet').last);
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final updated = await LocationRepository(db).getById('shelf');
    expect(updated, isNotNull);
    expect(updated!.name, 'Short Box 1');
    expect(updated.parentId, 'closet');
    expect(updated.description, 'Top shelf overflow');
  });

  testWidgets('location management dialog deletes a location and unparents children',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.batch((batch) {
      batch.insertAll(db.locationsCache, [
        LocationsCacheCompanion.insert(
          id: 'room',
          name: 'Room',
          sortOrder: const Value(1),
        ),
        LocationsCacheCompanion.insert(
          id: 'shelf',
          name: 'Shelf',
          parentId: const Value('room'),
          sortOrder: const Value(2),
        ),
      ]);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationManagementDialog(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Room').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete location'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    final repo = LocationRepository(db);
    final deleted = await repo.getById('room');
    final child = await repo.getById('shelf');
    expect(deleted, isNull);
    expect(child, isNotNull);
    expect(child!.parentId, isNull);
  });
}