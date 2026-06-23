import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('admin page searches provider metadata and ingests a result',
      (tester) async {
    final api = _FakeAdminApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    await LocationRepository(db).create(name: 'Shelf A');
    await CustomFieldRepository(db).upsertDefinition(
      CustomFieldDefinition(
        id: 'cf-1',
        name: 'Signed',
        fieldType: 'bool',
        mediaKind: 'comic',
        createdAt: DateTime.utc(2026, 5, 14),
      ),
    );
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
          authControllerProvider.overrideWith(
            (ref) => _AdminAuthController(ref),
          ),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );

    await pumpUntilSettled(tester);

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
    expect(find.text('Metadata proposal activity'), findsOneWidget);
    expect(find.text('1 recent approve'), findsOneWidget);
    expect(find.text('1 recent reject'), findsOneWidget);
    expect(find.text('Approved via provider'), findsOneWidget);
    expect(find.text('Rejected proposal'), findsOneWidget);

    await tester.tap(find.byTooltip('Reindex search'));
    await pumpUntilSettled(tester);

    expect(api.reindexCount, 1);
    expect(find.text('Reindexed 12'), findsOneWidget);

    // ─── Logs tab ───
    await tester.tap(find.text('Logs'));
    await pumpUntilSettled(tester);

    expect(find.text('Search index history'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('Admin audit log'));
    expect(find.text('metadata.correction'), findsOneWidget);
    expect(find.text('admin@example.com'), findsOneWidget);

    // ─── Providers tab ───
    await tester.tap(find.text('Providers'));
    await pumpUntilSettled(tester);

    expect(find.text('Metadata proposals'), findsOneWidget);
    expect(find.text('2 pending'), findsOneWidget);
    expect(find.text('1 approved'), findsOneWidget);
    expect(find.text('1 rejected'), findsOneWidget);
    expect(find.text('Manual GCD correction'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(OutlinedButton, 'Review in search').first);
    await pumpUntilSettled(tester);

    expect(find.textContaining('Reviewing proposal:'), findsOneWidget);
    await _scrollUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Approve proposal').first,
      delta: -400,
    );
    await tester
        .tap(find.widgetWithText(FilledButton, 'Approve proposal').first);
    await pumpUntilSettled(tester);

    expect(api.lastApprovedProposalId, 'proposal-1');
    expect(api.lastApprovedProposalProviderItemId, '12345');
    expect(
      find.text('Proposal approved with selected provider item.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reject').first);
    await pumpUntilSettled(tester);

    expect(api.lastRejectedProposalId, 'proposal-2');
    expect(find.text('Proposal rejected.'), findsOneWidget);

    // Provider ingest by ID
    await tester.tap(find.widgetWithText(FilledButton, 'Open add dialog'));
    await pumpUntilSettled(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Media kind',
      ),
    );
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Comic').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Known ID'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Provider item ID'),
      'direct-123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add to catalog'));
    await pumpUntilSettled(tester);

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, 'direct-123');

    await tester.tap(find.widgetWithText(FilledButton, 'Open add dialog'));
    await pumpUntilSettled(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Media kind',
      ),
    );
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Comic').last);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Provider query'),
      'Batman #1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Search provider'));
    await tester.pump();
    await tester.pump();
    await pumpUntilSettled(tester);

    expect(api.lastSearchProvider, 'gcd');
    expect(api.lastSearchQuery, 'Batman #1');
    expect(api.lastSearchKind, 'comic');

    // Scroll down to find the provider result and ingest it.
    await _scrollUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Ingest'),
    );
    expect(find.text('Absolute Batman #1'), findsWidgets);
    expect(find.text('12345'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ingest').first);
    await pumpUntilSettled(tester);

    expect(api.lastIngestProvider, 'gcd');
    expect(api.lastIngestProviderItemId, '12345');
  });

  testWidgets('admin page persists series tag corrections for books',
      (tester) async {
    final api = _BookAdminApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
          authControllerProvider.overrideWith(
            (ref) => _AdminAuthController(ref),
          ),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(Tab, 'Catalog'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Find catalog items'),
      'Lord of the Rings',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await pumpUntilSettled(tester);

    await _scrollUntilVisible(
      tester,
      find.text('Edit'),
      delta: -500,
    );
    await tester.tap(find.text('Edit').first);
    await pumpUntilSettled(tester);

    await tester.ensureVisible(find.widgetWithText(TextField, 'Series tags'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Original title'),
      'La Fraternidad del Anillo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Localized title'),
      'The Fellowship (RO)',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Sort key'),
      'fellowship-ring-1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Search aliases'),
      'LOTR 1, Fellowship',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Genres'),
      'Fantasy, Adventure',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Platforms'),
      'Switch, PC',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Characters'),
      'Frodo',
    );
    await tester.ensureVisible(find.byTooltip('Add Characters'));
    await tester.tap(find.byTooltip('Add Characters'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Characters'),
      'Gandalf',
    );
    await tester.ensureVisible(find.byTooltip('Add Characters'));
    await tester.tap(find.byTooltip('Add Characters'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Story arcs'),
      'Fellowship Quest',
    );
    await tester.ensureVisible(find.byTooltip('Add Story arcs'));
    await tester.tap(find.byTooltip('Add Story arcs'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Story arcs'),
      'Ring Journey',
    );
    await tester.ensureVisible(find.byTooltip('Add Story arcs'));
    await tester.tap(find.byTooltip('Add Story arcs'));
    await pumpUntilSettled(tester);
    await tester.ensureVisible(find.byTooltip('Add creator'));
    await tester.tap(find.byTooltip('Add creator'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Creator name'),
      'J.R.R. Tolkien',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Role'),
      'Author',
    );
    await tester.ensureVisible(find.byTooltip('Add track'));
    await tester.tap(find.byTooltip('Add track'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Track title'),
      'The Shire Theme',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Position'),
      '1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Duration seconds'),
      '180',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Artist'),
      'Howard Shore',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Trailer URLs'),
      'https://trailers.example/fellowship',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'External links'),
      'https://wiki.example/fellowship',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Title extension'),
      'Collector Edition',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Audience rating'),
      '4.8/5',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Color'), 'Color');
    await tester.enterText(
      find.widgetWithText(TextField, 'Number of discs'),
      '3',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Screen ratio'),
      '16:9',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Audio tracks'),
      'Stereo, Dolby Atmos',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Subtitles'),
      'EN, RO',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Layers'), 'BD-50');
    await tester.enterText(find.widgetWithText(TextField, 'Crossover'), 'N/A');
    await tester.enterText(
      find.widgetWithText(TextField, 'Plot summary'),
      'Frodo starts the quest.',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Plot description'),
      'The fellowship forms and departs from Rivendell.',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Series tags'),
      'Fantasy, Epic Fantasy, Fellowship',
    );

    await tester
        .tap(find.widgetWithText(FilledButton, 'Save correction').first);
    await pumpUntilSettled(tester);
    expect(find.text('Preview metadata correction'), findsOneWidget);
    expect(find.text('Series tags'), findsWidgets);

    await _tapPreviewSaveCorrection(tester, 'Preview metadata correction');
    await pumpUntilSettled(tester);

    expect(api.lastSeriesTagsSeriesId, 'series-book-1');
    expect(api.lastSeriesTags, ['Fantasy', 'Epic Fantasy', 'Fellowship']);
    expect(api.lastCatalogUpdateOriginalTitle, 'La Fraternidad del Anillo');
    expect(api.lastCatalogUpdateLocalizedTitle, 'The Fellowship (RO)');
    expect(api.lastCatalogUpdateSortKey, 'fellowship-ring-1');
    expect(api.lastCatalogUpdateSearchAliases, ['LOTR 1', 'Fellowship']);
    expect(api.lastCatalogUpdateGenres, ['Fantasy', 'Adventure']);
    expect(api.lastCatalogUpdatePlatforms, ['Switch', 'PC']);
    expect(api.lastCatalogUpdateCharacters, ['Frodo', 'Gandalf']);
    expect(
      api.lastCatalogUpdateStoryArcs,
      ['Fellowship Quest', 'Ring Journey'],
    );
    expect(api.lastCatalogUpdateCreators, [
      {'name': 'J.R.R. Tolkien', 'role': 'Author'},
    ]);
    expect(api.lastCatalogUpdateTracks, hasLength(1));
    expect(api.lastCatalogUpdateTracks!.single.title, 'The Shire Theme');
    expect(api.lastCatalogUpdateTracks!.single.position, 1);
    expect(api.lastCatalogUpdateTrailerUrls, hasLength(1));
    expect(api.lastCatalogUpdateTrailerUrls!.single.url,
        'https://trailers.example/fellowship');
    expect(api.lastCatalogUpdateTrailerUrls!.single.kind, 'trailer');
    expect(api.lastCatalogUpdateExternalLinks, hasLength(1));
    expect(api.lastCatalogUpdateExternalLinks!.single.url,
        'https://wiki.example/fellowship');
    expect(api.lastCatalogUpdateExternalLinks!.single.kind, 'external');
    expect(api.lastCatalogUpdateTitleExtension, 'Collector Edition');
    expect(api.lastCatalogUpdateAudienceRating, '4.8/5');
    expect(api.lastCatalogUpdateColor, 'Color');
    expect(api.lastCatalogUpdateNrDiscs, 3);
    expect(api.lastCatalogUpdateScreenRatio, '16:9');
    expect(api.lastCatalogUpdateAudioTracks, 'Stereo, Dolby Atmos');
    expect(api.lastCatalogUpdateSubtitles, 'EN, RO');
    expect(api.lastCatalogUpdateLayers, 'BD-50');
    expect(api.lastCatalogUpdateCrossover, 'N/A');
    expect(api.lastCatalogUpdatePlotSummary, 'Frodo starts the quest.');
    expect(api.lastCatalogUpdatePlotDescription,
        'The fellowship forms and departs from Rivendell.');
  });
}

Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 500,
}) async {
  final visibleScrollables = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable();
  final scrollable = visibleScrollables.evaluate().isNotEmpty
      ? visibleScrollables.last
      : find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last;
  for (var index = 0; index < 50; index++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await pumpUntilSettled(tester);
      return;
    }
    await tester.drag(scrollable, Offset(0, -delta.abs()));
    await pumpUntilSettled(tester);
  }
  throw StateError('Could not find widget after scrolling: $finder');
}

Future<void> _tapPreviewSaveCorrection(
  WidgetTester tester,
  String dialogTitle,
) async {
  final dialog = find.ancestor(
    of: find.text(dialogTitle),
    matching: find.byType(AlertDialog),
  );
  await tester.tap(
    find.descendant(
      of: dialog,
      matching: find.widgetWithText(FilledButton, 'Save correction'),
    ),
  );
}

class _AdminAuthController extends AuthController {
  _AdminAuthController(super.ref) {
    state = const AuthState(
      token: 'test-token',
      email: 'admin@example.com',
      isAdmin: true,
    );
  }
}

class _FakeAdminApiClient extends ApiClient {
  _FakeAdminApiClient() : super(baseUrl: 'http://metadata.local');

  String? lastSearchProvider;
  String? lastSearchQuery;
  String? lastSearchKind;
  String? lastApprovedProposalId;
  String? lastApprovedProposalProviderItemId;
  String? lastRejectedProposalId;
  String? lastUpdatedUserId;
  String? lastUpdatedUserDisplayName;
  String? lastUpdatedUserRole;
  bool? lastUpdatedUserIsActive;
  String? lastPurgedImageProvider;
  String? lastSeriesTagsSeriesId;
  String? lastIngestProvider;
  String? lastIngestProviderItemId;
  String? lastInspectKind;
  String? lastInspectId;
  String? lastMergeTargetItemId;
  String? lastCatalogUpdateTitle;
  String? lastCatalogUpdateOriginalTitle;
  String? lastCatalogUpdateLocalizedTitle;
  String? lastCatalogUpdateSortKey;
  List<String>? lastCatalogUpdateSearchAliases;
  List<String>? lastCatalogUpdateGenres;
  List<String>? lastCatalogUpdatePlatforms;
  List<String>? lastCatalogUpdateCharacters;
  List<String>? lastCatalogUpdateStoryArcs;
  List<Map<String, dynamic>>? lastCatalogUpdateCreators;
  List<CatalogTrack>? lastCatalogUpdateTracks;
  List<TrailerLink>? lastCatalogUpdateTrailerUrls;
  List<TrailerLink>? lastCatalogUpdateExternalLinks;
  String? lastCatalogUpdateTitleExtension;
  String? lastCatalogUpdateAudienceRating;
  String? lastCatalogUpdateColor;
  int? lastCatalogUpdateNrDiscs;
  String? lastCatalogUpdateScreenRatio;
  String? lastCatalogUpdateAudioTracks;
  String? lastCatalogUpdateSubtitles;
  String? lastCatalogUpdateLayers;
  String? lastCatalogUpdateCrossover;
  String? lastCatalogUpdatePlotSummary;
  String? lastCatalogUpdatePlotDescription;
  String? lastCatalogUpdatePhysicalFormat;
  String? lastBundleUpdateId;
  String? lastBundleUpdateTitle;
  String? lastQueuedProviderItemId;
  int? lastRetryHistoryId;
  List<String>? lastSeriesTags;
  List<String>? lastMergeSourceItemIds;
  bool duplicateResolved = false;
  bool retryResolved = false;
  bool catalogUpdated = false;
  bool bundleUpdated = false;
  bool queuedJobCreated = false;
  int catalogUpdateCount = 0;
  int runPendingCount = 0;
  int reindexCount = 0;
  final List<AdminUser> _users = [
    AdminUser(
      id: 'user-1',
      email: 'alice@example.com',
      displayName: 'Alice Admin',
      isActive: true,
      isAdmin: true,
      role: 'admin',
      createdAt: DateTime.utc(2026, 5, 10, 9),
      updatedAt: DateTime.utc(2026, 5, 14, 9),
    ),
    AdminUser(
      id: 'user-2',
      email: 'bob@example.com',
      displayName: 'Bob Editor',
      isActive: true,
      isAdmin: false,
      role: 'editor',
      createdAt: DateTime.utc(2026, 5, 11, 9),
      updatedAt: DateTime.utc(2026, 5, 14, 10),
    ),
  ];
  final Map<String, int> _imageProviders = {'gcd': 12, 'comicvine': 4};
  final List<AdminMetadataProposal> _pendingProposals = [
    const AdminMetadataProposal(
      id: 'proposal-1',
      provider: 'gcd',
      providerItemId: 'manual-123',
      query: 'Absolute Batman manual correction',
      title: 'Manual GCD correction',
      summary: 'Needs a provider-backed match before ingest.',
      status: 'pending',
    ),
    const AdminMetadataProposal(
      id: 'proposal-2',
      provider: 'comicvine',
      query: 'Variant cleanup proposal',
      title: 'Variant cleanup',
      summary: 'Reject this duplicate suggestion.',
      status: 'pending',
    ),
  ];

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
    String? titleExtension,
    String? sortKey,
    String? originalTitle,
    String? localizedTitle,
    List<String>? searchAliases,
    String? itemNumber,
    String? synopsis,
    String? editionTitle,
    int? pageCount,
    int? runtimeMinutes,
    String? publisher,
    DateTime? releaseDate,
    String? imprint,
    String? subtitle,
    String? seriesGroup,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    List<String>? genres,
    List<String>? platforms,
    List<CatalogTrack>? tracks,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<String>? storyArcs,
    String? color,
    int? nrDiscs,
    String? screenRatio,
    String? audioTracks,
    String? subtitles,
    String? layers,
    List<TrailerLink>? trailerUrls,
    List<TrailerLink>? externalLinks,
    String? crossover,
    String? plotSummary,
    String? plotDescription,
    String? catalogNumber,
    String? releaseStatus,
    String? physicalFormat,
    String? variantName,
    String? barcode,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    bool includeNulls = false,
    Set<String> explicitFields = const <String>{},
  }) async {
    catalogUpdateCount += 1;
    lastCatalogUpdateTitle = title;
    lastCatalogUpdateOriginalTitle = originalTitle;
    lastCatalogUpdateLocalizedTitle = localizedTitle;
    lastCatalogUpdateSortKey = sortKey;
    lastCatalogUpdateSearchAliases = searchAliases;
    lastCatalogUpdateGenres = genres;
    lastCatalogUpdatePlatforms = platforms;
    lastCatalogUpdateCharacters = characters;
    lastCatalogUpdateStoryArcs = storyArcs;
    lastCatalogUpdateCreators = creators;
    lastCatalogUpdateTracks = tracks;
    lastCatalogUpdateTrailerUrls = trailerUrls;
    lastCatalogUpdateExternalLinks = externalLinks;
    lastCatalogUpdateTitleExtension = titleExtension;
    lastCatalogUpdateAudienceRating = audienceRating;
    lastCatalogUpdateColor = color;
    lastCatalogUpdateNrDiscs = nrDiscs;
    lastCatalogUpdateScreenRatio = screenRatio;
    lastCatalogUpdateAudioTracks = audioTracks;
    lastCatalogUpdateSubtitles = subtitles;
    lastCatalogUpdateLayers = layers;
    lastCatalogUpdateCrossover = crossover;
    lastCatalogUpdatePlotSummary = plotSummary;
    lastCatalogUpdatePlotDescription = plotDescription;
    lastCatalogUpdatePhysicalFormat = physicalFormat;
    catalogUpdated = true;
    return (await adminCatalogItems()).single;
  }

  @override
  Future<Map<String, dynamic>> adminUpdateSeriesTags({
    required String seriesId,
    required List<String> tags,
  }) async {
    lastSeriesTagsSeriesId = seriesId;
    lastSeriesTags = tags;
    return {
      'id': seriesId,
      'title': 'Series',
      'tags': tags,
    };
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
    if (entityType == 'metadata_proposal') {
      return [
        AdminAuditLogEntry(
          id: 'proposal-audit-1',
          action: 'metadata_proposal.approve_provider',
          actorEmail: 'admin@example.com',
          entityType: 'metadata_proposal',
          entityId: 'proposal-1',
          detailsJson: const {'provider': 'gcd'},
          createdAt: DateTime.utc(2026, 5, 14, 9, 20),
        ),
        AdminAuditLogEntry(
          id: 'proposal-audit-2',
          action: 'metadata_proposal.reject',
          actorEmail: 'admin@example.com',
          entityType: 'metadata_proposal',
          entityId: 'proposal-2',
          detailsJson: const {'provider': 'comicvine'},
          createdAt: DateTime.utc(2026, 5, 14, 9, 25),
        ),
      ];
    }
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
  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    return AdminMetadataProposalSummary(
      pending: _pendingProposals
          .where((proposal) =>
              proposal.id != lastApprovedProposalId &&
              proposal.id != lastRejectedProposalId)
          .length,
      approved: 1 + (lastApprovedProposalId == null ? 0 : 1),
      rejected: 1 + (lastRejectedProposalId == null ? 0 : 1),
      total: _pendingProposals.length + 2,
    );
  }

  @override
  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
    String? provider,
  }) async {
    Iterable<AdminMetadataProposal> proposals;
    if (status == 'pending') {
      proposals = _pendingProposals.where((proposal) {
        if (lastApprovedProposalId == proposal.id ||
            lastRejectedProposalId == proposal.id) {
          return false;
        }
        return true;
      });
    } else if (status == 'approved') {
      proposals = const [
        AdminMetadataProposal(
          id: 'proposal-approved-1',
          provider: 'gcd',
          query: 'Approved proposal',
          title: 'Approved proposal',
          status: 'approved',
        ),
      ];
    } else {
      proposals = const [
        AdminMetadataProposal(
          id: 'proposal-rejected-1',
          provider: 'comicvine',
          query: 'Rejected proposal',
          title: 'Rejected proposal',
          status: 'rejected',
        ),
      ];
    }
    if (provider != null && provider.isNotEmpty) {
      proposals = proposals.where((proposal) => proposal.provider == provider);
    }
    return proposals.toList(growable: false);
  }

  @override
  Future<AdminProviderIngestResult> adminApproveMetadataProposal({
    required String proposalId,
  }) async {
    lastApprovedProposalId = proposalId;
    return const AdminProviderIngestResult(
      itemId: 'item-1',
      created: true,
      item: AdminMetadataItem(
        id: 'item-1',
        kind: 'comic',
        title: 'Absolute Batman',
      ),
    );
  }

  @override
  Future<AdminProviderIngestResult>
      adminApproveMetadataProposalWithProviderItem({
    required String proposalId,
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    lastApprovedProposalId = proposalId;
    lastApprovedProposalProviderItemId = providerItemId;
    return const AdminProviderIngestResult(
      itemId: 'item-1',
      created: true,
      item: AdminMetadataItem(
        id: 'item-1',
        kind: 'comic',
        title: 'Absolute Batman',
      ),
    );
  }

  @override
  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    lastRejectedProposalId = proposalId;
    return const AdminMetadataProposal(
      id: 'proposal-2',
      provider: 'comicvine',
      query: 'Variant cleanup proposal',
      title: 'Variant cleanup',
      status: 'rejected',
    );
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
        ),
      ],
    );
  }

  @override
  Future<List<BundleReleaseSummary>> getItemBundleReleases(
      String itemId) async {
    if (itemId != 'item-1') {
      return const [];
    }
    return [
      BundleReleaseSummary(
        id: 'bundle-1',
        kind: 'comic',
        title: bundleUpdated
            ? 'Absolute Batman Collector Box'
            : 'Absolute Batman Collector Bundle',
        publisher: 'DC Comics',
        bundleType: 'box_set',
        contentSummary: const BundleReleaseContentSummary(
          totalItems: 2,
          primaryCount: 1,
          bonusCount: 1,
        ),
      ),
    ];
  }

  @override
  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    expect(bundleReleaseId, 'bundle-1');
    return BundleReleaseDetail.fromJson({
      'id': 'bundle-1',
      'kind': 'comic',
      'title': bundleUpdated
          ? 'Absolute Batman Collector Box'
          : 'Absolute Batman Collector Bundle',
      'bundle_type': 'box_set',
      'publisher': 'DC Comics',
      'primary_item_id': 'item-1',
      'content_summary': const {
        'total_items': 2,
        'primary_count': 1,
        'bonus_count': 1,
      },
      'members': const [
        {
          'id': 'bundle-member-1',
          'item_id': 'item-1',
          'role': 'primary',
          'sequence_number': 1,
          'quantity': 1,
          'is_primary': true,
          'kind': 'comic',
          'title': 'Absolute Batman #1B',
          'item_number': '1B',
        },
        {
          'id': 'bundle-member-2',
          'item_id': 'item-3',
          'role': 'bonus',
          'sequence_number': 2,
          'quantity': 1,
          'is_primary': false,
          'kind': 'comic',
          'title': 'Absolute Batman Sketchbook',
        },
      ],
    });
  }

  @override
  Future<BundleReleaseDetail> adminUpdateBundleRelease({
    required String bundleReleaseId,
    required AdminBundleReleaseCorrection correction,
  }) async {
    lastBundleUpdateId = bundleReleaseId;
    lastBundleUpdateTitle = correction.title;
    bundleUpdated = true;
    return getBundleRelease(bundleReleaseId);
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
    String? kind,
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

  @override
  Future<List<AdminUser>> adminListUsers() async {
    return List<AdminUser>.from(_users);
  }

  @override
  Future<AdminUser> adminUpdateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? displayName,
  }) async {
    final index = _users.indexWhere((user) => user.id == userId);
    expect(index, isNonNegative);
    final current = _users[index];
    final updated = AdminUser(
      id: current.id,
      email: current.email,
      displayName: displayName ?? current.displayName,
      isActive: isActive ?? current.isActive,
      isAdmin: (role ?? current.role) == 'admin',
      role: role ?? current.role,
      createdAt: current.createdAt,
      updatedAt: DateTime.utc(2026, 5, 14, 11),
    );
    _users[index] = updated;
    lastUpdatedUserId = userId;
    lastUpdatedUserDisplayName = displayName;
    lastUpdatedUserRole = role;
    lastUpdatedUserIsActive = isActive;
    return updated;
  }

  @override
  Future<AdminImageCacheStats> adminImageCacheStats() async {
    final totalEntries =
        _imageProviders.values.fold<int>(0, (sum, item) => sum + item);
    final totalSizeBytes = totalEntries * 1024 * 128;
    const maxSizeBytes = 1024 * 1024 * 8;
    return AdminImageCacheStats(
      totalEntries: totalEntries,
      totalSizeBytes: totalSizeBytes,
      maxSizeBytes: maxSizeBytes,
      usagePercent: totalSizeBytes / maxSizeBytes * 100,
      mirroringEnabled: true,
      providers: Map<String, int>.from(_imageProviders),
    );
  }

  @override
  Future<AdminImageCachePurgeResult> adminPurgeImageCache(
      {String? provider}) async {
    lastPurgedImageProvider = provider;
    if (provider == null || provider.isEmpty) {
      final deletedEntries =
          _imageProviders.values.fold<int>(0, (sum, item) => sum + item);
      _imageProviders.updateAll((key, value) => 0);
      return AdminImageCachePurgeResult(
        deletedEntries: deletedEntries,
        freedBytes: deletedEntries * 1024 * 128,
      );
    }
    final deletedEntries = _imageProviders[provider] ?? 0;
    _imageProviders[provider] = 0;
    return AdminImageCachePurgeResult(
      deletedEntries: deletedEntries,
      freedBytes: deletedEntries * 1024 * 128,
    );
  }
}

class _BookAdminApiClient extends _FakeAdminApiClient {
  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return const [
      CatalogMediaType(
        kind: 'book',
        singularLabel: 'Book',
        pluralLabel: 'Books',
        routeSegments: ['books', 'book'],
        defaultProvider: 'openlibrary',
        providers: ['openlibrary', 'hardcover'],
      ),
    ];
  }

  @override
  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    return [
      AdminMetadataItem(
        id: 'book-item-1',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        itemNumber: '1',
        synopsis: 'The first journey into Middle-earth.',
        publisher: 'Allen & Unwin',
        series: CatalogSeriesDetails(
          seriesId: 'series-book-1',
          seriesTitle: 'The Lord of the Rings',
          volumeNumber: 1,
          tags: lastSeriesTags ?? const ['Fantasy'],
        ),
        publishing: const CatalogPublishingDetails(
          subtitle: 'Being the First Part',
          pageCount: 423,
        ),
        editions: const [
          AdminEdition(
            id: 'edition-book-1',
            title: 'Hardcover',
            publisher: 'Allen & Unwin',
            variants: [
              AdminVariant(
                id: 'variant-book-1',
                name: 'Primary',
                isPrimary: true,
                coverImageUrl: 'https://cdn.example/fellowship.jpg',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
