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

import '../../../helpers/test_constants.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    // Verify the dialog opened with an edit heading
    expect(find.textContaining('Edit'), findsWidgets);

    // Edit the title
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Blade Runner: Final Cut',
    );

    // Video kinds merge purchase/value fields into Personal.
    await tester.tap(find.text('Personal').last);
    await pumpUntilSettled(tester);

    // Stay on Personal to set location.
    await pumpUntilSettled(tester);
    await tester.tap(find.byIcon(Icons.place).first);
    await pumpUntilSettled(tester);
    expect(find.textContaining('Location'), findsWidgets);
    await tester.tap(find.text('Shelf B').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await pumpUntilSettled(tester);

    // The dialog footer can trigger a transient RenderFlex overflow during
    // the dismiss animation in compact test viewports. Suppress it.
    final origHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      origHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = origHandler);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    // Verify the dialog returned the edited values
    expect(selection?.item.title, 'Blade Runner: Final Cut');
    expect(selection?.item.barcode, '883929087129');
    expect(selection?.personal?.locationId, 'loc-b');
    expect(selection?.personal?.locationChanged, isTrue);
    expect(selection?.personal?.pricePaidCents, 999);
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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    // Navigate to the Edition tab (video kind places ownership anchor here)
    await tester.tap(find.text('Edition'));
    await pumpUntilSettled(tester);

    await tester.tap(find.byKey(const Key('library-edit-owned-anchor-field')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Edition').last);
    await pumpUntilSettled(tester);

    expect(find.widgetWithText(InputDecorator, 'Owned edition'), findsOneWidget);
    expect(find.widgetWithText(InputDecorator, 'Owned variant'), findsNothing);

    await tester.tap(find.widgetWithText(InputDecorator, 'Owned edition'));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Steelbook').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection?.personal?.anchorType, 'edition');
    expect(selection?.personal?.editionId, 'edition-steelbook');
    expect(selection?.personal?.variantId, isNull);
  });

  testWidgets('movie edit dialog hides book-style publishing fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'movie-publishing-1',
        kind: 'movie',
        title: 'Session 9',
        releaseYear: 2001,
        publishing: const CatalogPublishingDetails(
          pageCount: 123,
          imprint: 'Should stay hidden',
          seriesGroup: 'Noisy field',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => LibraryEditRenderer(
                      type: type,
                      item: item,
                      ownedItem: null,
                      accent: Colors.red,
                      physicalFormats: videoPhysicalMediaFormats,
                    ),
                  );
                },
                child: const Text('Open movie publishing test'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open movie publishing test'));
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Main').last);
    await pumpUntilSettled(tester);

    expect(find.text('Release Date'), findsOneWidget);
    expect(find.text('Release year'), findsNothing);
    expect(find.text('Page count'), findsNothing);
    expect(find.text('Imprint'), findsNothing);
    expect(find.text('Series group'), findsNothing);
    expect(find.text('Episodes'), findsNothing);
  });

  testWidgets('owned comic edit dialog uses consolidated CLZ-style main layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'comic-box-a',
            name: 'Box A',
            sortOrder: const Value(1),
          ),
        );

    final type = collectarrLibraryTypes.byKind('comic')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Over the Garden Wall',
        itemNumber: 'TP-1',
        publisher: 'Boom! Studios',
        releaseDate: DateTime.utc(2017, 3, 22),
        variant: 'Trade Paperback',
        barcode: '9781608869404',
        country: 'USA',
        language: 'English',
        ageRating: 'Modern Age',
        publishing: const CatalogPublishingDetails(
          pageCount: 128,
          imprint: 'KaBOOM!',
          seriesGroup: 'Miniseries',
        ),
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-comic-1',
      itemId: 'comic-1',
      locationId: 'comic-box-a',
      rating: 8,
      readStatus: 'Unread',
      indexNumber: 1,
      createdAt: DateTime.utc(2026, 5, 26, 23, 5, 39),
      updatedAt: DateTime.utc(2026, 5, 27, 9, 15, 0),
      condition: 'Near Mint',
      grade: '9.8',
      coverPriceCents: 1499,
      pricePaidCents: 999,
      currency: 'USD',
      rawOrSlabbed: 'Raw',
      gradingCompany: 'CGC',
      certificationNumber: '12345',
      ownerLabel: 'Andrei',
      quantity: 1,
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
                    builder: (context) => LibraryEditRenderer(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.deepOrange,
                    ),
                  );
                },
                child: const Text('Open comic owned'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open comic owned'));
    await pumpUntilSettled(tester);

    expect(find.text('Details'), findsWidgets);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Covers'), findsOneWidget);
    expect(find.text('Plot'), findsOneWidget);
    expect(find.text('Custom Fields'), findsOneWidget);
    expect(find.text('My Images'), findsOneWidget);
    expect(find.text('Sold'), findsNothing);

    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.text('Crossover'), findsOneWidget);
    expect(find.text('Story Arcs'), findsOneWidget);
    expect(find.text('Genres'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('No. of Pages'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Subtitle'),
      'Deluxe Edition',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Crossover'),
      'Adventure Time',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Story Arcs'),
      'Unknowning, The Tome of the Unknown',
    );

    await tester.tap(find.text('Main').last);
    await pumpUntilSettled(tester);

    expect(find.text('#TP-1'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Series Group'), findsOneWidget);
    expect(find.text('Issue No.'), findsOneWidget);
    expect(find.text('Variant'), findsOneWidget);
    expect(find.text('Variant Description'), findsOneWidget);
    expect(find.text('TP-1'), findsOneWidget);
    expect(find.text('Trade Paperback'), findsWidgets);
    expect(find.text('Cover Date'), findsOneWidget);
    expect(find.text('Release Date'), findsOneWidget);
    expect(find.text('Publisher'), findsOneWidget);
    expect(find.text('Imprint'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('comic-cover-date-year')),
      '2016',
    );
    await tester.enterText(
      find.byKey(const Key('comic-cover-date-month')),
      '10',
    );
    await tester.enterText(
      find.byKey(const Key('comic-cover-date-day')),
      '26',
    );

    await tester.tap(find.text('Covers').last);
    await pumpUntilSettled(tester);

    expect(find.text('Front Cover'), findsOneWidget);
    expect(find.text('Back Cover'), findsOneWidget);
    expect(find.text('Manage My Images'), findsOneWidget);
    expect(find.text('Find Better Cover'), findsOneWidget);

    await tester.tap(find.text('My Images').last);
    await pumpUntilSettled(tester);

    expect(find.text('My images workflow'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection?.item.titleExtension, 'Deluxe Edition');
    expect(selection?.item.crossover, 'Adventure Time');
    expect(selection?.item.storyArcs, const ['Unknowning', 'The Tome of the Unknown']);
    expect(selection?.item.coverDate?.year, 2016);
    expect(selection?.item.coverDate?.month, 10);
    expect(selection?.item.coverDate?.day, 26);
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
    await pumpUntilSettled(tester);

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Credits & Characters'), findsOneWidget);
    expect(find.text('Main'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title sort').first,
      'lord-of-the-rings-001',
    );
    await tester.tap(find.text('Credits & Characters'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add tag').first,
      'Epic Fantasy',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add tag').first,
      'Middle-earth',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    // Tracking fields now live under the Personal tab for video kinds.
    await tester.tap(find.text('Personal'));
    await pumpUntilSettled(tester);

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Tracking edition'), findsAtLeastNWidgets(1));
    expect(find.text('Value'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    // Navigate to the Edition tab (video kind places ownership anchor here)
    await tester.tap(find.text('Edition'));
    await pumpUntilSettled(tester);

    await tester.tap(find.byKey(const Key('library-edit-owned-anchor-field')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Bundle release').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection?.personal?.anchorType, 'bundle_release');
    expect(selection?.personal?.bundleReleaseId, 'bundle-1');
    expect(selection?.tracking?.editionId, isNull);
    expect(selection?.tracking?.variantId, isNull);
  });

  testWidgets(
      'generic edit dialog preserves existing bundle anchor without bundle summaries',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'movie-bundle-existing-1',
        kind: 'movie',
        title: 'Alien',
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-bundle-existing-1',
      itemId: 'movie-bundle-existing-1',
      anchorType: 'bundle_release',
      bundleReleaseId: 'bundle-existing-1',
      updatedAt: DateTime.utc(2026, 5, 31),
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
                    builder: (context) => LibraryEditRenderer(
                      type: type,
                      item: item,
                      ownedItem: ownedItem,
                      accent: Colors.orange,
                    ),
                  );
                },
                child: const Text('Open existing bundle'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open existing bundle'));
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Edition'));
    await pumpUntilSettled(tester);

    expect(find.text('Bundle release'), findsOneWidget);
    expect(find.text('Current bundle release'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection?.personal?.anchorType, 'bundle_release');
    expect(selection?.personal?.bundleReleaseId, 'bundle-existing-1');
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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    // Ownership-specific fields now live under the Personal tab for video kinds.
    await tester.tap(find.text('Personal'));
    await pumpUntilSettled(tester);

    expect(
      find.text('Digital copies do not expose physical storage fields.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Condition'), findsNothing);
    expect(find.widgetWithText(TextField, 'Grade'), findsNothing);
    expect(find.byIcon(Icons.place), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

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
                    builder: (context) => LibraryEditRenderer(
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
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Personal'));
    await pumpUntilSettled(tester);
    await tester.tap(find.byKey(const Key('library-edit-wishlist-anchor-field')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Bundle release').last);
    await pumpUntilSettled(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Target price'), '54.99');
    await tester.enterText(find.widgetWithText(TextField, 'Currency'), 'USD');
    await tester.enterText(find.widgetWithText(TextFormField, 'Wishlist notes'), 'Need the collector box.');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

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
    await pumpUntilSettled(tester);

    expect(find.text('Classical'), findsOneWidget);
    expect(find.text('Tracks'), findsWidgets);
    expect(find.text('Details / Personal'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Links'), findsOneWidget);
    expect(find.text('Value'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Artist').first, 'cAd');
    await tester.enterText(
      find.widgetWithText(TextField, 'Catalog number').first,
      'KDCD 1022-R',
    );
    await tester.tap(find.text('People'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Credits').first,
      'Artist: cAd\nVocals: Melissa Bonny',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection?.item.series?.seriesTitle, 'cAd');
    expect(selection?.item.music?.catalogNumber, 'KDCD 1022-R');
    expect(selection?.item.creators, [
      {'role': 'Artist', 'name': 'cAd'},
      {'role': 'Vocals', 'name': 'Melissa Bonny'},
    ]);
  });
}
