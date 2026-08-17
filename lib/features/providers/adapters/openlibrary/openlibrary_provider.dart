import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/contracts/metadata_provider.dart';
import '../../domain/models/normalized_provider_envelope_v1.dart';
import '../../domain/models/provider_attribution.dart';
import '../../domain/models/provider_descriptor.dart';
import '../../domain/models/provider_exception.dart';
import '../../domain/models/provider_image_ref.dart';
import '../../domain/models/provider_provenance.dart';
import '../../domain/models/provider_search_result.dart';
import '../../runtime/provider_http_client.dart';
import '../provider_adapter.dart';

final RegExp _olidRegex = RegExp(r'^(?:OL)?(\d+[MWA])$', caseSensitive: false);
final RegExp _yearRegex = RegExp(r'\b(\d{4})\b');

class OpenLibraryProvider extends ProviderAdapter {
  OpenLibraryProvider({
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://openlibrary.org',
    this.coversBaseUrl = 'https://covers.openlibrary.org',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'openlibrary',
              baseUrl: baseUrl,
            );

  final ProviderHttpClient _client;
  final String baseUrl;
  final String coversBaseUrl;

  static const ProviderDescriptor openLibraryDescriptor = ProviderDescriptor(
    name: 'openlibrary',
    displayName: 'Open Library',
    kind: 'book',
    supportedKinds: ['book'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: false,
    nonCommercialOnly: false,
    allowsRedistribution: true,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'Open Library Data',
    termsUrl: 'https://openlibrary.org/developers',
    attributionUrl: 'https://openlibrary.org/',
    rateLimit: '1 req/sec',
    cachePolicy:
        'Cache bibliographic metadata with attribution. Prefer Open Library cover URLs for public covers; do not crawl the cover API.',
  );

  @override
  ProviderDescriptor get descriptor => openLibraryDescriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage =>
      'Open Library metadata is available without an API key.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    final response = await _client.get<Map<String, dynamic>>(
      '/search.json',
      queryParameters: {
        'q': normalizedQuery,
        'limit': limit,
        'fields':
            'key,title,author_name,first_publish_year,edition_key,isbn,publisher,cover_i',
      },
    );

    final data = response.data;
    if (data == null) return [];

    final docs = data['docs'];
    if (docs is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final doc in docs.take(limit)) {
      if (doc is! Map) continue;
      final docMap = Map<String, dynamic>.from(doc);
      final result = _searchResultFromDoc(docMap);
      if (result.providerItemId.isNotEmpty) {
        results.add(result);
      }
    }
    return results;
  }

  /// Search Open Library directly by ISBN / barcode.
  Future<List<ProviderSearchResult>> searchByBarcode(
    String barcode, {
    String? kind,
    int limit = 25,
  }) async {
    final normalized = barcode.trim().replaceAll('-', '');
    if (normalized.isEmpty) return [];
    return search('isbn:$normalized', kind: kind, limit: limit);
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    final providerId = _normalizeProviderId(providerItemId);
    if (providerId == null || providerId.isEmpty) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid Open Library ID: $providerItemId',
      );
    }

    Map<String, dynamic>? workRaw;
    Map<String, dynamic>? editionRaw;
    String rawPayloadString = '';

    if (providerId.toUpperCase().startsWith('ISBN:')) {
      final isbn = providerId.substring(5);
      final response =
          await _client.get<Map<String, dynamic>>('/isbn/$isbn.json');
      editionRaw = response.data != null
          ? Map<String, dynamic>.from(response.data!)
          : null;
      rawPayloadString = jsonEncode(editionRaw);
    } else if (providerId.toUpperCase().endsWith('M')) {
      final response =
          await _client.get<Map<String, dynamic>>('/books/$providerId.json');
      editionRaw = response.data != null
          ? Map<String, dynamic>.from(response.data!)
          : null;
      rawPayloadString = jsonEncode(editionRaw);
    } else {
      final response =
          await _client.get<Map<String, dynamic>>('/works/$providerId.json');
      workRaw = response.data != null
          ? Map<String, dynamic>.from(response.data!)
          : null;
      rawPayloadString = jsonEncode(workRaw);
    }

    if (editionRaw != null && workRaw == null) {
      final workId = _workIdFromEdition(editionRaw);
      if (workId != null) {
        try {
          final workResp =
              await _client.get<Map<String, dynamic>>('/works/$workId.json');
          if (workResp.data != null) {
            workRaw = Map<String, dynamic>.from(workResp.data!);
          }
        } catch (_) {
          // Non-fatal if work endpoint fails when edition is loaded
        }
      }
    }

    if (workRaw == null && editionRaw == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for Open Library ID: $providerItemId',
      );
    }

    final normalized = normalize(workRaw: workRaw, editionRaw: editionRaw);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'Open Library',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    final canonicalItemId = normalized['provider_ids'] is Map &&
            (normalized['provider_ids'] as Map)[name] != null
        ? (normalized['provider_ids'] as Map)[name].toString()
        : providerId;

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: canonicalItemId,
      kind: 'book',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://openlibrary.org/works/$canonicalItemId',
        rawPayloadHash:
            sha256.convert(utf8.encode(rawPayloadString)).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by Open Library',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize({
    Map<String, dynamic>? workRaw,
    Map<String, dynamic>? editionRaw,
    Map<String, dynamic>? searchDoc,
  }) {
    final title = _optionalText(editionRaw?['title']) ??
        _optionalText(workRaw?['title']) ??
        _optionalText(searchDoc?['title']) ??
        'Unknown book';

    final subtitle = _optionalText(editionRaw?['subtitle']);
    final synopsis = _description(editionRaw?['description']) ??
        _description(workRaw?['description']);

    final isbn = _firstText([
      editionRaw?['isbn_13'],
      editionRaw?['isbn_10'],
      searchDoc?['isbn'],
    ]);

    final workId = _workIdFromEdition(editionRaw) ?? _workId(workRaw);
    final editionId = _editionId(editionRaw) ?? _editionKey(searchDoc);
    final primaryId = workId ?? editionId ?? '';

    final publishDateRaw =
        editionRaw?['publish_date'] ?? searchDoc?['first_publish_year'];
    final releaseDate = _parseDate(publishDateRaw);

    final subjects = workRaw?['subjects'];
    final genres = <String>[];
    if (subjects is List) {
      for (final s in subjects) {
        if (s != null && s.toString().trim().isNotEmpty) {
          genres.add(s.toString().trim());
          if (genres.length >= 20) break;
        }
      }
    }

    final publisher = _firstText([
      editionRaw?['publishers'],
      searchDoc?['publisher'],
    ]);

    final pageCount = _parseInt(editionRaw?['number_of_pages']);

    final creators = <Map<String, dynamic>>[];
    final authors = _textList(searchDoc?['author_name']);
    for (final author in authors) {
      creators.add({
        'name': author,
        'role': 'author',
        'external_ids': {},
      });
    }

    final providerIds = <String, String>{};
    if (primaryId.isNotEmpty) {
      providerIds['openlibrary'] = primaryId;
    }
    if (editionId != null && editionId.isNotEmpty && editionId != primaryId) {
      providerIds['openlibrary_edition'] = editionId;
    }

    final volumeProviderIds = <String, String>{};
    if (workId != null && workId.isNotEmpty && workId != primaryId) {
      volumeProviderIds['openlibrary'] = workId;
    }

    final coverUrl =
        _coverUrl(editionRaw ?? searchDoc ?? workRaw ?? {}, isbn: isbn);

    return {
      'kind': 'book',
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (synopsis != null) 'synopsis': synopsis,
      'publisher': publisher,
      if (pageCount != null) 'page_count': pageCount,
      'release_date': releaseDate?.toIso8601String().split('T').first,
      if (isbn != null) 'isbn': isbn,
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
      'volume_provider_ids': volumeProviderIds,
    };
  }

  ProviderSearchResult _searchResultFromDoc(Map<String, dynamic> doc) {
    final title = _optionalText(doc['title']) ?? 'Unknown Open Library book';
    final providerItemId = _editionKey(doc) ?? _workId(doc) ?? '';
    final authors = _textList(doc['author_name']);
    final publishers = _textList(doc['publisher']);
    final firstPublishYear = _optionalText(doc['first_publish_year']);

    final summaryParts = <String>[];
    if (authors.isNotEmpty) {
      summaryParts.add(authors.take(2).join(', '));
    }
    if (firstPublishYear != null) {
      summaryParts.add(firstPublishYear);
    }
    if (publishers.isNotEmpty) {
      summaryParts.add(publishers.first);
    }

    final isbn = _firstText([doc['isbn']]);

    return ProviderSearchResult(
      provider: name,
      providerItemId: providerItemId,
      title: title,
      kind: 'book',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _coverUrl(doc, isbn: isbn),
      publisher: publishers.isNotEmpty ? publishers.first : null,
    );
  }

  String? _normalizeProviderId(String? value) {
    if (value == null) return null;
    var text = value.trim();
    if (text.isEmpty) return null;
    text = text
        .replaceAll('/books/', '')
        .replaceAll('/works/', '')
        .replaceAll('/isbn/', '');

    if (text.toUpperCase().startsWith('ISBN:')) {
      return 'ISBN:${text.substring(5).trim()}';
    }
    if (RegExp(r'^\d{9}[\dX]$', caseSensitive: false).hasMatch(text) ||
        RegExp(r'^\d{13}$').hasMatch(text)) {
      return 'ISBN:$text';
    }
    final match = _olidRegex.firstMatch(text);
    if (match != null) {
      return 'OL${match.group(1)}';
    }
    return text.startsWith('OL') ? text : 'OL$text';
  }

  String? _editionKey(Map<String, dynamic>? data) {
    if (data == null) return null;
    final editionKeys = data['edition_key'];
    final editionId = _firstText([editionKeys]);
    if (editionId != null) {
      return _normalizeProviderId(editionId);
    }
    return _editionId(data);
  }

  String? _editionId(Map<String, dynamic>? data) {
    if (data == null) return null;
    final key = data['key'] ?? data['ocaid'];
    return _normalizeProviderId(key?.toString());
  }

  String? _workId(Map<String, dynamic>? data) {
    if (data == null) return null;
    final key = data['key'];
    return _normalizeProviderId(key?.toString());
  }

  String? _workIdFromEdition(Map<String, dynamic>? data) {
    if (data == null) return null;
    final works = data['works'];
    if (works is List && works.isNotEmpty) {
      final first = works.first;
      if (first is Map) {
        return _normalizeProviderId(first['key']?.toString());
      }
    }
    return null;
  }

  String? _coverUrl(Map<String, dynamic> data, {String? isbn}) {
    final coverId = _firstText([data['covers'], data['cover_i']]);
    if (coverId != null && coverId.isNotEmpty && coverId != '-1') {
      return '$coversBaseUrl/b/id/$coverId-L.jpg';
    }
    if (isbn != null && isbn.isNotEmpty) {
      return '$coversBaseUrl/b/isbn/$isbn-L.jpg';
    }
    return null;
  }

  String? _description(dynamic value) {
    if (value is Map) {
      return _optionalText(value['value']);
    }
    return _optionalText(value);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is int && value > 0 && value < 10000) {
      return DateTime.utc(value, 1, 1);
    }
    final text = _optionalText(value);
    if (text == null) return null;
    final match = _yearRegex.firstMatch(text);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      if (year != null) {
        return DateTime.utc(year, 1, 1);
      }
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value != null) {
      return int.tryParse(value.toString());
    }
    return null;
  }

  String? _firstText(List<dynamic> values) {
    for (final val in values) {
      if (val is List) {
        for (final item in val) {
          final t = _optionalText(item);
          if (t != null) return t;
        }
      } else {
        final t = _optionalText(val);
        if (t != null) return t;
      }
    }
    return null;
  }

  List<String> _textList(dynamic value) {
    if (value is List) {
      final list = <String>[];
      for (final item in value) {
        final t = _optionalText(item);
        if (t != null) list.add(t);
      }
      return list;
    }
    final t = _optionalText(value);
    return t != null ? [t] : [];
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
