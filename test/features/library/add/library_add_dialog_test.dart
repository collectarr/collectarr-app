import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/state/auth_provider.dart';
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

  test('book provider add merge preserves preview creators', () {
    final ingested = LibraryMetadataItem(
      id: 'book-item-1',
      kind: 'book',
      title: 'The Hobbit',
      publisher: 'Allen & Unwin',
      publishing: const CatalogPublishingDetails(
        pageCount: 310,
      ),
    );
    final edited = LibraryMetadataItem(
      id: 'book-item-1',
      kind: 'book',
      title: 'The Hobbit',
      publisher: 'Allen & Unwin',
      creators: const [
        {
          'name': 'J.R.R. Tolkien',
          'role': 'Author',
          'image_url': 'https://cdn.example/tolkien.jpg',
        },
      ],
      genres: const ['Fantasy'],
      publishing: const CatalogPublishingDetails(
        pageCount: 310,
      ),
    );

    final merged = mergeProviderAddResult(
      ingested: ingested,
      edited: edited,
    );

    expect(merged.creators, isNotNull);
    expect(merged.creators, isNotEmpty);
    expect(merged.creators!.first['name'], 'J.R.R. Tolkien');
    expect(merged.creators!.first['role'], 'Author');
    expect(merged.creators!.first['image_url'], 'https://cdn.example/tolkien.jpg');
    expect(merged.genres, contains('Fantasy'));
  });

  test('local cover image preprocessor applies crop and rotation transforms',
      () async {
    final pngBytes = await _generateSolidPngBytes(width: 2, height: 3);
    final reviewed = LibraryCoverReviewedImage.fromFile(
      XFile.fromData(pngBytes, name: 'cover.png'),
      imageBytes: pngBytes,
      rotationQuarterTurns: 1,
      cropBounds: const LibraryCoverCropBounds(
        left: 0,
        top: 0,
        right: 1,
        bottom: 0.5,
      ),
    );

    final prepared = await const LocalLibraryCoverImagePreprocessor()
        .prepareImage(type: comicsLibraryConfig, image: reviewed);

    expect(prepared.transformsApplied, isTrue);
    expect(prepared.preparedBytes, isNotNull);
    expect(prepared.preparedBytes, isNot(equals(pngBytes)));
  });

  testWidgets('generic add dialog exposes scanned barcode in manual flow',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1080);
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
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
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
                textRecognizer: const _FakeCoverTextRecognizer(
                  text: 'Batman 423 1988 DC',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final showAdvanced = find.byTooltip('Show advanced fields');
    if (showAdvanced.evaluate().isNotEmpty) {
      await tester.tap(showAdvanced);
      await tester.pump();
    }

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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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
                  reviewedRotationQuarterTurns: 1,
                  reviewedCropBounds: LibraryCoverCropBounds(
                    left: 0.05,
                    top: 0.0,
                    right: 1.0,
                    bottom: 0.95,
                  ),
                ),
                textRecognizer: const _FakeCoverTextRecognizer(
                  text: 'Batman 423 1988 DC',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final showAdvanced = find.byTooltip('Show advanced fields');
    if (showAdvanced.evaluate().isNotEmpty) {
      await tester.tap(showAdvanced);
      await tester.pump();
    }

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    final publisherField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-publisher-field')),
    );

    expect(queryField.controller!.text, 'Batman');
    expect(publisherField.controller!.text, 'DC');
  });

  testWidgets('comic add dialog uses reviewed cover text when filename is generic',
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
                  reviewedDisplayName: 'IMG_1234.jpg',
                  reviewedExtractedText: 'Batman 423 1988 DC',
                ),
                textRecognizer: const _FakeCoverTextRecognizer(
                  text: 'Batman 423 1988 DC',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Scan cover'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final showAdvanced = find.byTooltip('Show advanced fields');
    if (showAdvanced.evaluate().isNotEmpty) {
      await tester.tap(showAdvanced);
      await tester.pump();
    }

    final queryField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-query-field')),
    );
    final yearField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-add-year-field')),
    );

    expect(queryField.controller!.text, 'Batman');
    expect(yearField.controller!.text, '1988');
  });

  testWidgets('real cover review dialog auto-fills extracted text preview',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                DialogLibraryCoverImageReview(
                  imagePreprocessor: const _FakeCoverImagePreprocessor(),
                  textRecognizer: const _FakeCoverTextRecognizer(
                    text: 'Batman 423 1988 DC',
                  ),
                ).reviewImage(
                  context: context,
                  type: comicsLibraryConfig,
                  file: XFile.fromData(Uint8List(0), name: 'IMG_1234.jpg'),
                );
              },
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final textField = tester.widget<TextField>(
      find.byKey(const ValueKey('library-cover-review-text-field')),
    );
    expect(textField.controller!.text, 'Batman 423 1988 DC');
  });

  test('provider candidate reranking favors exact local scan hints', () {
    final ranked = rerankProviderCandidates(
      const [
        ProviderCandidate(
          provider: 'comicvine',
          providerItemId: 'comicvine-detective-423',
          title: 'Detective Comics #423',
          kind: 'comic',
          publisher: 'DC',
          issueNumber: '423',
          series: CatalogSeriesDetails(
            seriesTitle: 'Detective Comics',
            volumeStartYear: 1988,
          ),
        ),
        ProviderCandidate(
          provider: 'comicvine',
          providerItemId: 'comicvine-423',
          title: 'Batman #423 (match)',
          kind: 'comic',
          publisher: 'DC',
          issueNumber: '423',
          series: CatalogSeriesDetails(
            seriesTitle: 'Batman',
            volumeStartYear: 1988,
          ),
        ),
      ],
      const LibraryAddLocalRerankHints(
        query: 'Batman',
        series: 'Batman',
        issueNumber: '423',
        publisher: 'DC',
        year: 1988,
      ),
    );

    expect(ranked.first.title, 'Batman #423 (match)');
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

  testWidgets('real cover review dialog returns selected rotation state',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    LibraryCoverReviewedImage? reviewedImage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                reviewedImage = await const DialogLibraryCoverImageReview()
                    .reviewImage(
                  context: context,
                  type: comicsLibraryConfig,
                  file: XFile.fromData(Uint8List(0), name: 'IMG_1234.jpg'),
                );
              },
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('library-cover-review-rotation-label')),
        matching: find.text('Rotation: 0°'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('library-cover-review-rotate-right')),
    );
    await tester.tap(
      find.byKey(const ValueKey('library-cover-review-rotate-right')),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('library-cover-review-rotation-label')),
        matching: find.text('Rotation: 90°'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Use image'));
    await tester.tap(find.widgetWithText(FilledButton, 'Use image'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(reviewedImage, isNotNull);
    expect(reviewedImage!.rotationQuarterTurns, 1);
  });

  testWidgets('real cover review dialog returns selected crop bounds',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    LibraryCoverReviewedImage? reviewedImage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                reviewedImage = await const DialogLibraryCoverImageReview()
                    .reviewImage(
                  context: context,
                  type: comicsLibraryConfig,
                  file: XFile.fromData(Uint8List(0), name: 'IMG_1234.jpg'),
                );
              },
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Crop: 100% width x 100% height'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('library-cover-review-trim-left')),
    );
    await tester.tap(find.byKey(const ValueKey('library-cover-review-trim-left')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('library-cover-review-trim-top')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Crop: 95% width x 95% height'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Use image'));
    await tester.tap(find.widgetWithText(FilledButton, 'Use image'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(reviewedImage, isNotNull);
    expect(reviewedImage!.cropBounds.left, closeTo(0.05, 0.0001));
    expect(reviewedImage!.cropBounds.top, closeTo(0.05, 0.0001));
    expect(reviewedImage!.cropBounds.right, closeTo(1.0, 0.0001));
    expect(reviewedImage!.cropBounds.bottom, closeTo(1.0, 0.0001));
  });

  testWidgets('real cover review dialog returns edited visible text',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    LibraryCoverReviewedImage? reviewedImage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                reviewedImage = await const DialogLibraryCoverImageReview()
                    .reviewImage(
                  context: context,
                  type: comicsLibraryConfig,
                  file: XFile.fromData(Uint8List(0), name: 'IMG_1234.jpg'),
                );
              },
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(
      find.byKey(const ValueKey('library-cover-review-text-field')),
      'Batman 423 1988 DC',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Use image'));
    await tester.tap(find.widgetWithText(FilledButton, 'Use image'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(reviewedImage, isNotNull);
    expect(reviewedImage!.extractedText, 'Batman 423 1988 DC');
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
          authControllerProvider.overrideWith((ref) => _TestAuthController(ref)),
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
    if (kind == 'comic' && query == 'Batman') {
      return const [
        {
          'provider': 'comicvine',
          'provider_item_id': 'comicvine-detective-423',
          'title': 'Detective Comics #423',
          'kind': 'comic',
          'summary': 'Wrong series candidate.',
          'image_url': 'https://example.test/detective-423.jpg',
          'series_title': 'Detective Comics',
          'issue_number': '423',
          'publisher': 'DC',
          'volume_start_year': 1988,
        },
        {
          'provider': 'comicvine',
          'provider_item_id': 'comicvine-423',
          'title': 'Batman #423 (match)',
          'kind': 'comic',
          'summary': 'Preferred candidate.',
          'image_url': 'https://example.test/batman-423.jpg',
          'series_title': 'Batman',
          'issue_number': '423',
          'publisher': 'DC',
          'volume_start_year': 1988,
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
    Map<String, dynamic>? metadataPayload,
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
    return _providerPreviewFor(provider: provider, providerItemId: providerItemId);
  }

  @override
  Future<AdminProviderPreview> adminProviderPreview({
    required String provider,
    required String providerItemId,
  }) async {
    return _providerPreviewFor(provider: provider, providerItemId: providerItemId);
  }

  @override
  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
  }) async {
    lastIngestProvider = provider;
    lastIngestProviderItemId = providerItemId;
    if (providerItemId == 'openlibrary-1') {
      return const AdminProviderIngestResult(
        itemId: 'book-item-1',
        created: true,
        item: AdminMetadataItem(
          id: 'book-item-1',
          kind: 'book',
          title: 'The Hobbit',
          series: CatalogSeriesDetails(seriesTitle: 'Middle-earth Tales'),
          publisher: 'Allen & Unwin',
          publishing: CatalogPublishingDetails(pageCount: 310),
          providerLinks: [
            AdminProviderLink(
              provider: 'openlibrary',
              entityType: 'item',
              providerItemId: 'openlibrary-1',
            ),
          ],
          editions: [
            AdminEdition(
              id: 'edition-book-1',
              title: 'Standard Edition',
              publisher: 'Allen & Unwin',
              variants: [
                AdminVariant(
                  id: 'variant-book-1',
                  name: 'Hardcover',
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const AdminProviderIngestResult(
      itemId: 'music-item-1',
      created: true,
      item: AdminMetadataItem(
        id: 'music-item-1',
        kind: 'music',
        title: 'Provider result Discovery',
      ),
    );
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

  AdminProviderPreview _providerPreviewFor({
    required String provider,
    required String providerItemId,
  }) {
    if (providerItemId == 'openlibrary-1') {
      return AdminProviderPreview.fromJson({
        'provider': provider,
        'provider_item_id': providerItemId,
        'kind': 'book',
        'title': 'The Hobbit',
        'series_title': 'Middle-earth Tales',
        'publisher': 'Allen & Unwin',
        'release_date': '1937-09-21',
        'page_count': 310,
        'creators': [
          {
            'name': 'J.R.R. Tolkien',
            'role': 'Author',
          },
        ],
      });
    }
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
}

class _TestAuthController extends AuthController {
  _TestAuthController(super.ref) : super() {
    state = const AuthState(
      token: 'test-token',
      isAdmin: true,
      isRestoring: false,
    );
  }
}

class _FakeCoverImagePreprocessor implements LibraryCoverImagePreprocessor {
  const _FakeCoverImagePreprocessor();

  @override
  Future<LibraryCoverPreparedImage> prepareImage({
    required LibraryTypeConfig type,
    required LibraryCoverReviewedImage image,
  }) async {
    return LibraryCoverPreparedImage(
      reviewedImage: image,
      preparedBytes: image.imageBytes,
    );
  }
}

class _FakeCoverTextRecognizer implements LibraryCoverTextRecognizer {
  const _FakeCoverTextRecognizer({this.text});

  final String? text;

  @override
  Future<String?> recognizeText({
    required LibraryTypeConfig type,
    required LibraryCoverPreparedImage image,
  }) async {
    return text;
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
    this.reviewedCropBounds = const LibraryCoverCropBounds.fullFrame(),
    this.reviewedRotationQuarterTurns = 0,
    this.reviewedExtractedText,
  });

  final bool acceptImport;
  final String? reviewedDisplayName;
  final LibraryCoverCropBounds reviewedCropBounds;
  final int reviewedRotationQuarterTurns;
  final String? reviewedExtractedText;

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
      imageBytes: Uint8List(0),
      displayName: reviewedDisplayName,
      cropBounds: reviewedCropBounds,
      rotationQuarterTurns: reviewedRotationQuarterTurns,
      extractedText: reviewedExtractedText,
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

Future<Uint8List> _generateSolidPngBytes({
  required int width,
  required int height,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFF39A7FF),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
