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
import 'models/gcd_issue.dart';

final RegExp _issueIdRegex = RegExp(r'/issue/(\d+)/?');
final RegExp _seriesYearRegex =
    RegExp(r'\s+\((\d{4})\s+series\)$', caseSensitive: false);
final RegExp _issueQueryRegex = RegExp(
  r'^(.*?)\s*(?:#|issue\s+|no\.?\s*)?\s*(\d+[A-Za-z0-9./-]*)$',
  caseSensitive: false,
);

class GCDProvider extends ProviderAdapter {
  GCDProvider({
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://www.comics.org/api',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'gcd',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.gcd(),
            );

  final ProviderHttpClient _client;
  final String baseUrl;

  static const ProviderDescriptor gcdDescriptor = ProviderDescriptor(
    name: 'gcd',
    displayName: 'Grand Comics Database',
    kind: 'comic',
    supportedKinds: ['comic'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: false,
    nonCommercialOnly: false,
    allowsRedistribution: true,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'CC BY-SA 4.0',
    termsUrl: 'https://www.comics.org/',
    attributionUrl: 'https://www.comics.org/',
    rateLimit: '2 req/sec',
    cachePolicy:
        'Cache with attribution and share-alike provenance; cover rights vary.',
  );

  @override
  ProviderDescriptor get descriptor => gcdDescriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage => 'GCD metadata is available without an API key.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final trimmed = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return [];

    final (seriesName, issueNumber) = _parseSearchQuery(trimmed);

    final path = issueNumber != null
        ? '/series/name/${Uri.encodeComponent(seriesName)}/issue/${Uri.encodeComponent(issueNumber)}/'
        : '/series/name/${Uri.encodeComponent(seriesName)}/issue/1/';

    final response = await _client.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) return [];

    final resultsList = data['results'];
    if (resultsList is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final item in resultsList.take(limit)) {
      if (item is! Map) continue;
      final itemMap = Map<String, dynamic>.from(item);
      final searchResult = _searchResultFromIssue(GcdIssue.fromJson(itemMap));
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
    final issueId = _extractIssueId(providerItemId);
    if (issueId == null || issueId.isEmpty) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid GCD issue ID: $providerItemId',
      );
    }

    final response =
        await _client.get<Map<String, dynamic>>('/issue/$issueId/');
    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for GCD issue ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(data);
    final issue = GcdIssue.fromJson(raw);
    final normalized = normalizeIssue(issue);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'Grand Comics Database',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: issueId,
      kind: 'comic',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://www.comics.org/issue/$issueId/',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by Grand Comics Database',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    return normalizeIssue(GcdIssue.fromJson(data));
  }

  Map<String, dynamic> normalizeIssue(GcdIssue issue) {
    final issueId = _extractIssueId(issue.apiUrl ?? issue.id);
    final rawSeriesName = issue.seriesName ?? 'Unknown comic';
    final seriesTitle = _cleanSeriesTitle(rawSeriesName);
    final issueNumber = issue.number ?? issue.descriptor;
    final issueTitle = issue.title;
    final title = (issueTitle != null && issueTitle.isNotEmpty)
        ? issueTitle
        : (issueNumber != null ? '$seriesTitle #$issueNumber' : seriesTitle);

    final publisher = issue.publisherName;
    final synopsis = _extractSynopsis(issue);
    final coverUrl = issue.cover;
    final creators =
        _extractCredits(issue.stories, issueEditing: issue.editing);
    final characters = _extractCharacters(issue.stories);
    final storyArcs = _extractStoryArcs(issue.stories);

    final providerIds = <String, String>{};
    if (issueId != null && issueId.isNotEmpty) {
      providerIds['gcd'] = issueId;
    }

    return {
      'kind': 'comic',
      'title': title,
      if (seriesTitle.isNotEmpty) 'series_title': seriesTitle,
      if (issueNumber != null) 'item_number': issueNumber,
      if (publisher != null) 'publisher': publisher,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      'creators': creators,
      'characters': characters,
      'genres': <String>[],
      'story_arcs': storyArcs,
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

  ProviderSearchResult _searchResultFromIssue(GcdIssue issue) {
    final issueId = _extractIssueId(issue.apiUrl ?? issue.id) ?? '';
    final seriesName = issue.seriesName ?? 'Unknown GCD issue';
    final seriesTitle = _cleanSeriesTitle(seriesName);
    final descriptor = issue.descriptor;
    final issueNumber = descriptor ?? issue.number;
    final title = descriptor != null ? '$seriesName #$descriptor' : seriesName;

    final pubDate = issue.publicationDate;
    final price = issue.price;

    final summaryParts = <String>[
      if (pubDate != null && pubDate.isNotEmpty) pubDate,
      if (price != null && price.isNotEmpty) price,
    ];

    final characterPreview = <String>[];
    for (final char in _extractCharacters(issue.stories)) {
      final name = char['name']?.toString();
      if (name != null) characterPreview.add(name);
    }

    final storyArcPreview = _extractStoryArcs(issue.stories);

    return ProviderSearchResult(
      provider: name,
      providerItemId: issueId,
      title: title,
      kind: 'comic',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: issue.cover,
      seriesTitle: seriesTitle,
      issueNumber: issueNumber,
      candidateType: issue.variantOf != null ? 'variant' : 'issue',
      isVariant: issue.variantOf != null,
      characterPreview: characterPreview,
      storyArcPreview: storyArcPreview,
    );
  }

  (String, String?) _parseSearchQuery(String query) {
    final match = _issueQueryRegex.firstMatch(query);
    if (match != null) {
      final series = match.group(1)?.trim();
      final issue = match.group(2)?.trim();
      if (series != null && series.isNotEmpty) {
        return (series, issue);
      }
    }
    return (query, null);
  }

  String? _extractIssueId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return trimmed;
    final match = _issueIdRegex.firstMatch(trimmed);
    return match?.group(1);
  }

  String _cleanSeriesTitle(String raw) {
    return raw.replaceAll(_seriesYearRegex, '').trim();
  }

  String? _extractSynopsis(GcdIssue issue) {
    final synopsis = issue.synopsis;
    if (synopsis != null && synopsis.isNotEmpty) return synopsis;

    for (final story in issue.stories) {
      final storySynopsis = story.synopsis;
      if (storySynopsis != null && storySynopsis.isNotEmpty) {
        return storySynopsis;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractCredits(Iterable<GcdStory> storySet,
      {String? issueEditing}) {
    final credits = <Map<String, dynamic>>[];

    for (final story in storySet) {
      _addCreditIfPresent(credits, story.script, 'writer');
      _addCreditIfPresent(credits, story.pencils, 'penciller');
      _addCreditIfPresent(credits, story.inks, 'inker');
      _addCreditIfPresent(credits, story.colors, 'colorist');
      _addCreditIfPresent(credits, story.letters, 'letterer');
      _addCreditIfPresent(credits, story.editing, 'editor');
    }

    _addCreditIfPresent(credits, issueEditing, 'editor');
    return credits;
  }

  void _addCreditIfPresent(
    List<Map<String, dynamic>> credits,
    dynamic value,
    String role,
  ) {
    if (value == null) return;
    final text = value.toString().trim();
    if (text.isEmpty || text == '?' || text.toLowerCase() == 'none') return;

    for (final name in text.split(RegExp(r'[,;]\s*|\s+and\s+'))) {
      final cleanName = name.trim();
      if (cleanName.isNotEmpty &&
          !credits.any((c) => c['name'] == cleanName && c['role'] == role)) {
        credits.add(<String, dynamic>{
          'name': cleanName,
          'role': role,
          'external_ids': <String, dynamic>{},
        });
      }
    }
  }

  List<Map<String, dynamic>> _extractCharacters(Iterable<GcdStory> storySet) {
    final characters = <Map<String, dynamic>>[];
    final seen = <String>{};

    for (final story in storySet) {
      final charText = story.characters;
      if (charText == null || charText.isEmpty) continue;

      for (final rawName in charText.split(RegExp(r'[;\n]\s*'))) {
        final name = rawName.split('(').first.trim();
        if (name.isNotEmpty && seen.add(name.toLowerCase())) {
          characters.add(<String, dynamic>{
            'name': name,
            'external_ids': <String, dynamic>{},
          });
        }
      }
    }
    return characters;
  }

  List<String> _extractStoryArcs(Iterable<GcdStory> storySet) {
    final arcs = <String>[];
    final seen = <String>{};

    for (final story in storySet) {
      final partOf = story.partOfIssueStoryArc;
      if (partOf != null &&
          partOf.isNotEmpty &&
          seen.add(partOf.toLowerCase())) {
        arcs.add(partOf);
      }
    }
    return arcs;
  }

  String? _optionalText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isNotEmpty ? text : null;
  }
}
