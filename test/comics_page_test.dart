import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const catalogItems = [
    CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      synopsis: 'Escape From Dinosaur Island, Part One',
    ),
    CatalogItem(
      id: 'comic-2',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '9',
      synopsis: 'A follow-up issue.',
    ),
  ];

  final ownedItem = OwnedItem(
    id: 'owned-1',
    itemId: 'comic-1',
    condition: 'Near Mint',
    grade: '9.8',
    purchaseDate: DateTime.utc(2026, 5, 10),
    pricePaidCents: 1299,
    currency: 'USD',
    personalNotes: 'Signed copy',
    updatedAt: DateTime.utc(2026, 5, 11),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('comics page shows desktop local library workspace',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => ShelfState(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: catalogItems[0],
                  ownedItem: ownedItem,
                ),
                ShelfEntry(
                  itemId: 'comic-2',
                  catalogItem: catalogItems[1],
                ),
              ],
              ownedCount: 1,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 1,
              totalPaidCents: 1299,
              primaryCurrency: 'USD',
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => [ownedItem]),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Superman, Vol. 4'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Owned'), findsWidgets);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('9.8'), findsWidgets);
    expect(find.text('Personal details'), findsOneWidget);
    expect(find.text('Purchased 2026-05-10'), findsOneWidget);
    expect(find.widgetWithText(TextField, '12.99'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Signed copy'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Move to wishlist'), findsOneWidget);
    expect(find.byTooltip('Grid view'), findsOneWidget);
    expect(find.byTooltip('List view'), findsOneWidget);

    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();

    expect(find.text('Issue'), findsOneWidget);
    expect(find.text('Grade'), findsWidgets);
    expect(find.text('Condition'), findsWidgets);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Updated'), findsOneWidget);
  });

  testWidgets(
      'compact comics page keeps add, scan, and metadata refresh actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => ShelfState(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: catalogItems[0],
                ),
                ShelfEntry(
                  itemId: 'comic-2',
                  catalogItem: catalogItems[1],
                ),
              ],
              ownedCount: 0,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('Superman, Vol. 4'), findsNothing);
    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
  });

  testWidgets('comics page restores persisted list view preferences',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'comics.view_mode': 'list',
      'comics.sort_column': 'updated',
      'comics.sort_ascending': false,
      'comics.cover_size': 188.0,
    });
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => ShelfState(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: catalogItems[0],
                  ownedItem: ownedItem,
                ),
              ],
              ownedCount: 1,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 1,
              totalPaidCents: 1299,
              primaryCurrency: 'USD',
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => [ownedItem]),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Issue'), findsOneWidget);
    expect(find.text('Updated'), findsOneWidget);
  });

  testWidgets('comics page filters local shelf by ownership', (tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => ShelfState(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: catalogItems[0],
                  ownedItem: ownedItem,
                ),
                ShelfEntry(
                  itemId: 'comic-2',
                  catalogItem: catalogItems[1],
                ),
              ],
              ownedCount: 1,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 1,
              totalPaidCents: 1299,
              primaryCurrency: 'USD',
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => [ownedItem]),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Superman, Vol. 4 #9'), findsOneWidget);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All comics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Owned').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #9'), findsNothing);
  });
}
