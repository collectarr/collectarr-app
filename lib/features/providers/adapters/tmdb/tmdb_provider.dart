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
import 'models/tmdb_media.dart';

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
      final media = _mediaFromRaw(itemMap, targetKind);
      final searchResult = _searchResultFromItem(media, targetKind);
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

    final media = _mediaFromRaw(raw, targetKind);
    final normalized = targetKind == 'tv' || targetKind == 'anime'
        ? normalizeTv(media as TmdbTvSeries, kind: targetKind)
        : normalizeMovie(media as TmdbMovie);
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
    final media = _mediaFromRaw(data, kind);
    return kind == 'tv' || kind == 'anime'
        ? normalizeTv(media as TmdbTvSeries, kind: kind)
        : normalizeMovie(media as TmdbMovie);
  }

  Map<String, dynamic> normalizeMovie(TmdbMovie movie) {
    return _normalizeMedia(movie, 'movie');
  }

  Map<String, dynamic> normalizeTv(
    TmdbTvSeries series, {
    String kind = 'tv',
  }) {
    return _normalizeMedia(series, kind);
  }

  Map<String, dynamic> _normalizeMedia(TmdbMedia data, String kind) {
    final tmdbId = data.id;
    final title = _extractTitle(data, kind) ?? 'Unknown $kind';
    final synopsis = data.overview;
    final runtimeMinutes = _extractRuntime(data);
    final publisher = _extractPublisher(data.productionCompanies);
    final coverUrl = _extractPosterUrl(data.posterPath);
    final creators = _extractCreators(data.credits);
    final genres = _extractGenres(data.genres);
    final voteAverage = data.voteAverage;
    final audienceRating = voteAverage?.toStringAsFixed(1);

    final providerIds = <String, String>{};
    if (tmdbId != null) {
      providerIds['tmdb'] = tmdbId.toString();
    }
    final imdb = data.externalIds?.imdbId;
    if (imdb != null) {
      providerIds['imdb'] = imdb;
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

  ProviderSearchResult _searchResultFromItem(TmdbMedia item, String kind) {
    final title = _extractTitle(item, kind) ?? 'Unknown TMDb $kind';
    final tmdbId = item.id;
    final date =
        _optionalText(item.releaseDate) ?? _optionalText(item.firstAirDate);
    final lang = _optionalText(item.originalLanguage);

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
      imageUrl: _extractPosterUrl(item.posterPath),
    );
  }

  TmdbMedia _mediaFromRaw(Map<String, dynamic> data, String kind) {
    if (kind == 'tv' || kind == 'anime') {
      return TmdbTvSeries.fromJson(data);
    }
    return TmdbMovie.fromJson(data);
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

  String? _extractTitle(TmdbMedia data, String kind) {
    if (kind == 'tv' || kind == 'anime') {
      final name = _optionalText(data.name);
      if (name != null) return name;
    }
    return _optionalText(data.title) ??
        _optionalText(data.name) ??
        _optionalText(data.originalTitle);
  }

  String? _extractPosterUrl(String? posterPath) {
    final path = _optionalText(posterPath);
    if (path == null) return null;
    return '$imageBaseUrl$path';
  }

  int? _extractRuntime(TmdbMedia data) {
    if (data is TmdbMovie && data.runtime != null && data.runtime! > 0) {
      return data.runtime;
    }
    if (data is TmdbTvSeries && data.episodeRunTime.isNotEmpty) {
      final first = data.episodeRunTime.first;
      if (first > 0) return first;
    }
    return null;
  }

  String? _extractPublisher(List<TmdbProductionCompany> productionCompanies) {
    if (productionCompanies.isEmpty) return null;
    return _optionalText(productionCompanies.first.name);
  }

  List<String> _extractGenres(List<TmdbGenre> genres) {
    return [
      for (final genre in genres)
        if (_optionalText(genre.name) case final name?) name,
    ];
  }

  List<Map<String, dynamic>> _extractCreators(TmdbCredits? credits) {
    if (credits == null) return [];
    final creators = <Map<String, dynamic>>[];

    for (final person in credits.crew) {
      final job = _optionalText(person.job);
      final name = _optionalText(person.name);
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

    for (final person in credits.cast.take(6)) {
      final name = _optionalText(person.name);
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
