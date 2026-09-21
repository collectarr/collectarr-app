import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../../core/models/catalog_media_kind.dart';

import '../../domain/models/provider_attribution.dart';
import '../../domain/models/provider_descriptor.dart';
import '../../domain/models/provider_exception.dart';
import '../../domain/models/provider_provenance.dart';
import '../../runtime/provider_http_client.dart';
import '../../runtime/provider_rate_limiter.dart';
import 'mapping/musicbrainz_music_mapper.dart';
import 'models/musicbrainz_release.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_metadata.dart';
import '../../transport/provider_envelope.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

final RegExp _mbidRegex = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

class MusicBrainzProvider extends MusicProviderAdapter {
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

  /// Typed release search used by the Music Add flow.
  Future<List<MusicReleaseCandidate>> searchReleaseCandidates(
    String query, {
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return const <MusicReleaseCandidate>[];

    final response = await _client.get<Map<String, dynamic>>(
      '/release',
      queryParameters: {
        'query': normalizedQuery,
        'fmt': 'json',
        'limit': limit,
      },
    );
    final data = response.data;
    final releases = data?['releases'];
    if (releases is! List) return const <MusicReleaseCandidate>[];

    final provenance = _provenance('https://musicbrainz.org/ws/2/release');
    final attribution = _attribution();
    return [
      for (final value in releases.take(limit))
        if (value is Map)
          MusicBrainzMusicMapper.releaseCandidate(
            MusicBrainzRelease.fromJson(Map<String, dynamic>.from(value)),
            coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
            provenance: provenance,
            attribution: attribution,
          ),
    ];
  }

  @override
  Future<List<MusicProviderCandidate>> searchCandidates(
    String query, {
    required CatalogMediaKind kind,
    required LibraryEntityScope entityScope,
    int limit = 25,
  }) async {
    if (kind != CatalogMediaKind.music) {
      return const <MusicProviderCandidate>[];
    }
    if (entityScope == LibraryEntityScope.work) {
      return searchReleaseGroupCandidates(query, limit: limit);
    }
    return searchReleaseCandidates(query, limit: limit);
  }

  /// Typed release-group search.  A group is an explicit Work candidate and
  /// its children remain typed release summaries.
  Future<List<MusicReleaseGroupCandidate>> searchReleaseGroupCandidates(
    String query, {
    int limit = 25,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) {
      return const <MusicReleaseGroupCandidate>[];
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/release-group',
      queryParameters: {
        'query': normalizedQuery,
        'fmt': 'json',
        'limit': limit,
      },
    );
    final data = response.data;
    final groups = data?['release-groups'];
    if (groups is! List) return const <MusicReleaseGroupCandidate>[];

    final provenance =
        _provenance('https://musicbrainz.org/ws/2/release-group');
    final attribution = _attribution();
    return [
      for (final value in groups.take(limit))
        if (value is Map)
          if (MusicBrainzReleaseGroupResponse.fromJson(
            Map<String, dynamic>.from(value),
          )
              case final group
              when group.id.isNotEmpty && group.title.isNotEmpty)
            MusicBrainzMusicMapper.releaseGroupCandidate(
              group,
              coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
              provenance: provenance,
              attribution: attribution,
            ),
    ];
  }

  Future<ProviderEnvelope<MusicReleaseCandidate>> fetchReleaseCandidate(
    String providerItemId,
  ) async {
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
    final provenance = _provenance(
      'https://musicbrainz.org/release/$id',
      raw: raw,
    );
    return MusicBrainzMusicMapper.releaseEnvelope(
      MusicBrainzRelease.fromJson(raw),
      coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
      provenance: provenance,
      attribution: _attribution(),
    );
  }

  @override
  Future<ProviderEnvelope<MusicProviderCandidate>> fetchCandidate(
    String providerItemId,
  ) async {
    final typed = releaseGroupIdFromProviderItemId(providerItemId) != null
        ? await fetchReleaseGroupCandidate(providerItemId)
        : await fetchReleaseCandidate(providerItemId);
    return ProviderEnvelope<MusicProviderCandidate>(
      schemaVersion: typed.schemaVersion,
      provider: typed.provider,
      providerItemId: typed.providerItemId,
      entityScope: typed.entityScope,
      payload: typed.payload,
      provenance: typed.provenance,
      images: typed.images,
      attribution: typed.attribution,
    );
  }

  Future<ProviderEnvelope<MusicReleaseGroupCandidate>>
      fetchReleaseGroupCandidate(String providerItemId) async {
    final id = releaseGroupIdFromProviderItemId(providerItemId) ??
        providerItemId.trim();
    if (!_mbidRegex.hasMatch(id)) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'Invalid MusicBrainz release group ID: $providerItemId',
      );
    }
    final response = await _client.get<Map<String, dynamic>>(
      '/release-group/$id',
      queryParameters: {
        'fmt': 'json',
        'inc': 'artist-credits+releases+tags',
      },
    );
    final data = response.data;
    if (data == null) {
      throw ProviderNotFoundException(
        provider: name,
        message: 'No metadata found for MusicBrainz release group: $id',
      );
    }
    final raw = Map<String, dynamic>.from(data);
    final provenance = _provenance(
      'https://musicbrainz.org/release-group/$id',
      raw: raw,
    );
    return MusicBrainzMusicMapper.releaseGroupEnvelope(
      MusicBrainzReleaseGroupResponse.fromJson(raw),
      providerItemId: releaseGroupProviderItemId(id),
      coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
      provenance: provenance,
      attribution: _attribution(),
    );
  }

  ProviderAttribution _attribution() => ProviderAttribution(
        required: true,
        text: 'Data provided by MusicBrainz',
        url: descriptor.attributionUrl,
        licenseName: descriptor.licenseName,
      );

  ProviderProvenance _provenance(
    String sourceUrl, {
    Map<String, dynamic>? raw,
  }) {
    return ProviderProvenance(
      fetchedAt: DateTime.now().toUtc().toIso8601String(),
      sourceUrl: sourceUrl,
      rawPayloadHash: raw == null
          ? null
          : sha256.convert(utf8.encode(jsonEncode(raw))).toString(),
      providerVersion: '1.0.0',
    );
  }
}
