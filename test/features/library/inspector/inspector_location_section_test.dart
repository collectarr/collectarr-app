import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/inspector/inspector_location_section.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cancel keeps the current location assignment', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Office Shelf',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'comic-1',
            locationId: const Value('loc-1'),
            updatedAt: DateTime.utc(2026, 5, 22),
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorLocationSection(
            ownedItemId: 'owned-1',
            db: db,
            accent: Colors.orange,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Office Shelf'), findsOneWidget);

    await tester.tap(find.text('Office Shelf'));
    await tester.pumpAndSettle();

    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final owned = await (db.select(db.ownedItemsCache)
          ..where((t) => t.id.equals('owned-1')))
        .getSingle();

    expect(owned.locationId, 'loc-1');
    expect(find.text('Office Shelf'), findsOneWidget);
  });
}
