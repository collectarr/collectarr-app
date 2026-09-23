import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../../core/models/catalog_media_kind.dart';

import '../../domain/models/provider_attribution.dart';
import '../../domain/models/provider_descriptor.dart';
import '../../domain/models/provider_exception.dart';
import '../../domain/models/provider_provenance.dart';
import '../../runtime/provider_http_client.dart';
import '../../runtime/provider_rate_limiter.dart';
import '../../runtime/provider_runtime.dart';
import 'models/musicbrainz_release.dart';
import 'models/musicbrainz_wire_response.dart';

final RegExp _mbidRegex = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// MusicBrainz protocol client.
///
/// This adapter knows the MusicBrainz HTTP contract and its wire DTOs only.
/// Mapping into Collectarr Music candidates belongs to the Music integration.
class MusicBrainzProvider {
  MusicBrainzProvider({
    ProviderHttpClient? httpClient,
    this.baseUrl = 'https://musicbrainz.org/ws/2',
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
  final String contactEmail;

  String get name => musicBrainzDescriptor.name;

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

  Future<MusicBrainzWireResponse<List<MusicBrainzRelease>>> searchReleases(
    String query, {
    int limit = 25,
    ProviderCancellationToken? cancellationToken,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) {
      return _searchResponse(
        const <MusicBrainzRelease>[],
        sourceUrl: 'https://musicbrainz.org/ws/2/release',
        providerItemId: normalizedQuery,
      );
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/release',
      queryParameters: {
        'query': normalizedQuery,
        'fmt': 'json',
        'limit': limit,
      },
      cancellationToken: cancellationToken,
    );
    final data = response.data;
    final releases = data?['releases'];
    if (releases is! List) {
      return _searchResponse(
        const <MusicBrainzRelease>[],
        sourceUrl: 'https://musicbrainz.org/ws/2/release',
        providerItemId: normalizedQuery,
      );
    }
    final values = [
      for (final value in releases.take(limit))
        if (value is Map)
          MusicBrainzRelease.fromJson(Map<String, dynamic>.from(value)),
    ];
    return _searchResponse(
      values,
      sourceUrl: 'https://musicbrainz.org/ws/2/release',
      providerItemId: normalizedQuery,
    );
  }

  Future<MusicBrainzWireResponse<List<MusicBrainzReleaseGroupResponse>>>
      searchReleaseGroups(
    String query, {
    int limit = 25,
    ProviderCancellationToken? cancellationToken,
  }) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) {
      return _searchResponse(
        const <MusicBrainzReleaseGroupResponse>[],
        sourceUrl: 'https://musicbrainz.org/ws/2/release-group',
        providerItemId: normalizedQuery,
      );
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/release-group',
      queryParameters: {
        'query': normalizedQuery,
        'fmt': 'json',
        'limit': limit,
      },
      cancellationToken: cancellationToken,
    );
    final data = response.data;
    final groups = data?['release-groups'];
    if (groups is! List) {
      return _searchResponse(
        const <MusicBrainzReleaseGroupResponse>[],
        sourceUrl: 'https://musicbrainz.org/ws/2/release-group',
        providerItemId: normalizedQuery,
      );
    }
    final values = [
      for (final value in groups.take(limit))
        if (value is Map)
          if (MusicBrainzReleaseGroupResponse.fromJson(
            Map<String, dynamic>.from(value),
          )
              case final group
              when group.id.isNotEmpty && group.title.isNotEmpty)
            group,
    ];
    return _searchResponse(
      values,
      sourceUrl: 'https://musicbrainz.org/ws/2/release-group',
      providerItemId: normalizedQuery,
    );
  }

  Future<MusicBrainzWireResponse<MusicBrainzRelease>> fetchRelease(
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
    return MusicBrainzWireResponse(
      providerItemId: id,
      payload: MusicBrainzRelease.fromJson(raw),
      provenance: provenance,
      attribution: _attribution(),
    );
  }

  Future<MusicBrainzWireResponse<MusicBrainzReleaseGroupResponse>>
      fetchReleaseGroup(String providerItemId) async {
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
    return MusicBrainzWireResponse(
      providerItemId: releaseGroupProviderItemId(id),
      payload: MusicBrainzReleaseGroupResponse.fromJson(raw),
      provenance: provenance,
      attribution: _attribution(),
    );
  }

  ProviderAttribution _attribution() => ProviderAttribution(
        required: true,
        text: 'Data provided by MusicBrainz',
        url: musicBrainzDescriptor.attributionUrl,
        licenseName: musicBrainzDescriptor.licenseName,
      );

  MusicBrainzWireResponse<List<T>> _searchResponse<T>(
    List<T> payload, {
    required String sourceUrl,
    required String providerItemId,
  }) {
    return MusicBrainzWireResponse(
      providerItemId: providerItemId,
      payload: List.unmodifiable(payload),
      provenance: _provenance(sourceUrl),
      attribution: _attribution(),
    );
  }

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
