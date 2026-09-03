import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/credentials/provider_credential_store.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCredentialStore implements ProviderCredentialStore {
  final Map<String, String> values = {};

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  late LocalDatabase database;
  late _MemoryCredentialStore credentials;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
    credentials = _MemoryCredentialStore();
  });

  tearDown(() => database.close());

  test('persists provider account metadata and keeps credentials separate',
      () async {
    final store = DriftProviderAccountStore(
      database: database,
      credentials: credentials,
    );
    final account = ProviderAccount(
      id: 'acc-1',
      provider: ProviderId.aniList,
      displayName: 'AniList account',
      authType: ProviderAuthType.accessToken,
      remoteAccountId: '100',
      username: 'collector',
      connectedAt: DateTime.utc(2026, 9, 3),
      enabledCapabilities: const {'personal_read', 'personal_write'},
      syncPolicy: const ProviderSyncPolicy(
        status: SyncDirection.pullOnly,
        history: SyncDirection.disabled,
      ),
    );

    await store.saveAccount(
      account,
      accessToken: 'secret-token',
      credentials: const {'client_id': 'client-1'},
    );

    final reopened = DriftProviderAccountStore(
      database: database,
      credentials: credentials,
    );
    final persisted = await reopened.getAccount('acc-1');
    final context = await reopened.getAccountContext('acc-1');

    expect(persisted?.provider, ProviderId.aniList);
    expect(persisted?.username, 'collector');
    expect(persisted?.enabledCapabilities, {'personal_read', 'personal_write'});
    expect(persisted?.syncPolicy.status, SyncDirection.pullOnly);
    expect(persisted?.syncPolicy.history, SyncDirection.disabled);
    expect(context?.accessToken, 'secret-token');
    expect(context?.credentials, {'client_id': 'client-1'});

    final row =
        await database.select(database.providerAccountsCache).getSingle();
    expect(row.toString(), isNot(contains('secret-token')));
  });

  test('round-trips provider links and updates their base snapshot', () async {
    final store = DriftProviderLinkStore(database);
    final base = ProviderPersonalEntry(
      provider: ProviderId.aniList,
      remoteItemId: 'remote-21',
      remoteEntryId: 'entry-21',
      kind: CatalogMediaKind.anime,
      title: 'Imported anime',
      status: ProviderEntryStatus.current,
      progress: 4,
      rawPayload: const {'source': 'anilist'},
    );
    final link = ProviderItemLink(
      accountId: 'acc-1',
      provider: ProviderId.aniList,
      remoteItemId: 'remote-21',
      remoteEntryId: 'entry-21',
      localEntityRef: const CatalogEntityRef(
        id: 'anime-21',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      ),
      baseSnapshot: base,
      remoteRevision: 'rev-1',
      metadata: const {'source': 'file-import'},
    );

    await store.saveLink(link);
    final persisted = await store.getLinkByRemoteId('acc-1', 'remote-21');

    expect(persisted?.localEntityRef.entityType, CatalogEntityType.work);
    expect(persisted?.baseSnapshot?.progress, 4);
    expect(persisted?.baseSnapshot?.rawPayload['source'], 'anilist');
    expect(persisted?.remoteRevision, 'rev-1');
    expect(persisted?.metadata['source'], 'file-import');

    await store.updateBaseSnapshot(
      accountId: 'acc-1',
      remoteItemId: 'remote-21',
      baseSnapshot: ProviderPersonalEntry(
        provider: base.provider,
        remoteItemId: base.remoteItemId,
        remoteEntryId: base.remoteEntryId,
        kind: base.kind,
        title: base.title,
        externalIds: base.externalIds,
        status: base.status,
        rating: base.rating,
        progress: 5,
        totalProgress: base.totalProgress,
        startedAt: base.startedAt,
        completedAt: base.completedAt,
        repeatCount: base.repeatCount,
        remoteUpdatedAt: base.remoteUpdatedAt,
        remoteRevision: base.remoteRevision,
        notes: base.notes,
        rawPayload: base.rawPayload,
      ),
      pulledAt: DateTime.utc(2026, 9, 3, 12),
      revision: 'rev-2',
    );
    final updated = await store.getLinkByLocalRef(
      const CatalogEntityRef(
        id: 'anime-21',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      ),
    );

    expect(updated?.baseSnapshot?.progress, 5);
    expect(updated?.lastPulledAt?.toUtc(), DateTime.utc(2026, 9, 3, 12));
    expect(updated?.remoteRevision, 'rev-2');
  });
}
