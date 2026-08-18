import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../credentials/models/hardcover_credentials.dart';
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

const String _hardcoverSearchQuery = '''
query SearchBooks(\$query: String!, \$perPage: Int!, \$page: Int!) {
  search(
    query: \$query,
    query_type: "Book",
    per_page: \$perPage,
    page: \$page,
    fields: "title,isbns,series_names,author_names,alternative_titles",
    sort: "_text_match:desc,users_count:desc"
  ) {
    results
  }
}
''';

const String _hardcoverBookDetailQuery = '''
query GetBook(\$id: Int!) {
  books(where: {id: {_eq: \$id}}) {
    id
    title
    subtitle
    slug
    description
    pages
    release_date
    contributions {
      author {
        name
        image {
          url
        }
      }
      contribution_type
    }
    book_series {
      series {
        id
        name
        slug
      }
      position
    }
    editions(
      where: {is_default: {_eq: true}}
      limit: 1
    ) {
      isbn_10
      isbn_13
      pages
      release_date
      edition_format
      image {
        url
      }
      publisher {
        name
      }
    }
    image {
      url
    }
    taggings {
      tag {
        tag
      }
    }
  }
}
''';

class HardcoverProvider extends ProviderAdapter {
  HardcoverProvider({
    this.credentials,
    ProviderHttpClient? httpClient,
    this.apiUrl = 'https://api.hardcover.app/v1/graphql',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'hardcover',
              baseUrl: apiUrl,
              rateLimiter: ProviderRateLimiter.hardcover(),
            );

  final HardcoverCredentials? credentials;
  final ProviderHttpClient _client;
  final String apiUrl;

  static const ProviderDescriptor hardcoverDescriptor = ProviderDescriptor(
    name: 'hardcover',
    displayName: 'Hardcover',
    kind: 'book',
    supportedKinds: ['book', 'manga'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: true,
    nonCommercialOnly: false,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'Hardcover API Terms',
    termsUrl: 'https://docs.hardcover.app/api/getting-started/',
    attributionUrl: 'https://hardcover.app/',
    rateLimit: '60 req/min',
    cachePolicy: 'Cache book/series details; search results are ephemeral.',
  );

  @override
  ProviderDescriptor get descriptor => hardcoverDescriptor;

  @override
  bool get isConfigured => credentials?.isValid ?? false;

  @override
  String get statusMessage => isConfigured
      ? 'Hardcover API key is configured.'
      : 'Hardcover requires an API key. Get one at https://hardcover.app/account/api';

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
    final payload = await _graphql(
      _hardcoverSearchQuery,
      {
        'query': normalizedQuery,
        'perPage': limit,
        'page': 1,
      },
    );

    final searchData = payload['data'] is Map ? payload['data'] as Map : {};
    final searchResult =
        searchData['search'] is Map ? searchData['search'] as Map : {};
    final rawResults = searchResult['results'];
    if (rawResults == null) return [];

    List<dynamic> resultsList;
    if (rawResults is String) {
      try {
        resultsList = jsonDecode(rawResults) as List<dynamic>;
      } catch (_) {
        return [];
      }
    } else if (rawResults is List) {
      resultsList = rawResults;
    } else {
      return [];
    }

    final hits = <ProviderSearchResult>[];
    for (final hit in resultsList) {
      if (hit is! Map) continue;
      final doc = hit['document'] is Map ? hit['document'] as Map : hit;
      final bookId = doc['id'];
      if (bookId == null) continue;

      final title = _optionalText(doc['title']) ?? 'Unknown';
      final authorNames =
          doc['author_names'] is List ? (doc['author_names'] as List) : [];
      final series =
          doc['featured_series'] is Map ? doc['featured_series'] as Map : null;
      final seriesName = _optionalText(series?['name']);
      final releaseYear = _optionalText(doc['release_year']);

      final summaryParts = <String>[
        if (authorNames.isNotEmpty)
          authorNames.take(2).map((a) => a.toString()).join(', '),
        if (seriesName != null && seriesName.isNotEmpty) seriesName,
        if (releaseYear != null && releaseYear.isNotEmpty) releaseYear,
      ];

      final image = doc['image'] is Map ? doc['image'] as Map : null;
      final imageUrl = _optionalText(image?['url']);

      hits.add(
        ProviderSearchResult(
          provider: name,
          providerItemId: _formatProviderItemId(targetKind, bookId.toString()),
          title: title,
          kind: targetKind,
          summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
          imageUrl: imageUrl,
          seriesTitle: seriesName,
        ),
      );
    }
    return hits;
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    _ensureConfigured();

    final (targetKind, bookId) =
        _parseKindAndBookId(providerItemId, defaultKind: kind);
    final intId = int.tryParse(bookId);
    if (intId == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid Hardcover book ID: $providerItemId',
      );
    }

    final payload = await _graphql(_hardcoverBookDetailQuery, {'id': intId});
    final books = (payload['data'] is Map && payload['data']['books'] is List)
        ? payload['data']['books'] as List
        : [];

    if (books.isEmpty || books.first is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Hardcover book not found for ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(books.first as Map);
    raw['_collectarr_kind'] = targetKind;

    final normalized = normalize(raw);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'Hardcover',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    final canonicalItemId = intId.toString();

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: canonicalItemId,
      kind: targetKind,
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://hardcover.app/books/${raw['slug'] ?? intId}',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by Hardcover',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final title = _optionalText(data['title']) ?? 'Unknown';
    final bookId = _parseInt(data['id']);
    final synopsis = _optionalText(data['description']);
    final creators = _extractCreators(data['contributions']);
    final genres = _extractTags(data['taggings']);

    final image = data['image'] is Map ? data['image'] as Map : null;
    var coverUrl = _optionalText(image?['url']);

    final editions = data['editions'] is List ? data['editions'] as List : [];
    final defaultEdition = editions.isNotEmpty && editions.first is Map
        ? editions.first as Map
        : null;

    String? publisher;
    int? pageCount = _parseInt(data['pages']);
    if (defaultEdition != null) {
      final pub = defaultEdition['publisher'] is Map
          ? defaultEdition['publisher'] as Map
          : null;
      publisher = _optionalText(pub?['name']);
      pageCount = pageCount ?? _parseInt(defaultEdition['pages']);
      final edImage = defaultEdition['image'] is Map
          ? defaultEdition['image'] as Map
          : null;
      if (coverUrl == null) {
        coverUrl = _optionalText(edImage?['url']);
      }
    }

    final targetKind = _optionalText(data['_collectarr_kind']) ?? 'book';
    final providerIds = <String, String>{};
    if (bookId != null) {
      providerIds['hardcover'] = bookId.toString();
    }

    return {
      'kind': targetKind,
      'title': title,
      if (synopsis != null) 'synopsis': synopsis,
      if (publisher != null) 'publisher': publisher,
      if (pageCount != null) 'page_count': pageCount,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      'creators': creators,
      'genres': genres,
      'characters': [],
      'story_arcs': [],
      'platforms': [],
      'tracks': [],
      'variant_covers': [],
      'trailer_urls': [],
      'external_ids': {},
      'external_links': [],
      'relations': [],
      'provider_ids': providerIds,
      'volume_provider_ids': {},
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
      options: Options(
        headers: {
          'Authorization': 'Bearer ${credentials!.apiKey}',
        },
      ),
    );

    final payload = response.data;
    if (payload == null) {
      throw ProviderInvalidPayloadException(
        provider: name,
        message: 'Empty response received from Hardcover GraphQL',
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
        message: msg ?? 'Hardcover GraphQL error',
      );
    }

    return payload;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw ProviderAuthException(
        provider: name,
        message: 'Hardcover API key is not configured',
      );
    }
  }

  String _resolveTargetKind(String? kind) {
    if (kind == null) return 'book';
    final norm = kind.trim().toLowerCase();
    return norm == 'manga' ? 'manga' : 'book';
  }

  (String, String) _parseKindAndBookId(String value, {String? defaultKind}) {
    final text = value.trim();
    if (text.contains(':')) {
      final parts = text.split(':');
      final prefix = parts[0].trim().toLowerCase();
      final suffix = parts[1].trim();
      if (prefix == 'book' || prefix == 'manga') {
        return (prefix, suffix);
      }
    }
    return (_resolveTargetKind(defaultKind), text);
  }

  String _formatProviderItemId(String kind, String bookId) {
    if (kind == 'book') return bookId;
    return '$kind:$bookId';
  }

  List<Map<String, dynamic>> _extractCreators(dynamic contributions) {
    if (contributions is! List) return [];
    final creators = <Map<String, dynamic>>[];

    for (final contrib in contributions) {
      if (contrib is! Map) continue;
      final author = contrib['author'];
      final name = author is Map ? _optionalText(author['name']) : null;
      if (name != null && name.isNotEmpty) {
        final role = _optionalText(contrib['contribution_type']) ?? 'Author';
        creators.add({
          'name': name,
          'role': role,
          'external_ids': {},
        });
      }
    }
    return creators;
  }

  List<String> _extractTags(dynamic taggings) {
    if (taggings is! List) return [];
    final list = <String>[];
    for (final t in taggings) {
      if (t is! Map) continue;
      final tagObj = t['tag'];
      final tagName = tagObj is Map
          ? _optionalText(tagObj['tag'])
          : _optionalText(t['tag']);
      if (tagName != null && tagName.isNotEmpty) {
        list.add(tagName);
      }
    }
    return list;
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
