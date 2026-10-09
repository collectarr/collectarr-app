import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_import_data_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('LibraryKindImportCapability & Contributors', () {
    test('music kind provides its supported file import sources', () {
      final capability = libraryImportForKind(CatalogMediaKind.music);
      expect(capability.sources, isNotEmpty);

      final sourceIds = capability.sources.map((s) => s.id).toList();
      expect(sourceIds, contains('text'));
      expect(sourceIds, contains('discogs'));
      expect(sourceIds, contains('catraxx'));
      expect(sourceIds, contains('delicious'));
      expect(sourceIds, contains('orangecd'));
      expect(sourceIds, contains('cdpedia'));
      expect(sourceIds, contains('musiccollector'));
      expect(sourceIds, contains('clzweb'));

      expect(capability.mappableFields, isNotEmpty);
      expect(capability.mappableFields.any((f) => f.key == 'artist'), isTrue);
      expect(capability.mappableFields.any((f) => f.key == 'title'), isTrue);
    });

    test('book, comic, and other kinds resolve import capabilities', () {
      final bookCap = libraryImportForKind(CatalogMediaKind.book);
      expect(bookCap.sources.any((s) => s.id == 'text'), isTrue);
      expect(bookCap.sources.any((s) => s.id == 'goodreads'), isTrue);

      final comicCap = libraryImportForKind(CatalogMediaKind.comic);
      expect(comicCap.sources.any((s) => s.id == 'text'), isTrue);
      expect(comicCap.sources.any((s) => s.id == 'comicrack'), isTrue);
    });
  });

  group('LibraryImportDataPage Widget', () {
    testWidgets('renders root menu with all CLZ Music Web import cards',
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
      expect(find.text('Music Label'), findsOneWidget);
      expect(find.text('CATraxx'), findsOneWidget);
      expect(find.text('Delicious Library'), findsOneWidget);
      expect(find.text('OrangeCD'), findsOneWidget);
      expect(find.text('CDpedia'), findsOneWidget);
      expect(find.text('Music Collector'), findsOneWidget);
      expect(find.text('CLZ Music Web'), findsOneWidget);

      // Other imports section
      expect(find.text('Other imports'), findsOneWidget);
      expect(
        find.text('Import User Defined Fields from Music Collector'),
        findsOneWidget,
      );

      // Footer should not be present
      expect(
        find.textContaining('CLZ.com Web © Copyright 2000-2026'),
        findsNothing,
      );
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
        find.textContaining('You currently have 1 Albums in your collection'),
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
      expect(find.text('Import Albums'), findsOneWidget);

      // Tap Back to return to menu
      await tester.tap(find.byKey(const Key('import_data.back')));
      await tester.pumpAndSettle();
      expect(find.text('Import from:'), findsOneWidget);
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
    });
  });
}
