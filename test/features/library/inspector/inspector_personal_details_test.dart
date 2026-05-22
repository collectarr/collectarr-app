import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('personal details editor saves structured locations',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-a',
            name: 'Shelf A',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-b',
            name: 'Shelf B',
            sortOrder: const Value(2),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'movie-1',
            storageBox: const Value('Legacy shelf'),
            locationId: const Value('loc-a'),
            updatedAt: DateTime.utc(2026, 5, 23),
          ),
        );

    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      storageBox: 'Legacy shelf',
      locationId: 'loc-a',
      updatedAt: DateTime.utc(2026, 5, 23),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorPersonalDetailsEditor(
              ownedItem: ownedItem,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.place));
    await tester.pumpAndSettle();
    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Shelf B').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save personal details'));
    await tester.pumpAndSettle();

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.locationId, 'loc-b');
    expect(updated.storageBox, isNull);
  });
}