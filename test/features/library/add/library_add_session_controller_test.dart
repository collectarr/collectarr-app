import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import '../../../helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late OwnedItemMutations ownedMutations;
  late WishlistMutations wishlistMutations;
  late TrackingMutations trackingMutations;
  late LibraryAddSessionController controller;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    final runner = CollectionMutationRunner(
      database: db,
      events: CollectionEventBus(),
    );
    final catalogCache = CatalogCacheRepository(db);

    ownedMutations = OwnedItemMutations(
      ownedItems: OwnedItemsCacheRepository(db),
      wishlist: WishlistItemsCacheRepository(db),
      catalogCache: catalogCache,
      trackingEntries: TrackingEntriesCacheRepository(db),
      syncQueue: SyncQueueRepository(db),
      mutationRunner: runner,
    );

    wishlistMutations = WishlistMutations(
      wishlist: WishlistItemsCacheRepository(db),
      catalogCache: catalogCache,
      trackingEntries: TrackingEntriesCacheRepository(db),
      trackingUnits: TrackingUnitsCacheRepository(db),
      syncQueue: SyncQueueRepository(db),
      mutationRunner: runner,
    );

    trackingMutations = TrackingMutations(
      trackingEntries: TrackingEntriesCacheRepository(db),
      trackingUnits: TrackingUnitsCacheRepository(db),
      watchSessions: WatchSessionsCacheRepository(db),
      catalogCache: catalogCache,
      ownedItems: OwnedItemsCacheRepository(db),
      syncQueue: SyncQueueRepository(db),
      mutationRunner: runner,
    );

    controller = LibraryAddSessionController(
      kind: CatalogMediaKind.comic,
      ownedMutations: ownedMutations,
      wishlistMutations: wishlistMutations,
      trackingMutations: trackingMutations,
    );
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('LibraryAddSessionController Tests', () {
    test('initial state matches kind and defaults', () {
      expect(controller.state.mode, LibraryAddDialogMode.search);
      expect(controller.state.target, LibraryAddTarget.owned);
      expect(controller.state.manualDraft, isA<ComicAddDraft>());
    });

    test('updates query and cancels search cleanly', () {
      controller.updateQuery('Spider-Man');
      expect(controller.state.search.query, 'Spider-Man');

      controller.cancelSearch();
      expect(controller.state.search.isSearching, false);
    });

    test('selects result and switches mode', () {
      controller.selectResult('item-123');
      expect(controller.state.selection.selectedId, 'item-123');

      controller.setMode(LibraryAddDialogMode.manual);
      expect(controller.state.mode, LibraryAddDialogMode.manual);
    });

    test('manual draft editing updates state', () {
      controller.updateCommonDraft(
        (c) => c.copyWith(condition: 'Mint', rating: 9),
      );
      expect(controller.state.commonDraft.condition, 'Mint');
      expect(controller.state.commonDraft.rating, 9);

      controller.updateKindDraft(
        (k) => (k as ComicAddDraft).copyWith(gradingCompany: 'CGC'),
      );
      final draft = controller.state.manualDraft as ComicAddDraft;
      expect(draft.gradingCompany, 'CGC');
    });

    test('resets controller to initial state', () {
      controller.updateQuery('Batman');
      controller.selectResult('bm-1');
      controller.setMode(LibraryAddDialogMode.manual);

      controller.reset();

      expect(controller.state.search.query, isEmpty);
      expect(controller.state.selection.selectedId, isNull);
      expect(controller.state.mode, LibraryAddDialogMode.search);
    });

    test(
        'submits selected item to owned items using capability command building',
        () async {
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(
          id: 'comic-sub-1',
          kind: 'comic',
          title: 'Amazing Fantasy #15',
        ),
      );

      final success = await controller.submitSelectedItem(item);
      expect(success, true);

      final owned = await db.select(db.ownedItemsCache).getSingle();
      expect(owned.itemId, 'comic-sub-1');
    });

    test('submits item to wishlist target', () async {
      controller.setTarget(LibraryAddTarget.wishlist);
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(
          id: 'comic-wish-1',
          kind: 'comic',
          title: 'Action Comics #1',
        ),
      );

      final success = await controller.submitSelectedItem(item);
      expect(success, true);

      final wishlist = await db.select(db.wishlistItemsCache).getSingle();
      expect(wishlist.itemId, 'comic-wish-1');
    });

    test('submits item to tracking target', () async {
      controller.setTarget(LibraryAddTarget.track);
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(
          id: 'comic-track-1',
          kind: 'comic',
          title: 'Detective Comics #27',
        ),
      );

      final success = await controller.submitSelectedItem(item);
      expect(success, true);

      final tracking = await db.select(db.trackingEntriesCache).getSingle();
      expect(tracking.itemId, 'comic-track-1');
    });

    test('toggleCheckedResult and toggleCheckedProvider update selection', () {
      controller.toggleCheckedResult('res-1');
      expect(controller.state.selection.checkedResultIds, contains('res-1'));

      controller.toggleCheckedResult('res-1');
      expect(controller.state.selection.checkedResultIds, isEmpty);

      controller.toggleCheckedProvider('cand-1');
      expect(controller.state.selection.checkedProviderIds, contains('cand-1'));

      controller.toggleCheckedProvider('cand-1');
      expect(controller.state.selection.checkedProviderIds, isEmpty);
    });

    test(
        'selectProviderCandidate updates selection state and clears result selection',
        () {
      controller.selectResult('res-1');
      expect(controller.state.selection.selectedResultId, 'res-1');

      controller.selectProviderCandidate('prov-cand-1');
      expect(controller.state.selection.selectedProviderCandidateId,
          'prov-cand-1');
      expect(controller.state.selection.selectedResultId, isNull);
    });

    test('reference type selection and configuration', () {
      controller.setReferenceType(LibraryAddReferenceType.edition);
      expect(controller.state.selection.referenceType,
          LibraryAddReferenceType.edition);

      controller.selectReferenceVariant('Variant A');
      expect(
          controller.state.selection.selectedReferenceVariantId, 'Variant A');
    });

    test('empty search sets validation error', () async {
      controller.updateQuery('  ');
      await controller.executeSearch();
      expect(controller.state.search.error, isNotNull);
      expect(controller.state.search.isSearching, false);
    });

    test('video kind defaults do not count as search input', () async {
      final movieController = LibraryAddSessionController(
        kind: CatalogMediaKind.movie,
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
      );
      addTearDown(movieController.dispose);

      await movieController.executeSearch();

      expect(movieController.state.search.error, isNotNull);
      expect(movieController.state.search.isSearching, false);
    });

    test('selectSuggestion updates query and selects suggestion', () {
      final suggestion = LibraryMetadataItem.fromMetadataMap({
        'id': 'sugg-1',
        'kind': 'comic',
        'title': 'Daredevil',
      });

      controller.selectSuggestion(suggestion);

      expect(controller.state.search.query, 'Daredevil');
      expect(controller.state.selection.selectedResultId, 'sugg-1');
      expect(controller.state.search.showSuggestions, false);
    });

    test('advanced search fields update state', () {
      const seriesId = LibraryAddFilterId('comic.series');
      const issueId = LibraryAddFilterId('comic.issue');
      const publisherId = LibraryAddFilterId('comic.publisher');
      const yearId = LibraryAddFilterId('comic.year');
      controller.updateAdvancedFilter(seriesId, 'X-Men');
      controller.updateAdvancedFilter(issueId, '1');
      controller.updateAdvancedFilter(publisherId, 'Marvel');
      controller.updateAdvancedFilter(yearId, '1963');
      controller.toggleAdvancedSearch();

      expect(controller.state.search.advancedFilters[seriesId], 'X-Men');
      expect(controller.state.search.advancedFilters[issueId], '1');
      expect(controller.state.search.advancedFilters[publisherId], 'Marvel');
      expect(controller.state.search.advancedFilters[yearId], '1963');
      expect(controller.state.search.showAdvancedSearch, true);
    });

    test('defaults configuration updates state', () {
      final now = DateTime.now();
      controller.setDefaultCondition('Fine');
      controller.setDefaultGrade('9.8');
      controller.setDefaultPurchaseDate(now);
      controller.setDefaultLocationId('loc-1');
      controller.setDefaultReadStatus('read');
      controller.setDefaultTags('key,rare');
      controller.setPhysicalFormatId('cgc_slab');

      expect(controller.state.defaultCondition, 'Fine');
      expect(controller.state.defaultGrade, '9.8');
      expect(controller.state.defaultPurchaseDate, now);
      expect(controller.state.defaultLocationId, 'loc-1');
      expect(controller.state.defaultReadStatus, 'read');
      expect(controller.state.defaultTags, 'key,rare');
      expect(controller.state.physicalFormatId, 'cgc_slab');
    });
  });

  group('Kind-Specific Add Draft to Command Capability Tests', () {
    test('ComicAddDraft produces valid AddOwnedItemCommand', () {
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(id: 'c1', kind: 'comic', title: 'Comic 1'),
      );
      const common = LibraryAddCommonDraft(condition: 'NM', rating: 10);
      const draft = ComicAddDraft(gradingCompany: 'CBCS', signedBy: 'Stan Lee');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.comic).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'c1');
      expect(command.common.condition, 'NM');
      expect(command.details.toDetails().comic?.gradingCompany, 'CBCS');
      expect(command.details.toDetails().comic?.signedBy, 'Stan Lee');
    });

    test('MovieAddDraft produces valid AddOwnedItemCommand', () {
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(id: 'v1', kind: 'movie', title: 'Video 1'),
      );
      const common = LibraryAddCommonDraft(condition: 'New');
      const draft = MovieAddDraft(packaging: 'SteelBook', region: 'Region A');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.movie).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'v1');
      expect(command.details.toDetails().movie?.packaging, 'SteelBook');
      expect(command.details.toDetails().movie?.region, 'Region A');
    });

    test('GameAddDraft produces valid AddOwnedItemCommand', () {
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(id: 'g1', kind: 'game', title: 'Game 1'),
      );
      const common = LibraryAddCommonDraft(quantity: 2);
      const draft = GameAddDraft(completeness: 'CIB', hasBox: true);

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.game).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'g1');
      expect(command.details.toDetails().game?.completeness, 'CIB');
      expect(command.details.toDetails().game?.hasBox, true);
    });

    test('MusicAddDraft produces valid AddOwnedItemCommand', () {
      final item = LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(id: 'm1', kind: 'music', title: 'Music 1'),
      );
      const common = LibraryAddCommonDraft();
      const draft = MusicAddDraft(storageDevice: 'Shelf A', storageSlot: '12');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.music).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'm1');
      expect(command.details.toDetails().music?.storageDevice, 'Shelf A');
      expect(command.details.toDetails().music?.storageSlot, '12');
    });

    test(
        'runLibraryAddProviderSearch uses ProviderRegistry and isolates broken provider',
        () async {
      final registry = InMemoryProviderRegistry();

      final goodProvider = _MockProvider(
        name: 'good_prov',
        kind: 'comic',
        searchHandler: (query, {kind, limit = 25}) async => [
          ProviderSearchResult(
            provider: 'good_prov',
            providerItemId: 'item-good-1',
            title: 'Good Result for $query',
            kind: 'comic',
          ),
        ],
      );

      final brokenProvider = _MockProvider(
        name: 'broken_prov',
        kind: 'comic',
        searchHandler: (query, {kind, limit = 25}) async =>
            throw Exception('Broken network connection!'),
      );

      registry.register(goodProvider.toConnector());
      registry.register(brokenProvider.toConnector());

      final sessionController = LibraryAddSessionController(
        kind: CatalogMediaKind.comic,
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
        providerRegistry: registry,
      );

      final results = await runLibraryAddProviderSearch(
        type: libraryKindRuntimeForKind(CatalogMediaKind.comic),
        provider: 'all',
        query: 'Batman',
        ranking: libraryKindRuntimeForKind(CatalogMediaKind.comic)
            .add
            .search
            .ranking,
        searchContext: LibraryAddSearchContext(query: 'Batman'),
        providerRegistry: registry,
      );

      expect(results, hasLength(1));
      expect(results.first.provider, 'good_prov');
      expect(results.first.title, 'Good Result for Batman');

      sessionController.dispose();
    });

    test(
        'selectProviderCandidate fetches preview from ProviderRegistry and converts via mapper',
        () async {
      final registry = InMemoryProviderRegistry();

      final testProvider = _MockProvider(
        name: 'test_prov',
        kind: 'book',
        searchHandler: (query, {kind, limit = 25}) async => [
          const ProviderSearchResult(
            provider: 'test_prov',
            providerItemId: 'book-42',
            title: 'Hitchhiker Guide',
            kind: 'book',
          ),
        ],
        fetchHandler: (id, {kind}) async => NormalizedProviderEnvelopeV1(
          schemaVersion: 'v1',
          provider: 'test_prov',
          providerItemId: id,
          kind: 'book',
          normalized: {
            'title': 'The Hitchhiker\'s Guide to the Galaxy',
            'publisher': 'Pan Books',
            'synopsis': 'Don\'t Panic.',
            'genres': ['Sci-Fi', 'Comedy'],
            'creators': [
              {'name': 'Douglas Adams', 'role': 'Author'}
            ],
            'page_count': 224,
          },
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
            sourceUrl: 'https://example.com/books/42',
            rawPayloadHash: 'hash42',
            providerVersion: '1.0.0',
          ),
          images: const [],
          attribution: const ProviderAttribution(
            required: true,
            text: 'Data by TestProv',
          ),
        ),
      );

      registry.register(testProvider.toConnector());

      final sessionController = LibraryAddSessionController(
        kind: CatalogMediaKind.book,
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
        providerRegistry: registry,
      );

      const candidate = ProviderCandidate(
        provider: 'test_prov',
        providerItemId: 'book-42',
        title: 'The Hitchhiker\'s Guide to the Galaxy',
        kind: 'book',
      );

      sessionController.state = sessionController.state.copyWith(
        search: sessionController.state.search.copyWith(
          providerResults: [candidate],
        ),
      );

      sessionController.selectProviderCandidate(candidate.localCatalogId);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final preview = sessionController.state.preview
          .providerPreviewFor(candidate.localCatalogId);
      expect(preview, isNotNull);
      expect(preview!.title, 'The Hitchhiker\'s Guide to the Galaxy');
      expect(preview.publisher, 'Pan Books');
      expect(preview.synopsis, 'Don\'t Panic.');
      expect(preview.genres, containsAll(['Sci-Fi', 'Comedy']));
      expect(preview.creators, hasLength(1));
      expect(preview.creators.first.name, 'Douglas Adams');

      sessionController.dispose();
    });

    test(
        'submitCurrentSelection performs local add without Core ingest using deterministic provisional identity',
        () async {
      final registry = InMemoryProviderRegistry();

      final comicProvider = _MockProvider(
        name: 'comic_prov',
        kind: 'comic',
        searchHandler: (query, {kind, limit = 25}) async => [
          const ProviderSearchResult(
            provider: 'comic_prov',
            providerItemId: 'c-99',
            title: 'Action Comics #1',
            kind: 'comic',
          ),
        ],
        fetchHandler: (id, {kind}) async => NormalizedProviderEnvelopeV1(
          schemaVersion: 'v1',
          provider: 'comic_prov',
          providerItemId: id,
          kind: 'comic',
          normalized: {
            'title': 'Action Comics #1',
            'publisher': 'DC Comics',
            'synopsis': 'The first appearance of Superman.',
            'genres': ['Superhero'],
            'creators': [
              {'name': 'Jerry Siegel', 'role': 'Writer'},
              {'name': 'Joe Shuster', 'role': 'Artist'},
            ],
          },
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
            sourceUrl: 'https://example.com/comics/99',
            rawPayloadHash: 'hash99',
            providerVersion: '1.0.0',
          ),
          images: const [],
          attribution: const ProviderAttribution(
            required: true,
            text: 'Data by ComicProv',
          ),
        ),
      );

      registry.register(comicProvider.toConnector());

      final catalog = CatalogCacheRepository(db);

      final sessionController = LibraryAddSessionController(
        kind: CatalogMediaKind.comic,
        ownedMutations: ownedMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
        catalog: catalog,
        providerRegistry: registry,
      );

      const candidate = ProviderCandidate(
        provider: 'comic_prov',
        providerItemId: 'c-99',
        title: 'Action Comics #1',
        kind: 'comic',
        publisher: 'DC Comics',
      );

      sessionController.state = sessionController.state.copyWith(
        search: sessionController.state.search.copyWith(
          providerResults: [candidate],
        ),
      );

      // Select candidate and ensure preview loads
      sessionController.selectProviderCandidate(candidate.localCatalogId);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
          sessionController.state.preview
              .providerPreviewFor(candidate.localCatalogId),
          isNotNull);

      // Submit to owned locally without Core (api is null)
      final success = await sessionController.submitCurrentSelection();
      expect(success, isTrue);

      // Verify item exists in local database and catalog cache with deterministic provisional identity
      final expectedProvisionalId = candidate.localCatalogId;
      final cachedItem = await catalog.findById(expectedProvisionalId);
      expect(cachedItem, isNotNull);
      expect(cachedItem!.id, expectedProvisionalId);
      expect(cachedItem.title, 'Action Comics #1');
      expect(cachedItem.payload['publisher'], 'DC Comics');

      // Verify owned item record exists in DB
      final ownedItem = await db.managers.ownedItemsCache
          .filter((f) => f.itemId.equals(expectedProvisionalId))
          .getSingleOrNull();
      expect(ownedItem, isNotNull);
      expect(ownedItem!.itemId, expectedProvisionalId);

      sessionController.dispose();
    });
  });
}

class _MockProvider implements MetadataProvider, MetadataCapability {
  _MockProvider({
    required this.name,
    required this.kind,
    this.searchHandler,
    this.fetchHandler,
  });

  @override
  final String name;
  final String kind;
  final Future<List<ProviderSearchResult>> Function(String query,
      {String? kind, int limit})? searchHandler;
  final Future<NormalizedProviderEnvelopeV1> Function(String id,
      {String? kind})? fetchHandler;

  @override
  ProviderDescriptor get descriptor => ProviderDescriptor(
        name: name,
        displayName: name,
        kind: kind,
        supportedKinds: [kind],
        supportsSearch: true,
        supportsIngest: true,
      );

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage => 'Configured';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    Object? kind,
    int limit = 25,
  }) async {
    if (searchHandler != null) {
      return searchHandler!(query, kind: kind?.toString(), limit: limit);
    }
    return [];
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    Object? kind,
  }) async {
    if (fetchHandler != null) {
      return fetchHandler!(providerItemId, kind: kind?.toString());
    }
    throw UnimplementedError();
  }

  ProviderConnector toConnector() => ProviderConnector(
        id: ProviderId.fromValue(name) ?? ProviderId.comicVine,
        descriptor: descriptor,
        metadata: this,
      );
}

extension on ComicAddDraft {
  ComicAddDraft copyWith({
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? customLabel,
    String? pageQuality,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
    int? coverPriceCents,
  }) {
    return ComicAddDraft(
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      customLabel: customLabel ?? this.customLabel,
      pageQuality: pageQuality ?? this.pageQuality,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
    );
  }
}
