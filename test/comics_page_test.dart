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
  final catalogItems = [
    CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      synopsis: 'Escape From Dinosaur Island, Part One',
      publisher: 'DC',
      releaseDate: DateTime.utc(2016, 10, 5),
      releaseYear: 2016,
      barcode: '76194134192700811',
      variant: 'Regular Cover',
    ),
    CatalogItem(
      id: 'comic-2',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '9',
      synopsis: 'A follow-up issue.',
      publisher: 'Marvel',
      releaseDate: DateTime.utc(2017, 1, 4),
      releaseYear: 2017,
      barcode: '76194134192700911',
      variant: 'Variant Cover',
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
    storageBox: 'Box 6',
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
    expect(find.text('Variant'), findsOneWidget);
    expect(find.text('Publisher'), findsWidgets);
    expect(find.text('Release Date'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);
    expect(find.text('Grade'), findsWidgets);
    expect(find.text('Condition'), findsWidgets);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Storage Box'), findsOneWidget);
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

  testWidgets('add comics opens Collectarr Core style dialog', (tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => const ShelfState(
              entries: [],
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
    await tester.tap(find.widgetWithText(FilledButton, 'Add Comics'));
    await tester.pumpAndSettle();

    expect(find.text('Add Comics from Collectarr Core'), findsOneWidget);
    expect(find.text('Add Comics'), findsWidgets);
    expect(find.text('Search Collectarr Core'), findsOneWidget);
    expect(find.text('Add 1 Comic to Collection'), findsOneWidget);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Series'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Issue #'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Publisher'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Barcode / UPC'), findsOneWidget);
  });

  testWidgets('comics page restores persisted list view preferences',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'comics.view_mode': 'list',
      'comics.sort_column': 'updated',
      'comics.sort_ascending': false,
      'comics.cover_size': 188.0,
      'comics.visible_columns': ['title', 'issue', 'price'],
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
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Updated'), findsNothing);
  });

  testWidgets('comics page opens column chooser from list view',
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
    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Select columns'));
    await tester.pumpAndSettle();

    expect(find.text('Select columns'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Variant'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Barcode'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'price');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Price'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Price'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Price'), findsNothing);
    expect(find.text('Grade'), findsWidgets);
  });

  testWidgets('comics page opens owned comic edit dialog tabs', (tester) async {
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
    await tester.tap(find.byTooltip('Edit comic'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Edit - Superman, Vol. 4'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);
    expect(find.text('Plot'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Personal notes'), findsWidgets);

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Quantity'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Storage box'), findsOneWidget);
    expect(find.text('Key comic'), findsOneWidget);
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

  testWidgets('comics page filters local shelf by metadata', (tester) async {
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
                ShelfEntry(itemId: 'comic-1', catalogItem: catalogItems[0]),
                ShelfEntry(itemId: 'comic-2', catalogItem: catalogItems[1]),
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

    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #9'), findsOneWidget);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publisher').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DC').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Year').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2016').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #9'), findsNothing);
  });

  testWidgets('comics page supports multi-select bulk edit entrypoint',
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

    await tester.tap(find.byTooltip('Select comics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Superman, Vol. 4 #8A').first);
    await tester.pumpAndSettle();

    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byTooltip('Bulk actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulk edit'));
    await tester.pumpAndSettle();

    expect(find.text('Bulk edit'), findsOneWidget);
    expect(find.text('Condition'), findsWidgets);
    expect(find.text('Grade'), findsWidgets);
  });

  testWidgets('comics page shows missing issue gaps for selected series',
      (tester) async {
    const gapItems = [
      CatalogItem(
        id: 'gap-1',
        kind: 'comic',
        title: 'Gap Series',
        itemNumber: '1',
      ),
      CatalogItem(
        id: 'gap-3',
        kind: 'comic',
        title: 'Gap Series',
        itemNumber: '3',
      ),
    ];
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
                ShelfEntry(itemId: 'gap-1', catalogItem: gapItems[0]),
                ShelfEntry(itemId: 'gap-3', catalogItem: gapItems[1]),
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
    await tester.tap(find.text('Gap Series').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.format_list_numbered));
    await tester.pumpAndSettle();

    expect(find.text('#2'), findsOneWidget);
  });
}
