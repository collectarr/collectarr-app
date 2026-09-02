import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/adapters/anilist/anilist_sync_adapter.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
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
  group('PR 20: Provider Identity Cleanup & AniList Verification', () {
    test(
        'ProviderAccount separates internal ID from remoteAccountId and remoteHandle',
        () {
      const internalId = 'local-uuid-1234';
      final account = ProviderAccount(
        id: internalId,
        provider: ProviderId.aniList,
        displayName: 'My AniList',
        authType: ProviderAuthType.oauth2,
        remoteAccountId: '98765',
        remoteHandle: 'saitama_user',
      );

      expect(account.id, 'local-uuid-1234');
      expect(account.remoteAccountId, '98765');
      expect(account.remoteHandle, 'saitama_user');
      expect(account.username, 'saitama_user');

      final json = account.toJson();
      expect(json['id'], 'local-uuid-1234');
      expect(json['remoteAccountId'], '98765');
      expect(json['remoteHandle'], 'saitama_user');

      final restored = ProviderAccount.fromJson(json);
      expect(restored.id, 'local-uuid-1234');
      expect(restored.remoteAccountId, '98765');
      expect(restored.remoteHandle, 'saitama_user');
    });

    test('ProviderAccountContext carries context into capability calls', () {
      const context = ProviderAccountContext(
        accountId: 'acc-uuid-1',
        provider: ProviderId.aniList,
        remoteAccountId: '98765',
        remoteHandle: 'saitama_user',
        accessToken: 'secret-token-xyz',
      );

      expect(context.accountId, 'acc-uuid-1');
      expect(context.remoteAccountId, '98765');
      expect(context.remoteHandle, 'saitama_user');
      expect(context.accessToken, 'secret-token-xyz');
    });

    test('readPersonalList distinguishes mediaId vs listEntryId', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'MediaListCollection': {
                'lists': [
                  {
                    'name': 'Watching',
                    'entries': [
                      {
                        'id': 777888999, // list entry ID
                        'mediaId': 21, // entity media ID (One Piece)
                        'status': 'CURRENT',
                        'score': 95,
                        'progress': 1050,
                        'media': {
                          'id': 21,
                          'idMal': 21,
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
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'anilist',
          maxRequests: 90,
          interval: const Duration(minutes: 1),
        ),
      );

      final adapter = AniListSyncAdapter(client: client, accessToken: 'token');
      final entries = await adapter.readPersonalList(
        accountId: 'local-acc-id',
        context: const ProviderAccountContext(
          accountId: 'local-acc-id',
          provider: ProviderId.aniList,
          remoteHandle: 'saitama',
        ),
      );

      expect(entries, hasLength(1));
      final entry = entries.first;

      // Entity ID is mediaId (21)
      expect(entry.remoteItemId, '21');
      // List Entry ID is 777888999
      expect(entry.remoteEntryId, '777888999');
      // mediaId != listEntryId
      expect(entry.remoteItemId, isNot(equals(entry.remoteEntryId)));
      expect(entry.title, 'One Piece');
      expect(entry.status, ProviderEntryStatus.current);
      expect(entry.rating, 95.0);
      expect(entry.progress, 1050);
    });

    test('SaveMediaListEntry sends both id (list entry ID) and mediaId',
        () async {
      Map<String, dynamic>? sentVariables;
      String? sentQuery;

      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        final body = options.data is Map
            ? options.data as Map<String, dynamic>
            : jsonDecode(options.data.toString()) as Map<String, dynamic>;
        sentQuery = body['query']?.toString();
        sentVariables = body['variables'] as Map<String, dynamic>?;

        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'SaveMediaListEntry': {
                'id': 777888999,
                'mediaId': 21,
                'status': 'CURRENT',
                'score': 90,
                'progress': 1050,
              }
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'anilist',
          maxRequests: 90,
          interval: const Duration(minutes: 1),
        ),
      );

      final adapter = AniListSyncAdapter(client: client);
      const entry = ProviderPersonalEntry(
        provider: ProviderId.aniList,
        remoteItemId: '21', // mediaId
        remoteEntryId: '777888999', // listEntryId
        kind: CatalogMediaKind.anime,
        status: ProviderEntryStatus.current,
        rating: 90.0,
        progress: 1050,
      );

      await adapter.writePersonalEntry(
        accountId: 'local-acc-id',
        entry: entry,
        context: const ProviderAccountContext(
          accountId: 'local-acc-id',
          provider: ProviderId.aniList,
          accessToken: 'test-token',
        ),
      );

      expect(sentQuery, contains('SaveMediaListEntry'));
      expect(sentVariables?['id'], 777888999);
      expect(sentVariables?['mediaId'], 21);
      expect(sentVariables?['status'], 'CURRENT');
      expect(sentVariables?['score'], 90.0);
      expect(sentVariables?['progress'], 1050);
    });

    test('DeleteMediaListEntry sends list entry ID () and NOT mediaId',
        () async {
      Map<String, dynamic>? sentVariables;
      String? sentQuery;

      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        final body = options.data is Map
            ? options.data as Map<String, dynamic>
            : jsonDecode(options.data.toString()) as Map<String, dynamic>;
        sentQuery = body['query']?.toString();
        sentVariables = body['variables'] as Map<String, dynamic>?;

        return ResponseBody.fromString(
          jsonEncode({
            'data': {
              'DeleteMediaListEntry': {
                'deleted': true,
              }
            }
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'anilist',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'anilist',
          maxRequests: 90,
          interval: const Duration(minutes: 1),
        ),
      );

      final adapter = AniListSyncAdapter(client: client);

      await adapter.deletePersonalEntry(
        accountId: 'local-acc-id',
        remoteItemId: '21', // mediaId
        remoteEntryId: '777888999', // listEntryId
        context: const ProviderAccountContext(
          accountId: 'local-acc-id',
          provider: ProviderId.aniList,
          accessToken: 'test-token',
        ),
      );

      expect(sentQuery, contains('DeleteMediaListEntry'));
      // Verifies that DeleteMediaListEntry sends listEntryId (777888999), NOT mediaId (21)
      expect(sentVariables?['id'], 777888999);
      expect(sentVariables?['id'], isNot(equals(21)));
    });
  });
}
