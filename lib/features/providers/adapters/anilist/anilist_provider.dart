import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/models/normalized_provider_envelope_v1.dart';
import '../../domain/models/provider_attribution.dart';
import '../../domain/models/provider_descriptor.dart';
import '../../domain/models/provider_exception.dart';
import '../../domain/models/provider_image_ref.dart';
import '../../domain/models/provider_provenance.dart';
import '../../domain/models/provider_search_result.dart';
import '../../runtime/provider_http_client.dart';
import '../../runtime/provider_rate_limiter.dart';
import '../provider_adapter.dart';
import 'models/anilist_media.dart';

final RegExp _htmlTagRegex = RegExp(r'<[^>]+>');

const String _mediaFields = '''
id
idMal
siteUrl
type
title {
  romaji
  english
  native
}
description(asHtml: false)
format
status
averageScore
chapters
volumes
episodes
duration
startDate {
  year
  month
  day
}
coverImage {
  large
  medium
}
genres
trailer {
  id
  site
  thumbnail
}
externalLinks {
  site
  url
}
staff(perPage: 10) {
  edges {
    role
    node {
      name {
        full
      }
      siteUrl
    }
  }
}
characters(perPage: 10) {
  edges {
    role
    node {
      name {
        full
      }
      siteUrl
      image {
        large
        medium
      }
    }
  }
}
relations {
  edges {
    relationType
    node {
      id
      type
      format
      title {
        romaji
        english
        native
      }
      startDate {
        year
      }
      coverImage {
        medium
      }
    }
  }
}
''';

class AniListProvider extends ProviderAdapter {
  AniListProvider({
    ProviderHttpClient? httpClient,
    this.apiUrl = 'https://graphql.anilist.co',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'anilist',
              baseUrl: apiUrl,
              rateLimiter: ProviderRateLimiter.aniList(),
            );

  final ProviderHttpClient _client;
  final String apiUrl;

  static const ProviderDescriptor anilistDescriptor = ProviderDescriptor(
    name: 'anilist',
    displayName: 'AniList',
    kind: 'manga',
    supportedKinds: ['manga', 'anime'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: false,
    nonCommercialOnly: false,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'AniList API Terms',
    termsUrl: 'https://anilist.gitbook.io/anilist-apiv2-docs/',
    attributionUrl: 'https://anilist.co/',
    rateLimit: '90 req/min',
    cachePolicy:
        'Cache per instance to minimize GraphQL calls; preserve AniList attribution links.',
  );

  @override
  ProviderDescriptor get descriptor => anilistDescriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage =>
      'AniList public anime/manga metadata is available without OAuth.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    final targetKind = _resolveTargetKind(kind);
    final anilistType = targetKind == 'anime' ? 'ANIME' : 'MANGA';

    final payload = await _graphql(
      '''
      query (\$search: String, \$perPage: Int) {
        Page(page: 1, perPage: \$perPage) {
          media(search: \$search, type: $anilistType) {
            id
            type
            title {
              romaji
              english
              native
            }
            format
            status
            startDate {
              year
            }
            coverImage {
              large
              medium
            }
            characters(perPage: 3) {
              edges {
                node {
                  name {
                    full
                  }
                }
              }
            }
          }
        }
      }
      ''',
      {
        'search': normalizedQuery,
        'perPage': limit,
      },
    );

    final data = payload['data'];
    if (data is! Map) return [];

    final page = data['Page'];
    if (page is! Map) return [];

    final mediaList = page['media'];
    if (mediaList is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final item in mediaList) {
      if (item is! Map) continue;
      final media = AniListMedia.fromJson(Map<String, dynamic>.from(item));
      results.add(_searchResultFromMedia(media, targetKind));
    }
    return results;
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    final (resolvedKind, anilistId) =
        _parseKindAndMediaId(providerItemId, defaultKind: kind);
    if (anilistId == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid AniList media ID: $providerItemId',
      );
    }

    final anilistType = resolvedKind == 'anime' ? 'ANIME' : 'MANGA';
    final payload = await _graphql(
      '''
      query (\$id: Int) {
        Media(id: \$id, type: $anilistType) {
          $_mediaFields
        }
      }
      ''',
      {'id': anilistId},
    );

    final data = payload['data'];
    if (data is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'AniList media not found for ID: $providerItemId',
      );
    }

    final media = data['Media'];
    if (media is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'AniList media not found for ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(media);
    raw['media_type'] = resolvedKind;

    final normalized = normalizeMedia(
      AniListMedia.fromJson(raw),
      resolvedKind,
    );
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'AniList',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    final canonicalItemId = _formatProviderItemId(resolvedKind, anilistId);

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: canonicalItemId,
      kind: resolvedKind,
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://anilist.co/$resolvedKind/$anilistId',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by AniList',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final kind = _kindFromRaw(data);
    return normalizeMedia(AniListMedia.fromJson(data), kind);
  }

  Map<String, dynamic> normalizeMedia(AniListMedia media, String kind) {
    final anilistId = media.id;
    final title = _extractTitle(media.title) ?? 'Unknown $kind';
    final genres = media.genres;
    final coverUrl = _extractCoverUrl(media.coverImage);
    final synopsis = _cleanHtmlDescription(media.description);

    final creators = <Map<String, dynamic>>[];
    for (final staffCredit in media.staff) {
      final fullName = staffCredit.name;
      if (fullName != null && fullName.trim().isNotEmpty) {
        creators.add(<String, dynamic>{
          'name': fullName.trim(),
          'role': staffCredit.role ?? 'Creator',
          'external_ids': <String, dynamic>{},
        });
      }
    }

    final providerIds = <String, String>{};
    if (anilistId != null) {
      providerIds['anilist'] = anilistId.toString();
    }
    final malId = media.idMal;
    if (malId != null) {
      providerIds['mal'] = malId.toString();
    }

    return {
      'kind': kind,
      'title': title,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      'creators': creators,
      'genres': genres,
      'characters': <dynamic>[],
      'story_arcs': <dynamic>[],
      'platforms': <dynamic>[],
      'tracks': <dynamic>[],
      'variant_covers': <dynamic>[],
      'trailer_urls': <dynamic>[],
      'external_ids': <String, dynamic>{},
      'external_links': <dynamic>[],
      'relations': <dynamic>[],
      'provider_ids': providerIds,
      'volume_provider_ids': <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> _graphql(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '',
      data: {
        'query': query,
        'variables': variables,
      },
    );

    final payload = response.data;
    if (payload == null) {
      throw ProviderInvalidPayloadException(
        provider: name,
        message: 'Empty response received from AniList GraphQL',
      );
    }

    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      final msg = firstError is Map
          ? firstError['message']?.toString()
          : 'GraphQL error';
      throw ProviderException(
        provider: name,
        message: msg ?? 'AniList GraphQL error',
      );
    }

    return payload;
  }

  ProviderSearchResult _searchResultFromMedia(
    AniListMedia item,
    String targetKind,
  ) {
    final title = _extractTitle(item.title) ?? 'Unknown AniList $targetKind';
    final anilistId = item.id;
    final providerItemId =
        anilistId != null ? _formatProviderItemId(targetKind, anilistId) : '';
    final year = item.startDate?.year?.toString();
    final romaji = item.title?.romaji;
    final english = item.title?.english;
    final altTitle = (english != null && romaji != null && romaji != english)
        ? romaji
        : null;

    final summaryParts = <String>[
      if (altTitle != null && altTitle.isNotEmpty) altTitle,
      if (item.format != null) item.format!,
      if (item.status != null) item.status!,
      if (year != null && year.isNotEmpty) year,
    ];

    final characterPreview = <String>[];
    for (final character in item.characters) {
      final characterName = character.name;
      if (characterName != null && characterName.isNotEmpty) {
        characterPreview.add(characterName);
      }
    }

    return ProviderSearchResult(
      provider: name,
      providerItemId: providerItemId,
      title: title,
      kind: targetKind,
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _extractCoverUrl(item.coverImage),
      characterPreview: characterPreview,
    );
  }

  String _resolveTargetKind(String? kind) {
    if (kind == null) return 'manga';
    final normalized = kind.trim().toLowerCase();
    return (normalized == 'anime') ? 'anime' : 'manga';
  }

  String _kindFromRaw(Map<String, dynamic> data) {
    final mediaType = data['media_type']?.toString().trim().toLowerCase();
    final anilistType = data['type']?.toString().trim().toUpperCase();
    if (mediaType == 'anime' || anilistType == 'ANIME') {
      return 'anime';
    }
    return 'manga';
  }

  (String, int?) _parseKindAndMediaId(String value, {String? defaultKind}) {
    final text = value.trim();
    final lower = text.toLowerCase();

    for (final rawPrefix in ['anime', 'manga']) {
      for (final sep in [':', '-']) {
        final prefix = '$rawPrefix$sep';
        if (lower.startsWith(prefix)) {
          return (rawPrefix, _parseInt(text.substring(prefix.length)));
        }
      }
    }

    return (_resolveTargetKind(defaultKind), _parseInt(text));
  }

  String _formatProviderItemId(String kind, int anilistId) {
    if (kind == 'manga') {
      return anilistId.toString();
    }
    return 'anime:$anilistId';
  }

  String? _extractTitle(AniListTitle? title) {
    final english = title?.english;
    if (english != null && english.isNotEmpty) return english;
    final romaji = title?.romaji;
    if (romaji != null && romaji.isNotEmpty) return romaji;
    final native = title?.native;
    if (native != null && native.isNotEmpty) return native;
    return null;
  }

  String? _extractCoverUrl(AniListCoverImage? cover) {
    final large = cover?.large;
    if (large != null && large.isNotEmpty) return large;
    final medium = cover?.medium;
    if (medium != null && medium.isNotEmpty) return medium;
    return null;
  }

  String? _cleanHtmlDescription(dynamic value) {
    if (value == null) return null;
    var text = value.toString().trim();
    if (text.isEmpty) return null;
    text = text.replaceAll(_htmlTagRegex, '').trim();
    return text.isNotEmpty ? text : null;
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value != null) {
      return int.tryParse(value.toString().trim());
    }
    return null;
  }
}
