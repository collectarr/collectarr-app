import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'generic edit dialog returns media-aware catalog and owned fields',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(CatalogItem(
      id: 'movie-1',
      kind: 'movie',
      title: 'Blade Runner',
      itemNumber: '1',
      publisher: 'Warner Bros.',
      releaseYear: 1982,
      variant: 'DVD',
      barcode: '883929087129',
      editions: const [
        CatalogEdition(
          id: 'edition-standard',
          title: 'Standard',
          variants: [
            CatalogVariant(id: 'variant-dvd', name: 'DVD', isPrimary: true),
          ],
        ),
        CatalogEdition(
          id: 'edition-steelbook',
          title: 'Steelbook',
          variants: [
            CatalogVariant(id: 'variant-4k', name: '4K Variant', isPrimary: true),
          ],
        ),
      ],
    ));
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      editionId: 'edition-standard',
      variantId: 'variant-dvd',
      condition: 'Good',
      pricePaidCents: 999,
      currency: 'USD',
      quantity: 1,
      locationId: 'loc-a',
      updatedAt: DateTime.utc(2026, 5, 15),
    );
    final trackingEntry = TrackingEntry(
      id: 'tracking-1',
      itemId: 'movie-1',
      ownedItemId: 'owned-1',
      editionId: 'edition-steelbook',
      variantId: 'variant-4k',
      sourceType: 'physical',
      status: 'In progress',
      rating: 9,
      startedAt: DateTime.utc(2026, 5, 10),
      updatedAt: DateTime.utc(2026, 5, 15),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      trackingEntry: trackingEntry,
                      accent: Colors.red,
                      physicalFormats: videoPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Edit movie'), findsOneWidget);
    expect(find.text('Format / Edition'), findsOneWidget);
    expect(find.text('UPC / Barcode'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Blade Runner: Final Cut',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4K UHD'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Steelbook').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4K Variant').last);
    await tester.pumpAndSettle();

    // Navigate to Value tab to set price
    await tester.tap(find.text('Value'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Price paid'), '12.50');

    // Navigate to Personal tab to set location
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.place).first);
    await tester.pumpAndSettle();
    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Shelf B').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();

    // The dialog footer can trigger a transient RenderFlex overflow during
    // the dismiss animation in compact test viewports. Suppress it.
    final origHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      origHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = origHandler);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.item.title, 'Blade Runner: Final Cut');
    expect(selection?.item.variant, '4K UHD');
    expect(selection?.item.physicalFormat, '4k-uhd');
    expect(selection?.item.physicalFormatLabel, '4K UHD');
    expect(selection?.item.barcode, '883929087129');
    expect(selection?.personal?.locationId, 'loc-b');
    expect(selection?.personal?.locationChanged, isTrue);
    expect(selection?.personal?.anchorType, 'variant');
    expect(selection?.personal?.editionId, 'edition-steelbook');
    expect(selection?.personal?.variantId, 'variant-4k');
    expect(selection?.personal?.pricePaidCents, 1250);
    expect(selection?.personal?.quantity, 1);
    expect(selection?.tracking?.readStatus, 'In progress');
    expect(selection?.tracking?.rating, 9);
    expect(selection?.tracking?.startedAt, DateTime.utc(2026, 5, 10));
  });

  testWidgets('generic edit dialog saves edition ownership without a physical release',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(CatalogItem(
      id: 'movie-edition-1',
      kind: 'movie',
      title: 'Blade Runner',
      variant: 'DVD',
      editions: const [
        CatalogEdition(
          id: 'edition-standard',
          title: 'Standard',
          variants: [
            CatalogVariant(id: 'variant-dvd', name: 'DVD', isPrimary: true),
          ],
        ),
        CatalogEdition(
          id: 'edition-steelbook',
          title: 'Steelbook',
          variants: [
            CatalogVariant(id: 'variant-4k', name: '4K Variant', isPrimary: true),
          ],
        ),
      ],
    ));
    final ownedItem = OwnedItem(
      id: 'owned-edition-1',
      itemId: 'movie-edition-1',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 5, 24),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.red,
                      physicalFormats: videoPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open edition owned'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open edition owned'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('library-edit-owned-anchor-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edition').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputDecorator, 'Owned edition'), findsOneWidget);
    expect(find.widgetWithText(InputDecorator, 'Owned variant'), findsNothing);

    await tester.tap(find.widgetWithText(InputDecorator, 'Owned edition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Steelbook').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.personal?.anchorType, 'edition');
    expect(selection?.personal?.editionId, 'edition-steelbook');
    expect(selection?.personal?.variantId, isNull);
  });

  testWidgets('book kind uses dedicated edit dialog builder', (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'The Lord of the Rings',
          volumeNumber: 1,
        ),
      ),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showLibraryEditDialog(
                    context: context,
                    request: LibraryEditDialogRequest(
                      type: type,
                      item: item,
                      ownedItem: null,
                      accent: Colors.orange,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Credits & Characters'), findsOneWidget);
    expect(find.text('Main'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title sort').first,
      'lord-of-the-rings-001',
    );
    await tester.tap(find.text('Credits & Characters'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Add tag').first,
      'Epic Fantasy',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Add tag').first,
      'Middle-earth',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.item.sortKey, 'lord-of-the-rings-001');
    expect(selection?.item.series?.tags, ['Epic Fantasy', 'Middle-earth']);
  });

  testWidgets('generic edit dialog exposes tracking fields for tracked-only items',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(CatalogItem(
      id: 'movie-tracked-1',
      kind: 'movie',
      title: 'Dune',
      variant: 'Blu-ray',
      editions: const [
        CatalogEdition(
          id: 'edition-digital',
          title: 'Digital',
          variants: [
            CatalogVariant(
              id: 'variant-stream',
              name: 'Streaming',
              isPrimary: true,
            ),
          ],
        ),
      ],
    ));
    final trackingEntry = TrackingEntry(
      id: 'tracking-digital-1',
      itemId: 'movie-tracked-1',
      editionId: 'edition-digital',
      variantId: 'variant-stream',
      sourceType: 'digital',
      status: 'Planned',
      rating: 8,
      startedAt: DateTime.utc(2026, 5, 1),
      updatedAt: DateTime.utc(2026, 5, 5),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: null,
                      trackingEntry: trackingEntry,
                      accent: Colors.teal,
                      physicalFormats: videoPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open tracked'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open tracked'));
    await tester.pumpAndSettle();

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Tracking edition'), findsAtLeastNWidgets(1));
    expect(find.text('Value'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.personal, isNull);
    expect(selection?.tracking?.editionId, 'edition-digital');
    expect(selection?.tracking?.variantId, 'variant-stream');
    expect(selection?.tracking?.readStatus, 'Planned');
    expect(selection?.tracking?.rating, 8);
    expect(selection?.tracking?.startedAt, DateTime.utc(2026, 5, 1));
  });

  testWidgets('generic edit dialog returns owned bundle reference selection',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(CatalogItem(
      id: 'movie-bundle-1',
      kind: 'movie',
      title: 'Alien Anthology',
      editions: const [
        CatalogEdition(
          id: 'edition-standard',
          title: 'Standard',
          variants: [CatalogVariant(id: 'variant-bluray', name: 'Blu-ray', isPrimary: true)],
        ),
      ],
    ));
    final ownedItem = OwnedItem(
      id: 'owned-bundle-1',
      itemId: 'movie-bundle-1',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 5, 20),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.blue,
                      availableBundleReleases: const [
                        BundleReleaseSummary(
                          id: 'bundle-1',
                          kind: 'movie',
                          title: 'Alien Anthology Box Set',
                          publisher: 'Fox',
                          coverImageUrl: null,
                          thumbnailImageUrl: null,
                          contentSummary: BundleReleaseContentSummary(
                            totalItems: 4,
                            primaryCount: 4,
                            bonusCount: 0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open bundle owned'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open bundle owned'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bundle release').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.personal?.anchorType, 'bundle_release');
    expect(selection?.personal?.bundleReleaseId, 'bundle-1');
    expect(selection?.tracking?.editionId, isNull);
    expect(selection?.tracking?.variantId, isNull);
  });

  testWidgets('generic edit dialog hides physical-only owned fields for digital items',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-digital',
            name: 'Downloads',
            sortOrder: const Value(1),
          ),
        );

    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'movie-digital-1',
        kind: 'movie',
        title: 'Ghost in the Shell',
        physicalFormat: 'digital',
        physicalFormatLabel: 'Digital',
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-digital-1',
      itemId: 'movie-digital-1',
      condition: 'Mint',
      grade: '10',
      locationId: 'loc-digital',
      updatedAt: DateTime.utc(2026, 5, 24),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.teal,
                      physicalFormats: videoPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open digital'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open digital'));
    await tester.pumpAndSettle();

    expect(find.text('Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Condition'), findsNothing);
    expect(find.widgetWithText(TextField, 'Grade'), findsNothing);
    expect(find.byIcon(Icons.place), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.personal?.condition, isNull);
    expect(selection?.personal?.grade, isNull);
    expect(selection?.personal?.locationId, isNull);
    expect(selection?.personal?.locationChanged, isFalse);
  });

  testWidgets('generic edit dialog returns wishlist reference edits',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(CatalogItem(
      id: 'movie-wishlist-1',
      kind: 'movie',
      title: 'Akira',
      editions: const [
        CatalogEdition(
          id: 'edition-standard',
          title: 'Standard',
          variants: [CatalogVariant(id: 'variant-4k', name: '4K', isPrimary: true)],
        ),
      ],
    ));
    final wishlistItem = WishlistItem(
      id: 'wishlist-1',
      itemId: 'movie-wishlist-1',
      createdAt: DateTime.utc(2026, 5, 19),
      updatedAt: DateTime.utc(2026, 5, 20),
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => LibraryEditDialog(
                      type: type,
                      item: item,
                      ownedItem: null,
                      wishlistItem: wishlistItem,
                      accent: Colors.purple,
                      availableBundleReleases: const [
                        BundleReleaseSummary(
                          id: 'bundle-akira',
                          kind: 'movie',
                          title: 'Akira Collector Box',
                          publisher: 'GKIDS',
                          coverImageUrl: null,
                          thumbnailImageUrl: null,
                          contentSummary: BundleReleaseContentSummary(
                            totalItems: 3,
                            primaryCount: 1,
                            bonusCount: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open wishlist'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open wishlist'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('library-edit-wishlist-anchor-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bundle release').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Target price'), '54.99');
    await tester.enterText(find.widgetWithText(TextField, 'Currency'), 'USD');
    await tester.enterText(find.widgetWithText(TextFormField, 'Wishlist notes'), 'Need the collector box.');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.wishlist?.anchorType, 'bundle_release');
    expect(selection?.wishlist?.bundleReleaseId, 'bundle-akira');
    expect(selection?.wishlist?.targetPriceCents, 5499);
    expect(selection?.wishlist?.currency, 'USD');
    expect(selection?.wishlist?.notes, 'Need the collector box.');
  });

  testWidgets('music kind uses dedicated edit dialog tabs and music fields',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-music',
            name: 'Listening Room',
            sortOrder: const Value(1),
          ),
        );
    final type = collectarrLibraryTypes.byKind('music')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Ad Infinitum',
        sortKey: 'ad-infinitum',
        publisher: 'Kinesis',
        barcode: '781207102222',
        releaseYear: 1998,
        releaseDate: DateTime.utc(1998, 5, 23),
        series: const CatalogSeriesDetails(seriesTitle: 'Ad Infinitum'),
        music: const MusicCatalogDetails(
          trackCount: 2,
          catalogNumber: 'KDCD 1022',
          releaseStatus: 'Official',
          tracks: [
            CatalogTrack(title: 'Ad Infinitum', position: 1, durationSeconds: 506),
            CatalogTrack(title: 'Immortality', position: 2, durationSeconds: 421),
          ],
        ),
        creators: [
          {'name': 'Ad Infinitum', 'role': 'Artist'},
          {'name': 'Melissa Bonny', 'role': 'Vocals'},
        ],
        genres: ['Rock', 'Progressive Rock'],
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-music-1',
      itemId: 'music-1',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 5, 23),
      locationId: 'loc-music',
    );
    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  selection = await showLibraryEditDialog(
                    context: context,
                    request: LibraryEditDialogRequest(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.cyan,
                      physicalFormats: musicPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Classical'), findsOneWidget);
    expect(find.text('Tracks'), findsWidgets);
    expect(find.text('Details / Personal'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Links'), findsOneWidget);
    expect(find.text('Value'), findsNothing);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Artist').first, 'cAd');
    await tester.enterText(
      find.widgetWithText(TextField, 'Catalog number').first,
      'KDCD 1022-R',
    );
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Credits').first,
      'Artist: cAd\nVocals: Melissa Bonny',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.item.series?.seriesTitle, 'cAd');
    expect(selection?.item.music?.catalogNumber, 'KDCD 1022-R');
    expect(selection?.item.creators, [
      {'role': 'Artist', 'name': 'cAd'},
      {'role': 'Vocals', 'name': 'Melissa Bonny'},
    ]);
  });
}
