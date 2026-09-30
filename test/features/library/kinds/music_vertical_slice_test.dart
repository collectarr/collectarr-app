import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one Music Catalog Item round-trips its edition and contained discs',
      () {
    final album = MusicRelease(
      id: const MusicReleaseId('album-1'),
      title: 'The Dark Side of the Moon (Vinyl)',
      artist: 'Pink Floyd',
      originalReleaseDate: DateTime(1973, 3, 1),
      studios: const ['Abbey Road Studios'],
      genres: const ['Progressive Rock', 'Psychedelic Rock'],
      publisher: 'Harvest',
      catalogNumber: 'SHVL 804',
      countryCode: 'GB',
      barcode: '5099902987613',
      mediums: [
        MusicMedium(
          id: const MusicMediumId('disc-1'),
          releaseId: const MusicReleaseId('album-1'),
          mediumNumber: 1,
          mediumType: 'Vinyl',
          tracks: [
            MusicTrack(
              id: const MusicTrackId('track-1'),
              mediumId: const MusicMediumId('disc-1'),
              position: '1',
              title: 'Speak to Me',
              durationMs: 65000,
            ),
            MusicTrack(
              id: const MusicTrackId('track-2'),
              mediumId: const MusicMediumId('disc-1'),
              position: '2',
              title: 'Breathe (In the Air)',
              durationMs: 169000,
            ),
          ],
        ),
      ],
      contributions: [
        MusicReleaseContribution(
          id: const MusicReleaseContributionId('contribution-1'),
          releaseId: const MusicReleaseId('album-1'),
          personId: 'person-pink-floyd',
          role: 'Artist',
          displayName: 'Pink Floyd',
        ),
      ],
    );

    final restored = MusicRelease.fromJson(album.toJson());
    expect(restored.id, album.id);
    expect(restored.title, album.title);
    expect(restored.artist, 'Pink Floyd');
    expect(restored.originalReleaseDate, DateTime(1973, 3, 1));
    expect(restored.mediums.single.releaseId, restored.id);
    expect(restored.mediums.single.mediumType, 'Vinyl');
    expect(restored.tracks, hasLength(2));
    expect(restored.tracks.first.title, 'Speak to Me');
    expect(restored.trackCount, 2);
  });

  test('Music listening history targets its Catalog Item', () {
    final event = MusicListenEvent(
      id: 'session-1',
      catalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: 'album-1',
      ),
      listenedAt: DateTime(2026, 8, 20, 21, 30),
      location: 'Living Room Turntable',
      notes: 'Sound quality is stellar.',
    );
    final restored = MusicListenEvent.fromJson(event.toJson());
    final stats = MusicListeningStats.fromSessions([event]);

    expect(restored.catalogRef.id, 'album-1');
    expect(restored.location, 'Living Room Turntable');
    expect(stats.listenCount, 1);
    expect(stats.lastListened, event.listenedAt);
  });
}
