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
      final id = item.getAttribute('id');
      if (id == null || id.isEmpty) continue;

      final nameElement = item.findElements('name').firstWhere(
            (e) => e.getAttribute('type') == 'primary',
            orElse: () => item.findElements('name').isNotEmpty
                ? item.findElements('name').first
                : XmlElement(const XmlName.parts('name')),
          );
      final title = nameElement.getAttribute('value') ?? 'Unknown Board Game';

      final yearElement = item.findElements('yearpublished').firstOrNull;
      final year = yearElement?.getAttribute('value');

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

    final raw = _thingItemRaw(itemElement);
    final normalized = normalize(raw);
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
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
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
    final bggId = _optionalText(data['id']);
    final title = _primaryName(data) ?? 'Unknown board game';
    final links = data['links'] is List
        ? (data['links'] as List<dynamic>)
        : const <dynamic>[];

    final publishers = _linkValues(links, 'boardgamepublisher');
    final designers = _linkValues(links, 'boardgamedesigner');
    final categories = _linkValues(links, 'boardgamecategory');
    final families = _linkValues(links, 'boardgamefamily');

    final minAge = _parseInt(data['minage']);
    final minPlayers = _parseInt(data['minplayers']);
    final maxPlayers = _parseInt(data['maxplayers']);
    final playingTime = _parseInt(data['playingtime']);

    final coverUrl =
        _optionalText(data['image']) ?? _optionalText(data['thumbnail']);
    final synopsis = _optionalText(data['description']);

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

  Map<String, dynamic> _thingItemRaw(XmlElement item) {
    final links = item.findElements('link').map((link) {
      return {
        'type': link.getAttribute('type'),
        'id': link.getAttribute('id'),
        'value': link.getAttribute('value'),
      };
    }).toList();

    final names = item.findElements('name').map((name) {
      return {
        'type': name.getAttribute('type'),
        'sortindex': name.getAttribute('sortindex'),
        'value': name.getAttribute('value'),
      };
    }).toList();

    return {
      'id': item.getAttribute('id'),
      'type': item.getAttribute('type'),
      'names': names,
      'description': item.findElements('description').firstOrNull?.innerText,
      'yearpublished':
          item.findElements('yearpublished').firstOrNull?.getAttribute('value'),
      'minplayers':
          item.findElements('minplayers').firstOrNull?.getAttribute('value'),
      'maxplayers':
          item.findElements('maxplayers').firstOrNull?.getAttribute('value'),
      'playingtime':
          item.findElements('playingtime').firstOrNull?.getAttribute('value'),
      'minplaytime':
          item.findElements('minplaytime').firstOrNull?.getAttribute('value'),
      'maxplaytime':
          item.findElements('maxplaytime').firstOrNull?.getAttribute('value'),
      'minage': item.findElements('minage').firstOrNull?.getAttribute('value'),
      'image': item.findElements('image').firstOrNull?.innerText,
      'thumbnail': item.findElements('thumbnail').firstOrNull?.innerText,
      'links': links,
    };
  }

  String? _primaryName(Map<String, dynamic> data) {
    final names = data['names'];
    if (names is! List) return null;

    for (final name in names) {
      if (name is Map) {
        final nameMap = Map<String, dynamic>.from(name);
        if (nameMap['type'] != 'primary') continue;
        final val = _optionalText(nameMap['value']);
        if (val != null) return val;
      }
    }
    if (names.isNotEmpty && names.first is Map) {
      final firstName = Map<String, dynamic>.from(names.first as Map);
      return _optionalText(firstName['value']);
    }
    return null;
  }

  List<String> _linkValues(List<dynamic> links, String linkType) {
    final values = <String>[];
    for (final link in links) {
      if (link is Map) {
        final linkMap = Map<String, dynamic>.from(link);
        if (linkMap['type'] != linkType) continue;
        final val = _optionalText(linkMap['value']);
        if (val != null && val.isNotEmpty) {
          values.add(val);
        }
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
