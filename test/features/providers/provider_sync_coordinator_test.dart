import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/engine/provider_sync_coordinator.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockPersonalReadWrite
    implements PersonalListReadCapability, PersonalListWriteCapability {
  _MockPersonalReadWrite() : remoteEntries = const [];

  List<ProviderPersonalEntry> remoteEntries;
  final List<ProviderPersonalEntry> writtenEntries = [];
  final List<String> deletedItemIds = [];

  @override
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    CatalogMediaKind? kind,
    ProviderAccountContext? context,
  }) async {
    return remoteEntries;
  }

  @override
  Future<void> writePersonalEntry({
    required String accountId,
    required ProviderPersonalEntry entry,
    ProviderAccountContext? context,
  }) async {
    writtenEntries.add(entry);
  }

  @override
  Future<void> deletePersonalEntry({
    required String accountId,
    required String remoteItemId,
    String? remoteEntryId,
    CatalogMediaKind? kind,
    ProviderAccountContext? context,
  }) async {
    deletedItemIds.add(remoteEntryId ?? remoteItemId);
  }
}

void main() {
  group('PR 21: ProviderSyncCoordinator & End-to-End ExternalStateEngine', () {
    late ExternalStateEngine engine;
    late ProviderConnectorRegistry registry;
    late InMemoryProviderAccountStore accountStore;
    late InMemoryProviderLinkStore linkStore;
    late _MockPersonalReadWrite mockCapability;

    setUp(() {
      engine = const ExternalStateEngine();
      mockCapability = _MockPersonalReadWrite();

      final connector = ProviderConnector(
        id: ProviderId.aniList,
        descriptor: const ProviderDescriptor(
          name: 'anilist',
          displayName: 'AniList',
          kind: 'anime',
          supportedKinds: ['anime', 'manga'],
        ),
        personalRead: mockCapability,
        personalWrite: mockCapability,
      );

      registry = InMemoryProviderConnectorRegistry([connector]);

      accountStore = InMemoryProviderAccountStore();
      linkStore = InMemoryProviderLinkStore();
    });

    test(
        'pullAccount performs 3-way diff (BASE, LOCAL, REMOTE) and applies remote changes',
        () async {
      const account = ProviderAccount(
        id: 'acc-1',
        provider: ProviderId.aniList,
        displayName: 'Test User',
        authType: ProviderAuthType.accessToken,
        remoteAccountId: '100',
        remoteHandle: 'test_user',
      );
      await accountStore.saveAccount(account, accessToken: 'token-123');

      const localRef = CatalogEntityRef(
        id: 'local-anime-1',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );

      // BASE snapshot
      const baseEntry = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        remoteEntryId: '1001',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80.0,
        progress: 10,
      );

      // Save initial link with BASE snapshot
      await linkStore.saveLink(
        const ProviderItemLink(
          accountId: 'acc-1',
          provider: ProviderId.aniList,
          remoteItemId: '21',
          remoteEntryId: '1001',
          localEntityRef: localRef,
          baseSnapshot: baseEntry,
        ),
      );

      // REMOTE has progressed to 12
      const remoteEntry = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        remoteEntryId: '1001',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80.0,
        progress: 12,
      );
      mockCapability.remoteEntries = [remoteEntry];

      ProviderPersonalEntry? currentLocal = baseEntry;
      MutationOrigin? appliedOrigin;

      final coordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
        localStateReader: (ref) async => currentLocal,
        localStateApplier: (ref, entry, origin) async {
          currentLocal = entry;
          appliedOrigin = origin;
        },
      );

      final result = await coordinator.pullAccount(accountId: 'acc-1');

      expect(result.pulledCount, 1);
      expect(result.appliedCount, 1);
      expect(result.conflictCount, 0);
      expect(currentLocal?.progress, 12);
      expect(appliedOrigin?.source, MutationSourceType.externalProvider);
      expect(appliedOrigin?.provider, ProviderId.aniList);

      // Verify link baseSnapshot updated
      final updatedLink = await linkStore.getLinkByRemoteId('acc-1', '21');
      expect(updatedLink?.baseSnapshot?.progress, 12);
      expect(updatedLink?.lastPulledAt, isNotNull);
    });

    test(
        'Echo Prevention: handleLocalMutation suppresses push if mutation came from externalProvider',
        () async {
      const account = ProviderAccount(
        id: 'acc-1',
        provider: ProviderId.aniList,
        displayName: 'Test User',
        authType: ProviderAuthType.accessToken,
      );
      await accountStore.saveAccount(account, accessToken: 'token-123');

      const localRef = CatalogEntityRef(
        id: 'local-anime-1',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );

      await linkStore.saveLink(
        const ProviderItemLink(
          accountId: 'acc-1',
          provider: ProviderId.aniList,
          remoteItemId: '21',
          localEntityRef: localRef,
        ),
      );

      final coordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
      );

      const modifiedLocal = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.completed,
      );

      // Case 1: Mutation originated from externalProvider -> DO NOT PUSH BACK
      final pushedExternal = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: modifiedLocal,
        origin: MutationOrigin.externalProvider(ProviderId.aniList),
      );
      expect(pushedExternal, isFalse);
      expect(mockCapability.writtenEntries, isEmpty);

      final pushedFileImport = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: modifiedLocal,
        origin: MutationOrigin.fileImport,
      );
      expect(pushedFileImport, isFalse);
      expect(mockCapability.writtenEntries, isEmpty);

      final pushedUser = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: modifiedLocal,
        origin: MutationOrigin.user,
      );
      expect(pushedUser, isTrue);
      expect(mockCapability.writtenEntries, hasLength(1));
      expect(mockCapability.writtenEntries.first.status,
          ProviderEntryStatus.completed);

      // Verify link baseSnapshot was updated upon push
      final updatedLink = await linkStore.getLinkByRemoteId('acc-1', '21');
      expect(updatedLink?.baseSnapshot?.status, ProviderEntryStatus.completed);
      expect(updatedLink?.lastPushedAt, isNotNull);
    });

    test('linkImportedItem establishes ProviderItemLink with baseSnapshot',
        () async {
      final coordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
      );

      const localRef = CatalogEntityRef(
        id: 'local-anime-55',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );

      const entry = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '55',
        remoteEntryId: '9988',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.completed,
        rating: 90.0,
      );

      final link = await coordinator.linkImportedItem(
        accountId: 'acc-1',
        provider: ProviderId.aniList,
        localRef: localRef,
        entry: entry,
      );

      expect(link.accountId, 'acc-1');
      expect(link.remoteItemId, '55');
      expect(link.remoteEntryId, '9988');
      expect(link.baseSnapshot?.rating, 90.0);
      expect(link.lastPulledAt, isNotNull);

      final fetched = await linkStore.getLinkByLocalRef(localRef);
      expect(fetched?.remoteItemId, '55');
      expect(fetched?.baseSnapshot?.status, ProviderEntryStatus.completed);
    });

    test('sync policy filters pull and push fields independently', () async {
      const policy = ProviderSyncPolicy(
        status: SyncDirection.pullOnly,
        rating: SyncDirection.pushOnly,
        progress: SyncDirection.disabled,
        history: SyncDirection.disabled,
        wishlist: SyncDirection.disabled,
      );
      const account = ProviderAccount(
        id: 'acc-policy',
        provider: ProviderId.aniList,
        displayName: 'Policy User',
        authType: ProviderAuthType.accessToken,
        syncPolicy: policy,
      );
      await accountStore.saveAccount(account, accessToken: 'token-123');

      const localRef = CatalogEntityRef(
        id: 'local-anime-policy',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );
      const base = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 80,
        progress: 10,
      );
      await linkStore.saveLink(
        const ProviderItemLink(
          accountId: 'acc-policy',
          provider: ProviderId.aniList,
          remoteItemId: '21',
          localEntityRef: localRef,
          baseSnapshot: base,
        ),
      );
      mockCapability.remoteEntries = [
        const ProviderPersonalEntry(
          provider: ProviderId.aniList,
          remoteItemId: '21',
          kind: CatalogMediaKind.anime,
          status: ProviderEntryStatus.completed,
          rating: 90,
          progress: 11,
        ),
      ];

      ProviderPersonalEntry? localEntry = const ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 85,
        progress: 12,
      );
      final coordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
        localStateReader: (ref) async => localEntry,
        localStateApplier: (ref, entry, origin) async {
          localEntry = entry;
        },
      );

      final pull = await coordinator.pullAccount(accountId: 'acc-policy');

      expect(pull.appliedCount, 1);
      expect(localEntry?.status, ProviderEntryStatus.completed);
      expect(localEntry?.rating, 85);
      expect(localEntry?.progress, 12);

      final pushed = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: const ProviderPersonalEntry(
          provider: ProviderId.aniList,
          remoteItemId: '21',
          kind: CatalogMediaKind.anime,
          status: ProviderEntryStatus.dropped,
          rating: 85,
          progress: 12,
        ),
        origin: MutationOrigin.user,
      );

      expect(pushed, isTrue);
      expect(mockCapability.writtenEntries.single.status,
          ProviderEntryStatus.completed);
      expect(mockCapability.writtenEntries.single.rating, 85);
      expect(mockCapability.writtenEntries.single.progress, 11);
    });
  });
}
