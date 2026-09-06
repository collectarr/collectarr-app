import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music release dto maps to domain snapshot with media and tracks', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'music-1',
      'title': 'The Wall',
      'artist': 'Pink Floyd',
      'subtitle': 'Pink Floyd',
      'publisher': 'Harvest',
      'release_date': '1979-11-30T00:00:00Z',
      'recording_date': '1979-01-01T00:00:00Z',
      'release_status': 'released',
      'release_type': 'album',
      'sort_title': 'Wall, The',
      'studio': 'Abbey Road',
      'track_count': 2,
      'barcode': '1234567890',
      'cover_image_url': 'https://example.com/cover.jpg',
      'language': 'en',
      'country_code': 'GB',
      'extras': 'catalog-42',
      'genres': ['rock'],
      'contributions': [
        {'name': 'Pink Floyd', 'role': 'artist'},
      ],
      'media': [
        {
          'id': 'media-1',
          'title': 'Disc 1',
          'media_number': 1,
          'track_count': 2,
          'tracks': [
            {
              'id': 'track-1',
              'media_id': 'media-1',
              'position': '1',
              'title': 'Speak to Me',
              'duration_ms': 90000,
            },
          ],
        },
      ],
    });

    final release = MusicCoreMapper.fromReleaseDto(dto);

    expect(release.title, 'The Wall');
    expect(release.artist, 'Pink Floyd');
    expect(release.catalogNumber, 'catalog-42');
    expect(release.genres, ['rock']);
    expect(release.media, hasLength(1));
    expect(release.discs, hasLength(1));
    expect(release.tracks, hasLength(1));
    expect(release.tracks.first.title, 'Speak to Me');
  });

  test('MusicCatalogMetadata and MusicReleaseMetadata roundtrip', () {
    final meta = MusicCatalogMetadata(
      title: 'The Dark Side of the Moon',
      artist: 'Pink Floyd',
      originalReleaseDate: DateTime.utc(1973, 3, 1),
      recordingDate: DateTime.utc(1972, 6, 1),
      studio: 'Abbey Road Studios',
      isLive: false,
      genres: const ['Progressive Rock', 'Psychedelic Rock'],
      credits: const [
        MusicCredit(
            name: 'David Gilmour',
            role: 'musician',
            instrument: 'Guitar, Vocals'),
        MusicCredit(
            name: 'Roger Waters', role: 'composer', instrument: 'Bass, Vocals'),
        MusicCredit(name: 'Alan Parsons', role: 'engineer'),
      ],
      releases: [
        MusicReleaseMetadata(
          id: 'rel-lp-1',
          title: 'UK First Pressing Vinyl',
          catalogNumber: 'SHVL 804',
          format: 'Vinyl LP',
          country: 'UK',
          releaseLanguage: 'en',
          mediaOrDiscCount: 1,
          label: 'Harvest',
          releaseDate: DateTime.utc(1973, 3, 24),
          tracks: const [
            MusicTrackMetadata(
                disc: 1,
                side: 'A',
                number: '1',
                title: 'Speak to Me',
                durationSeconds: 65),
            MusicTrackMetadata(
                disc: 1,
                side: 'A',
                number: '2',
                title: 'Breathe',
                durationSeconds: 169),
            MusicTrackMetadata(
                disc: 1,
                side: 'B',
                number: '1',
                title: 'Money',
                durationSeconds: 382),
          ],
        ),
      ],
    );

    final json = meta.toJson();
    final fromJson = MusicCatalogMetadata.fromJson(json);

    expect(fromJson.title, 'The Dark Side of the Moon');
    expect(fromJson.studio, 'Abbey Road Studios');
    expect(fromJson.credits, hasLength(3));
    expect(fromJson.credits.last.role, 'engineer');
    expect(fromJson.releases, hasLength(1));
    expect(fromJson.releases.first.catalogNumber, 'SHVL 804');
    expect(fromJson.releases.first.tracks, hasLength(3));
    expect(fromJson.releases.first.tracks.last.side, 'B');
  });

  test('MusicOwnedDetails supports matrix/runout, signature, and cleaning date',
      () {
    final details = MusicOwnedDetails(
      signedBy: 'David Gilmour',
      lastCleanedDate: DateTime.utc(2026, 7, 10),
      matrixRunouts: const [
        MusicMatrixRunout(
            mediumIndex: 1, side: 'A', runoutText: 'SHVL 804 A-2'),
        MusicMatrixRunout(
            mediumIndex: 1, side: 'B', runoutText: 'SHVL 804 B-2'),
      ],
    );

    final json = details.toJson();
    final fromJson = MusicOwnedDetails.fromJson(json);

    expect(fromJson.signedBy, 'David Gilmour');
    expect(fromJson.lastCleanedDate, DateTime.utc(2026, 7, 10));
    expect(fromJson.matrixRunouts, hasLength(2));
    expect(fromJson.matrixRunouts.first.runoutText, 'SHVL 804 A-2');
    expect(fromJson.matrixRunouts.last.side, 'B');
    expect(fromJson, details);
  });

  test('ListeningSession and MusicListeningStats derive listening history', () {
    final sessions = [
      ListeningSession(
        id: 'session-1',
        itemId: 'music-1',
        releaseId: 'rel-lp-1',
        listenedAt: DateTime.utc(2026, 8, 1, 20, 0),
        location: 'Living Room Hi-Fi',
        notes: 'Listened on turntable with headphones',
      ),
      ListeningSession(
        id: 'session-2',
        itemId: 'music-1',
        releaseId: 'rel-lp-1',
        listenedAt: DateTime.utc(2026, 8, 15, 21, 30),
      ),
    ];

    final stats = MusicListeningStats.fromSessions(sessions);

    expect(stats.listenCount, 2);
    expect(stats.lastListened, DateTime.utc(2026, 8, 15, 21, 30));
    expect(stats.history, hasLength(2));
    expect(stats.history.first.listenedAt, DateTime.utc(2026, 8, 15, 21, 30));
  });

  test('musicKindModule registers dedicated Music capabilities', () {
    expect(musicKindModule.kind, CatalogMediaKind.music);
    expect(musicKindModule.add.kind, CatalogMediaKind.music);
    expect(musicKindModule.add.createInitialDraft(), isA<MusicAddDraft>());
    expect(musicKindModule.ownedDetailsCodec, isA<MusicOwnedDetailsCodec>());
    expect(musicKindModule.ownedDetailsCodec.defaultDetails(),
        isA<MusicOwnedDetails>());
  });
}
