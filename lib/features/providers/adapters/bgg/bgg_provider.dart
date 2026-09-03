import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../credentials/models/bgg_credentials.dart';
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
import 'models/bgg_thing.dart';

class BGGProvider extends ProviderAdapter {
  BGGProvider({
    this.credentials,
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://boardgamegeek.com/xmlapi2',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'bgg',
              baseUrl: baseUrl,
              rateLimiter: ProviderRateLimiter.bgg(),
            );

  final BggCredentials? credentials;
  final ProviderHttpClient _client;
  final String baseUrl;

  static const ProviderDescriptor bggDescriptor = ProviderDescriptor(
    name: 'bgg',
    displayName: 'BoardGameGeek',
    kind: 'boardgame',
    supportedKinds: ['boardgame'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: true,
    nonCommercialOnly: true,
    allowsRedistribution: false,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'BoardGameGeek XML API Terms',
    termsUrl: 'https://boardgamegeek.com/wiki/page/BGG_XML_API2',
    attributionUrl: 'https://boardgamegeek.com/',
    rateLimit: '2 req/sec',
    cachePolicy:
        'Cache per instance to minimize XML API calls; do not redistribute as a competing database.',
  );

  @override
  ProviderDescriptor get descriptor => bggDescriptor;

  @override
  bool get isConfigured => credentials?.isValid ?? false;

  @override
  String get statusMessage => isConfigured
      ? 'BoardGameGeek API token configured.'
      : 'BoardGameGeek requires an API token configured in settings.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    _ensureConfigured();

    final headers = <String, String>{
      'Accept': 'application/xml',
      if (credentials?.apiToken != null &&
          credentials!.apiToken!.trim().isNotEmpty)
        'Authorization': 'Bearer ${credentials!.apiToken!.trim()}',
    };

    final response = await _client.get<String>(
      '/search',
      queryParameters: {
        'query': normalizedQuery,
        'type': 'boardgame',
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: headers,
      ),
    );

    final xmlString = response.data;
    if (xmlString == null || xmlString.trim().isEmpty) return [];

    final document = XmlDocument.parse(xmlString);
    final items = document.findAllElements('item');

    final results = <ProviderSearchResult>[];
    for (final item in items.take(limit)) {
      final thing = BggThing.fromXml(item);
      final id = thing.id;
      if (id == null || id.isEmpty) continue;

      final title = _primaryName(thing.names) ?? 'Unknown Board Game';
      final year = thing.yearPublished?.toString();

      results.add(
        ProviderSearchResult(
          provider: name,
          providerItemId: id,
          title: title,
          kind: 'boardgame',
          summary: year,
        ),
      );
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
    if (int.tryParse(cleanId) == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid BoardGameGeek item ID: $providerItemId',
      );
    }

    final headers = <String, String>{
      'Accept': 'application/xml',
      if (credentials?.apiToken != null &&
          credentials!.apiToken!.trim().isNotEmpty)
        'Authorization': 'Bearer ${credentials!.apiToken!.trim()}',
    };

    final response = await _client.get<String>(
      '/thing',
      queryParameters: {
        'id': cleanId,
        'stats': '1',
        'type': 'boardgame',
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: headers,
      ),
    );

    final xmlString = response.data;
    if (xmlString == null || xmlString.trim().isEmpty) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for BGG ID: $providerItemId',
      );
    }

    final document = XmlDocument.parse(xmlString);
    final itemElement = document.findAllElements('item').firstOrNull;
    if (itemElement == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'BoardGameGeek item not found: $providerItemId',
      );
    }

    final thing = BggThing.fromXml(itemElement);
    final normalized = normalizeThing(thing);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'BoardGameGeek',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: cleanId,
      kind: 'boardgame',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl:
            'https://boardgamegeek.com/boardgame/$cleanId/${_slug(normalized['title']?.toString() ?? 'game')}',
        rawPayloadHash:
            sha256.convert(utf8.encode(jsonEncode(thing.toJson()))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by BoardGameGeek',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    return normalizeThing(BggThing.fromJson(data));
  }

  Map<String, dynamic> normalizeThing(BggThing data) {
    final bggId = data.id;
    final title = _primaryName(data.names) ?? 'Unknown board game';

    final publishers = _linkValues(data.links, 'boardgamepublisher');
    final designers = _linkValues(data.links, 'boardgamedesigner');
    final categories = _linkValues(data.links, 'boardgamecategory');
    final families = _linkValues(data.links, 'boardgamefamily');

    final minAge = data.minAge;
    final minPlayers = data.minPlayers;
    final maxPlayers = data.maxPlayers;
    final playingTime = data.playingTime;

    final coverUrl = _optionalText(data.image) ?? _optionalText(data.thumbnail);
    final synopsis = _optionalText(data.description);

    final creators = designers
        .map((d) => <String, dynamic>{
              'name': d,
              'role': 'Designer',
              'external_ids': <String, dynamic>{},
            })
        .toList();

    final genres = <String>[
      ...categories,
      ...families.where((f) => !categories.contains(f)),
    ];

    final providerIds = <String, String>{};
    if (bggId != null && bggId.isNotEmpty) {
      providerIds['bgg'] = bggId;
    }

    return {
      'kind': 'boardgame',
      'title': title,
      if (synopsis != null) 'synopsis': synopsis,
      if (publishers.isNotEmpty) 'publisher': publishers.first,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      if (minPlayers != null) 'min_players': minPlayers,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (minAge != null) 'min_age': minAge,
      if (playingTime != null) 'playing_time_minutes': playingTime,
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

  String? _primaryName(List<BggName> names) {
    for (final name in names) {
      if (name.type != 'primary') continue;
      final value = _optionalText(name.value);
      if (value != null) return value;
    }
    return names.isNotEmpty ? _optionalText(names.first.value) : null;
  }

  List<String> _linkValues(List<BggLink> links, String linkType) {
    final values = <String>[];
    for (final link in links) {
      if (link.type != linkType) continue;
      final value = _optionalText(link.value);
      if (value != null && value.isNotEmpty) {
        values.add(value);
      }
    }
    return values;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw ProviderAuthException(
        provider: name,
        message: 'BoardGameGeek API credentials are not configured',
      );
    }
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
