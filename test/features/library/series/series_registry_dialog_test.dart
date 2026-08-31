import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/series_registry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CatalogCacheRepository catalog;
  late SeriesRegistryRepository registry;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = CatalogCacheRepository(db);
    registry = SeriesRegistryRepository(db);
  });

  tearDown(() => db.close());

  testWidgets('series picker renders table chrome and returns selection',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-a',
          seriesTitle: 'Amazing Adventures',
        ),
      ),
      testCatalogItem(
        id: 'comic-2',
        kind: 'comic',
        title: 'Issue 2',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-b',
          seriesTitle: 'Beta Squad',
        ),
      ),
    ]);

    SeriesRegistryEntry? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selection = await showSeriesPickerDialog(
                  context: context,
                  db: db,
                  mediaKind: 'comic',
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    expect(find.text('Select Series'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Sort Name'), findsOneWidget);
    expect(find.text('Count'), findsOneWidget);
    expect(find.text('2 series'), findsOneWidget);
    expect(find.text('Search by series name or sort name'), findsOneWidget);

    await tester.tap(find.text('Beta Squad').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(selection, isNotNull);
    expect(selection?.title, 'Beta Squad');
    expect(selection?.coreSeriesId, 'series-b');
  });

  testWidgets('series manager renames an entry from the dialog',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-a',
          seriesTitle: 'Amazing Adventures',
        ),
      ),
      testCatalogItem(
        id: 'comic-2',
        kind: 'comic',
        title: 'Issue 2',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-b',
          seriesTitle: 'Beta Squad',
        ),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showSeriesManagerDialog(
                  context: context,
                  db: db,
                  mediaKind: 'comic',
                );
              },
              child: const Text('Open Manager'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Manager'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Series'), findsOneWidget);
    expect(find.text('Search by series name or sort name'), findsOneWidget);
    expect(find.text('2 entries'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.byTooltip('Edit series'), findsNWidgets(2));
    expect(find.byTooltip('Merge series'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Edit series').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Series'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Name'), 'Alpha Prime');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Prime'), findsOneWidget);

    final entries = await registry.searchEntries(mediaKind: 'comic');
    expect(entries.any((entry) => entry.title == 'Alpha Prime'), isTrue);
  });

  testWidgets('series picker can create a new series from the dialog',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-a',
          seriesTitle: 'Amazing Adventures',
        ),
      ),
    ]);

    SeriesRegistryEntry? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selection = await showSeriesPickerDialog(
                  context: context,
                  db: db,
                  mediaKind: 'comic',
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'New Series'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Crimson Orbit',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Sort Name'),
      'Crimson Orbit',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Crimson Orbit'), findsWidgets);

    await tester.tap(find.text('Crimson Orbit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(selection, isNotNull);
    expect(selection?.title, 'Crimson Orbit');

    final entries = await registry.searchEntries(mediaKind: 'comic');
    expect(entries.any((entry) => entry.title == 'Crimson Orbit'), isTrue);
  });
}
