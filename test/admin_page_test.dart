import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin page searches provider metadata and ingests a result',
      (tester) async {
    final api = _FakeAdminApiClient();
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(api)],
        child: const MaterialApp(home: AdminPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Metadata dashboard'), findsOneWidget);
    expect(find.text('1 providers live'), findsOneWidget);
    expect(find.text('3 providers registered'), findsOneWidget);
    expect(find.text('12 items'), findsOneWidget);
    expect(find.text('1 duplicate groups'), findsOneWidget);
    expect(find.text('items: 12 docs'), findsOneWidget);
    expect(find.text('Absolute Batman #1A'), findsOneWidget);
    expect(find.text('GCD'), findsWidgets);

    await tester.tap(find.byTooltip('Reindex search'));
    await tester.pumpAndSettle();

    expect(api.reindexCount, 1);
    expect(find.text('Reindexed 12'), findsOneWidget);
    expect(find.text('Search index history'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Inspect'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Inspect'));
    await tester.pumpAndSettle();

    expect(api.lastInspectKind, 'comic');
    expect(api.lastInspectId, 'item-1');
    expect(find.text('Absolute Batman #1B'), findsOneWidget);

    await tester.ensureVisible(find.text('Merge into first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merge into first'));
    await tester.pumpAndSettle();

    expect(api.lastMergeTargetItemId, 'item-1');
    expect(api.lastMergeSourceItemIds, ['item-2']);
    expect(find.text('Merged 1 duplicate items.'), findsOneWidget);
    expect(find.text('No duplicate candidates detected.'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Provider item ID'),
      'direct-123',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ingest ID'));
    await tester.pumpAndSettle();

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, 'direct-123');
    expect(find.text('Metadata item ingested.'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    expect(api.lastSearchProvider, 'gcd');
    expect(api.lastSearchQuery, 'Batman #1');
    expect(api.lastSearchKind, 'comic');
    expect(find.text('1 provider results.'), findsOneWidget);
    expect(find.text('Absolute Batman #1'), findsWidgets);
    expect(find.text('ID 12345'), findsOneWidget);

    final ingestButton = find.widgetWithText(FilledButton, 'Ingest').first;
    await tester.ensureVisible(ingestButton);
    await tester.pumpAndSettle();
    await tester.tap(ingestButton);
    await tester.pumpAndSettle();

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, '12345');
    expect(find.text('Metadata item ingested.'), findsOneWidget);
    expect(find.text('Absolute Batman #1A'), findsWidgets);
  });
}

class _FakeAdminApiClient extends ApiClient {
  _FakeAdminApiClient() : super(baseUrl: 'http://metadata.local');

  String? lastSearchProvider;
  String? lastSearchQuery;
  String? lastSearchKind;
  String? lastIngestProvider;
  String? lastIngestProviderItemId;
  String? lastInspectKind;
  String? lastInspectId;
  String? lastMergeTargetItemId;
  List<String>? lastMergeSourceItemIds;
  bool duplicateResolved = false;
  int reindexCount = 0;

  @override
  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    return const [
      AdminProviderStatus(
        name: 'gcd',
        displayName: 'GCD',
        kind: 'comic',
        status: 'live',
        isConfigured: true,
        supportsSearch: true,
        supportsIngest: true,
        requiresUserKey: false,
        nonCommercialOnly: false,
        allowsRedistribution: true,
        requiresAttribution: true,
        licenseName: 'CC BY-SA',
        message: 'Ready',
      ),
      AdminProviderStatus(
        name: 'comicvine',
        displayName: 'ComicVine',
        kind: 'comic',
        status: 'stub',
        isConfigured: false,
        supportsSearch: true,
        supportsIngest: true,
        requiresUserKey: true,
        nonCommercialOnly: true,
        allowsRedistribution: false,
        requiresAttribution: true,
        message: 'Set COMICVINE_API_KEY',
      ),
      AdminProviderStatus(
        name: 'igdb',
        displayName: 'IGDB',
        kind: 'game',
        status: 'stub',
        isConfigured: false,
        supportsSearch: true,
        supportsIngest: true,
        requiresUserKey: true,
        nonCommercialOnly: false,
        allowsRedistribution: false,
        requiresAttribution: true,
        message: 'Planned game provider',
      ),
    ];
  }

  @override
  Future<AdminCatalogSummary> adminCatalogSummary() async {
    return AdminCatalogSummary(
      items: 12,
      series: 4,
      volumes: 4,
      editions: 12,
      variants: 15,
      releases: 12,
      providerLinks: 20,
      imageAssets: 0,
      imageCacheEntries: 0,
      pendingProposals: 2,
      missingCoverItems: 3,
      missingProviderLinkItems: 1,
      duplicateCandidateGroups: duplicateResolved ? 0 : 1,
    );
  }

  @override
  Future<AdminSearchStatus> adminSearchStatus() async {
    return const AdminSearchStatus(
      ok: true,
      indexName: 'items',
      documentCount: 12,
      isEmpty: false,
    );
  }

  @override
  Future<AdminSearchReindexResult> adminReindexSearch() async {
    reindexCount += 1;
    return const AdminSearchReindexResult(
      ok: true,
      indexName: 'items',
      indexedDocuments: 12,
    );
  }

  @override
  Future<List<AdminSearchHistoryEntry>> adminSearchHistory() async {
    if (reindexCount == 0) {
      return const [];
    }
    return [
      AdminSearchHistoryEntry(
        timestamp: DateTime.utc(2026, 5, 14, 9, 0),
        ok: true,
        indexName: 'items',
        indexedDocuments: 12,
      ),
    ];
  }

  @override
  Future<List<AdminDuplicateCandidate>> adminDuplicateCandidates({
    int limit = 10,
  }) async {
    if (duplicateResolved) {
      return const [];
    }
    return const [
      AdminDuplicateCandidate(
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1A',
        count: 2,
        itemIds: ['item-1', 'item-2'],
      ),
    ];
  }

  @override
  Future<AdminDuplicateActionResult> adminIgnoreDuplicateCandidate({
    required List<String> itemIds,
  }) async {
    duplicateResolved = true;
    return AdminDuplicateActionResult(
      ok: true,
      affectedItems: itemIds.length,
    );
  }

  @override
  Future<AdminDuplicateActionResult> adminMergeDuplicateCandidate({
    required String targetItemId,
    required List<String> sourceItemIds,
  }) async {
    lastMergeTargetItemId = targetItemId;
    lastMergeSourceItemIds = sourceItemIds;
    duplicateResolved = true;
    return AdminDuplicateActionResult(
      ok: true,
      affectedItems: sourceItemIds.length,
      item: const AdminMetadataItem(
        id: 'item-1',
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1A',
        seriesTitle: 'Absolute Batman',
        publisher: 'DC Comics',
        editions: [
          AdminEdition(
            id: 'edition-1',
            title: 'Standard Edition',
            variants: [
              AdminVariant(
                id: 'variant-1',
                name: 'Cover A',
                isPrimary: true,
              ),
            ],
          ),
          AdminEdition(
            id: 'edition-2',
            title: 'Variant Edition',
            variants: [
              AdminVariant(
                id: 'variant-2',
                name: 'Variant Cover',
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    lastInspectKind = kind;
    lastInspectId = id;
    return const AdminMetadataItem(
      id: 'item-1',
      kind: 'comic',
      title: 'Absolute Batman',
      itemNumber: '1B',
      seriesTitle: 'Absolute Batman',
      publisher: 'DC Comics',
      barcode: '76194138584600121',
      pageCount: 48,
      providerLinks: [
        AdminProviderLink(
          provider: 'gcd',
          entityType: 'item',
          providerItemId: '12346',
        ),
      ],
      editions: [
        AdminEdition(
          id: 'edition-2',
          title: 'Variant Edition',
          publisher: 'DC Comics',
          variants: [
            AdminVariant(
              id: 'variant-2',
              name: 'Variant Cover',
              isPrimary: true,
              barcode: '76194138584600121',
              coverPriceCents: 599,
              currency: 'USD',
            ),
          ],
          releases: [
            AdminRelease(id: 'release-2', region: 'US'),
          ],
        ),
      ],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> adminProviderSearch({
    required String provider,
    required String query,
    String? kind,
  }) async {
    lastSearchProvider = provider;
    lastSearchQuery = query;
    lastSearchKind = kind;
    return const [
      {
        'provider': 'gcd',
        'provider_item_id': '12345',
        'title': 'Absolute Batman #1',
        'kind': 'comic',
        'summary': 'DC issue metadata',
      },
    ];
  }

  @override
  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
  }) async {
    lastIngestProvider = provider;
    lastIngestProviderItemId = providerItemId;
    return const AdminProviderIngestResult(
      itemId: 'item-1',
      created: true,
      item: AdminMetadataItem(
        id: 'item-1',
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1A',
        seriesTitle: 'Absolute Batman',
        publisher: 'DC Comics',
        barcode: '76194138584600111',
        pageCount: 48,
        coverDate: null,
        storeDate: null,
        providerLinks: [
          AdminProviderLink(
            provider: 'gcd',
            entityType: 'item',
            providerItemId: '12345',
          ),
        ],
        editions: [
          AdminEdition(
            id: 'edition-1',
            title: 'Standard Edition',
            publisher: 'DC Comics',
            variants: [
              AdminVariant(
                id: 'variant-1',
                name: 'Cover A',
                isPrimary: true,
                barcode: '76194138584600111',
                coverPriceCents: 499,
                currency: 'USD',
              ),
            ],
            releases: [
              AdminRelease(id: 'release-1', region: 'US'),
            ],
          ),
        ],
      ),
    );
  }
}
