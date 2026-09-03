import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../credentials/models/comicvine_credentials.dart';
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
import 'models/comic_vine_issue.dart';

class ComicVineProvider extends ProviderAdapter {
  ComicVineProvider({
    this.credentials,
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://comicvine.gamespot.com/api',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'comicvine',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.comicVine(),
            );

  final ComicVineCredentials? credentials;
  final ProviderHttpClient _client;
  final String baseUrl;

  static const ProviderDescriptor comicVineDescriptor = ProviderDescriptor(
    name: 'comicvine',
    displayName: 'Comic Vine',
    kind: 'comic',
    supportedKinds: ['comic', 'manga'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: true,
    nonCommercialOnly: true,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'Comic Vine API Terms',
    termsUrl: 'https://comicvine.gamespot.com/api/',
    attributionUrl: 'https://comicvine.gamespot.com/',
    rateLimit: '200 req/15min',
    cachePolicy:
        'Cache per instance to reduce duplicate API calls; do not redistribute.',
  );

  @override
  ProviderDescriptor get descriptor => comicVineDescriptor;

  @override
  bool get isConfigured => credentials?.isValid ?? false;

  @override
  String get statusMessage => isConfigured
      ? 'Comic Vine API key configured.'
      : 'Comic Vine requires an API key. Get one at https://comicvine.gamespot.com/api/';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final targetKind = _resolveTargetKind(kind);
    final issues = await searchIssues(query, limit: limit);
    return [
      for (final issue in issues) _searchResultFromIssue(issue, targetKind),
    ];
  }

  Future<List<ComicVineIssue>> searchIssues(
    String query, {
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    _ensureConfigured();

    final queryParams = <String, dynamic>{
      'api_key': credentials!.apiKey,
      'format': 'json',
      'query': normalizedQuery,
      'resources': 'issue',
      'limit': limit,
      'field_list':
          'id,api_detail_url,name,issue_number,deck,description,image,volume',
    };

    final response = await _client.get<Map<String, dynamic>>(
      '/search/',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data == null) return [];

    final resultsList = data['results'];
    if (resultsList is! List) return [];

    final results = <ComicVineIssue>[];
    for (final item in resultsList) {
      if (item is! Map) continue;
      final itemMap = Map<String, dynamic>.from(item);
      final issue = ComicVineIssue.fromJson(itemMap);
      if (_canonicalIssueId(issue.id).isNotEmpty) {
        results.add(issue);
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

    final (targetKind, resourceId) =
        _parseKindAndResourceId(providerItemId, defaultKind: kind);
    final canonicalId = _canonicalIssueId(resourceId);

    final queryParams = <String, dynamic>{
      'api_key': credentials!.apiKey,
      'format': 'json',
      'field_list':
          'id,api_detail_url,site_detail_url,name,issue_number,deck,description,cover_date,store_date,number_of_pages,person_credits,character_credits,story_arc_credits,image,associated_images,volume',
    };

    final response = await _client.get<Map<String, dynamic>>(
      '/issue/$canonicalId/',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No issue found for Comic Vine ID: $providerItemId',
      );
    }

    final rawItem = data['results'];
    if (rawItem is! Map) {
      throw ProviderNotFoundException(
        provider: name,
        message:
            'Invalid response from Comic Vine for issue ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(rawItem);
    raw['media_type'] = targetKind;
    final issue = ComicVineIssue.fromJson(raw);

    final normalized = normalizeIssue(issue);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'Comic Vine',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    for (final variant in issue.associatedImages) {
      final vcUrl = _extractImageUrl(variant);
      if (vcUrl != null) {
        images.add(
          ProviderImageRef(
            provider: name,
            url: vcUrl,
            thumbnailUrl:
                variant.squareMini ?? variant.iconUrl ?? variant.thumbUrl,
            kind: 'variant_cover',
            attribution: 'Comic Vine',
            cachePolicy: descriptor.cachePolicy,
          ),
        );
      }
    }

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: canonicalId,
      kind: targetKind,
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: _optionalText(raw['site_detail_url']) ??
            'https://comicvine.gamespot.com/issue/$canonicalId/',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by Comic Vine',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    return normalizeIssue(ComicVineIssue.fromJson(data));
  }

  Map<String, dynamic> normalizeIssue(ComicVineIssue issue) {
    final rawKind = issue.mediaType ?? 'comic';
    final issueNumber = issue.issueNumber;
    final volumeName = issue.volume?.name;
    final issueName = issue.name;

    final title = _buildTitle(
        volumeName: volumeName, issueName: issueName, issueNumber: issueNumber);
    final synopsis = _cleanHtml(issue.description ?? issue.deck);
    final coverUrl = _extractImageUrl(issue.image);
    final creators = _extractCreators(issue.personCredits);
    final publisher = issue.volume?.publisherName;
    final variantCovers = _extractVariantCovers(issue.associatedImages);
    final volumeStartYear = issue.volume?.startYear;

    final canonicalId = _canonicalIssueId(issue.id);
    final providerIds = <String, String>{};
    if (canonicalId.isNotEmpty) {
      providerIds['comicvine'] = canonicalId;
    }

    return {
      'kind': rawKind,
      'title': title,
      if (issueNumber != null) 'item_number': issueNumber,
      if (volumeName != null) 'series_title': volumeName,
      if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
      if (synopsis != null) 'synopsis': synopsis,
      if (publisher != null) 'publisher': publisher,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      'creators': creators,
      'genres': <String>[],
      'characters': <dynamic>[],
      'story_arcs': <dynamic>[],
      'platforms': <dynamic>[],
      'tracks': <dynamic>[],
      'variant_covers': variantCovers,
      'trailer_urls': <dynamic>[],
      'external_ids': <String, dynamic>{},
      'external_links': <dynamic>[],
      'relations': <dynamic>[],
      'provider_ids': providerIds,
      'volume_provider_ids': <String, dynamic>{},
    };
  }

  ProviderSearchResult _searchResultFromIssue(
      ComicVineIssue issue, String kind) {
    final issueNumber = issue.issueNumber;
    final volumeName = issue.volume?.name;
    final issueName = issue.name;

    final title = _buildTitle(
        volumeName: volumeName, issueName: issueName, issueNumber: issueNumber);
    final canonicalId = _canonicalIssueId(issue.id);

    final summaryParts = <String>[
      if (volumeName != null && volumeName.isNotEmpty) volumeName,
      if (issueNumber != null && issueNumber.isNotEmpty) '#$issueNumber',
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: canonicalId,
      title: title,
      kind: kind,
      summary: summaryParts.isNotEmpty ? summaryParts.join(' ') : null,
      imageUrl: _extractImageUrl(issue.image),
      seriesTitle: volumeName,
      issueNumber: issueNumber,
    );
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw ProviderAuthException(
        provider: name,
        message: 'Comic Vine API key is not configured',
      );
    }
  }

  String _resolveTargetKind(String? kind) {
    if (kind == null) return 'comic';
    final norm = kind.trim().toLowerCase();
    return norm == 'manga' ? 'manga' : 'comic';
  }

  (String, String) _parseKindAndResourceId(String value,
      {String? defaultKind}) {
    final text = value.trim();
    if (text.contains(':')) {
      final parts = text.split(':');
      final prefix = parts[0].trim().toLowerCase();
      final suffix = parts[1].trim();
      if (prefix == 'comic' || prefix == 'manga') {
        return (prefix, suffix);
      }
    }
    return (_resolveTargetKind(defaultKind), text);
  }

  String _canonicalIssueId(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return '';
    final text = rawId.trim();
    if (text.startsWith('4000-')) return text;
    if (int.tryParse(text) != null) return '4000-$text';
    return text;
  }

  String _buildTitle({
    String? volumeName,
    String? issueName,
    String? issueNumber,
  }) {
    if (volumeName != null && volumeName.isNotEmpty) {
      if (issueNumber != null && issueNumber.isNotEmpty) {
        return '$volumeName #$issueNumber';
      }
      return volumeName;
    }
    if (issueName != null && issueName.isNotEmpty) {
      return issueName;
    }
    return 'Unknown Comic';
  }

  String? _extractImageUrl(ComicVineImage? image) {
    return image?.superUrl ??
        image?.mediumUrl ??
        image?.scaleLarge ??
        image?.originalUrl;
  }

  List<Map<String, dynamic>> _extractCreators(
      Iterable<ComicVinePerson> personCredits) {
    final creators = <Map<String, dynamic>>[];

    for (final person in personCredits) {
      final name = person.name;
      final role = person.role;
      if (name != null && name.isNotEmpty) {
        creators.add(<String, dynamic>{
          'name': name,
          'role': role ?? 'Creator',
          'external_ids': <String, dynamic>{},
        });
      }
    }
    return creators;
  }

  List<Map<String, dynamic>> _extractVariantCovers(
      Iterable<ComicVineImage> associatedImages) {
    final variants = <Map<String, dynamic>>[];

    for (final img in associatedImages) {
      final url = img.scaleLarge ?? img.originalUrl ?? img.superUrl;
      final thumb = img.squareMini ?? img.iconUrl ?? img.thumbUrl;
      final caption = img.caption ?? 'Variant Cover';

      if (url != null) {
        variants.add({
          'name': caption,
          'cover_image_url': url,
          if (thumb != null) 'thumbnail_image_url': thumb,
        });
      }
    }
    return variants;
  }

  String? _cleanHtml(String? text) {
    if (text == null) return null;
    final withoutTags = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return withoutTags.isNotEmpty ? withoutTags : null;
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
