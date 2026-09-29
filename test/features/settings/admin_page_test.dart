import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
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
  testWidgets('admin page manages catalog proposals without provider ingest',
      (tester) async {
    final api = _FakeAdminApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    await LocationRepository(db).create(name: 'Shelf A');
    await CustomFieldRepository(db).upsertDefinition(
      CustomFieldDefinition(
        id: 'cf-1',
        name: 'Signed',
        fieldType: 'boolean',
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
            () => _AdminAuthController(),
          ),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );

    await pumpUntilSettled(tester);

    // â”€â”€â”€ Dashboard tab (default) â”€â”€â”€
    expect(find.text('Metadata dashboard'), findsOneWidget);
    expect(find.text('1 live'), findsOneWidget);
    expect(find.text('3 registered'), findsOneWidget);
    expect(find.text('12 items'), findsOneWidget);
    expect(find.text('75% covers'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);
    expect(find.text('Shared contract in sync'), findsOneWidget);
    expect(find.text('Normalized drift clear'), findsOneWidget);
    expect(find.text('Metadata proposal activity'), findsOneWidget);
    expect(find.text('1 recent approve'), findsOneWidget);
    expect(find.text('1 recent reject'), findsOneWidget);
    expect(find.text('Rejected proposal'), findsOneWidget);
    expect(find.text('Collection schema'), findsOneWidget);
    expect(find.text('Schema explorer'), findsOneWidget);

    await tester.tap(find.byTooltip('Reindex search'));
    await pumpUntilSettled(tester);

    expect(api.reindexCount, 1);
    expect(find.text('Reindexed 12'), findsOneWidget);

    // â”€â”€â”€ Stats tab â”€â”€â”€
    await tester.tap(find.widgetWithText(Tab, 'Stats'));
    await pumpUntilSettled(tester);
    expect(find.text('Catalog stats'), findsOneWidget);
    expect(find.text('Comics: 7'), findsOneWidget);
    expect(find.text('Books: 3'), findsOneWidget);
    expect(find.text('Music: 2'), findsOneWidget);
    expect(find.textContaining('cache usage'), findsOneWidget);
    expect(find.textContaining('Mirroring enabled'), findsOneWidget);

    // â”€â”€â”€ Logs tab â”€â”€â”€
    await tester.tap(find.text('Logs'));
    await pumpUntilSettled(tester);

    expect(find.text('Search index history'), findsOneWidget);
    expect(find.text('12 docs'), findsOneWidget);

    await _scrollUntilVisible(tester, find.text('Admin audit log'));
    expect(find.text('metadata.correction'), findsOneWidget);
    expect(find.text('admin@example.com'), findsOneWidget);

    // â”€â”€â”€ Proposals tab â”€â”€â”€
    await tester.tap(find.widgetWithText(Tab, 'Proposals'));
    await pumpUntilSettled(tester);

    expect(find.text('Metadata proposals'), findsOneWidget);
    expect(find.text('2 pending'), findsOneWidget);
    expect(find.text('1 approved'), findsOneWidget);
    expect(find.text('1 rejected'), findsOneWidget);
    expect(find.text('Manual user correction'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(OutlinedButton, 'Edit metadata').first);
    await pumpUntilSettled(tester);
    expect(find.textContaining('Edit proposal metadata -'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Game'), findsWidgets);
    expect(
      find.widgetWithText(TextFormField, 'Platforms (comma separated)'),
      findsOneWidget,
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Title').first,
        'Manual user correction updated');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Platforms (comma separated)').first,
      'PlayStation 5, Nintendo Switch',
    );
    await tester.enterText(
      find
          .widgetWithText(TextFormField,
              'External links (label | url | kind | description)')
          .first,
      'Official site | https://example.com/official | official | Main website',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes').first);
    await pumpUntilSettled(tester);
    expect(api.lastUpdatedProposalId, 'proposal-1');
    expect(api.lastUpdatedProposalTitle, 'Manual user correction updated');
    expect(
      api.lastUpdatedProposalMetadataPayload?['platforms'],
      ['PlayStation 5', 'Nintendo Switch'],
    );
    expect(
      api.lastUpdatedProposalMetadataPayload?['external_links'],
      [
        {
          'label': 'Official site',
          'url': 'https://example.com/official',
          'kind': 'official',
          'description': 'Main website',
        },
      ],
    );
    expect(find.text('Proposal metadata updated.'), findsOneWidget);
    expect(find.text('Manual user correction updated'), findsWidgets);

    await _scrollUntilVisible(
      tester,
      find.widgetWithText(FilledButton, 'Approve proposal').first,
      delta: -400,
    );
    await tester
        .tap(find.widgetWithText(FilledButton, 'Approve proposal').first);
    await pumpUntilSettled(tester);
    expect(find.text('Approve proposal?'), findsOneWidget);
    final approveDialog = find.ancestor(
      of: find.text('Approve proposal?'),
      matching: find.byType(AlertDialog),
    );
    await tester.tap(
      find.descendant(
        of: approveDialog,
        matching: find.widgetWithText(FilledButton, 'Approve'),
      ),
    );
    await pumpUntilSettled(tester);

    expect(api.lastApprovedProposalId, 'proposal-1');
    expect(
      find.text(
        'Proposal approved.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    final rejectButtons = find.widgetWithText(
      OutlinedButton,
      'Reject',
      skipOffstage: false,
    );
    await _scrollUntilVisible(tester, rejectButtons);
    await tester.tap(rejectButtons.first);
    await pumpUntilSettled(tester);

    expect(api.lastRejectedProposalId, 'proposal-2');
    expect(
      find.text('Proposal rejected.', skipOffstage: false),
      findsOneWidget,
    );
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
            () => _AdminAuthController(),
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
      find.widgetWithText(TextField, 'Series tags'),
      'Fantasy, Epic Fantasy, Fellowship',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Review correction'));
    await pumpUntilSettled(tester);
    expect(find.text('Preview metadata correction'), findsOneWidget);

    await _tapPreviewSaveCorrection(tester, 'Preview metadata correction');
    await pumpUntilSettled(tester);

    expect(api.lastSeriesTagsSeriesId, 'series-book-1');
    expect(api.lastSeriesTags, ['Fantasy', 'Epic Fantasy', 'Fellowship']);
  });

  testWidgets('proposal editor validates malformed external links',
      (tester) async {
    final api = _FakeAdminApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
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
            () => _AdminAuthController(),
          ),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(Tab, 'Proposals'));
    await pumpUntilSettled(tester);
    await tester
        .tap(find.widgetWithText(OutlinedButton, 'Edit metadata').first);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find
          .widgetWithText(TextFormField,
              'External links (label | url | kind | description)')
          .first,
      'Bad link | not-a-url',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes').first);
    await pumpUntilSettled(tester);

    expect(
      find.textContaining('invalid URL "not-a-url"'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('admin page renders and navigates tabs on compact mobile screen',
      (tester) async {
    final api = _FakeAdminApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          localDatabaseProvider.overrideWithValue(db),
          authControllerProvider.overrideWith(
            () => _AdminAuthController(),
          ),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Metadata dashboard'), findsOneWidget);

    // Scroll and tap Catalog tab
    await tester.tap(find.widgetWithText(Tab, 'Catalog'));
    await pumpUntilSettled(tester);

    expect(find.text('Catalog search'), findsOneWidget);
    expect(find.text('Find catalog items'), findsOneWidget);

    // Tap Providers tab
    await tester.tap(find.widgetWithText(Tab, 'Proposals'));
    await pumpUntilSettled(tester);

    expect(find.text('Metadata proposals'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
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
  _AdminAuthController();

  @override
  AuthState build() => const AuthState(
        token: 'test-token',
        email: 'admin@example.com',
        isAdmin: true,
      );
}

class _FakeAdminApiClient extends ApiClient {
  _FakeAdminApiClient() : super(baseUrl: 'http://metadata.local');

  String? lastSearchQuery;
  String? lastSearchKind;
  String? lastApprovedProposalId;
  String? lastUpdatedProposalId;
  String? lastUpdatedProposalTitle;
  Map<String, dynamic>? lastUpdatedProposalMetadataPayload;
  String? lastRejectedProposalId;
  String? lastUpdatedUserId;
  String? lastUpdatedUserDisplayName;
  String? lastUpdatedUserRole;
  bool? lastUpdatedUserIsActive;
  String? lastSeriesTagsSeriesId;
  String? lastInspectKind;
  String? lastInspectId;
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
  List<CatalogTrackDto>? lastCatalogUpdateTracks;
  List<TrailerLinkDto>? lastCatalogUpdateTrailerUrls;
  List<TrailerLinkDto>? lastCatalogUpdateExternalLinks;
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
  List<String>? lastSeriesTags;
  bool catalogUpdated = false;
  bool bundleUpdated = false;
  int catalogUpdateCount = 0;
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
  final List<AdminMetadataProposal> _pendingProposals = [
    const AdminMetadataProposal(
      id: 'proposal-1',
      kind: 'game',
      catalogItem: {
        'title': 'Manual user correction',
        'platforms': ['PlayStation 5'],
        'external_links': [
          {'label': 'Store', 'url': 'https://example.com/store'},
        ],
      },
      status: 'pending',
    ),
    const AdminMetadataProposal(
      id: 'proposal-2',
      kind: 'comic',
      catalogItem: {'title': 'Variant cleanup'},
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
      ),
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
      ),
      CatalogMediaType(
        kind: 'anime',
        singularLabel: 'Anime',
        pluralLabel: 'Anime',
        routeSegments: ['anime'],
      ),
    ];
  }

  @override
  Future<MetadataNormalizedManifest> metadataNormalizedManifest() async {
    return const MetadataNormalizedManifest(
      schemaVersion: 1,
      commonFields: ['audience_rating'],
      kindFields: {
        'comic': ['genres'],
        'game': ['platforms'],
        'movie': ['color'],
      },
      valueTypes: {
        'audience_rating': 'string',
        'genres': 'string_list',
        'platforms': 'string_list',
        'color': 'string',
      },
    );
  }

  @override
  Future<AdminCatalogSummary> adminCatalogSummary() async {
    return AdminCatalogSummary(
      items: 12,
      itemsByKind: const {
        'comic': 7,
        'book': 3,
        'music': 2,
      },
      series: 4,
      volumes: 4,
      editions: 12,
      variants: 15,
      imageAssets: 0,
      imageCacheEntries: 0,
      pendingProposals: 2,
      missingCoverItems: 3,
      duplicateCandidateGroups: 0,
    );
  }

  @override
  Future<AdminNormalizedMetadataDriftReport> adminNormalizedMetadataDrift(
      {int sampleLimit = 100}) async {
    return const AdminNormalizedMetadataDriftReport(
      expectedSchemaVersion: 1,
      scannedEntities: 12,
      entitiesWithNormalized: 10,
      driftedEntities: 0,
      typedScannedItems: 8,
      typedDriftedItems: 0,
      releaseGateOk: true,
      issueCounts: {},
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
        canonicalFieldValues: const {
          'series_title': 'Absolute Batman',
          'publisher': 'DC Comics',
          'barcode': '76194138584600111',
        },
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
    Object? releaseDate,
    String? imprint,
    String? subtitle,
    String? seriesGroup,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    List<String>? genres,
    List<String>? platforms,
    List<CatalogTrackDto>? tracks,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<String>? storyArcs,
    String? color,
    int? nrDiscs,
    String? screenRatio,
    String? audioTracks,
    String? subtitles,
    String? layers,
    List<TrailerLinkDto>? trailerUrls,
    List<TrailerLinkDto>? externalLinks,
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
  Future<Map<String, dynamic>> adminUpdateSeriesFields({
    required String seriesId,
    required Map<String, Object?> fields,
  }) async {
    final tags = (fields['tags'] as List? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false);
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
          action: 'metadata_proposal.approve',
          actorEmail: 'admin@example.com',
          entityType: 'metadata_proposal',
          entityId: 'proposal-1',
          createdAt: DateTime.utc(2026, 5, 14, 9, 20),
        ),
        AdminAuditLogEntry(
          id: 'proposal-audit-2',
          action: 'metadata_proposal.reject',
          actorEmail: 'admin@example.com',
          entityType: 'metadata_proposal',
          entityId: 'proposal-2',
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
  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    return AdminMetadataProposalSummary(
      pending: _pendingProposals
          .where((proposal) => proposal.status == 'pending')
          .length,
      approved:
          1 + _pendingProposals.where((p) => p.status == 'approved').length,
      rejected:
          1 + _pendingProposals.where((p) => p.status == 'rejected').length,
      total: _pendingProposals.length + 2,
    );
  }

  @override
  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
  }) async {
    if (status == 'approved') {
      return const [
        AdminMetadataProposal(
          id: 'proposal-approved-1',
          kind: 'comic',
          catalogItem: {'title': 'Approved proposal'},
          status: 'approved',
        ),
      ];
    }
    if (status == 'rejected') {
      return const [
        AdminMetadataProposal(
          id: 'proposal-rejected-1',
          kind: 'comic',
          catalogItem: {'title': 'Rejected proposal'},
          status: 'rejected',
        ),
      ];
    }
    return _pendingProposals
        .where((proposal) => proposal.status == status)
        .toList(growable: false);
  }

  @override
  Future<AdminMetadataProposal> adminApproveMetadataProposal({
    required String proposalId,
  }) async {
    final index =
        _pendingProposals.indexWhere((proposal) => proposal.id == proposalId);
    if (index < 0) throw StateError('Unknown proposal: $proposalId');
    final current = _pendingProposals[index];
    final updated = AdminMetadataProposal(
      id: current.id,
      kind: current.kind,
      catalogItem: current.catalogItem,
      status: 'approved',
      reviewNote: current.reviewNote,
      createdAt: current.createdAt,
    );
    _pendingProposals[index] = updated;
    lastApprovedProposalId = proposalId;
    return updated;
  }

  @override
  Future<AdminMetadataProposal> adminUpdateMetadataProposal({
    required String proposalId,
    required Map<String, dynamic> catalogItem,
    String? reviewNote,
  }) async {
    final index =
        _pendingProposals.indexWhere((proposal) => proposal.id == proposalId);
    if (index < 0) throw StateError('Unknown proposal: $proposalId');
    final current = _pendingProposals[index];
    final updated = AdminMetadataProposal(
      id: current.id,
      kind: current.kind,
      catalogItem: Map<String, dynamic>.unmodifiable(catalogItem),
      status: current.status,
      reviewNote: reviewNote ?? current.reviewNote,
      createdAt: current.createdAt,
    );
    _pendingProposals[index] = updated;
    lastUpdatedProposalId = proposalId;
    lastUpdatedProposalTitle = catalogItem['title'] as String?;
    lastUpdatedProposalMetadataPayload = catalogItem;
    return updated;
  }

  @override
  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    final index =
        _pendingProposals.indexWhere((proposal) => proposal.id == proposalId);
    if (index < 0) throw StateError('Unknown proposal: $proposalId');
    final current = _pendingProposals[index];
    final updated = AdminMetadataProposal(
      id: current.id,
      kind: current.kind,
      catalogItem: current.catalogItem,
      status: 'rejected',
      reviewNote: current.reviewNote,
      createdAt: current.createdAt,
    );
    _pendingProposals[index] = updated;
    lastRejectedProposalId = proposalId;
    return updated;
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
      canonicalFieldValues: {
        'series_title': 'Absolute Batman',
        'publisher': 'DC Comics',
        'barcode': '76194138584600121',
        'page_count': 48,
      },
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
    const totalEntries = 16;
    const totalSizeBytes = totalEntries * 1024 * 128;
    const maxSizeBytes = 1024 * 1024 * 8;
    return const AdminImageCacheStats(
      totalEntries: totalEntries,
      totalSizeBytes: totalSizeBytes,
      maxSizeBytes: maxSizeBytes,
      usagePercent: totalSizeBytes / maxSizeBytes * 100,
      mirroringEnabled: true,
    );
  }

  @override
  Future<AdminImageCachePurgeResult> adminPurgeImageCache() async {
    return const AdminImageCachePurgeResult(
      deletedEntries: 16,
      freedBytes: 16 * 1024 * 128,
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
      ),
    ];
  }

  @override
  Future<MetadataFieldSchema> metadataFieldSchema({
    bool editableOnly = true,
  }) async {
    return const MetadataFieldSchema(
      schemaVersion: 1,
      fields: [
        MetadataFieldSpec(
          key: 'series_tags',
          valueType: 'string_list',
          label: 'Series tags',
          common: false,
          typed: true,
          normalized: true,
          editable: true,
          section: 'relations',
          input: 'text',
          kinds: ['book'],
          ownershipByKind: {
            'book': MetadataFieldOwnership(
              scope: MetadataFieldScope.relations,
              sourceEntityType: 'book_series',
              sourceTable: 'book_series',
              writeTarget: MetadataWriteTarget.coreCanonicalRelation,
            ),
          },
        ),
      ],
      kindFields: {
        'book': ['series_tags']
      },
      sections: ['relations'],
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
        id: 'book-item-1',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        itemNumber: '1',
        canonicalFieldValues: {
          'publisher': 'Allen & Unwin',
          'synopsis': 'The first journey into Middle-earth.',
          'series_id': 'series-book-1',
          'series_title': 'The Lord of the Rings',
          'volume_number': '1',
          'series_tags': lastSeriesTags ?? const ['Fantasy'],
          'subtitle': 'Being the First Part',
          'page_count': 423,
        },
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
