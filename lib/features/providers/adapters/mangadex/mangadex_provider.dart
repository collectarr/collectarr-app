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
import 'models/mangadex_manga.dart';

class MangaDexProvider extends ProviderAdapter {
  MangaDexProvider({
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://api.mangadex.org',
    this.uploadsBaseUrl = 'https://uploads.mangadex.org',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'mangadex',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.mangaDex(),
            );

  final ProviderHttpClient _client;
  final String baseUrl;
  final String uploadsBaseUrl;

  static const ProviderDescriptor mangadexDescriptor = ProviderDescriptor(
    name: 'mangadex',
    displayName: 'MangaDex',
    kind: 'manga',
    supportedKinds: ['manga'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: false,
    nonCommercialOnly: false,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'MangaDex API Terms',
    termsUrl: 'https://api.mangadex.org/docs/',
    attributionUrl: 'https://mangadex.org/',
    rateLimit: '5 req/sec',
    cachePolicy: 'Cache manga detail and chapter feeds to minimize API calls.',
  );

  @override
  ProviderDescriptor get descriptor => mangadexDescriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage =>
      'MangaDex public API is available without authentication.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    final response = await _client.get<Map<String, dynamic>>(
      '/manga',
      queryParameters: {
        'title': normalizedQuery,
        'limit': limit,
        'includes[]': ['cover_art', 'author'],
        'order[relevance]': 'desc',
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
      },
    );

    final data = response.data;
    if (data == null) return [];

    final resultsList = data['data'];
    if (resultsList is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final item in resultsList.take(limit)) {
      if (item is! Map) continue;
      final manga = MangaDexManga.fromJson(Map<String, dynamic>.from(item));
      final searchResult = _searchResultFromManga(manga);
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
    final mangaId = providerItemId.trim();
    if (mangaId.isEmpty) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid MangaDex manga ID: $providerItemId',
      );
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/manga/$mangaId',
      queryParameters: {
        'includes[]': ['cover_art', 'author', 'artist'],
      },
    );

    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for MangaDex ID: $providerItemId',
      );
    }

    final manga = data['data'];
    if (manga is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'MangaDex manga payload missing for ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(manga);
    final typedManga = MangaDexManga.fromJson(raw);
    final normalized = normalizeManga(typedManga);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'MangaDex',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: mangaId,
      kind: 'manga',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://mangadex.org/title/$mangaId',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by MangaDex',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    return normalizeManga(MangaDexManga.fromJson(data));
  }

  Map<String, dynamic> normalizeManga(MangaDexManga manga) {
    final attrs = manga.attributes;
    final mangaId = manga.id;
    final title = _extractTitle(attrs?.title) ?? 'Unknown';
    final creators = _extractCreators(manga.relationships);
    final genres = _extractTags(attrs?.tags ?? const []);
    final coverUrl = _extractCoverUrl(manga);
    final synopsis = _extractDescription(attrs?.description);
    final publisher = _optionalText(attrs?.publisher);

    final providerIds = <String, String>{};
    if (mangaId != null && mangaId.isNotEmpty) {
      providerIds['mangadex'] = mangaId;
    }

    return {
      'kind': 'manga',
      'title': title,
      if (publisher != null) 'publisher': publisher,
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

  ProviderSearchResult _searchResultFromManga(MangaDexManga manga) {
    final attrs = manga.attributes;
    final title = _extractTitle(attrs?.title) ?? 'Unknown';
    final mangaId = manga.id ?? '';
    final statusText = attrs?.status;
    final year = attrs?.year?.toString();
    final demographic = attrs?.publicationDemographic;

    final summaryParts = <String>[
      if (demographic != null && demographic.isNotEmpty) demographic,
      if (statusText != null && statusText.isNotEmpty) statusText,
      if (year != null && year.isNotEmpty) year,
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: mangaId,
      title: title,
      kind: 'manga',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _extractCoverUrl(manga),
    );
  }

  String? _extractTitle(MangaDexLocalizedText? title) {
    return title?.preferred;
  }

  String? _extractDescription(MangaDexLocalizedText? description) {
    return description?.preferred;
  }

  String? _extractCoverUrl(MangaDexManga manga) {
    final mangaId = manga.id;
    final relationships = manga.relationships;
    if (mangaId == null || mangaId.isEmpty || relationships is! List) {
      return null;
    }

    for (final rel in relationships) {
      if (rel.type == 'cover_art') {
        final fileName = rel.fileName;
        if (fileName != null && fileName.isNotEmpty) {
          return '$uploadsBaseUrl/covers/$mangaId/$fileName.256.jpg';
        }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractCreators(
    List<MangaDexRelationship> relationships,
  ) {
    final creators = <Map<String, dynamic>>[];

    for (final rel in relationships) {
      final relType = rel.type;
      if (relType != 'author' && relType != 'artist') continue;

      final name = rel.name;
      if (name != null && name.isNotEmpty) {
        final role = relType == 'author' ? 'Author' : 'Artist';
        creators.add(<String, dynamic>{
          'name': name,
          'role': role,
          'external_ids': <String, dynamic>{},
        });
      }
    }
    return creators;
  }

  List<String> _extractTags(List<MangaDexTag> tags) {
    final tagList = <String>[];
    for (final tag in tags) {
      final name = tag.name?.preferred;
      if (name != null && name.isNotEmpty) {
        tagList.add(name);
      }
    }
    return tagList;
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
