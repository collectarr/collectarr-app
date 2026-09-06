import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

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

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItemFromJson({
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '8A',
      }),
    ]);
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-box-6',
            name: 'Box 6',
            sortOrder: const Value(1),
          ),
        );
    await OwnedItemsRepository(db).upsert(
      testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        kind: 'comic',
        condition: 'Near Mint',
        grade: '9.8',
        pricePaidCents: 1299,
        currency: 'USD',
        personalNotes: 'Signed copy',
        quantity: 2,
        locationId: 'loc-box-6',
        keyComic: true,
        readStatus: 'read',
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
    expect(find.text('2'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('USD 12.99'), findsWidgets);
    expect(find.text('Read status'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
    expect(find.text('Completed: 1'), findsOneWidget);
    expect(find.text('Box 6: 1'), findsOneWidget);
    expect(find.text('Superman, Vol. 4 #8A'), findsOneWidget);
    expect(find.text('Signed copy'), findsOneWidget);

    await tester.tap(find.byTooltip('Export…'));
    await pumpUntilSettled(tester);

    expect(find.text('Import or export'), findsOneWidget);
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

  testWidgets('shelf page renders on compact screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItemFromJson({
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '8A',
      }),
    ]);
    await OwnedItemsRepository(db).upsert(
      testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        kind: 'comic',
        condition: 'Near Mint',
        grade: '9.8',
        pricePaidCents: 1299,
        currency: 'USD',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 11),
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
    await tester.scrollUntilVisible(
      find.text('Superman, Vol. 4 #8A'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Superman, Vol. 4 #8A'), findsOneWidget);
  });
}
