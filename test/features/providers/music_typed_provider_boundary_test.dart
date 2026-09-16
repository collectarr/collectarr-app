import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_release_correction_patch.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/mapping/musicbrainz_music_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';
import 'package:flutter_test/flutter_test.dart';

const _provenance = ProviderProvenance(
  fetchedAt: '2026-09-16T00:00:00Z',
  sourceUrl: 'https://musicbrainz.org/ws/2/release',
);
const _attribution = ProviderAttribution(
  required: true,
  text: 'Data provided by MusicBrainz',
);

void main() {
  test('MusicBrainz typed mapping preserves release hierarchy and credits', () {
    final release = MusicBrainzRelease.fromJson({
      'id': 'release-1',
      'title': 'Multidisc Album',
      'date': '2024-05-01',
      'country': 'RO',
      'release-group': {'id': 'group-1', 'title': 'Multidisc Album'},
      'artist-credit': [
        {
          'artist': {'name': 'Artist One'}
        },
      ],
      'media': [
        {
          'format': 'CD',
          'tracks': [
            {
              'position': 1,
              'title': 'Intro',
              'length': 61000,
              'recording': {'id': 'recording-1'},
              'artist-credit': [
                {
                  'artist': {'name': 'Track Artist'}
                },
              ],
            },
          ],
        },
        {
          'format': 'CD',
          'tracks': [
            {'position': 1, 'title': 'Outro', 'length': 62000},
          ],
        },
      ],
    });

    final envelope = MusicBrainzMusicMapper.releaseEnvelope(
      release,
      coverArtArchiveBaseUrl: 'https://coverartarchive.org',
      provenance: _provenance,
      attribution: _attribution,
    );
    final candidate = envelope.payload;

    expect(envelope.entityScope.apiValue, 'release');
    expect(envelope.providerItemId, 'release-1');
    expect(candidate.releaseGroupId, 'group-1');
    expect(candidate.artist, 'Artist One');
    expect(candidate.mediums, hasLength(2));
    expect(candidate.mediums[1].mediumNumber, 2);
    expect(candidate.mediums[0].tracks.single.artist, 'Track Artist');
    expect(candidate.mediums[0].tracks.single.recordingId, 'recording-1');
  });

  test('typed Music candidate projects directly into canonical catalog data',
      () {
    const candidate = MusicReleaseCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'release-1',
        scope: LibraryEntityScope.release,
      ),
      title: 'Multidisc Album',
      releaseGroupId: 'group-1',
      releaseGroupTitle: 'Multidisc Album',
      artist: 'Artist One',
      mediums: [
        MusicMediumCandidate(
          mediumNumber: 1,
          format: 'CD',
          tracks: [
            MusicTrackCandidate(
              position: 1,
              title: 'Intro',
              artist: 'Track Artist',
              recordingId: 'recording-1',
            ),
          ],
        ),
        MusicMediumCandidate(
          mediumNumber: 2,
          format: 'CD',
          tracks: [
            MusicTrackCandidate(position: 1, title: 'Outro'),
          ],
        ),
      ],
      provenance: _provenance,
    );

    final item = musicCatalogTransportFromTypedProviderCandidate(candidate);
    final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
    final release = group.releases.single;

    expect(item.mediaKind, CatalogMediaKind.music);
    expect(group.title, 'Multidisc Album');
    expect(group.artist, 'Artist One');
    expect(release.mediums.map((medium) => medium.mediumNumber), [1, 2]);
    expect(release.mediums[0].tracks.single.artist, 'Track Artist');
    expect(
      release.mediums[0].tracks.single.metadataJson['recording_id'],
      'recording-1',
    );
  });

  test('typed release-group mapping keeps concrete release summaries', () {
    final group = MusicBrainzReleaseGroupResponse.fromJson({
      'id': 'group-1',
      'title': 'Multidisc Album',
      'first-release-date': '2024-05-01',
      'primary-type': 'Album',
      'artist-credit': [
        {
          'artist': {'name': 'Artist One'}
        },
      ],
      'releases': [
        {
          'id': 'release-1',
          'title': 'Multidisc Album',
          'date': '2024-05-01',
          'country': 'RO',
          'media': [
            {'format': 'CD'},
          ],
        },
      ],
    });

    final candidate = MusicBrainzMusicMapper.releaseGroupCandidate(
      group,
      coverArtArchiveBaseUrl: 'https://coverartarchive.org',
      provenance: _provenance,
      attribution: _attribution,
    );

    expect(candidate.entityScope, LibraryEntityScope.work);
    expect(candidate.title, 'Multidisc Album');
    expect(candidate.artist, 'Artist One');
    expect(candidate.releases.single.providerItemId, 'release-1');
    expect(candidate.releases.single.format, 'CD');
  });

  test('Music correction patch preserves unchanged, set and clear semantics',
      () {
    const patch = MusicReleaseCorrectionPatch(
      title: ProviderPatch.unchanged(),
      barcode: ProviderPatch.set('1234567890123'),
      catalogNumber: ProviderPatch.clear(),
    );

    expect(patch.isEmpty, isFalse);
    expect(patch.toFields(), {
      'barcode': '1234567890123',
      'catalog_number': null,
    });
  });
}
