import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_preview_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider preview preserves Music disc numbers on tracks', () {
    final preview = providerPreviewFromMusicReleaseCandidate(
      MusicReleaseCandidate(
        identity: const ProviderEntityIdentity(
          provider: 'musicbrainz',
          externalId: 'release-1',
          scope: LibraryEntityScope.release,
        ),
        title: 'Multidisc album',
        releaseGroupId: 'group-1',
        mediums: const [
          MusicMediumCandidate(
            mediumNumber: 1,
            tracks: [MusicTrackCandidate(position: 1, title: 'Side A')],
          ),
          MusicMediumCandidate(
            mediumNumber: 2,
            tracks: [MusicTrackCandidate(position: 1, title: 'Side B')],
          ),
        ],
        provenance: ProviderProvenance(fetchedAt: ''),
      ),
    );

    expect(
      preview.tracks.map((track) => track.discNumber),
      [1, 2],
    );
  });
}
