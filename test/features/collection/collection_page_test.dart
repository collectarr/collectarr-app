import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('shelf page shows local collection stats and filters',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            title: 'Superman, Vol. 4',
            itemNumber: const Value('8A'),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-box-6',
            name: 'Box 6',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'comic-1',
            condition: const Value('Near Mint'),
            grade: const Value('9.8'),
            pricePaidCents: const Value(1299),
            currency: const Value('USD'),
            personalNotes: const Value('Signed copy'),
            quantity: const Value(2),
            locationId: const Value('loc-box-6'),
            keyComic: const Value(true),
            readStatus: const Value('read'),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await db.into(db.wishlistItemsCache).insert(
          WishlistItemsCacheCompanion.insert(
            id: 'wish-1',
            itemId: 'comic-2',
            createdAt: DateTime.utc(2026, 5, 10),
            updatedAt: DateTime.utc(2026, 5, 10),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: CollectionPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Shelf'), findsOneWidget);
    expect(find.text('Owned'), findsWidgets);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Key comics'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('USD 12.99'), findsWidgets);
    expect(find.text('Read status'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
    expect(find.text('Top series'), findsOneWidget);
    expect(find.text('Completed: 1'), findsOneWidget);
    expect(find.text('Box 6: 1'), findsOneWidget);
    expect(find.text('Superman, Vol. 4 #8A'), findsOneWidget);
    expect(find.text('Signed copy'), findsOneWidget);

    await tester.tap(find.byTooltip('Export collection'));
    await pumpUntilSettled(tester);

    expect(find.text('Import or export collection'), findsOneWidget);
    expect(find.text('Copy Collectarr CSV'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly CSV'), findsOneWidget);
    expect(find.text('2 rows'), findsOneWidget);
    expect(find.text('1 owned'), findsOneWidget);
    expect(find.text('1 wishlist'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await pumpUntilSettled(tester);

    await tester.tap(find.byKey(const ValueKey('shelf-filter-wishlist')));
    await pumpUntilSettled(tester);

    expect(find.text('Superman, Vol. 4 #8A'), findsNothing);
    expect(find.textContaining('Catalog item'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
