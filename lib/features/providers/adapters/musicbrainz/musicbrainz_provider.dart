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

final RegExp _mbidRegex = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);
final RegExp _yearRegex = RegExp(r'\b(\d{4})\b');

class MusicBrainzProvider extends ProviderAdapter {
  MusicBrainzProvider({
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://musicbrainz.org/ws/2',
    this.coverArtArchiveBaseUrl = 'https://coverartarchive.org',
    this.contactEmail = 'contact@collectarr.app',
  }) : _client = httpClient ??
            ProviderHttpClient(
              provider: 'musicbrainz',
              baseUrl: baseUrl,
              customUserAgent: 'Collectarr/0.2.1 ($contactEmail)',
              rateLimiter: ProviderRateLimiter.musicBrainz(),
            );

  final ProviderHttpClient _client;
  final String baseUrl;
  final String coverArtArchiveBaseUrl;
  final String contactEmail;

  static const ProviderDescriptor musicBrainzDescriptor = ProviderDescriptor(
    name: 'musicbrainz',
    displayName: 'MusicBrainz',
    kind: 'music',
    supportedKinds: ['music'],
    supportsSearch: true,
    supportsIngest: true,
    requiresUserKey: false,
    nonCommercialOnly: false,
    allowsRedistribution: true,
    allowsImageMirroring: true,
    requiresAttribution: true,
    licenseName: 'MusicBrainz Data Licenses',
    termsUrl: 'https://musicbrainz.org/doc/MusicBrainz_Database',
    attributionUrl: 'https://musicbrainz.org/',
    rateLimit: '1 req/sec',
    cachePolicy:
        'Cache MusicBrainz metadata with attribution; cover art references use Cover Art Archive URLs.',
  );

  @override
  ProviderDescriptor get descriptor => musicBrainzDescriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage =>
      'MusicBrainz release metadata is available without an API key.';

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return [];

    final response = await _client.get<Map<String, dynamic>>(
      '/release',
      queryParameters: {
        'query': normalizedQuery,
        'fmt': 'json',
        'limit': limit,
      },
    );

    final data = response.data;
    if (data == null) return [];

    final releases = data['releases'];
    if (releases is! List) return [];

    final results = <ProviderSearchResult>[];
    for (final release in releases.take(limit)) {
      if (release is! Map) continue;
      final releaseMap = Map<String, dynamic>.from(release);
      final searchResult = _searchResultFromRelease(releaseMap);
      if (searchResult.providerItemId.isNotEmpty) {
        results.add(searchResult);
      }
    }
    return results;
  }

  /// Search MusicBrainz by release barcode / UPC.
  Future<List<ProviderSearchResult>> searchByBarcode(
    String barcode, {
    String? kind,
    int limit = 25,
  }) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return [];
    return search('barcode:$normalized', kind: kind, limit: limit);
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    final id = providerItemId.trim();
    if (!_mbidRegex.hasMatch(id)) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid MusicBrainz release ID: $providerItemId',
      );
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/release/$id',
      queryParameters: {
        'fmt': 'json',
        'inc': 'artist-credits+labels+release-groups+media+recordings',
      },
    );

    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for MusicBrainz ID: $providerItemId',
      );
    }

    final raw = Map<String, dynamic>.from(data);
    final normalized = normalize(raw);
    final coverUrl = normalized['cover_image_url']?.toString();

    final images = <ProviderImageRef>[];
    if (coverUrl != null && coverUrl.isNotEmpty) {
      images.add(
        ProviderImageRef(
          provider: name,
          url: coverUrl,
          kind: 'cover',
          attribution: 'MusicBrainz',
          cachePolicy: descriptor.cachePolicy,
        ),
      );
    }

    return NormalizedProviderEnvelopeV1(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: id,
      kind: 'music',
      normalized: normalized,
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://musicbrainz.org/release/$id',
        rawPayloadHash: sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
        providerVersion: '1.0.0',
      ),
      images: images,
      attribution: ProviderAttribution(
        required: true,
        text: 'Data provided by MusicBrainz',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      ),
    );
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final providerItemId = _optionalText(data['id']);
    final title = _optionalText(data['title']) ?? 'Unknown release';
    final releaseGroup =
        data['release-group'] is Map ? data['release-group'] as Map : null;
    final releaseDate = _parseDate(data['date']);
    final artistNames = _extractArtistNames(data['artist-credit']);
    final media = data['media'];
    final (trackCount, mediumFormats, tracks) = _extractMediaDetails(media);
    final publisher = _extractPublisher(data);
    final catalogNumber = _extractCatalogNumber(data);
    final barcode = _optionalText(data['barcode']);
    final coverUrl = _extractCoverUrl(data);
    final genres = _extractGenres(data);

    final creators = artistNames
        .map((name) => {
              'name': name,
              'role': 'Artist',
              'external_ids': {},
            })
        .toList(growable: false);

    final providerIds = <String, String>{};
    if (providerItemId != null && providerItemId.isNotEmpty) {
      providerIds['musicbrainz'] = providerItemId;
    }

    final volumeProviderIds = <String, String>{};
    final releaseGroupId = releaseGroup?['id']?.toString();
    if (releaseGroupId != null && releaseGroupId.isNotEmpty) {
      volumeProviderIds['musicbrainz'] = releaseGroupId;
    }

    return {
      'kind': 'music',
      'title': title,
      if (publisher != null) 'publisher': publisher,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (releaseDate != null)
        'release_date': releaseDate.toIso8601String().split('T').first,
      if (barcode != null) 'barcode': barcode,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      'creators': creators,
      'genres': genres,
      'characters': [],
      'story_arcs': [],
      'platforms': [],
      if (trackCount != null) 'track_count': trackCount,
      'tracks': tracks,
      'variant_covers': [],
      'trailer_urls': [],
      'external_ids': {},
      'external_links': [],
      'relations': [],
      'provider_ids': providerIds,
      'volume_provider_ids': volumeProviderIds,
    };
  }

  ProviderSearchResult _searchResultFromRelease(Map<String, dynamic> release) {
    final title =
        _optionalText(release['title']) ?? 'Unknown MusicBrainz release';
    final providerItemId = _optionalText(release['id']) ?? '';
    final artistNames = _extractArtistNames(release['artist-credit']);
    final date = _optionalText(release['date']);
    final country = _optionalText(release['country']);

    final summaryParts = <String>[
      if (artistNames.isNotEmpty) artistNames.join(', '),
      if (date != null && date.isNotEmpty) date,
      if (country != null && country.isNotEmpty) country,
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: providerItemId,
      title: title,
      kind: 'music',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      imageUrl: _extractCoverUrl(release),
    );
  }

  List<String> _extractArtistNames(dynamic artistCredit) {
    if (artistCredit is! List) return [];
    final names = <String>[];
    for (final credit in artistCredit) {
      if (credit is! Map) continue;
      final artist = credit['artist'];
      final name = artist is Map ? _optionalText(artist['name']) : null;
      final creditName = _optionalText(credit['name']);
      final finalName = name ?? creditName;
      if (finalName != null && finalName.isNotEmpty) {
        names.add(finalName);
      }
    }
    return names;
  }

  String? _extractPublisher(Map<String, dynamic> data) {
    final labels = data['label-info'];
    if (labels is! List) return null;
    for (final entry in labels) {
      if (entry is! Map) continue;
      final label = entry['label'];
      if (label is Map) {
        final name = _optionalText(label['name']);
        if (name != null && name.isNotEmpty) return name;
      }
    }
    return null;
  }

  String? _extractCatalogNumber(Map<String, dynamic> data) {
    final labels = data['label-info'];
    if (labels is! List) return null;
    for (final entry in labels) {
      if (entry is! Map) continue;
      final cat = _optionalText(entry['catalog-number']);
      if (cat != null && cat.isNotEmpty) return cat;
    }
    return null;
  }

  String? _extractCoverUrl(Map<String, dynamic> data) {
    final id = _optionalText(data['id']);
    if (id == null || id.isEmpty) return null;

    final caa = data['cover-art-archive'];
    final hasArtwork =
        caa is Map && (caa['artwork'] == true || caa['front'] == true);
    if (hasArtwork || id.isNotEmpty) {
      return '$coverArtArchiveBaseUrl/release/$id/front.jpg';
    }
    return null;
  }

  List<String> _extractGenres(Map<String, dynamic> data) {
    final genres = data['genres'] ?? data['tags'];
    if (genres is List) {
      final list = <String>[];
      for (final g in genres) {
        if (g is Map) {
          final name = _optionalText(g['name']);
          if (name != null) list.add(name);
        } else if (g != null && g.toString().trim().isNotEmpty) {
          list.add(g.toString().trim());
        }
      }
      return list;
    }
    return [];
  }

  (int?, List<String>, List<Map<String, dynamic>>) _extractMediaDetails(
      dynamic media) {
    if (media is! List || media.isEmpty) {
      return (null, <String>[], <Map<String, dynamic>>[]);
    }

    var totalTracks = 0;
    final formats = <String>[];
    final tracks = <Map<String, dynamic>>[];

    for (var discIndex = 1; discIndex <= media.length; discIndex++) {
      final medium = media[discIndex - 1];
      if (medium is! Map) continue;

      final count = _parseInt(medium['track-count']);
      if (count != null && count > 0) {
        totalTracks += count;
      }

      final fmt = _optionalText(medium['format']);
      if (fmt != null && !formats.contains(fmt)) {
        formats.add(fmt);
      }

      final rawTracks = medium['tracks'];
      if (rawTracks is! List) continue;

      for (final rawTrack in rawTracks) {
        if (rawTrack is! Map) continue;
        final position = _parseInt(rawTrack['position']);
        if (position == null) continue;

        final title = _optionalText(rawTrack['title']) ?? 'Untitled';
        final lengthMs = rawTrack['length'];
        final durationSeconds =
            (lengthMs is num && lengthMs > 0) ? (lengthMs ~/ 1000) : null;

        final artistCredit = rawTrack['artist-credit'];
        final artistNames = _extractArtistNames(artistCredit);
        final artist = artistNames.isNotEmpty ? artistNames.join(', ') : null;

        tracks.add({
          'position': position,
          'title': title,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
          if (artist != null) 'artist': artist,
          if (media.length > 1) 'disc_number': discIndex,
        });
      }
    }

    return (totalTracks > 0 ? totalTracks : null, formats, tracks);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;

    final parts = text.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime.utc(y, m, d);
      }
    }

    final match = _yearRegex.firstMatch(text);
    if (match != null) {
      final y = int.tryParse(match.group(1)!);
      if (y != null) {
        return DateTime.utc(y, 1, 1);
      }
    }
    return null;
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
