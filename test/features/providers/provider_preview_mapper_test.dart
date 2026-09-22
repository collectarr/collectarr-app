import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_preview_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider preview preserves Music disc numbers on tracks', () {
    const envelope = ProviderRawEnvelope(
      provider: 'musicbrainz',
      providerItemId: 'release-1',
      kind: CatalogMediaKind.music,
      payload: ProviderNormalizedPayload({'title': 'Multidisc album'}),
      provenance: ProviderProvenance(fetchedAt: ''),
      images: [],
      attribution: ProviderAttribution(required: false),
    );

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
