import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../../../core/models/catalog_media_kind.dart';

import '../../transport/provider_metadata_envelope.dart';
import '../../domain/models/provider_attribution.dart';
import '../../domain/models/provider_descriptor.dart';
import '../../domain/models/provider_exception.dart';
import '../../domain/models/provider_image_ref.dart';
import '../../domain/models/provider_provenance.dart';
import '../../transport/provider_search_result.dart';
import '../../transport/provider_search_parent_hint.dart';
import '../../runtime/provider_http_client.dart';
import '../../runtime/provider_rate_limiter.dart';
import '../provider_adapter.dart';
import 'models/musicbrainz_release.dart';

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

  static const releaseGroupProviderItemPrefix = 'release-group:';

  static String releaseGroupProviderItemId(String groupId) =>
      '$releaseGroupProviderItemPrefix${groupId.trim()}';

  static String? releaseGroupIdFromProviderItemId(String providerItemId) {
    final value = providerItemId.trim();
    if (!value.startsWith(releaseGroupProviderItemPrefix)) return null;
    final groupId = value.substring(releaseGroupProviderItemPrefix.length);
    return _mbidRegex.hasMatch(groupId) ? groupId : null;
  }

  static const ProviderDescriptor musicBrainzDescriptor = ProviderDescriptor(
    name: 'musicbrainz',
    displayName: 'MusicBrainz',
    kind: CatalogMediaKind.music,
    supportedKinds: [CatalogMediaKind.music],
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
    CatalogMediaKind? kind,
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
      final typedRelease =
          MusicBrainzRelease.fromJson(Map<String, dynamic>.from(release));
      final searchResult = _searchResultFromRelease(typedRelease);
      if (searchResult.providerItemId.isNotEmpty) {
        results.add(searchResult);
      }
    }
    return results;
  }

  /// Search MusicBrainz by release barcode / UPC.
  Future<List<ProviderSearchResult>> searchByBarcode(
    String barcode, {
    CatalogMediaKind? kind,
    int limit = 25,
  }) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return [];
    return search('barcode:$normalized', kind: kind, limit: limit);
  }

  @override
  Future<ProviderMetadataEnvelope> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  }) async {
    final id = providerItemId.trim();
    final releaseGroupId = releaseGroupIdFromProviderItemId(id);
    if (releaseGroupId != null) {
      return _fetchReleaseGroup(
        providerItemId: id,
        releaseGroupId: releaseGroupId,
      );
    }
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
    final release = MusicBrainzRelease.fromJson(raw);
    final normalized = normalizeRelease(release);
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

    return ProviderMetadataEnvelope(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: id,
      kind: CatalogMediaKind.music,
      payload: ProviderMetadataPayload(normalized),
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

  Future<ProviderMetadataEnvelope> _fetchReleaseGroup({
    required String providerItemId,
    required String releaseGroupId,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/release-group/$releaseGroupId',
      queryParameters: {
        'fmt': 'json',
        'inc': 'artist-credits+releases+tags',
      },
    );

    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message:
            'No metadata found for MusicBrainz release group: $releaseGroupId',
      );
    }

    final raw = Map<String, dynamic>.from(data);
    final normalized = _normalizeReleaseGroup(raw, releaseGroupId);
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

    return ProviderMetadataEnvelope(
      schemaVersion: 'v1',
      provider: name,
      providerItemId: providerItemId,
      kind: CatalogMediaKind.music,
      payload: ProviderMetadataPayload(normalized),
      provenance: ProviderProvenance(
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
        sourceUrl: 'https://musicbrainz.org/release-group/$releaseGroupId',
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

  Map<String, dynamic> _normalizeReleaseGroup(
    Map<String, dynamic> raw,
    String releaseGroupId,
  ) {
    final group = MusicBrainzRelease.fromJson(raw);
    final title = group.releaseGroup?.title ??
        raw['title']?.toString().trim() ??
        'Unknown release group';
    final artistNames = _extractArtistNames(group.artistCredits);
    final firstReleaseDate =
        _parseDate(raw['first-release-date'] ?? raw['first_release_date']);
    final releases = <Map<String, dynamic>>[];
    final rawReleases = raw['releases'];
    if (rawReleases is List) {
      for (final value in rawReleases) {
        if (value is! Map) continue;
        final release = Map<String, dynamic>.from(value);
        final id = release['id']?.toString().trim();
        final releaseTitle = release['title']?.toString().trim();
        if (id == null ||
            id.isEmpty ||
            releaseTitle == null ||
            releaseTitle.isEmpty) {
          continue;
        }
        releases.add({
          'id': id,
          'kind': 'music',
          'release_group_id': releaseGroupId,
          'title': releaseTitle,
          if (_parseDate(release['date']) case final date?)
            'release_date': date.toIso8601String(),
          if (release['status'] != null)
            'release_status': release['status'].toString(),
          if (release['packaging'] != null)
            'packaging': release['packaging'].toString(),
          if (release['country'] != null)
            'country_code': release['country'].toString(),
          'cover_image_url': '$coverArtArchiveBaseUrl/release/$id/front.jpg',
          'mediums': const <Map<String, dynamic>>[],
        });
      }
    }

    return {
      'kind': 'music',
      'entity_type': 'music_release_group',
      'id': releaseGroupId,
      'title': title,
      if (artistNames.isNotEmpty) 'artist': artistNames.join(', '),
      if (firstReleaseDate != null)
        'original_release_date': firstReleaseDate.toIso8601String(),
      'release_group_id': releaseGroupId,
      'release_group_title': title,
      'cover_image_url':
          '$coverArtArchiveBaseUrl/release-group/$releaseGroupId/front.jpg',
      'creators': [
        for (final artist in artistNames)
          {
            'name': artist,
            'role': 'Artist',
          },
      ],
      'genres': group.genres.isNotEmpty ? group.genres : group.tags,
      'releases': releases,
      'tracks': const <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> normalize(Map<String, dynamic> data) {
    return normalizeRelease(MusicBrainzRelease.fromJson(data));
  }

  Map<String, dynamic> normalizeRelease(MusicBrainzRelease release) {
    final providerItemId = release.id;
    final title = release.title ?? 'Unknown release';
    final releaseDate = _parseDate(release.date);
    final artistNames = _extractArtistNames(release.artistCredits);
    final (trackCount, mediumFormats, tracks) =
        _extractMediaDetails(release.media);
    final publisher = _extractPublisher(release.labelInfo);
    final catalogNumber = _extractCatalogNumber(release.labelInfo);
    final barcode = release.barcode;
    final coverUrl = _extractCoverUrl(release);
    final genres = release.genres.isNotEmpty ? release.genres : release.tags;

    final creators = artistNames
        .map((name) => <String, dynamic>{
              'name': name,
              'role': 'Artist',
              'external_ids': <String, dynamic>{},
            })
        .toList(growable: false);

    final providerIds = <String, String>{};
    if (providerItemId != null && providerItemId.isNotEmpty) {
      providerIds['musicbrainz'] = providerItemId;
    }

    final volumeProviderIds = <String, String>{};
    final releaseGroupId = release.releaseGroup?.id;
    final releaseGroupTitle = release.releaseGroup?.title;
    if (releaseGroupId != null && releaseGroupId.isNotEmpty) {
      volumeProviderIds['musicbrainz'] = releaseGroupId;
    }

    return {
      'kind': 'music',
      'entity_type': 'music_release',
      if (providerItemId != null) 'id': providerItemId,
      'title': title,
      if (artistNames.isNotEmpty) 'artist': artistNames.join(', '),
      if (publisher != null) 'publisher': publisher,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (releaseDate != null)
        'release_date': releaseDate.toIso8601String().split('T').first,
      if (barcode != null) 'barcode': barcode,
      if (releaseGroupId != null) 'release_group_id': releaseGroupId,
      if (releaseGroupTitle != null) 'release_group_title': releaseGroupTitle,
      if (release.country != null) 'country': release.country,
      if (coverUrl != null) 'cover_image_url': coverUrl,
      if (mediumFormats.isNotEmpty) 'formats': mediumFormats,
      if (mediumFormats.isNotEmpty) 'format': mediumFormats.first,
      'creators': creators,
      'genres': genres,
      'characters': <dynamic>[],
      'story_arcs': <dynamic>[],
      'platforms': <dynamic>[],
      if (trackCount != null) 'track_count': trackCount,
      'tracks': tracks,
      'variant_covers': <dynamic>[],
      'trailer_urls': <dynamic>[],
      'external_ids': <String, dynamic>{},
      'external_links': <dynamic>[],
      'relations': <dynamic>[],
      'provider_ids': providerIds,
      'volume_provider_ids': volumeProviderIds,
    };
  }

  ProviderSearchResult _searchResultFromRelease(MusicBrainzRelease release) {
    final title = release.title ?? 'Unknown MusicBrainz release';
    final providerItemId = release.id ?? '';
    final artistNames = _extractArtistNames(release.artistCredits);
    final date = release.date;
    final country = release.country;
    final publisher = _extractPublisher(release.labelInfo);

    final summaryParts = <String>[
      if (artistNames.isNotEmpty) artistNames.join(', '),
      if (date != null && date.isNotEmpty) date,
      if (country != null && country.isNotEmpty) country,
    ];

    return ProviderSearchResult(
      provider: name,
      providerItemId: providerItemId,
      title: title,
      kind: CatalogMediaKind.music,
      candidateType: 'release',
      summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
      artist: artistNames.isNotEmpty ? artistNames.join(', ') : null,
      seriesTitle: artistNames.isNotEmpty ? artistNames.join(', ') : null,
      publisher: publisher,
      imageUrl: _extractCoverUrl(release),
      parent: release.releaseGroup == null
          ? null
          : ProviderSearchParentHint(
              id: release.releaseGroup!.id ?? '',
              title: release.releaseGroup!.title ?? title,
            ),
    );
  }

  List<String> _extractArtistNames(
    List<MusicBrainzArtistCredit> artistCredits,
  ) {
    final names = <String>[];
    for (final credit in artistCredits) {
      final name = credit.artist?.name;
      final creditName = credit.name;
      final finalName = name ?? creditName;
      if (finalName != null && finalName.isNotEmpty) {
        names.add(finalName);
      }
    }
    return names;
  }

  String? _extractPublisher(List<MusicBrainzLabelInfo> labelInfo) {
    for (final entry in labelInfo) {
      final name = entry.label?.name;
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  String? _extractCatalogNumber(List<MusicBrainzLabelInfo> labelInfo) {
    for (final entry in labelInfo) {
      final catalogNumber = entry.catalogNumber;
      if (catalogNumber != null && catalogNumber.isNotEmpty) {
        return catalogNumber;
      }
    }
    return null;
  }

  String? _extractCoverUrl(MusicBrainzRelease release) {
    final id = release.id;
    if (id == null || id.isEmpty) return null;

    final caa = release.coverArtArchive;
    final hasArtwork = caa != null && (caa.artwork || caa.front);
    if (hasArtwork || id.isNotEmpty) {
      return '$coverArtArchiveBaseUrl/release/$id/front.jpg';
    }
    return null;
  }

  (int?, List<String>, List<Map<String, dynamic>>) _extractMediaDetails(
      List<MusicBrainzMedium> media) {
    if (media.isEmpty) {
      return (null, <String>[], <Map<String, dynamic>>[]);
    }

    var totalTracks = 0;
    final formats = <String>[];
    final tracks = <Map<String, dynamic>>[];

    for (var discIndex = 1; discIndex <= media.length; discIndex++) {
      final medium = media[discIndex - 1];

      final count = medium.trackCount;
      if (count != null && count > 0) {
        totalTracks += count;
      }

      final fmt = medium.format;
      if (fmt != null && !formats.contains(fmt)) {
        formats.add(fmt);
      }

      for (final rawTrack in medium.tracks) {
        final position = rawTrack.position;
        if (position == null) continue;

        final title = rawTrack.title ?? 'Untitled';
        final lengthMs = rawTrack.length;
        final durationSeconds =
            (lengthMs != null && lengthMs > 0) ? (lengthMs ~/ 1000) : null;

        final artistNames = _extractArtistNames(rawTrack.artistCredits);
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
}
