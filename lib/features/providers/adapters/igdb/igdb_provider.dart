import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../credentials/models/igdb_credentials.dart';
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

class IGDBProvider extends ProviderAdapter {
  IGDBProvider({
    this.credentials,
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://api.igdb.com/v4',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'igdb',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.igdb(),
            );

  final IgdbCredentials? credentials;
  final ProviderHttpClient _client;
  final String baseUrl;

  static const ProviderDescriptor igdbDescriptor = ProviderDescriptor(
    name: 'igdb',
    displayName: 'IGDB',
    kind: 'game',
    supportedKinds: ['game'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: true,
    nonCommercialOnly: true,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'IGDB API Terms',
    termsUrl: 'https://api-docs.igdb.com/',
    attributionUrl: 'https://www.igdb.com/',
    rateLimit: '4 req/sec',
    cachePolicy:
        'Cache per instance; respect IGDB/Twitch non-commercial API terms.',
  );

  @override
  ProviderDescriptor get descriptor => igdbDescriptor;

  @override
  bool get isConfigured => credentials?.isValid ?? false;

  @override
  String get statusMessage => isConfigured
      ? 'IGDB credentials configured.'
      : 'Set IGDB Client ID and Access Token in Settings.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    _ensureConfigured();

    final body = [
      'search "${_escapeQuery(normalizedQuery)}";',
      'fields id,name,summary,first_release_date,cover.url,genres.name,involved_companies.company.name,involved_companies.developer,involved_companies.publisher,platforms.name;',
      'where version_parent = null;',
      'limit $limit;',
    ].join('\n');

    final games = await _request('games', body);

    final results = <ProviderSearchResult>[];
    for (final game in games) {
      if (game is! Map) continue;
      final gameMap = Map<String, dynamic>.from(game);
      final searchResult = _searchResultFromItem(gameMap);
      if (searchResult.providerItemId.isNotEmpty) {
        results.add(searchResult);
      }
    }
    return results;
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    _ensureConfigured();

    final cleanId = providerItemId.trim();
    final igdbId = int.tryParse(cleanId);
    if (igdbId == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid IGDB game ID: $providerItemId',
      );
    }

    final body = [
      'fields id,name,summary,storyline,first_release_date,cover.url,genres.name,involved_companies.company.name,involved_companies.developer,involved_companies.publisher,platforms.name,game_modes.name,age_ratings.rating,age_ratings.category,total_rating,slug;',
      'where id = $igdbId;',
      'limit 1;',
    ].join('\n');

    final games = await _request('games', body);
    if (games.isEmpty || games.first is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'IGDB game not found for ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(games.first as Map);
    final normalized = normalize(raw);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'IGDB',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    final gameSlug = _optionalText(raw['slug']) ??
        _slug(normalized['title']?.toString() ?? 'game');

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: cleanId,
      kind: 'game',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://www.igdb.com/games/$gameSlug',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by IGDB',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final igdbId = _optionalText(data['id']);
    final title = _optionalText(data['name']) ?? 'Unknown game';
    final synopsis =
        _optionalText(data['summary']) ?? _optionalText(data['storyline']);
    final coverUrl = _extractCoverUrl(data['cover']);
    final platforms = _extractNames(data['platforms']);
    final genres = _extractNames(data['genres']);

    final companies = data['involved_companies'] is List
      ? (data['involved_companies'] as List<dynamic>)
      : const <dynamic>[];
    final publishers = _extractCompanies(companies, 'publisher');
    final developers = _extractCompanies(companies, 'developer');

    final creators = developers
        .map((d) => <String, dynamic>{
              'name': d,
              'role': 'Developer',
              'external_ids': <String, dynamic>{},
            })
        .toList();

    final totalRating = data['total_rating'];
    final audienceRating = totalRating != null
        ? (totalRating is num
            ? totalRating.toStringAsFixed(1)
            : totalRating.toString())
        : null;

    final providerIds = <String, String>{};
    if (igdbId != null && igdbId.isNotEmpty) {
      providerIds['igdb'] = igdbId;
    }

    return {
      'kind': 'game',
      'title': title,
      if (synopsis != null) 'synopsis': synopsis,
      if (publishers.isNotEmpty) 'publisher': publishers.first,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      if (audienceRating != null) 'audience_rating': audienceRating,
      'creators': creators,
      'genres': genres,
      'platforms': platforms,
      'characters': <dynamic>[],
      'story_arcs': <dynamic>[],
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

  ProviderSearchResult _searchResultFromItem(Map<String, dynamic> item) {
    final igdbId = _optionalText(item['id']) ?? '';
    final title = _optionalText(item['name']) ?? 'Unknown IGDB game';
    final platforms = _extractNames(item['platforms']);
    final firstReleaseDate = item['first_release_date'];

    String? releaseIso;
    if (firstReleaseDate is num) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          firstReleaseDate.toInt() * 1000,
          isUtc: true);
      releaseIso = dt.toIso8601String().split('T')[0];
    }

    final summaryParts = <String>[
      if (releaseIso != null) releaseIso,
      if (platforms.isNotEmpty) platforms.take(2).join(', '),
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: igdbId,
      title: title,
      kind: 'game',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _extractCoverUrl(item['cover']),
    );
  }

  Future<List<dynamic>> _request(String endpoint, String body) async {
    final response = await _client.post<dynamic>(
      '/$endpoint',
      data: body,
      options: Options(
        headers: {
          'Client-ID': credentials!.clientId,
          'Authorization': 'Bearer ${credentials!.userAccessToken}',
          'Accept': 'application/json',
        },
      ),
    );

    final payload = response.data;
    if (payload is List) return payload;
    if (payload is Map && payload.containsKey('message')) {
      throw ProviderException(
        provider: name,
        message: payload['message'].toString(),
      );
    }
    return [];
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw ProviderAuthException(
        provider: name,
        message: 'IGDB credentials are not configured',
      );
    }
  }

  String _escapeQuery(String query) {
    return query.replaceAll('"', '\\"');
  }

  String? _extractCoverUrl(dynamic coverObj) {
    if (coverObj is! Map) return null;
    var url = _optionalText(coverObj['url']);
    if (url == null) return null;

    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    return url.replaceAll('t_thumb', 't_cover_big');
  }

  List<String> _extractNames(dynamic listObj) {
    if (listObj is! List) return [];
    final names = <String>[];
    for (final item in listObj) {
      if (item is Map) {
        final name = _optionalText(item['name']);
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }
    }
    return names;
  }

  List<String> _extractCompanies(List<dynamic> companies, String companyType) {
    final list = <String>[];
    for (final c in companies) {
      if (c is! Map) continue;
      final isMatch = c[companyType] == true;
      if (isMatch) {
        final comp = c['company'];
        if (comp is Map) {
          final name = _optionalText(comp['name']);
          if (name != null && name.isNotEmpty) {
            list.add(name);
          }
        }
      }
    }
    return list;
  }

  String _slug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
