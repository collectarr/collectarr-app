import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Music graph round-trips release groups, releases and media',
      () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-1'),
      title: 'The Dark Side of the Moon',
      artist: 'Pink Floyd',
      originalReleaseDate: DateTime(1973, 3, 1),
      studio: 'Abbey Road Studios',
      genres: ['Progressive Rock', 'Psychedelic Rock'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-1'),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'The Dark Side of the Moon (Vinyl)',
          publisher: 'Harvest',
          catalogNumber: 'SHVL 804',
          countryCode: 'GB',
          barcode: '5099902987613',
          mediums: [
            MusicMedium(
              id: MusicMediumId('medium-1'),
              releaseId: MusicReleaseId('release-1'),
              mediumNumber: 1,
              mediumType: 'Vinyl',
              tracks: [
                MusicTrack(
                  id: MusicTrackId('track-1'),
                  mediumId: MusicMediumId('medium-1'),
                  position: '1',
                  title: 'Speak to Me',
                  durationMs: 65000,
                ),
                MusicTrack(
                  id: MusicTrackId('track-2'),
                  mediumId: MusicMediumId('medium-1'),
                  position: '2',
                  title: 'Breathe (In the Air)',
                  durationMs: 169000,
                ),
              ],
            ),
          ],
          contributions: [
            MusicReleaseContribution(
              id: MusicReleaseContributionId('contribution-1'),
              releaseId: MusicReleaseId('release-1'),
              personId: 'person-pink-floyd',
              role: 'Artist',
              metadataJson: {'name': 'Pink Floyd'},
            ),
          ],
        ),
      ],
    );

    final restored = MusicReleaseGroup.fromJson(group.toJson());
    expect(restored.id, group.id);
    expect(restored.artist, 'Pink Floyd');
    expect(restored.primaryRelease?.releaseGroupId, group.id);
    expect(restored.primaryRelease?.mediums.single.mediumType, 'Vinyl');
    expect(restored.tracks, hasLength(2));
    expect(restored.tracks.first.track.title, 'Speak to Me');
    expect(restored.trackCount, 2);
  });

  test('Music provider mapping creates a canonical release group graph', () {
    const mapper = MusicLibraryKindProviderMapper();
    final group = mapper.catalogFromEnvelope(
      ProviderMetadataEnvelope(
        provider: 'musicbrainz',
        providerItemId: 'mb-release-1',
        kind: CatalogMediaKind.music,
        payload: const ProviderMetadataPayload({
          'title': 'Abbey Road',
          'artist': 'The Beatles',
          'publisher': 'Apple Records',
          'releases': [
            {
              'id': 'release-1',
              'title': 'Abbey Road (Vinyl)',
              'catalog_number': 'PCS 7088',
              'format': 'Vinyl',
              'country': 'GB',
              'tracks': [
                {'number': '1', 'title': 'Come Together'},
              ],
            },
          ],
        }),
        images: const [],
        provenance: ProviderProvenance(
          fetchedAt: '2026-09-15T00:00:00Z',
        ),
        attribution: const ProviderAttribution(required: false),
      ),
    );

    expect(group, isA<MusicReleaseGroup>());
    expect(group.title, 'Abbey Road');
    expect(group.artist, 'The Beatles');
    expect(group.primaryRelease?.catalogNumber, 'PCS 7088');
    expect(group.primaryRelease?.mediums.single.mediumType, 'Vinyl');
    expect(group.tracks.single.track.title, 'Come Together');
  });

  test('Music listening history uses release-group identity', () {
    final session = MusicListenEvent(
      id: 'session-1',
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId('release'),
        id: 'release-1',
        rootId: 'group-1',
      ),
      releaseGroupId: 'group-1',
      releaseId: 'release-1',
      listenedAt: DateTime(2026, 8, 20, 21, 30),
      location: 'Living Room Turntable',
      notes: 'Sound quality is stellar.',
    );
    final restored = MusicListenEvent.fromJson(session.toJson());
    final stats = MusicListeningStats.fromSessions([session]);

    expect(restored.releaseGroupId, 'group-1');
    expect(restored.releaseId, 'release-1');
    expect(restored.location, 'Living Room Turntable');
    expect(stats.listenCount, 1);
    expect(stats.lastListened, session.listenedAt);
  });
}
