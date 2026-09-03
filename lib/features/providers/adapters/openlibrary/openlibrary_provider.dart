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
import '../provider_adapter.dart';
import 'models/open_library_book.dart';

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
      final searchDoc =
          OpenLibrarySearchDoc.fromJson(Map<String, dynamic>.from(doc));
      final result = _searchResultFromDoc(searchDoc);
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

    OpenLibraryWork? work;
    OpenLibraryEdition? edition;
    String rawPayloadString = '';

    if (providerId.toUpperCase().startsWith('ISBN:')) {
      final isbn = providerId.substring(5);
      final response =
          await _client.get<Map<String, dynamic>>('/isbn/$isbn.json');
      edition = response.data != null
          ? OpenLibraryEdition.fromJson(response.data!)
          : null;
      rawPayloadString = jsonEncode(response.data);
    } else if (providerId.toUpperCase().endsWith('M')) {
      final response =
          await _client.get<Map<String, dynamic>>('/books/$providerId.json');
      edition = response.data != null
          ? OpenLibraryEdition.fromJson(response.data!)
          : null;
      rawPayloadString = jsonEncode(response.data);
    } else {
      final response =
          await _client.get<Map<String, dynamic>>('/works/$providerId.json');
      work = response.data != null
          ? OpenLibraryWork.fromJson(response.data!)
          : null;
      rawPayloadString = jsonEncode(response.data);
    }

    if (edition != null && work == null) {
      final workId = _workIdFromEditionModel(edition);
      if (workId != null) {
        try {
          final workResp =
              await _client.get<Map<String, dynamic>>('/works/$workId.json');
          if (workResp.data != null) {
            work = OpenLibraryWork.fromJson(workResp.data!);
          }
        } catch (_) {
          // Non-fatal if work endpoint fails when edition is loaded
        }
      }
    }

    if (work == null && edition == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for Open Library ID: $providerItemId',
      );
    }

    final normalized = normalizeTyped(work: work, edition: edition);
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
    return normalizeTyped(
      work: workRaw == null ? null : OpenLibraryWork.fromJson(workRaw),
      edition:
          editionRaw == null ? null : OpenLibraryEdition.fromJson(editionRaw),
      searchDoc:
          searchDoc == null ? null : OpenLibrarySearchDoc.fromJson(searchDoc),
    );
  }

  Map<String, dynamic> normalizeTyped({
    OpenLibraryWork? work,
    OpenLibraryEdition? edition,
    OpenLibrarySearchDoc? searchDoc,
  }) {
    final title =
        edition?.title ?? work?.title ?? searchDoc?.title ?? 'Unknown book';

    final subtitle = edition?.subtitle;
    final synopsis = edition?.description ?? work?.description;

    final isbn = _firstText([
      edition?.isbn13,
      edition?.isbn10,
      searchDoc?.isbn,
    ]);

    final workId =
        _workIdFromEditionModel(edition) ?? _normalizeProviderId(work?.key);
    final editionId = _editionIdModel(edition) ?? _editionKeyModel(searchDoc);
    final primaryId = workId ?? editionId ?? '';

    final publishDateRaw = edition?.publishDate ?? searchDoc?.firstPublishYear;
    final releaseDate = _parseDate(publishDateRaw);

    final genres = <String>[];
    for (final subject in work?.subjects ?? const <String>[]) {
      if (subject.trim().isNotEmpty) {
        genres.add(subject.trim());
        if (genres.length >= 20) break;
      }
    }

    final publisher = _firstText([
      edition?.publishers,
      searchDoc?.publishers,
    ]);

    final pageCount = edition?.numberOfPages;

    final creators = <Map<String, dynamic>>[];
    final authors = searchDoc?.authorNames ?? const <String>[];
    for (final author in authors) {
      creators.add(<String, dynamic>{
        'name': author,
        'role': 'author',
        'external_ids': <String, dynamic>{},
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

    final coverUrl = _coverUrlTyped(
      edition: edition,
      searchDoc: searchDoc,
      isbn: isbn,
    );

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
      'volume_provider_ids': volumeProviderIds,
    };
  }

  ProviderSearchResult _searchResultFromDoc(OpenLibrarySearchDoc doc) {
    final title = doc.title ?? 'Unknown Open Library book';
    final providerItemId =
        _editionKeyModel(doc) ?? _normalizeProviderId(doc.key) ?? '';
    final authors = doc.authorNames;
    final publishers = doc.publishers;
    final firstPublishYear = doc.firstPublishYear?.toString();

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

    final isbn = _firstText([doc.isbn]);

    return ProviderSearchResult(
      provider: name,
      providerItemId: providerItemId,
      title: title,
      kind: 'book',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _coverUrlTyped(
        searchDoc: doc,
        isbn: isbn,
      ),
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

  String? _editionKeyModel(OpenLibrarySearchDoc? data) {
    if (data == null) return null;
    final editionId = _firstText([data.editionKeys]);
    if (editionId != null) {
      return _normalizeProviderId(editionId);
    }
    return _normalizeProviderId(data.key);
  }

  String? _editionIdModel(OpenLibraryEdition? data) {
    if (data == null) return null;
    return _normalizeProviderId(data.key ?? data.ocaid);
  }

  String? _workIdFromEditionModel(OpenLibraryEdition? data) {
    if (data == null || data.works.isEmpty) return null;
    return _normalizeProviderId(data.works.first.key);
  }

  String? _coverUrlTyped({
    OpenLibraryEdition? edition,
    OpenLibrarySearchDoc? searchDoc,
    String? isbn,
  }) {
    final coverId = _firstText([
      edition?.covers,
      searchDoc?.coverId,
    ]);
    if (coverId != null && coverId.isNotEmpty && coverId != '-1') {
      return '$coversBaseUrl/b/id/$coverId-L.jpg';
    }
    if (isbn != null && isbn.isNotEmpty) {
      return '$coversBaseUrl/b/isbn/$isbn-L.jpg';
    }
    return null;
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

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
