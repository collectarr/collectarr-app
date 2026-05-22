import 'dart:typed_data';
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    resetMediaCatalogCacheForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('preview catalog ids stay deterministic and reserved', () {
    final first = buildPreviewCatalogItemId(
      kind: 'manga',
      provider: 'anilist',
      providerItemId: 'item:1/2',
    );
    final second = buildPreviewCatalogItemId(
      kind: 'manga',
      provider: 'anilist',
      providerItemId: 'item:1/2',
    );

    expect(first, second);
    expect(first, startsWith('preview-manga-'));
    expect(first, isNot(contains('item:1/2')));
  });

  testWidgets('generic add dialog exposes scanned barcode in manual flow',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: gamesLibraryConfig,
              initialBarcode: '759606083060',
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Add Games from Collectarr Core'), findsOneWidget);
    expect(
      find.text(
        'Barcode 759606083060 is prefilled for games. Search Core or add it manually with the same code.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('library-add-barcode-field')),
      findsWidgets,
    );
  });

  testWidgets('generic add dialog applies persisted prefill defaults',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.prefill.condition': 'Very Fine',
      'collectarr.prefill.grade': '9.6',
      'collectarr.prefill.location_id': 'loc-1',
      'collectarr.prefill.read_status': 'read',
      'collectarr.prefill.tags': 'favorite,dc',
    });
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Short Box 1',
            sortOrder: const Value(1),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
          localDatabaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Very Fine'), findsOneWidget);
    expect(find.text('9.6'), findsOneWidget);
    expect(find.text('Short Box 1'), findsOneWidget);
  });

  testWidgets('generic add dialog searches provider candidates',
      (tester) async {
    // Build a mock JWT with far-future expiry so AuthController restores
    // an admin session from SharedPreferences.
    final futureExp = DateTime.now()
            .toUtc()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch ~/
        1000;
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'exp': futureExp})),
    );
    final mockToken = 'header.$payload.signature';
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': mockToken,
      'collectarr.auth.is_admin': true,
    });
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeLibraryAddApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: mangaLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Naruto',
    );
    await tester.tap(find.text('Search Manga'));
    await tester.pumpAndSettle();

    expect(api.lastProvider, 'anilist');
    expect(api.lastProviderKind, 'manga');
    expect(api.lastProviderQuery, 'Naruto');
    expect(api.providerPreviewCallCount, 0);
    expect(find.textContaining('A ninja candidate.'), findsWidgets);
    expect(find.text('Select a manga to add'), findsOneWidget);
    expect(find.byTooltip('Queue Core ingest'), findsNothing);
    expect(find.byTooltip('Propose metadata to Core'), findsNothing);

    final providerCandidate = find.byKey(
      const ValueKey('provider:anilist:manga:anilist-1'),
    );
    await tester.ensureVisible(providerCandidate);
    await tester.tap(providerCandidate);
    await tester.pumpAndSettle();

    expect(api.providerPreviewCallCount, 1);
    expect(find.text('Add as owned'), findsOneWidget);
    expect(find.byTooltip('Queue Core ingest'), findsOneWidget);
    expect(find.byTooltip('Propose metadata to Core'), findsOneWidget);

    await tester.tap(find.byTooltip('Queue Core ingest'));
    await tester.pumpAndSettle();

    expect(api.lastIngestProvider, 'anilist');
    expect(api.lastIngestProviderItemId, 'anilist-1');
    expect(find.textContaining('Queued'), findsWidgets);
    expect(find.text('Search Core again'), findsOneWidget);
    expect(find.textContaining('job-1'), findsWidgets);

    await tester.ensureVisible(find.byTooltip('Propose metadata to Core'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Propose metadata to Core'));
    await tester.pumpAndSettle();

    expect(api.lastProposalProvider, 'anilist');
    expect(api.lastProposalProviderItemId, 'anilist-1');
    expect(api.lastProposalTitle, 'Naruto Vol. 1');
  });

  testWidgets('comic add dialog applies local cover scan hints to search fields',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
              coverScanService: LocalLibraryCoverScanService(
                sourcePrompt: const _FakeCoverScanSourcePrompt(
                  action: LibraryCoverScanAction.importImage,
                ),
                imagePicker: _FakeCoverImagePicker(
                  file: XFile('/tmp/Batman_423_1988_DC.jpg'),
                ),
                imageReview: const _FakeCoverImageReview(acceptImport: true),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cover scan filled search hints'), findsOneWidget);

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    final seriesField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-series-field')),
    );
    final numberField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-number-field')),
    );
    final publisherField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-publisher-field')),
    );
    final yearField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-year-field')),
    );

    expect(queryField.controller!.text, 'Batman');
    expect(seriesField.controller!.text, 'Batman');
    expect(numberField.controller!.text, '423');
    expect(publisherField.controller!.text, 'DC');
    expect(yearField.controller!.text, '1988');
  });

  testWidgets('comic add dialog leaves search untouched when cover scan is cancelled',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
              coverScanService: const LocalLibraryCoverScanService(
                sourcePrompt: _FakeCoverScanSourcePrompt(action: null),
                imagePicker: _FakeCoverImagePicker(file: null),
                imageReview: _FakeCoverImageReview(acceptImport: true),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Existing query',
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pumpAndSettle();

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    expect(queryField.controller!.text, 'Existing query');
    expect(find.textContaining('Cover scan filled search hints'), findsNothing);
  });

  testWidgets(
      'comic add dialog leaves search untouched when imported cover review is cancelled',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
              coverScanService: LocalLibraryCoverScanService(
                sourcePrompt: const _FakeCoverScanSourcePrompt(
                  action: LibraryCoverScanAction.importImage,
                ),
                imagePicker: _FakeCoverImagePicker(
                  file: XFile('/tmp/Batman_423_1988_DC.jpg'),
                ),
                imageReview: const _FakeCoverImageReview(acceptImport: false),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Existing query',
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pumpAndSettle();

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    expect(queryField.controller!.text, 'Existing query');
    expect(find.textContaining('Cover scan filled search hints'), findsNothing);
  });

  testWidgets('comic add dialog uses reviewed image label for local scan hints',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
              coverScanService: LocalLibraryCoverScanService(
                sourcePrompt: const _FakeCoverScanSourcePrompt(
                  action: LibraryCoverScanAction.importImage,
                ),
                imagePicker: _FakeCoverImagePicker(
                  file: XFile('/tmp/IMG_1234.jpg'),
                ),
                imageReview: const _FakeCoverImageReview(
                  acceptImport: true,
                  reviewedDisplayName: 'Batman_423_1988_DC.jpg',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pumpAndSettle();

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    final publisherField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-publisher-field')),
    );

    expect(queryField.controller!.text, 'Batman');
    expect(publisherField.controller!.text, 'DC');
  });

  testWidgets('comic add dialog applies edited review label from real review dialog',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
              coverScanService: LocalLibraryCoverScanService(
                sourcePrompt: const _FakeCoverScanSourcePrompt(
                  action: LibraryCoverScanAction.importImage,
                ),
                imagePicker: _FakeCoverImagePicker(
                  file: XFile.fromData(Uint8List(0), name: 'IMG_1234.jpg'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('library-cover-review-label-field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-cover-review-label-field')),
      'Batman_423_1988_DC.jpg',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Use image'));
    await tester.tap(find.widgetWithText(FilledButton, 'Use image'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    final numberField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-number-field')),
    );

    expect(queryField.controller!.text, 'Batman');
    expect(numberField.controller!.text, '423');
  });

  testWidgets('provider search does not claim fallback when results are mixed',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeLibraryAddApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: comicsLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Over the Garden Wall',
    );
    await tester.tap(find.text('Search Comics'));
    await tester.pumpAndSettle();

    expect(find.text('GCD unavailable, Comic Vine fallback used.'), findsNothing);
    expect(find.text('Provider candidates'), findsOneWidget);
    expect(
      find.text('Showing matches from GCD and Comic Vine.'),
      findsOneWidget,
    );
  });

  testWidgets('movie add dialog exposes physical format edition data',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: moviesLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    expect(find.text('Physical format'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Blu-ray'), findsOneWidget);
    expect(find.text('4K UHD'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Format / Edition'), findsOneWidget);
    expect(find.text('UPC / Barcode'), findsOneWidget);
  });

  testWidgets('core search results explain why a movie matched', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeLibraryAddApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: moviesLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Blade Runner',
    );
    await tester.tap(find.text('Search Movies'));
    await tester.pumpAndSettle();

    expect(api.lastSearchKind, 'movie');
    expect(api.lastSearchQuery, 'Blade Runner');
    expect(api.lastProvider, isNull);
    expect(find.text('Blade Runner 2049'), findsWidgets);
    expect(find.text('Matched on: Title'), findsOneWidget);
  });

  testWidgets('barcode lookup falls back to provider search on Core miss',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'admin@test.com',
      'collectarr.auth.is_admin': true,
    });
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeLibraryAddApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: booksLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Barcode'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('library-add-barcode-field')),
      '9780140328721',
    );
    await tester.tap(find.text('Lookup barcode'));
    await tester.pumpAndSettle();

    expect(api.lastLookupBarcode, '9780140328721');
    expect(api.lastLookupKind, 'book');
    expect(api.lastProvider, 'openlibrary');
    expect(api.lastProviderKind, 'book');
    expect(api.lastProviderQuery, '9780140328721');
    expect(find.textContaining('openlibrary-1'), findsWidgets);
  });

  testWidgets('music add dialog uses artist-oriented advanced search copy',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: musicLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('library-add-query-field')), findsOneWidget);
    expect(find.text('Search Music'), findsOneWidget);

    await tester.tap(find.byTooltip('Show advanced fields'));
    await tester.pumpAndSettle();

    expect(find.text('Artist...'), findsOneWidget);
    expect(find.text('Album / Release...'), findsOneWidget);
    expect(find.text('Label...'), findsOneWidget);
    expect(find.text('Series...'), findsNothing);

    await tester.tap(find.text('Search Music'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter an album, artist, release, or label.'),
      findsOneWidget,
    );
  });

  testWidgets('music provider search works with artist-only advanced search',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'admin@test.com',
      'collectarr.auth.is_admin': true,
    });
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeLibraryAddApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: musicLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Show advanced fields'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('library-add-series-field')),
      'Daft Punk',
    );
    await tester.tap(find.text('Search Music'));
    await tester.pumpAndSettle();

    expect(api.lastSearchKind, 'music');
    expect(api.lastSearchSeries, 'Daft Punk');
    expect(api.lastProvider, 'musicbrainz');
    expect(api.lastProviderKind, 'music');
    expect(api.lastProviderSeries, 'Daft Punk');
    expect(api.lastProviderQuery, 'Daft Punk');
    expect(find.textContaining('A ninja candidate.'), findsWidgets);
    expect(find.text('Matched on: Artist'), findsOneWidget);
  });

}

class _FakeLibraryAddApiClient extends ApiClient {
  _FakeLibraryAddApiClient() : super(baseUrl: 'http://unused');

  String? lastProvider;
  String? lastProviderQuery;
  String? lastProviderKind;
  String? lastProviderSeries;
  String? lastSearchQuery;
  String? lastSearchKind;
  String? lastSearchSeries;
  String? lastLookupBarcode;
  String? lastLookupKind;
  String? lastProposalProvider;
  String? lastProposalProviderItemId;
  String? lastProposalTitle;
  String? lastIngestProvider;
  String? lastIngestProviderItemId;
  int providerPreviewCallCount = 0;

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return fallbackMediaCatalog;
  }

  @override
  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    lastSearchQuery = query.query;
    lastSearchKind = query.kind;
    lastSearchSeries = query.series;
    if (query.kind == 'movie' && query.query == 'Blade Runner') {
      return const [
        {
          'id': 'movie-1',
          'kind': 'movie',
          'title': 'Blade Runner 2049',
          'publisher': 'Warner Bros.',
          'release_year': 2017,
        },
      ];
    }
    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    final resolvedProvider = provider ??
        switch (kind) {
          'book' => 'openlibrary',
          'manga' => 'mangadex',
          _ => 'auto',
        };
    lastProvider = provider;
    lastProviderQuery = query;
    lastProviderKind = kind;
    lastProviderSeries = series;
    if (kind == 'movie' && query == 'Blade Runner') {
      return const [
        {
          'provider': 'tmdb',
          'provider_item_id': 'tmdb-1',
          'title': 'Fallback candidate',
          'kind': 'movie',
          'summary': 'Different result.',
          'image_url': 'https://example.test/fallback.jpg',
          'publisher': 'Studio Canal',
        },
      ];
    }
    if (kind == 'comic' && query == 'Over the Garden Wall') {
      return const [
        {
          'provider': 'gcd',
          'provider_item_id': 'gcd-1',
          'title': 'Over the Garden Wall',
          'kind': 'comic',
          'summary': 'GCD series result.',
          'image_url': 'https://example.test/gcd.jpg',
          'publisher': 'Boom!',
        },
        {
          'provider': 'comicvine',
          'provider_item_id': 'comicvine-1',
          'title': 'Over the Garden Wall #1',
          'kind': 'comic',
          'summary': 'Comic Vine enriched result.',
          'image_url': 'https://example.test/comicvine.jpg',
          'publisher': 'Boom!',
        },
      ];
    }
    return [
      {
        'provider': resolvedProvider,
        'provider_item_id': '$resolvedProvider-1',
        'title': resolvedProvider == 'anilist' || resolvedProvider == 'mangadex'
            ? 'Naruto Vol. 1'
            : 'Provider result $query',
        'kind': kind ?? 'manga',
        'summary': 'A ninja candidate.',
        'image_url': 'https://example.test/naruto.jpg',
        'series_title': series,
        'publisher': kind == 'music' ? 'Virgin' : 'Shueisha',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> lookupBarcode(String barcode, {String? kind}) {
    lastLookupBarcode = barcode;
    lastLookupKind = kind;
    throw StateError('not found');
  }

  @override
  Future<Map<String, dynamic>> createMetadataProposal({
    required String provider,
    required String query,
    String? providerItemId,
    String? title,
    String? summary,
    String? imageUrl,
  }) async {
    lastProposalProvider = provider;
    lastProposalProviderItemId = providerItemId;
    lastProposalTitle = title;
    return const {
      'id': 'proposal-1',
      'status': 'pending',
    };
  }

  @override
  Future<AdminProviderPreview> providerPreview({
    required String provider,
    required String providerItemId,
  }) async {
    providerPreviewCallCount += 1;
    return AdminProviderPreview.fromJson({
      'provider': provider,
      'provider_item_id': providerItemId,
      'kind': 'music',
      'title': 'Provider result Discovery',
      'series_title': 'Daft Punk',
      'publisher': 'Virgin',
      'track_count': 2,
      'tracks': [
        {
          'position': 1,
          'title': 'One More Time',
          'duration_seconds': 320,
        },
        {
          'position': 2,
          'title': 'Aerodynamic',
          'duration_seconds': 212,
        },
      ],
    });
  }

  @override
  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    lastIngestProvider = provider;
    lastIngestProviderItemId = providerItemId;
    return AdminProviderIngestJob(
      id: 'job-1',
      provider: provider,
      providerItemId: providerItemId,
      status: 'queued',
      attempts: 0,
      maxAttempts: maxAttempts,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }
}

class _FakeCoverScanSourcePrompt implements LibraryCoverScanSourcePrompt {
  const _FakeCoverScanSourcePrompt({required this.action});

  final LibraryCoverScanAction? action;

  @override
  Future<LibraryCoverScanAction?> selectAction({
    required BuildContext context,
    required type,
  }) async {
    return action;
  }
}

class _FakeCoverImagePicker implements LibraryCoverImagePicker {
  const _FakeCoverImagePicker({required this.file});

  final XFile? file;

  @override
  Future<XFile?> pickImage() async {
    return file;
  }
}

class _FakeCoverImageReview implements LibraryCoverImageReview {
  const _FakeCoverImageReview({
    required this.acceptImport,
    this.reviewedDisplayName,
  });

  final bool acceptImport;
  final String? reviewedDisplayName;

  @override
  Future<LibraryCoverReviewedImage?> reviewImage({
    required BuildContext context,
    required type,
    required XFile file,
  }) async {
    if (!acceptImport) {
      return null;
    }
    return LibraryCoverReviewedImage.fromFile(
      file,
      displayName: reviewedDisplayName,
    );
  }
}

String _jwtExpiringAt(DateTime expiresAt) {
  final encodedHeader = _base64UrlJson({'alg': 'none', 'typ': 'JWT'});
  final encodedPayload = _base64UrlJson({
    'sub': '00000000-0000-0000-0000-000000000001',
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });
  return '$encodedHeader.$encodedPayload.signature';
}

String _base64UrlJson(Map<String, Object> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
