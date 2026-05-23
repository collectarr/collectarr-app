import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin page searches provider metadata and ingests a result',
      (tester) async {
    final api = _FakeAdminApiClient();
    tester.view.physicalSize = const Size(1200, 1600);
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

    // ─── Dashboard tab (default) ───
    expect(find.text('Metadata dashboard'), findsOneWidget);
    expect(find.text('1 live'), findsOneWidget);
    expect(find.text('3 registered'), findsOneWidget);
    expect(find.text('12 items'), findsOneWidget);
    expect(find.text('1 duplicate groups'), findsOneWidget);
    expect(find.text('75% covers'), findsOneWidget);
    expect(find.text('92% provider IDs'), findsOneWidget);
    expect(find.text('1 failures'), findsOneWidget);
    expect(find.text('5 ok'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);
    expect(find.text('GCD'), findsWidgets);

    await tester.tap(find.byTooltip('Reindex search'));
    await tester.pumpAndSettle();

    expect(api.reindexCount, 1);
    expect(find.text('Reindexed 12'), findsOneWidget);

    // ─── Logs tab ───
    await tester.tap(find.text('Logs'));
    await tester.pumpAndSettle();

    expect(find.text('Search index history'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('Admin audit log'));
    expect(find.text('metadata.correction'), findsOneWidget);
    expect(find.text('admin@example.com'), findsOneWidget);

    // ─── Catalog tab ───
    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Canonical catalog browser'), findsOneWidget);

    await _scrollUntilVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Covers'),
      delta: -500,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Covers').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('cover:'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await _scrollUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Edit'),
      delta: -500,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Edit').first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'Absolute Batman Deluxe');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Preview metadata correction'), findsOneWidget);
    await tester.tap(find.text('Save correction').last);
    await tester.pumpAndSettle();

    expect(api.lastCatalogUpdateTitle, 'Absolute Batman Deluxe');
    expect(find.text('Metadata correction saved.'), findsOneWidget);

    // Inspect + duplicates (also on Catalog tab)
    await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Inspect').first);
    await tester.pumpAndSettle();
    expect(find.text('Absolute Batman #1A'), findsWidgets);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Inspect').first);
    await tester.pumpAndSettle();

    expect(api.lastInspectKind, 'comic');
    expect(api.lastInspectId, 'item-1');
    expect(find.text('Inspect: Absolute Batman #1B'), findsOneWidget);
    expect(find.text('Absolute Batman #1B'), findsOneWidget);
    expect(find.text('Provider links'), findsOneWidget);
    expect(find.text('Item audit history'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Merge into first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merge into first'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Merge review:'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Type MERGE to confirm'),
      'MERGE',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Merge selected'));
    await tester.pumpAndSettle();

    expect(api.lastMergeTargetItemId, 'item-1');
    expect(api.lastMergeSourceItemIds, ['item-2']);
    expect(find.text('Merged 1 duplicate items.'), findsOneWidget);
    expect(find.text('No duplicate candidates detected.'), findsOneWidget);
    expect(find.text('Inspect: Absolute Batman #1B'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();

    // ─── Providers tab ───
    await tester.tap(find.text('Providers'));
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('Provider ingest jobs'));
    expect(find.text('Provider ingest jobs'), findsOneWidget);
    expect(find.text('1 queued'), findsOneWidget);
    expect(find.text('1 failed'), findsOneWidget);
    expect(find.text('1 due'), findsOneWidget);
    expect(find.text('gcd queued-123'), findsOneWidget);
    expect(find.text('Auto refresh'), findsOneWidget);
    expect(find.textContaining('Last refreshed'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Ingest job: gcd queued-123'), findsOneWidget);
    expect(find.text('Job ID'), findsOneWidget);
    expect(find.text('Provider item'), findsOneWidget);
    expect(find.text('Current state'), findsOneWidget);
    expect(find.text('Attempts left'), findsOneWidget);
    expect(find.text('Backoff / next run'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Refresh list'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();

    await tester
        .ensureVisible(find.widgetWithText(OutlinedButton, 'Queue current ID'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Job provider item ID'),
      'queued-direct',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Queue current ID'));
    await tester.pumpAndSettle();

    expect(api.lastQueuedProviderItemId, 'queued-direct');

    await tester.tap(find.widgetWithText(FilledButton, 'Run queued'));
    await tester.pumpAndSettle();

    expect(api.runPendingCount, 1);

    await _scrollUntilVisible(
      tester,
      find.text('Provider ingest history'),
      delta: -500,
    );
    expect(find.text('Provider ingest history'), findsOneWidget);
    expect(find.text('gcd failed-123'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(api.lastRetryHistoryId, 7);

    // Provider ingest by ID
    await _scrollUntilVisible(
      tester,
      find.widgetWithText(TextField, 'Provider item ID'),
      delta: -700,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Provider item ID'),
      'direct-123',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ingest ID'));
    await tester.pumpAndSettle();

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, 'direct-123');

    await _scrollUntilVisible(
      tester,
      find.widgetWithText(TextField, 'Provider query'),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Provider query'),
      'Batman #1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Search').last);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(api.lastSearchProvider, 'gcd');
    expect(api.lastSearchQuery, 'Batman #1');
    expect(api.lastSearchKind, 'comic');

    // Scroll down to find the provider result and ingest it.
    await _scrollUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Ingest'),
    );
    expect(find.text('Absolute Batman #1'), findsWidgets);
    expect(find.text('ID 12345'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ingest').first);
    await tester.pumpAndSettle();

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, '12345');
  });
}

Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 500,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    ).first,
    maxScrolls: 50,
  );
  await tester.pumpAndSettle();
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
  String? lastCatalogUpdateTitle;
  String? lastCatalogUpdatePhysicalFormat;
  String? lastQueuedProviderItemId;
  int? lastRetryHistoryId;
  List<String>? lastMergeSourceItemIds;
  bool duplicateResolved = false;
  bool retryResolved = false;
  bool catalogUpdated = false;
  bool queuedJobCreated = false;
  int runPendingCount = 0;
  int reindexCount = 0;

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return const [
      CatalogMediaType(
        kind: 'comic',
        singularLabel: 'Comic',
        pluralLabel: 'Comics',
        routeSegments: ['comics', 'comic'],
        defaultProvider: 'gcd',
        providers: ['gcd', 'comicvine'],
      ),
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
        defaultProvider: 'anilist',
        providers: ['anilist', 'comicvine'],
      ),
      CatalogMediaType(
        kind: 'anime',
        singularLabel: 'Anime',
        pluralLabel: 'Anime',
        routeSegments: ['anime'],
        defaultProvider: 'anilist',
        providers: ['anilist', 'tmdb'],
      ),
    ];
  }

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
        allowsImageMirroring: false,
        requiresAttribution: true,
        licenseName: 'CC BY-SA',
        message: 'Ready',
      ),
      AdminProviderStatus(
        name: 'comicvine',
        displayName: 'ComicVine',
        kind: 'comic',
        supportedKinds: ['comic', 'manga'],
        status: 'stub',
        isConfigured: false,
        supportsSearch: true,
        supportsIngest: true,
        requiresUserKey: true,
        nonCommercialOnly: true,
        allowsRedistribution: false,
        allowsImageMirroring: false,
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
        allowsImageMirroring: false,
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
      providerIngestSuccesses: retryResolved ? 6 : 5,
      providerIngestFailures: retryResolved ? 0 : 1,
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
  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    return [
      AdminMetadataItem(
        id: 'item-1',
        kind: 'comic',
        title: catalogUpdated ? 'Absolute Batman Deluxe' : 'Absolute Batman',
        itemNumber: '1A',
        series: const CatalogSeriesDetails(seriesTitle: 'Absolute Batman'),
        publisher: 'DC Comics',
        barcode: '76194138584600111',
        editions: const [
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
                coverImageUrl: 'https://cdn.example/absolute.jpg',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Future<AdminMetadataItem> adminUpdateCatalogItem({
    required String kind,
    required String id,
    String? title,
    String? itemNumber,
    String? synopsis,
    String? editionTitle,
    int? pageCount,
    String? publisher,
    DateTime? releaseDate,
    String? imprint,
    String? seriesGroup,
    String? physicalFormat,
    String? variantName,
    String? barcode,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    bool includeNulls = false,
    Set<String> explicitFields = const <String>{},
  }) async {
    lastCatalogUpdateTitle = title;
    lastCatalogUpdatePhysicalFormat = physicalFormat;
    catalogUpdated = true;
    return (await adminCatalogItems()).single;
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
  Future<List<AdminAuditLogEntry>> adminAuditLogs({
    String? action,
    String? entityType,
    String? entityId,
    int limit = 10,
  }) async {
    return [
      AdminAuditLogEntry(
        id: 'audit-1',
        action: 'metadata.correction',
        actorEmail: 'admin@example.com',
        entityType: 'item',
        entityId: 'item-1',
        detailsJson: const {
          'fields': ['title'],
        },
        createdAt: DateTime.utc(2026, 5, 14, 9, 15),
      ),
    ];
  }

  @override
  Future<List<AdminProviderIngestHistoryEntry>>
      adminProviderIngestHistory() async {
    if (retryResolved) {
      return [
        AdminProviderIngestHistoryEntry(
          id: 8,
          timestamp: DateTime.utc(2026, 5, 14, 9, 10),
          provider: 'gcd',
          providerItemId: 'failed-123',
          status: 'created',
          attempts: 1,
          itemId: 'item-1',
        ),
      ];
    }
    return [
      AdminProviderIngestHistoryEntry(
        id: 7,
        timestamp: DateTime.utc(2026, 5, 14, 9, 5),
        provider: 'gcd',
        providerItemId: 'failed-123',
        status: 'failed',
        attempts: 2,
        error: 'Provider timeout',
      ),
    ];
  }

  @override
  Future<AdminProviderIngestJobSummary> adminProviderIngestJobSummary() async {
    return AdminProviderIngestJobSummary(
      queued: runPendingCount > 0 ? (queuedJobCreated ? 1 : 0) : 1,
      running: 0,
      failed: retryResolved ? 0 : 1,
      done: runPendingCount > 0 ? 1 : 0,
      dueQueued: runPendingCount > 0 ? 0 : 1,
      staleRunning: 0,
      nextRunAt: runPendingCount > 0 ? null : DateTime.utc(2026, 5, 14, 9, 15),
      latestFailureAt: retryResolved ? null : DateTime.utc(2026, 5, 14, 9, 5),
    );
  }

  @override
  Future<List<AdminProviderIngestJob>> adminProviderIngestJobs({
    String? status,
    String? provider,
    String? query,
    int limit = 25,
  }) async {
    final jobs = [
      AdminProviderIngestJob(
        id: 'job-1',
        provider: 'gcd',
        providerItemId: 'queued-123',
        status: runPendingCount > 0 ? 'done' : 'queued',
        attempts: runPendingCount > 0 ? 1 : 0,
        maxAttempts: 3,
        nextRunAt:
            runPendingCount > 0 ? null : DateTime.utc(2026, 5, 14, 9, 15),
        createdAt: DateTime.utc(2026, 5, 14, 9, 0),
        updatedAt: DateTime.utc(2026, 5, 14, 9, 0),
        itemId: runPendingCount > 0 ? 'item-1' : null,
      ),
      if (queuedJobCreated)
        AdminProviderIngestJob(
          id: 'job-2',
          provider: 'gcd',
          providerItemId: 'queued-direct',
          status: 'queued',
          attempts: 0,
          maxAttempts: 3,
          createdAt: DateTime.utc(2026, 5, 14, 9, 2),
          updatedAt: DateTime.utc(2026, 5, 14, 9, 2),
        ),
    ];
    if (status == null || status.isEmpty) {
      return _filterJobs(jobs, provider, query);
    }
    return _filterJobs(
      jobs.where((job) => job.status == status).toList(growable: false),
      provider,
      query,
    );
  }

  List<AdminProviderIngestJob> _filterJobs(
    List<AdminProviderIngestJob> jobs,
    String? provider,
    String? query,
  ) {
    final normalizedQuery = query?.trim().toLowerCase();
    return jobs.where((job) {
      if (provider != null && provider.isNotEmpty && job.provider != provider) {
        return false;
      }
      if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
        return job.providerItemId.toLowerCase().contains(normalizedQuery) ||
            (job.lastError?.toLowerCase().contains(normalizedQuery) ?? false);
      }
      return true;
    }).toList(growable: false);
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
        hasCoverConflicts: true,
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
        series: CatalogSeriesDetails(seriesTitle: 'Absolute Batman'),
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
      series: CatalogSeriesDetails(seriesTitle: 'Absolute Batman'),
      publisher: 'DC Comics',
      barcode: '76194138584600121',
      publishing: CatalogPublishingDetails(pageCount: 48),
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
        series: CatalogSeriesDetails(seriesTitle: 'Absolute Batman'),
        publisher: 'DC Comics',
        barcode: '76194138584600111',
        publishing: CatalogPublishingDetails(pageCount: 48),
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

  @override
  Future<AdminProviderIngestResult> adminRetryProviderIngest({
    required int historyId,
  }) async {
    lastRetryHistoryId = historyId;
    retryResolved = true;
    return adminProviderIngest(provider: 'gcd', providerItemId: 'failed-123');
  }

  @override
  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    lastQueuedProviderItemId = providerItemId;
    queuedJobCreated = true;
    return AdminProviderIngestJob(
      id: 'job-2',
      provider: provider,
      providerItemId: providerItemId,
      status: 'queued',
      attempts: 0,
      maxAttempts: maxAttempts,
      createdAt: DateTime.utc(2026, 5, 14, 9, 2),
      updatedAt: DateTime.utc(2026, 5, 14, 9, 2),
    );
  }

  @override
  Future<AdminProviderIngestJobRunResult> adminRunPendingProviderIngestJobs({
    int limit = 5,
  }) async {
    runPendingCount += 1;
    return AdminProviderIngestJobRunResult(
      processed: 1,
      recovered: 0,
      jobs: await adminProviderIngestJobs(),
    );
  }
}
