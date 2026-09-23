import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_metadata.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/transport/provider_envelope.dart';
import 'package:collectarr_app/features/providers/runtime/provider_runtime.dart';
import 'musicbrainz_music_mapper.dart';

/// Adapts the MusicBrainz wire client to Music's typed provider capability.
///
/// The adapter is owned by Music, so the provider package remains unaware of
/// Music candidate/domain types while the generic connector still receives a
/// structural kind-owned capability.
final class MusicMusicBrainzProviderAdapter extends MusicProviderAdapter {
  MusicMusicBrainzProviderAdapter({MusicBrainzProvider? provider})
      : _provider = provider ?? MusicBrainzProvider();

  static const _coverArtArchiveBaseUrl = 'https://coverartarchive.org';

  final MusicBrainzProvider _provider;

  @override
  ProviderDescriptor get descriptor =>
      MusicBrainzProvider.musicBrainzDescriptor;

  @override
  Future<List<MusicProviderCandidate>> searchCandidates(
    String query, {
    required CatalogMediaKind kind,
    required LibraryEntityScope entityScope,
    int limit = 25,
    ProviderCancellationToken? cancellationToken,
  }) async {
    if (cancellationToken?.isCancelled ?? false) {
      return const <MusicProviderCandidate>[];
    }
    if (kind != CatalogMediaKind.music) {
      return const <MusicProviderCandidate>[];
    }
    if (entityScope == LibraryEntityScope.work) {
      final response = await _provider.searchReleaseGroups(
        query,
        limit: limit,
        cancellationToken: cancellationToken,
      );
      return [
        for (final group in response.payload)
          MusicBrainzMusicMapper.releaseGroupCandidate(
            group,
            coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
            provenance: response.provenance,
            attribution: response.attribution,
          ),
      ];
    }
    final response = await _provider.searchReleases(
      query,
      limit: limit,
      cancellationToken: cancellationToken,
    );
    return [
      for (final release in response.payload)
        MusicBrainzMusicMapper.releaseCandidate(
          release,
          coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
          provenance: response.provenance,
          attribution: response.attribution,
        ),
    ];
  }

  @override
  Future<ProviderEnvelope<MusicProviderCandidate>> fetchCandidate(
    String providerItemId,
  ) async {
    if (MusicBrainzProvider.releaseGroupIdFromProviderItemId(
          providerItemId,
        ) !=
        null) {
      final response = await _provider.fetchReleaseGroup(providerItemId);
      final typed = MusicBrainzMusicMapper.releaseGroupEnvelope(
        response.payload,
        providerItemId: response.providerItemId,
        coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
        provenance: response.provenance,
        attribution: response.attribution,
      );
      return ProviderEnvelope<MusicProviderCandidate>(
        provider: typed.provider,
        providerItemId: typed.providerItemId,
        entityScope: typed.entityScope,
        payload: typed.payload,
        provenance: typed.provenance,
        images: typed.images,
        attribution: typed.attribution,
      );
    }
    final response = await _provider.fetchRelease(providerItemId);
    final typed = MusicBrainzMusicMapper.releaseEnvelope(
      response.payload,
      coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
      provenance: response.provenance,
      attribution: response.attribution,
    );
    return ProviderEnvelope<MusicProviderCandidate>(
      provider: typed.provider,
      providerItemId: typed.providerItemId,
      entityScope: typed.entityScope,
      payload: typed.payload,
      provenance: typed.provenance,
      images: typed.images,
      attribution: typed.attribution,
    );
  }
}
