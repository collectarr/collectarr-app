import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/musicbrainz/musicbrainz_music_mapper.dart';

const _coverArtArchiveBaseUrl = 'https://coverartarchive.org';

/// Kind-owned facade over the MusicBrainz wire transport.
final class MusicMusicBrainzIntegration {
  MusicMusicBrainzIntegration({MusicBrainzProvider? provider})
      : _provider = provider ?? MusicBrainzProvider();

  final MusicBrainzProvider _provider;

  Future<MusicRelease> fetchRelease(String providerItemId) async {
    final response = await _provider.fetchRelease(providerItemId);
    final candidate = MusicBrainzMusicMapper.releaseCandidate(
      response.payload,
      coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
      provenance: response.provenance,
      attribution: response.attribution,
      isHydrated: true,
    );
    return MusicMusicBrainzMapper.fromCandidate(candidate);
  }

  Future<MusicReleaseGroup> fetchReleaseGroup(String providerItemId) async {
    final response = await _provider.fetchReleaseGroup(providerItemId);
    final candidate = MusicBrainzMusicMapper.releaseGroupCandidate(
      response.payload,
      coverArtArchiveBaseUrl: _coverArtArchiveBaseUrl,
      provenance: response.provenance,
      attribution: response.attribution,
    );
    return MusicMusicBrainzMapper.releaseGroupFromCandidate(candidate);
  }

  Future<List<MusicReleaseCandidate>> searchReleaseCandidates(
    String query, {
    int limit = 25,
  }) async {
    final response = await _provider.searchReleases(query, limit: limit);
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

  Future<List<MusicReleaseGroupCandidate>> searchReleaseGroupCandidates(
    String query, {
    int limit = 25,
  }) async {
    final response = await _provider.searchReleaseGroups(query, limit: limit);
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

  MusicRelease mapNative(MusicBrainzRelease release) {
    return MusicMusicBrainzMapper.fromNative(release);
  }
}
