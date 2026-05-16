import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
import 'package:collectarr_app/features/library/planned_library_configs.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    resetMediaCatalogCacheForTesting();
    SharedPreferences.setMockInitialValues({});
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

    expect(find.text('Add Games'), findsOneWidget);
    expect(
      find.text(
        'Core search uses the configured metadata server. If it is offline, use the manual panel; local items still sync normally.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Barcode 759606083060 is prefilled for games. Search Core or add it manually with the same code.',
      ),
      findsOneWidget,
    );
    expect(find.text('Barcode / UPC / ISBN'), findsWidgets);
    expect(
      find.widgetWithText(TextField, 'Barcode / UPC / ISBN'),
      findsWidgets,
    );
    expect(find.text('Requires API key'), findsOneWidget);
  });

  testWidgets('generic add dialog searches provider candidates',
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
              type: mangaLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Search Collectarr Core'),
      'Naruto',
    );
    await tester.tap(find.text('Search providers'));
    await tester.pumpAndSettle();

    expect(api.lastProvider, isNull);
    expect(api.lastProviderKind, 'manga');
    expect(api.lastProviderQuery, 'Naruto');
    expect(find.text('Attribution required'), findsOneWidget);
    expect(find.textContaining('A ninja candidate.'), findsOneWidget);
    expect(find.byTooltip('Add provider draft as owned'), findsOneWidget);
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

    expect(find.text('Physical format'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Blu-ray'), findsOneWidget);
    expect(find.text('4K UHD'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Format / Edition'), findsOneWidget);
    expect(find.text('UPC / Barcode'), findsOneWidget);
  });

  testWidgets('barcode lookup falls back to provider search on Core miss',
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
              type: booksLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Barcode / UPC / ISBN'),
      '9780140328721',
    );
    await tester.tap(find.text('Lookup'));
    await tester.pumpAndSettle();

    expect(api.lastLookupBarcode, '9780140328721');
    expect(api.lastLookupKind, 'book');
    expect(api.lastProvider, isNull);
    expect(api.lastProviderKind, 'book');
    expect(api.lastProviderQuery, '9780140328721');
    expect(find.textContaining('openlibrary-1'), findsOneWidget);
  });
}

class _FakeLibraryAddApiClient extends ApiClient {
  _FakeLibraryAddApiClient() : super(baseUrl: 'http://unused');

  String? lastProvider;
  String? lastProviderQuery;
  String? lastProviderKind;
  String? lastLookupBarcode;
  String? lastLookupKind;
  String? lastProposalProvider;
  String? lastProposalProviderItemId;
  String? lastProposalTitle;
  String? lastIngestProvider;
  String? lastIngestProviderItemId;

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return fallbackMediaCatalog;
  }

  @override
  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
  }) async {
    final resolvedProvider = provider ??
        switch (kind) {
          'book' => 'openlibrary',
          'manga' => 'anilist',
          _ => 'auto',
        };
    lastProvider = provider;
    lastProviderQuery = query;
    lastProviderKind = kind;
    return [
      {
        'provider': resolvedProvider,
        'provider_item_id': '$resolvedProvider-1',
        'title': resolvedProvider == 'anilist'
            ? 'Naruto Vol. 1'
            : 'Provider result $query',
        'kind': kind ?? 'manga',
        'summary': 'A ninja candidate.',
        'image_url': 'https://example.test/naruto.jpg',
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
