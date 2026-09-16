import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';

/// Kind-owned facade over the shared MusicBrainz transport.
final class MusicMusicBrainzIntegration {
  MusicMusicBrainzIntegration({MusicBrainzProvider? provider})
      : _provider = provider ?? MusicBrainzProvider();

  final MusicBrainzProvider _provider;

  Future<MusicRelease> fetchRelease(String providerItemId) async {
    final envelope = await _provider.fetchReleaseCandidate(providerItemId);
    return MusicMusicBrainzMapper.fromCandidate(envelope.payload);
  }

  Future<MusicReleaseGroup> fetchReleaseGroup(String providerItemId) async {
    final envelope = await _provider.fetchReleaseGroupCandidate(providerItemId);
    return MusicMusicBrainzMapper.releaseGroupFromCandidate(envelope.payload);
  }

  Future<List<MusicReleaseCandidate>> searchReleaseCandidates(
    String query, {
    int limit = 25,
  }) {
    return _provider.searchReleaseCandidates(query, limit: limit);
  }

  Future<List<MusicReleaseGroupCandidate>> searchReleaseGroupCandidates(
    String query, {
    int limit = 25,
  }) {
    return _provider.searchReleaseGroupCandidates(query, limit: limit);
  }

  MusicRelease mapNative(MusicBrainzRelease release) {
    return MusicMusicBrainzMapper.fromNative(release);
  }
}
