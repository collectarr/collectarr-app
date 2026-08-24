import 'dart:convert';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
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

  @override
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    CatalogMediaKind? kind,
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

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    final response = await client.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode({
        'query': query,
        'variables': {
          'userName': accountId,
          'type': type,
        },
      }),
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    final collection = data?['data']?['MediaListCollection'] as Map?;
    final lists = collection?['lists'] as List? ?? const [];

    final result = <ProviderPersonalEntry>[];
    for (final list in lists) {
      if (list is! Map) continue;
      final entries = list['entries'] as List? ?? const [];
      for (final raw in entries) {
        if (raw is! Map) continue;
        final media = raw['media'] as Map? ?? const {};
        final mediaId = (raw['mediaId'] ?? media['id'])?.toString() ?? '';
        final mediaType = media['type']?.toString();
        final entryKind = mediaType == 'MANGA'
            ? CatalogMediaKind.manga
            : CatalogMediaKind.anime;

        final titleMap = media['title'] as Map? ?? const {};
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
  }) async {
    if (accessToken == null) return;
    const mutation = r'''
mutation ($mediaId: Int, $status: MediaListStatus, $score: Float, $progress: Int, $repeat: Int, $notes: String) {
  SaveMediaListEntry(mediaId: $mediaId, status: $status, score: $score, progress: $progress, repeat: $repeat, notes: $notes) {
    id
    status
    score
    progress
  }
}
''';

    final mediaIdInt = int.tryParse(entry.remoteItemId);
    if (mediaIdInt == null) return;

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
      'Authorization': 'Bearer $accessToken',
    };

    await client.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode({
        'query': mutation,
        'variables': {
          'mediaId': mediaIdInt,
          if (aniListStatus != null) 'status': aniListStatus,
          if (entry.rating != null) 'score': entry.rating,
          if (entry.progress != null) 'progress': entry.progress,
          'repeat': entry.repeatCount,
          if (entry.notes != null) 'notes': entry.notes,
        },
      }),
    );
  }

  @override
  Future<void> deletePersonalEntry({
    required String accountId,
    required String remoteItemId,
    CatalogMediaKind? kind,
  }) async {
    if (accessToken == null) return;
    const mutation = r'''
mutation ($id: Int) {
  DeleteMediaListEntry(id: $id) {
    deleted
  }
}
''';

    final entryIdInt = int.tryParse(remoteItemId);
    if (entryIdInt == null) return;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    await client.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode({
        'query': mutation,
        'variables': {
          'id': entryIdInt,
        },
      }),
    );
  }
}
