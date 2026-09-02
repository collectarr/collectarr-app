import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/runtime/provider_http_client.dart';

class AniListSyncAdapter
    implements PersonalListReadCapability, PersonalListWriteCapability {
  AniListSyncAdapter({
    required this.client,
    this.accessToken,
  });

  final ProviderHttpClient client;
  final String? accessToken;

  static const _endpoint = 'https://graphql.anilist.co';

  /// Fetches the authenticated viewer's profile from AniList.
  Future<ProviderAccount?> fetchViewer({String? token}) async {
    final effectiveToken = token ?? accessToken;
    if (effectiveToken == null) return null;

    const query = r'''
query {
  Viewer {
    id
    name
    avatar {
      large
    }
  }
}

''';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $effectiveToken',
    };

    final response = await client.post<dynamic>(
      _endpoint,
      options: Options(headers: headers),
      data: {'query': query},
    );

    if (response.statusCode != 200) return null;

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>?
            : null);
    final dataPayload = data?['data'];
    final dataMap =
        dataPayload is Map ? Map<String, dynamic>.from(dataPayload) : null;
    final viewerPayload = dataMap?['Viewer'];
    final viewer =
        viewerPayload is Map ? Map<String, dynamic>.from(viewerPayload) : null;
    if (viewer == null) return null;

    final id = _textValue(viewer['id']) ?? '';
    final name = _textValue(viewer['name']) ?? 'AniList User';
    final avatarPayload = viewer['avatar'];
    final avatar = avatarPayload is Map
        ? _textValue(Map<String, dynamic>.from(avatarPayload)['large'])
        : null;

    return ProviderAccount(
      id: 'anilist-$id',
      provider: ProviderId.aniList,
      displayName: name,
      authType: ProviderAuthType.oauth2,
      remoteAccountId: id,
      remoteHandle: name,
      avatarUrl: avatar,
      connectedAt: DateTime.now().toUtc(),
      enabledCapabilities: const {'personalRead', 'personalWrite'},
    );
  }

  @override
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    CatalogMediaKind? kind,
    ProviderAccountContext? context,
  }) async {
    final type = kind == CatalogMediaKind.manga ? 'MANGA' : 'ANIME';
    const query = r'''
query ($userName: String, $type: MediaType) {
  MediaListCollection(userName: $userName, type: $type) {
    lists {
      name
      isCustomList
      entries {
        id
        mediaId
        status
        score(format: POINT_100)
        progress
        progressVolumes
        repeat
        notes
        startedAt {
          year
          month
          day
        }
        completedAt {
          year
          month
          day
        }
        updatedAt
        media {
          id
          idMal
          type
          title {
            romaji
            english
            native
          }
          episodes
          chapters
          volumes
        }
      }
    }
  }
}

''';

    final effectiveUsername =
        context?.remoteHandle ?? context?.remoteAccountId ?? accountId;
    final token = context?.accessToken ?? accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.post<dynamic>(
      _endpoint,
      options: Options(headers: headers),
      data: {
        'query': query,
        'variables': {
          'userName': effectiveUsername,
          'type': type,
        },
      },
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>?
            : (response.data is Map
                ? Map<String, dynamic>.from(response.data as Map)
                : null));
    final dataPayload = data?['data'];
    final dataMap =
        dataPayload is Map ? Map<String, dynamic>.from(dataPayload) : null;
    final collectionPayload = dataMap?['MediaListCollection'];
    final collection = collectionPayload is Map
        ? Map<String, dynamic>.from(collectionPayload)
        : null;
    final lists = collection?['lists'] is List
        ? collection!['lists'] as List<dynamic>
        : const <dynamic>[];

    final result = <ProviderPersonalEntry>[];
    for (final list in lists) {
      if (list is! Map) continue;
      final entries = list['entries'] is List
          ? list['entries'] as List<dynamic>
          : const <dynamic>[];
      for (final raw in entries) {
        if (raw is! Map) continue;
        final rawMap = Map<String, dynamic>.from(raw);
        final listEntryId = _textValue(rawMap['id']);
        final mediaPayload = rawMap['media'];
        final media = mediaPayload is Map
            ? Map<String, dynamic>.from(mediaPayload)
            : const <String, dynamic>{};
        final mediaId = _textValue(rawMap['mediaId'] ?? media['id']) ?? '';
        final mediaType = _textValue(media['type']);
        final entryKind = mediaType == 'MANGA'
            ? CatalogMediaKind.manga
            : CatalogMediaKind.anime;

        final titlePayload = media['title'];
        final titleMap = titlePayload is Map
            ? Map<String, dynamic>.from(titlePayload)
            : const <String, dynamic>{};
        final title =
            (titleMap['romaji'] ?? titleMap['english'] ?? titleMap['native'])
                ?.toString();

        final rawStatus = raw['status']?.toString();
        final status = switch (rawStatus) {
          'CURRENT' => ProviderEntryStatus.current,
          'PLANNING' => ProviderEntryStatus.planning,
          'COMPLETED' => ProviderEntryStatus.completed,
          'DROPPED' => ProviderEntryStatus.dropped,
          'PAUSED' => ProviderEntryStatus.paused,
          'REPEATING' => ProviderEntryStatus.repeating,
          _ => null,
        };

        final score = (raw['score'] as num?)?.toDouble();
        final progress = raw['progress'] as int?;
        final totalProgress = (media['episodes'] ?? media['chapters']) as int?;
        final repeat = (raw['repeat'] as int?) ?? 0;

        DateTime? startedAt;
        if (raw['startedAt'] is Map) {
          final s = raw['startedAt'] as Map;
          if (s['year'] != null && s['month'] != null && s['day'] != null) {
            startedAt =
                DateTime(s['year'] as int, s['month'] as int, s['day'] as int);
          }
        }

        DateTime? completedAt;
        if (raw['completedAt'] is Map) {
          final c = raw['completedAt'] as Map;
          if (c['year'] != null && c['month'] != null && c['day'] != null) {
            completedAt =
                DateTime(c['year'] as int, c['month'] as int, c['day'] as int);
          }
        }

        DateTime? remoteUpdatedAt;
        if (raw['updatedAt'] is int) {
          remoteUpdatedAt = DateTime.fromMillisecondsSinceEpoch(
            (raw['updatedAt'] as int) * 1000,
            isUtc: true,
          );
        }

        final externalIds = <String, String>{
          'anilist': mediaId,
          if (media['idMal'] != null) 'myanimelist': media['idMal'].toString(),
        };

        result.add(
          ProviderPersonalEntry(
            provider: ProviderId.aniList,
            remoteItemId: mediaId,
            remoteEntryId: listEntryId,
            kind: entryKind,
            title: title,
            externalIds: externalIds,
            status: status,
            rating: score,
            progress: progress,
            totalProgress: totalProgress,
            startedAt: startedAt,
            completedAt: completedAt,
            repeatCount: repeat,
            remoteUpdatedAt: remoteUpdatedAt,
            notes: raw['notes']?.toString(),
            rawPayload: Map<String, dynamic>.from(raw),
          ),
        );
      }
    }

    return result;
  }

  @override
  Future<void> writePersonalEntry({
    required String accountId,
    required ProviderPersonalEntry entry,
    ProviderAccountContext? context,
  }) async {
    final token = context?.accessToken ?? accessToken;
    if (token == null) return;
    const mutation = r'''
mutation ($id: Int, $mediaId: Int, $status: MediaListStatus, $score: Float, $progress: Int, $repeat: Int, $notes: String) {
  SaveMediaListEntry(id: $id, mediaId: $mediaId, status: $status, score: $score, progress: $progress, repeat: $repeat, notes: $notes) {
    id
    mediaId
    status
    score
    progress
  }
}
''';

    final mediaIdInt = int.tryParse(entry.remoteItemId);
    final listEntryIdInt =
        entry.remoteEntryId != null ? int.tryParse(entry.remoteEntryId!) : null;
    if (mediaIdInt == null && listEntryIdInt == null) return;

    final aniListStatus = switch (entry.status) {
      ProviderEntryStatus.current => 'CURRENT',
      ProviderEntryStatus.planning => 'PLANNING',
      ProviderEntryStatus.completed => 'COMPLETED',
      ProviderEntryStatus.dropped => 'DROPPED',
      ProviderEntryStatus.paused => 'PAUSED',
      ProviderEntryStatus.repeating => 'REPEATING',
      null => null,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    await client.post<dynamic>(
      _endpoint,
      options: Options(headers: headers),
      data: {
        'query': mutation,
        'variables': {
          if (listEntryIdInt != null) 'id': listEntryIdInt,
          if (mediaIdInt != null) 'mediaId': mediaIdInt,
          if (aniListStatus != null) 'status': aniListStatus,
          if (entry.rating != null) 'score': entry.rating,
          if (entry.progress != null) 'progress': entry.progress,
          'repeat': entry.repeatCount,
          if (entry.notes != null) 'notes': entry.notes,
        },
      },
    );
  }

  @override
  Future<void> deletePersonalEntry({
    required String accountId,
    required String remoteItemId,
    String? remoteEntryId,
    CatalogMediaKind? kind,
    ProviderAccountContext? context,
  }) async {
    final token = context?.accessToken ?? accessToken;
    if (token == null) return;
    const mutation = r'''
mutation ($id: Int) {
  DeleteMediaListEntry(id: $id) {
    deleted
  }
}
''';

    // AniList delete REQUIRES the list entry ID ($id), NOT the mediaId!
    final targetId = remoteEntryId ?? remoteItemId;
    final entryIdInt = int.tryParse(targetId);
    if (entryIdInt == null) return;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    await client.post<dynamic>(
      _endpoint,
      options: Options(headers: headers),
      data: {
        'query': mutation,
        'variables': {
          'id': entryIdInt,
        },
      },
    );
  }
}

String? _textValue(Object? value) {
  return switch (value) {
    String text => text,
    num number => number.toString(),
    bool flag => flag.toString(),
    _ => null,
  };
}
