import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/adapters/anilist/anilist_sync_adapter.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/engine/provider_sync_coordinator.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_http_client.dart';
import 'package:collectarr_app/features/providers/runtime/provider_rate_limiter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('PR 22: AniList Production Vertical Slice', () {
    late Dio dio;
    late ProviderHttpClient httpClient;
    late AniListSyncAdapter syncAdapter;
    late ProviderConnectorRegistry registry;
    late InMemoryProviderAccountStore accountStore;
    late InMemoryProviderLinkStore linkStore;
    late ExternalStateEngine engine;
    late ProviderSyncCoordinator coordinator;

    final List<Map<String, dynamic>> recordedRequests = [];

    setUp(() {
      recordedRequests.clear();
      dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        final body = options.data is Map
            ? options.data as Map<String, dynamic>
            : (options.data is String
                ? jsonDecode(options.data.toString()) as Map<String, dynamic>
                : <String, dynamic>{});
        recordedRequests.add(body);

        final query = body['query']?.toString() ?? '';

        if (query.contains('Viewer')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'Viewer': {
                  'id': 12345,
                  'name': 'otaku_hero',
                  'avatar': {'large': 'https://example.com/avatar.jpg'}
                }
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        if (query.contains('MediaListCollection')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'MediaListCollection': {
                  'lists': [
                    {
                      'name': 'Watching',
                      'entries': [
                        {
                          'id': 888999, // list entry ID
                          'mediaId': 21, // One Piece anime
                          'status': 'CURRENT',
                          'score': 90,
                          'progress': 1050,
                          'media': {
                            'id': 21,
                            'type': 'ANIME',
                            'title': {'romaji': 'One Piece'},
                            'episodes': 1100,
                          }
                        }
                      ]
                    }
                  ]
                }
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        if (query.contains('SaveMediaListEntry')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'SaveMediaListEntry': {
                  'id': 888999,
                  'mediaId': 21,
                  'status': 'COMPLETED',
                  'score': 95,
                  'progress': 1100,
                }
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        if (query.contains('DeleteMediaListEntry')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'DeleteMediaListEntry': {'deleted': true}
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        return ResponseBody.fromString('{}', 404);
      });

      httpClient = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'anilist',
          maxRequests: 90,
          interval: const Duration(minutes: 1),
        ),
      );

      syncAdapter = AniListSyncAdapter(client: httpClient);

      final connector = ProviderConnector(
        id: ProviderId.aniList,
        descriptor: const ProviderDescriptor(
          name: 'anilist',
          displayName: 'AniList',
          kind: 'anime',
          supportedKinds: ['anime', 'manga'],
        ),
        personalRead: syncAdapter,
        personalWrite: syncAdapter,
      );

      registry = InMemoryProviderConnectorRegistry([connector]);
      accountStore = InMemoryProviderAccountStore();
      linkStore = InMemoryProviderLinkStore();
      engine = const ExternalStateEngine();

      coordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
      );
    });

    test('Step 1: Auth & fetchViewer resolves remote account profile', () async {
      final account = await syncAdapter.fetchViewer(token: 'oauth-test-token');

      expect(account, isNotNull);
      expect(account!.id, 'anilist-12345');
      expect(account.remoteAccountId, '12345');
      expect(account.remoteHandle, 'otaku_hero');
      expect(account.avatarUrl, 'https://example.com/avatar.jpg');
      expect(account.enabledCapabilities, contains('personalRead'));
      expect(account.enabledCapabilities, contains('personalWrite'));

      await accountStore.saveAccount(account, accessToken: 'oauth-test-token');
      final stored = await accountStore.getAccount('anilist-12345');
      expect(stored?.remoteHandle, 'otaku_hero');
    });

    test('Step 2 & 3: Pull account sync, 3-way diff, and link persistence', () async {
      final account = await syncAdapter.fetchViewer(token: 'oauth-test-token');
      await accountStore.saveAccount(account!, accessToken: 'oauth-test-token');

      const localRef = CatalogEntityRef(
        id: 'local-work-21',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );

      // Pre-link catalog item
      await coordinator.linkImportedItem(
        accountId: account.id,
        provider: ProviderId.aniList,
        localRef: localRef,
        entry: const ProviderPersonalEntry(
          provider: ProviderId.aniList,
          remoteItemId: '21',
          remoteEntryId: '888999',
          kind: CatalogMediaKind.anime,
          status: ProviderEntryStatus.planning,
          progress: 0,
        ),
      );

      ProviderPersonalEntry? localEntry = const ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        remoteEntryId: '888999',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.planning,
        progress: 0,
      );

      final fullCoordinator = ProviderSyncCoordinator(
        engine: engine,
        registry: registry,
        accountStore: accountStore,
        linkStore: linkStore,
        localStateReader: (ref) async => localEntry,
        localStateApplier: (ref, remote, origin) async {
          localEntry = remote;
        },
      );

      final result = await fullCoordinator.pullAccount(accountId: account.id);

      expect(result.pulledCount, 1);
      expect(result.appliedCount, 1);
      expect(result.conflictCount, 0);

      // Local state was updated to remote
      expect(localEntry?.status, ProviderEntryStatus.current);
      expect(localEntry?.progress, 1050);

      // Provider link base snapshot was updated to remote
      final link = await linkStore.getLinkByRemoteId(account.id, '21');
      expect(link?.baseSnapshot?.status, ProviderEntryStatus.current);
      expect(link?.baseSnapshot?.progress, 1050);
      expect(link?.lastPulledAt, isNotNull);
    });

    test('Step 4 & 5: Push mutation and echo suppression', () async {
      final account = await syncAdapter.fetchViewer(token: 'oauth-test-token');
      await accountStore.saveAccount(account!, accessToken: 'oauth-test-token');

      const localRef = CatalogEntityRef(
        id: 'local-work-21',
        kind: 'anime',
        entityType: CatalogEntityType.work,
      );

      await coordinator.linkImportedItem(
        accountId: account.id,
        provider: ProviderId.aniList,
        localRef: localRef,
        entry: const ProviderPersonalEntry(
          provider: ProviderId.aniList,
          remoteItemId: '21',
          remoteEntryId: '888999',
          kind: CatalogMediaKind.anime,
          status: ProviderEntryStatus.current,
          progress: 1050,
        ),
      );

      const userUpdate = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21',
        remoteEntryId: '888999',
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.completed,
        rating: 95.0,
        progress: 1100,
      );

      // Echo suppression: mutation from externalProvider is NOT pushed
      final echoPush = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: userUpdate,
        origin: MutationOrigin.externalProvider(ProviderId.aniList),
      );
      expect(echoPush, isFalse);

      // User mutation IS pushed
      final userPush = await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: userUpdate,
        origin: MutationOrigin.user,
      );
      expect(userPush, isTrue);

      final saveCall = recordedRequests.firstWhere((r) => r['query'].toString().contains('SaveMediaListEntry'));
      expect(saveCall['variables']['id'], 888999);
      expect(saveCall['variables']['mediaId'], 21);
      expect(saveCall['variables']['status'], 'COMPLETED');
      expect(saveCall['variables']['score'], 95.0);
      expect(saveCall['variables']['progress'], 1100);

      // Base snapshot was updated after push
      final link = await linkStore.getLinkByRemoteId(account.id, '21');
      expect(link?.baseSnapshot?.status, ProviderEntryStatus.completed);
      expect(link?.lastPushedAt, isNotNull);
    });

    test('Step 6: Deletion with listEntryId', () async {
      await syncAdapter.deletePersonalEntry(
        accountId: 'anilist-12345',
        remoteItemId: '21',
        remoteEntryId: '888999',
        context: const ProviderAccountContext(
          accountId: 'anilist-12345',
          provider: ProviderId.aniList,
          accessToken: 'oauth-test-token',
        ),
      );

      final deleteCall = recordedRequests.firstWhere((r) => r['query'].toString().contains('DeleteMediaListEntry'));
      expect(deleteCall['variables']['id'], 888999);
      expect(deleteCall['variables']['id'], isNot(equals(21)));
    });
  });
}
