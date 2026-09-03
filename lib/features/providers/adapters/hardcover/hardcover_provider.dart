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
import 'models/hardcover_book.dart';

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

    final searchData = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : const <String, dynamic>{};
    final searchResult = searchData['search'] is Map
        ? Map<String, dynamic>.from(searchData['search'] as Map)
        : const <String, dynamic>{};
    final rawResults = searchResult['results'];
    if (rawResults == null) return [];

    final hits = <ProviderSearchResult>[];
    for (final hit in decodeHardcoverSearchHits(rawResults)) {
      final document = hit.document;
      final bookId = document.id;
      if (bookId == null) continue;

      final title = document.title ?? 'Unknown';
      final authorNames = document.authorNames;
      final seriesName = document.featuredSeries?.name;
      final releaseYear = document.releaseYear;

      final summaryParts = <String>[
        if (authorNames.isNotEmpty)
          authorNames.take(2).map((a) => a.toString()).join(', '),
        if (seriesName != null && seriesName.isNotEmpty) seriesName,
        if (releaseYear != null && releaseYear.isNotEmpty) releaseYear,
      ];

      final imageUrl = document.image?.url;

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
    final dataPayload = payload['data'];
    final data = dataPayload is Map
        ? Map<String, dynamic>.from(dataPayload)
        : const <String, dynamic>{};
    final books = data['books'];
    if (books is! List || books.isEmpty || books.first is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Hardcover book not found for ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(books.first as Map);
    final book = HardcoverBook.fromJson(raw);

    final normalized = normalizeBook(book, targetKind);
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
        sourceUrl: 'https://hardcover.app/books/${book.slug ?? intId}',
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
    final targetKind = _optionalText(data['_collectarr_kind']) ?? 'book';
    return normalizeBook(HardcoverBook.fromJson(data), targetKind);
  }

  Map<String, dynamic> normalizeBook(HardcoverBook book, String targetKind) {
    final title = book.title ?? 'Unknown';
    final bookId = book.id;
    final synopsis = book.description;
    final creators = _extractCreators(book.contributions);
    final genres = _extractTags(book.taggings);
    var coverUrl = book.image?.url;

    final defaultEdition =
        book.editions.isNotEmpty ? book.editions.first : null;

    String? publisher;
    int? pageCount = book.pages;
    if (defaultEdition != null) {
      publisher = defaultEdition.publisher?.name;
      pageCount = pageCount ?? defaultEdition.pages;
      coverUrl ??= defaultEdition.image?.url;
    }

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

  List<Map<String, dynamic>> _extractCreators(
    List<HardcoverContribution> contributions,
  ) {
    final creators = <Map<String, dynamic>>[];

    for (final contrib in contributions) {
      final name = contrib.author?.name;
      if (name != null && name.isNotEmpty) {
        final role = contrib.contributionType ?? 'Author';
        creators.add(<String, dynamic>{
          'name': name,
          'role': role,
          'external_ids': <String, dynamic>{},
        });
      }
    }
    return creators;
  }

  List<String> _extractTags(List<HardcoverTagging> taggings) {
    final list = <String>[];
    for (final t in taggings) {
      final tagName = t.name;
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
