import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../credentials/models/tmdb_credentials.dart';
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

class TMDbProvider extends ProviderAdapter {
  TMDbProvider({
    this.credentials,
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://api.themoviedb.org/3',
    this.imageBaseUrl = 'https://image.tmdb.org/t/p/w500',
    this.language = 'en-US',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'tmdb',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.tmdb(),
            );

  final TmdbCredentials? credentials;
  final ProviderHttpClient _client;
  final String baseUrl;
  final String imageBaseUrl;
  final String language;

  static const ProviderDescriptor tmdbDescriptor = ProviderDescriptor(
    name: 'tmdb',
    displayName: 'TMDb',
    kind: 'movie',
    supportedKinds: ['movie', 'tv', 'anime'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: true,
    nonCommercialOnly: false,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'TMDb API Terms',
    termsUrl: 'https://www.themoviedb.org/documentation/api/terms-of-use',
    attributionUrl: 'https://www.themoviedb.org/',
    rateLimit: '40 req/10s',
    cachePolicy:
        'Use TMDb as movie/TV metadata source with attribution. Store provider IDs and public poster URLs; keep physical video releases as editions/variants.',
  );

  @override
  ProviderDescriptor get descriptor => tmdbDescriptor;

  @override
  bool get isConfigured => credentials?.isValid ?? false;

  @override
  String get statusMessage => isConfigured
      ? 'TMDb API credentials configured.'
      : 'Set TMDb API Read Access Token or API Key in Settings.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    _ensureConfigured();

    final targetKind = _resolveTargetKind(kind);
    final endpoint = targetKind == 'tv' ? '/search/tv' : '/search/movie';

    final queryParams = <String, dynamic>{
      'query': normalizedQuery,
      'include_adult': 'false',
      'language': language,
      'page': 1,
      if (credentials?.readAccessToken == null && credentials?.apiKey != null)
        'api_key': credentials!.apiKey,
    };

    final headers = <String, String>{
      if (credentials?.readAccessToken != null)
        'Authorization': 'Bearer ${credentials!.readAccessToken}',
    };

    final response = await _client.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
      options: headers.isNotEmpty ? Options(headers: headers) : null,
    );

    final data = response.data;
    if (data == null) return [];

    final resultsList = data['results'];
    if (resultsList is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final item in resultsList.take(limit)) {
      if (item is! Map) continue;
      final itemMap = Map<String, dynamic>.from(item);
      final searchResult = _searchResultFromItem(itemMap, targetKind);
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

    final (targetKind, tmdbId) =
        _parseKindAndTmdbId(providerItemId, defaultKind: kind);
    if (tmdbId == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid TMDb media ID: $providerItemId',
      );
    }

    final endpoint = targetKind == 'tv' ? '/tv/$tmdbId' : '/movie/$tmdbId';

    final queryParams = <String, dynamic>{
      'append_to_response':
          'credits,external_ids,recommendations,release_dates,videos',
      'language': language,
      if (credentials?.readAccessToken == null && credentials?.apiKey != null)
        'api_key': credentials!.apiKey,
    };

    final headers = <String, String>{
      if (credentials?.readAccessToken != null)
        'Authorization': 'Bearer ${credentials!.readAccessToken}',
    };

    final response = await _client.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
      options: headers.isNotEmpty ? Options(headers: headers) : null,
    );

    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for TMDb ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(data);
    raw['media_type'] = targetKind;

    final normalized = normalize(raw);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'TMDb',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    final canonicalItemId = tmdbId.toString();

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: canonicalItemId,
      kind: targetKind,
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://www.themoviedb.org/$targetKind/$tmdbId',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by TMDb',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final kind = _kindFromRaw(data);
    final tmdbId = _parseInt(data['id']);
    final title = _extractTitle(data, kind) ?? 'Unknown $kind';
    final synopsis = _optionalText(data['overview']);
    final runtimeMinutes = _extractRuntime(data, kind);
    final publisher = _extractPublisher(data['production_companies']);
    final coverUrl = _extractPosterUrl(data['poster_path']);
    final creators = _extractCreators(data['credits'], kind);
    final genres = _extractGenres(data['genres']);
    final voteAverage = data['vote_average'];
    final audienceRating = voteAverage != null
        ? (voteAverage is num
            ? voteAverage.toStringAsFixed(1)
            : voteAverage.toString())
        : null;

    final providerIds = <String, String>{};
    if (tmdbId != null) {
      providerIds['tmdb'] = tmdbId.toString();
    }
    final externalIds = data['external_ids'];
    if (externalIds is Map) {
      final imdb = _optionalText(externalIds['imdb_id']);
      if (imdb != null) providerIds['imdb'] = imdb;
    }

    return {
      'kind': kind,
      'title': title,
      if (synopsis != null) 'synopsis': synopsis,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (publisher != null) 'publisher': publisher,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      if (audienceRating != null) 'audience_rating': audienceRating,
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

  ProviderSearchResult _searchResultFromItem(
      Map<String, dynamic> item, String kind) {
    final title = _extractTitle(item, kind) ?? 'Unknown TMDb $kind';
    final tmdbId = _parseInt(item['id']);
    final date = _optionalText(item['release_date']) ??
        _optionalText(item['first_air_date']);
    final lang = _optionalText(item['original_language']);

    final summaryParts = <String>[
      if (date != null && date.isNotEmpty) date,
      if (lang != null && lang.isNotEmpty) lang,
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: tmdbId != null ? '$kind:$tmdbId' : '',
      title: title,
      kind: kind,
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _extractPosterUrl(item['poster_path']),
    );
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw ProviderAuthException(
        provider: name,
        message: 'TMDb credentials are not configured',
      );
    }
  }

  String _resolveTargetKind(String? kind) {
    if (kind == null) return 'movie';
    final norm = kind.trim().toLowerCase();
    if (norm == 'tv' || norm == 'anime') return norm;
    return 'movie';
  }

  String _kindFromRaw(Map<String, dynamic> data) {
    final mediaType = data['media_type']?.toString().trim().toLowerCase();
    if (mediaType == 'tv') return 'tv';
    if (mediaType == 'anime') return 'anime';
    if (data.containsKey('first_air_date') ||
        data.containsKey('number_of_seasons')) {
      return 'tv';
    }
    return 'movie';
  }

  (String, int?) _parseKindAndTmdbId(String value, {String? defaultKind}) {
    final text = value.trim();
    final lower = text.toLowerCase();

    for (final rawPrefix in ['movie', 'tv', 'anime']) {
      for (final sep in [':', '-']) {
        final prefix = '$rawPrefix$sep';
        if (lower.startsWith(prefix)) {
          return (rawPrefix, _parseInt(text.substring(prefix.length)));
        }
      }
    }

    return (_resolveTargetKind(defaultKind), _parseInt(text));
  }

  String? _extractTitle(Map<String, dynamic> data, String kind) {
    if (kind == 'tv' || kind == 'anime') {
      final name = _optionalText(data['name']);
      if (name != null) return name;
    }
    return _optionalText(data['title']) ??
        _optionalText(data['name']) ??
        _optionalText(data['original_title']);
  }

  String? _extractPosterUrl(dynamic posterPath) {
    final path = _optionalText(posterPath);
    if (path == null) return null;
    return '$imageBaseUrl$path';
  }

  int? _extractRuntime(Map<String, dynamic> data, String kind) {
    final runtime = data['runtime'];
    if (runtime is num && runtime > 0) return runtime.toInt();

    final episodeRunTime = data['episode_run_time'];
    if (episodeRunTime is List && episodeRunTime.isNotEmpty) {
      final first = episodeRunTime.first;
      if (first is num && first > 0) return first.toInt();
    }
    return null;
  }

  String? _extractPublisher(dynamic productionCompanies) {
    if (productionCompanies is List && productionCompanies.isNotEmpty) {
      final first = productionCompanies.first;
      if (first is Map) {
        return _optionalText(first['name']);
      }
    }
    return null;
  }

  List<String> _extractGenres(dynamic genres) {
    if (genres is List) {
      final list = <String>[];
      for (final g in genres) {
        if (g is Map) {
          final name = _optionalText(g['name']);
          if (name != null) list.add(name);
        }
      }
      return list;
    }
    return [];
  }

  List<Map<String, dynamic>> _extractCreators(dynamic credits, String kind) {
    if (credits is! Map) return [];
    final creators = <Map<String, dynamic>>[];

    final crew = credits['crew'];
    if (crew is List) {
      for (final person in crew) {
        if (person is! Map) continue;
        final job = _optionalText(person['job']);
        final name = _optionalText(person['name']);
        if (name != null &&
            (job == 'Director' || job == 'Writer' || job == 'Creator')) {
          if (!creators.any((c) => c['name'] == name && c['role'] == job)) {
            creators.add(<String, dynamic>{
              'name': name,
              'role': job!,
              'external_ids': <String, dynamic>{},
            });
          }
        }
      }
    }

    final cast = credits['cast'];
    if (cast is List) {
      for (final person in cast.take(6)) {
        if (person is! Map) continue;
        final name = _optionalText(person['name']);
        if (name != null) {
          if (!creators.any((c) => c['name'] == name && c['role'] == 'Actor')) {
            creators.add(<String, dynamic>{
              'name': name,
              'role': 'Actor',
              'external_ids': <String, dynamic>{},
            });
          }
        }
      }
    }

    return creators;
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value != null) {
      return int.tryParse(value.toString().trim());
    }
    return null;
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
