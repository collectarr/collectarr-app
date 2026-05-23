import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
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
    ));
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      condition: 'Good',
      pricePaidCents: 999,
      currency: 'USD',
      quantity: 1,
      locationId: 'loc-a',
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
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Next'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Blade Runner: Final Cut',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4K UHD'));
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
    expect(selection?.personal?.pricePaidCents, 1250);
    expect(selection?.personal?.quantity, 1);
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
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Next'), findsNothing);

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
