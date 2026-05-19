import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_grid.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
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

    expect(find.text('Series'), findsWidgets);
    expect(find.text('Superman, Vol. 4'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Owned'), findsWidgets);
    expect(find.text('Near Mint'), findsWidgets);
    expect(find.text('9.8'), findsWidgets);
    expect(find.text('Personal details'), findsOneWidget);
    expect(find.text('Purchased 2026-05-10'), findsOneWidget);
    expect(find.widgetWithText(TextField, '12.99'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Signed copy'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Move to wishlist'), findsOneWidget);
    expect(find.byType(ComicsShelfCoverGrid), findsOneWidget);
    expect(find.byTooltip('Edit comic'), findsOneWidget);
    expect(find.byTooltip('Wishlist'), findsOneWidget);
    expect(find.byTooltip('Open details'), findsOneWidget);
    expect(find.byTooltip('Correct metadata'), findsOneWidget);
    expect(find.byTooltip('Cover view'), findsOneWidget);
    expect(find.byTooltip('Card view'), findsOneWidget);
    expect(find.byTooltip('List view'), findsOneWidget);
    expect(find.byTooltip('Details right'), findsOneWidget);
    expect(find.byTooltip('Details bottom'), findsOneWidget);
    expect(find.byTooltip('Hide details'), findsOneWidget);
    expect(find.byTooltip('Library tools'), findsOneWidget);

    await _tapLibraryTool(tester, 'Statistics');
    await tester.pumpAndSettle();

    expect(find.text('Local Comics Statistics'), findsOneWidget);
    expect(find.text('Top Series'), findsOneWidget);
    expect(find.text('Data Health'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

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

    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    expect(find.text('Refresh comics metadata'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Missing'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
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
    expect(find.text('Search Series'), findsOneWidget);
    expect(find.text('Add as owned'), findsOneWidget);
    expect(find.text('Add 1 Comic to Collection'), findsOneWidget);

    await tester.tap(find.text('Add as owned'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to wishlist').last);
    await tester.pumpAndSettle();

    expect(find.text('Add 1 Comic to Wishlist'), findsOneWidget);

    await tester.tap(find.text('Add Issue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Enter series title...'),
        findsOneWidget);
    expect(find.widgetWithText(TextField, 'Issue'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Publisher'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Barcode / UPC'), findsOneWidget);
  });

  testWidgets('add comics treats barcode in search box as barcode query',
      (tester) async {
    final api = _FakeApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
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
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter series title...'),
      '76194134192700811',
    );
    await tester.tap(find.text('Search Series'));
    await tester.pumpAndSettle();

    expect(api.lastSearchQuery?.query, '');
    expect(api.lastSearchQuery?.barcode, '76194134192700811');
    expect(api.lastDetailId, 'comic-8a');
    expect(find.textContaining('Pages: 32 pages'), findsOneWidget);
  });

  testWidgets('add comics batches barcode lookups for collection add',
      (tester) async {
    final api = _FakeApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
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

    final barcodeTab =
        tester.widget(find.byKey(const ValueKey('add-comics-barcode-tab')))
            as dynamic;
    barcodeTab.onTap();
    await tester.pumpAndSettle();

    final barcodeField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Scan or enter barcode / UPC...',
    );
    await tester.enterText(barcodeField, '76194134192700811');
    await tester.tap(find.text('Lookup barcode'));
    await tester.pumpAndSettle();
    await tester.enterText(barcodeField, '76194134192700911');
    await tester.tap(find.text('Lookup barcode'));
    await tester.pumpAndSettle();

    expect(api.lookupBarcodes, [
      '76194134192700811',
      '76194134192700911',
    ]);
    expect(find.text('2 scanned'), findsOneWidget);
    expect(find.text('2 found'), findsOneWidget);
    expect(find.text('Add 2 Comics to Collection'), findsOneWidget);
  });

  testWidgets('add comics pull list searches next local issue', (tester) async {
    final api = _FakeApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
          shelfProvider.overrideWith(
            (ref) async => ShelfState(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: catalogItems[0],
                  ownedItem: ownedItem,
                ),
                ShelfEntry(itemId: 'comic-2', catalogItem: catalogItems[1]),
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
    await tester.tap(find.widgetWithText(FilledButton, 'Add Comics'));
    await tester.pumpAndSettle();

    final pullListTab =
        tester.widget(find.byKey(const ValueKey('add-comics-pull-list-tab')))
            as dynamic;
    pullListTab.onTap();
    await tester.pumpAndSettle();

    expect(find.text('Local Pull List'), findsOneWidget);
    expect(find.text('#9'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Search Core').first);
    await tester.pumpAndSettle();

    expect(api.lastSearchQuery?.series, 'Superman, Vol. 4');
    expect(api.lastSearchQuery?.issueNumber, '9');
    expect(find.text('#9 | Standard cover | Regular Cover'), findsOneWidget);
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
    expect(find.text('Main'), findsWidgets);
    expect(find.text('Edition'), findsWidgets);
    expect(find.text('Value'), findsWidgets);
    expect(find.text('Essential'), findsOneWidget);
    expect(find.text('Ownership'), findsOneWidget);
    expect(find.text('Full'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'price');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Price'), findsOneWidget);
    expect(find.text('Personal purchase price'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Price'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Price'), findsNothing);
    expect(find.text('Grade'), findsWidgets);
  });

  testWidgets('comics page opens owned comic edit dialog tabs', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Suppress transient footer overflow during dialog dismiss animation.
    final origHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      origHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = origHandler);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
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
    expect(find.widgetWithText(Tab, 'Value'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Personal'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Plot'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Personal notes'), findsWidgets);

    await tester.tap(find.widgetWithText(Tab, 'Personal'));
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

    await _tapLibraryTool(tester, 'Filters');
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

  testWidgets('comics page applies quick shelf views from toolbar',
      (tester) async {
    final covered = CatalogItem(
      id: 'covered',
      kind: 'comic',
      title: 'Covered Series',
      itemNumber: '1',
      publisher: 'Image',
      releaseYear: 2026,
      barcode: '111',
      coverImageUrl: 'https://cdn.example/covered.jpg',
    );
    final missingCover = CatalogItem(
      id: 'missing-cover',
      kind: 'comic',
      title: 'Missing Cover Series',
      itemNumber: '1',
      publisher: 'Image',
      releaseYear: 2026,
      barcode: '222',
    );
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
                ShelfEntry(itemId: covered.id, catalogItem: covered),
                ShelfEntry(
                  itemId: missingCover.id,
                  catalogItem: missingCover,
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

    expect(find.text('Covered Series #1'), findsWidgets);
    expect(find.text('Missing Cover Series #1'), findsOneWidget);

    await tester.tap(find.byTooltip('Library tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Missing covers').last);
    await tester.pumpAndSettle();

    expect(find.text('Covered Series #1'), findsNothing);
    expect(find.text('Missing Cover Series #1'), findsWidgets);
    expect(find.byTooltip('Library tools'), findsOneWidget);
  });

  testWidgets('comics page restores and clears persisted filters',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'comics.filters.publisher': 'DC',
      'comics.filters.release_year': '2016',
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
    expect(find.text('Superman, Vol. 4 #9'), findsNothing);
    await _tapLibraryTool(tester, 'Clear filters');
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(find.text('Superman, Vol. 4 #9'), findsOneWidget);
    expect(prefs.getString('comics.filters.publisher'), isNull);
    expect(prefs.getString('comics.filters.release_year'), isNull);
  });

  testWidgets('comics page groups local shelf by publisher', (tester) async {
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
    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publisher').last);
    await tester.pumpAndSettle();

    expect(find.text('DC'), findsWidgets);
    expect(find.text('Marvel'), findsOneWidget);
    expect(find.text('Superman, Vol. 4 #9'), findsOneWidget);

    await tester.tap(find.text('DC').first);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('comics.grouping.mode'), 'publisher');
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

    await _tapLibraryTool(tester, 'Filters');
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
    expect(find.widgetWithText(TextField, 'Storage box'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Tags'), findsOneWidget);
    expect(find.text('Read status'), findsWidgets);
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
    await _tapLibraryTool(tester, 'Missing issues');
    await tester.pumpAndSettle();

    expect(find.text('#2'), findsWidgets);
  });
}

Future<void> _tapLibraryTool(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Library tools'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, label).last);
  await tester.pumpAndSettle();
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(baseUrl: 'http://unused');

  MetadataSearchQuery? lastSearchQuery;
  String? lastDetailId;
  final lookupBarcodes = <String>[];

  @override
  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    lastSearchQuery = query;
    if (query.issueNumber == '9') {
      return [
        {
          'id': 'comic-9',
          'kind': 'comic',
          'title': 'Superman, Vol. 4',
          'item_number': '9',
          'synopsis': 'A follow-up issue.',
          'publisher': 'DC',
          'release_date': '2017-01-04',
          'release_year': 2017,
          'barcode': '76194134192700911',
          'variant': 'Regular Cover',
        },
      ];
    }
    return [
      {
        'id': 'comic-8a',
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '8A',
        'synopsis': 'Escape From Dinosaur Island, Part One',
        'publisher': 'DC',
        'release_date': '2016-10-05',
        'release_year': 2016,
        'barcode': '76194134192700811',
        'variant': 'Regular Cover',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getComic(String id) async {
    lastDetailId = id;
    if (id == 'comic-9') {
      return {
        'id': id,
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '9',
        'sort_key': 'superman-vol-4-000009',
        'synopsis': 'A follow-up issue.',
        'series_title': 'Superman',
        'volume_name': 'Superman, Vol. 4',
        'volume_number': 4,
        'volume_start_year': 2016,
        'publisher': 'DC',
        'barcode': '76194134192700911',
        'cover_date': '2017-03-01',
        'store_date': '2017-01-04',
        'page_count': 32,
        'cover_price_cents': 299,
        'currency': 'USD',
        'creators': [],
        'characters': [],
        'story_arcs': [],
        'provider_links': [],
        'metadata_json': null,
        'release_type': null,
        'season_number': null,
        'episode_number': null,
        'runtime_minutes': null,
        'editions': [],
      };
    }
    return {
      'id': id,
      'kind': 'comic',
      'title': 'Superman, Vol. 4',
      'item_number': '8A',
      'sort_key': 'superman-vol-4-000008a',
      'synopsis': 'Escape From Dinosaur Island, Part One',
      'series_title': 'Superman',
      'volume_name': 'Superman, Vol. 4',
      'volume_number': 4,
      'volume_start_year': 2016,
      'publisher': 'DC',
      'barcode': '76194134192700811',
      'cover_date': '2016-12-01',
      'store_date': '2016-10-05',
      'page_count': 32,
      'cover_price_cents': 299,
      'currency': 'USD',
      'creators': [
        {'name': 'Patrick Gleason', 'role': 'Writer'},
      ],
      'characters': [
        {'name': 'Superman'},
      ],
      'story_arcs': [],
      'provider_links': [
        {
          'provider': 'comicvine',
          'entity_type': 'item',
          'provider_item_id': '4000-1',
        },
      ],
      'metadata_json': null,
      'release_type': null,
      'season_number': null,
      'episode_number': null,
      'runtime_minutes': null,
      'editions': [
        {
          'id': 'edition-1',
          'title': 'Regular Edition',
          'format': 'Comic',
          'publisher': 'DC',
          'isbn': null,
          'upc': '76194134192700811',
          'language': 'en',
          'region': 'US',
          'release_date': '2016-10-05',
          'metadata_json': null,
          'variants': [
            {
              'id': 'variant-1',
              'name': 'Regular Cover',
              'variant_type': 'regular',
              'sku': null,
              'barcode': '76194134192700811',
              'isbn': null,
              'region': 'US',
              'cover_price_cents': 299,
              'currency': 'USD',
              'cover_image_url': null,
              'thumbnail_image_url': null,
              'description': null,
              'is_primary': true,
            },
          ],
          'releases': [
            {
              'id': 'release-1',
              'region': 'US',
              'release_date': '2016-10-05',
              'publisher': 'DC',
              'external_ids': {'comicvine': '4000-1'},
              'metadata_json': null,
            },
          ],
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> lookupBarcode(String barcode,
      {String? kind}) async {
    lookupBarcodes.add(MetadataSearchQuery.normalizeBarcode(barcode));
    if (MetadataSearchQuery.normalizeBarcode(barcode).endsWith('911')) {
      return {
        'id': 'comic-9',
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '9',
        'synopsis': 'A follow-up issue.',
        'publisher': 'DC',
        'release_date': '2017-01-04',
        'release_year': 2017,
        'barcode': '76194134192700911',
        'variant': 'Regular Cover',
      };
    }
    return {
      'id': 'comic-8a',
      'kind': 'comic',
      'title': 'Superman, Vol. 4',
      'item_number': '8A',
      'synopsis': 'Escape From Dinosaur Island, Part One',
      'publisher': 'DC',
      'release_date': '2016-10-05',
      'release_year': 2016,
      'barcode': '76194134192700811',
      'variant': 'Regular Cover',
    };
  }
}
