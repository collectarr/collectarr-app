import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
      final item = CatalogItem(
        id: 'comic-sub-1',
        kind: 'comic',
        title: 'Amazing Fantasy #15',
      );

      final success = await controller.submitSelectedItem(item);
      expect(success, true);

      final owned = await db.select(db.ownedItemsCache).getSingle();
      expect(owned.itemId, 'comic-sub-1');
    });

    test('submits item to wishlist target', () async {
      controller.setTarget(LibraryAddTarget.wishlist);
      final item = CatalogItem(
        id: 'comic-wish-1',
        kind: 'comic',
        title: 'Action Comics #1',
      );

      final success = await controller.submitSelectedItem(item);
      expect(success, true);

      final wishlist = await db.select(db.wishlistItemsCache).getSingle();
      expect(wishlist.itemId, 'comic-wish-1');
    });

    test('submits item to tracking target', () async {
      controller.setTarget(LibraryAddTarget.track);
      final item = CatalogItem(
        id: 'comic-track-1',
        kind: 'comic',
        title: 'Detective Comics #27',
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

    test('selectSuggestion updates query and selects suggestion', () {
      final suggestion = LibraryMetadataItem(
        id: 'sugg-1',
        kind: 'comic',
        title: 'Daredevil',
      );

      controller.selectSuggestion(suggestion);

      expect(controller.state.search.query, 'Daredevil');
      expect(controller.state.selection.selectedResultId, 'sugg-1');
      expect(controller.state.search.showSuggestions, false);
    });

    test('advanced search fields update state', () {
      controller.updateSearchSeries('X-Men');
      controller.updateSearchNumber('1');
      controller.updateSearchPublisher('Marvel');
      controller.updateSearchYear('1963');
      controller.toggleAdvancedSearch();

      expect(controller.state.search.series, 'X-Men');
      expect(controller.state.search.number, '1');
      expect(controller.state.search.publisher, 'Marvel');
      expect(controller.state.search.year, '1963');
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
      final item = CatalogItem(id: 'c1', kind: 'comic', title: 'Comic 1');
      const common = LibraryAddCommonDraft(condition: 'NM', rating: 10);
      const draft = ComicAddDraft(gradingCompany: 'CBCS', signedBy: 'Stan Lee');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.comic).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'c1');
      expect(command.common.condition, 'NM');
      expect(command.details.toDetails().comic?.gradingCompany, 'CBCS');
      expect(command.details.toDetails().comic?.signedBy, 'Stan Lee');
    });

    test('VideoAddDraft produces valid AddOwnedItemCommand', () {
      final item = CatalogItem(id: 'v1', kind: 'movie', title: 'Video 1');
      const common = LibraryAddCommonDraft(condition: 'New');
      const draft = VideoAddDraft(packaging: 'SteelBook', region: 'Region A');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.movie).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'v1');
      expect(command.details.toDetails().video?.packaging, 'SteelBook');
      expect(command.details.toDetails().video?.region, 'Region A');
    });

    test('GameAddDraft produces valid AddOwnedItemCommand', () {
      final item = CatalogItem(id: 'g1', kind: 'game', title: 'Game 1');
      const common = LibraryAddCommonDraft(quantity: 2);
      const draft = GameAddDraft(completeness: 'CIB', hasBox: true);

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.game).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'g1');
      expect(command.details.toDetails().game?.completeness, 'CIB');
      expect(command.details.toDetails().game?.hasBox, true);
    });

    test('MusicAddDraft produces valid AddOwnedItemCommand', () {
      final item = CatalogItem(id: 'm1', kind: 'music', title: 'Music 1');
      const common = LibraryAddCommonDraft();
      const draft = MusicAddDraft(storageDevice: 'Shelf A', storageSlot: '12');

      final cap = libraryKindRuntimeForKind(CatalogMediaKind.music).add;
      final command = cap.buildCommand(item, common, draft);

      expect(command.catalogRef.id, 'm1');
      expect(command.details.toDetails().music?.storageDevice, 'Shelf A');
      expect(command.details.toDetails().music?.storageSlot, '12');
    });
  });
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
