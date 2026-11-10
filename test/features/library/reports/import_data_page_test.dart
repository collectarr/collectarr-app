import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/reports/import_data_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/builders/workspace_item_builder.dart';

void main() {
  late LocalDatabase db;
  setUp(() => db = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('LibraryKindImportCapability & Contributors', () {
    test('music kind provides its supported file import sources', () {
      final capability = libraryImportForKind(CatalogMediaKind.music);
      expect(capability.sources, isNotEmpty);

      final sourceIds = capability.sources.map((s) => s.id).toList();
      expect(sourceIds, contains('text'));
      expect(sourceIds, contains('discogs'));
      expect(sourceIds, contains('catraxx'));
      expect(sourceIds, contains('delicious'));
      expect(sourceIds, isNot(contains('orangecd')));
      expect(sourceIds, isNot(contains('cdpedia')));
      expect(sourceIds, contains('musiccollector'));
      expect(sourceIds, contains('clzweb'));

      expect(capability.mappableFields, isNotEmpty);
      expect(capability.mappableFields.any((f) => f.key == 'artist'), isTrue);
      expect(capability.mappableFields.any((f) => f.key == 'title'), isTrue);
    });

    test('unreleased kinds cannot borrow Music import semantics', () {
      for (final kind in [CatalogMediaKind.movie]) {
        expect(() => libraryImportForKind(kind), throwsArgumentError);
      }
    });

    test('Books does not advertise unverified import formats', () {
      final capability = libraryImportForKind(CatalogMediaKind.book);
      expect(capability.sources, isEmpty);
      expect(capability.mappedCsvImporter, isNull);
    });

    test('games import sources follow the reference order', () {
      final sources = libraryImportForKind(CatalogMediaKind.game).sources;
      expect(sources.map((source) => source.id), [
        'text',
        'delicious',
        'game_collector',
        'clz_game_web',
        'pricecharting',
        'game_collector_fields',
      ]);
      expect(sources.last.sectionTitle, 'Other imports');
    });

    test('comics lists available imports and unavailable source placeholders',
        () {
      final sources = libraryImportForKind(CatalogMediaKind.comic).sources;
      expect(sources.map((source) => source.id), [
        'text',
        'comiccollector',
        'clz_comic_web',
        'comic_collector_live',
        'comic_collector_fields',
      ]);
      expect(sources.last.sectionTitle, 'Other imports');
    });
  });

  group('LibraryImportDataPage Widget', () {
    testWidgets('comics placeholders do not accept unverified exports',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final type = defaultLibraryKindRegistry.require(CatalogMediaKind.comic);
      await tester.pumpWidget(ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
              home: LibraryImportDataPage(
                  type: type, allShelfEntries: const []))));
      await tester.pumpAndSettle();
      expect(find.text('Other imports'), findsOneWidget);
      expect(find.text('Comic Collector Live'), findsOneWidget);
      await tester
          .tap(find.byKey(const Key('import_source_comic_collector_live')));
      await tester.pumpAndSettle();
      expect(find.textContaining('This import is not available yet'),
          findsOneWidget);
      expect(find.byKey(const Key('import_file_picker_btn')), findsNothing);
      expect(find.byKey(const Key('import_guided.submit')), findsNothing);
      await tester.tap(find.byKey(const Key('import_data.back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('import_source_clz_comic_web')));
      await tester.pumpAndSettle();
      expect(find.text('Upload your CLZ Comics Web XML file:'), findsOneWidget);
      expect(find.byKey(const Key('import_file_picker_btn')), findsOneWidget);
    });

    testWidgets('games placeholders explain unavailable imports',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final type = defaultLibraryKindRegistry.require(CatalogMediaKind.game);
      await tester.pumpWidget(ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
              home: LibraryImportDataPage(
                  type: type, allShelfEntries: const []))));
      await tester.pumpAndSettle();
      expect(find.text('Other imports'), findsOneWidget);
      expect(find.text('PriceCharting'), findsOneWidget);
      await tester.tap(find.byKey(const Key('import_source_delicious')));
      await tester.pumpAndSettle();
      expect(find.textContaining('This import is not available yet'),
          findsOneWidget);
      expect(find.byKey(const Key('import_file_picker_btn')), findsNothing);
      expect(find.byKey(const Key('import_guided.submit')), findsNothing);
      await tester.tap(find.byKey(const Key('import_data.back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('import_source_clz_game_web')));
      await tester.pumpAndSettle();
      expect(find.text('Upload your CLZ Games Web XML file:'), findsOneWidget);
      expect(find.byKey(const Key('import_file_picker_btn')), findsOneWidget);
    });

    testWidgets('renders only verified import sources with parsers',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final musicType =
          defaultLibraryKindRegistry.require(CatalogMediaKind.music);

      final entry1 = testLibraryWorkspaceSource(
        itemId: 'album-1',
        kind: 'music',
        title: 'OK Computer',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryImportDataPage(
              type: musicType,
              allShelfEntries: [entry1],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Heading and container
      expect(find.text('Import from:'), findsOneWidget);
      expect(find.text('Import Data'), findsOneWidget);

      // Main sources
      expect(find.text('Import a Text or CSV file'), findsOneWidget);
      expect(find.text('Discogs'), findsOneWidget);
      expect(find.text('CATraxx'), findsOneWidget);
      expect(find.text('Delicious Library'), findsOneWidget);
      expect(find.text('OrangeCD'), findsNothing);
      expect(find.text('CDpedia'), findsNothing);
      expect(find.text('Music Collector'), findsOneWidget);
      expect(find.text('CLZ Music Web'), findsOneWidget);

      // Footer should not be present
      expect(
        find.textContaining('CLZ.com Web © Copyright 2000-2026'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets(
        'navigates to CSV / TXT import view with warning banner and settings',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final musicType =
          defaultLibraryKindRegistry.require(CatalogMediaKind.music);

      final entry1 = testLibraryWorkspaceSource(
        itemId: 'album-1',
        kind: 'music',
        title: 'OK Computer',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryImportDataPage(
              type: musicType,
              allShelfEntries: [entry1],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on CSV card
      await tester.tap(find.byKey(const Key('import_source_text')));
      await tester.pumpAndSettle();

      // Sub-view header
      expect(find.text('Import from CSV / TXT File'), findsOneWidget);
      expect(find.text('Import albums from CSV / TXT'), findsOneWidget);

      // Attention banner is visible because entryCount is 1
      expect(find.text('Attention!'), findsOneWidget);
      expect(
        find.textContaining('You currently have 1 Album in your collection'),
        findsOneWidget,
      );

      // Dismiss warning banner
      await tester.tap(find.byKey(const Key('import_data.dismiss_warning')));
      await tester.pumpAndSettle();
      expect(find.text('Attention!'), findsNothing);

      // Steps in CSV view
      expect(find.text('1. Upload your .csv or .txt file:'), findsOneWidget);
      expect(find.text('Choose File...'), findsOneWidget);
      expect(find.text('No File Selected'), findsOneWidget);

      expect(find.text('2. Choose your data format settings:'), findsOneWidget);
      expect(find.text('Skip First Row'), findsOneWidget);
      expect(find.text('Semicolon'),
          findsNWidgets(2)); // Delimiter + Multi-delimiter
      expect(find.text('Comma'), findsNWidgets(2));
      expect(find.text('Double Quote'), findsOneWidget);

      expect(find.text('3. Map your fields to our fields:'), findsOneWidget);
      expect(
        find.text(
            'Click the column headers below to map your fields to our fields.'),
        findsOneWidget,
      );

      // Action button
      expect(find.byKey(const Key('import_csv.submit')), findsOneWidget);

      // Tap Back to return to menu
      await tester.tap(find.byKey(const Key('import_data.back')));
      await tester.pumpAndSettle();
      expect(find.text('Import from:'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('navigates to guided file import view (Discogs)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final musicType =
          defaultLibraryKindRegistry.require(CatalogMediaKind.music);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryImportDataPage(
              type: musicType,
              initialSourceId: 'discogs',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Import from Discogs'),
          findsNWidgets(2)); // AppBar + Heading
      expect(
        find.textContaining(
            'you need to export a CSV file of your albums out of your Discogs account'),
        findsOneWidget,
      );
      expect(find.text('Upload your Discogs CSV file:'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);

      // Tap Back to return to root
      await tester.tap(find.byKey(const Key('import_data.back')));
      await tester.pumpAndSettle();
      expect(find.text('Import from:'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
