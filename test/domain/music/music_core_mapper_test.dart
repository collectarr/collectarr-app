import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the Core Music release graph into typed Music models', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'release-1',
      'kind': 'music',
      'title': 'The Wall',
      'artist': 'Pink Floyd',
      'publisher': 'Harvest',
      'release_date': '1979-11-30',
      'recording_date': '1979-01-01',
      'release_type': 'album',
      'barcode': '123',
      'cover_image_url': 'https://cdn/cover.jpg',
      'genres': ['rock', 'progressive rock'],
      'contributions': [
        {'name': 'Pink Floyd', 'role': 'artist'},
      ],
      'media': [
        {
          'id': 'media-1',
          'kind': 'music',
          'release_id': 'release-1',
          'media_number': 1,
          'media_type': 'vinyl',
          'packaging': 'gatefold',
          'tracks': [
            {
              'id': 'track-1',
              'kind': 'music',
              'media_id': 'media-1',
              'position': 'A1',
              'title': 'In the Flesh?',
              'duration_ms': 187000,
              'composition': 'Waters',
              'instrument': 'bass',
            },
          ],
        },
      ],
    });

    final release = MusicCoreMapper.fromReleaseDto(dto);

    expect(release, isA<MusicRelease>());
    expect(release.id, const MusicReleaseId('release-1'));
    expect(release.title, 'The Wall');
    expect(release.artist, 'Pink Floyd');
    expect(release.genres, ['rock', 'progressive rock']);
    expect(release.contributions.single['role'], 'artist');
    expect(release.media.single, isA<MusicMedia>());
    expect(release.media.single.id, const MusicMediaId('media-1'));
    expect(release.media.single.releaseId, release.id);
    expect(release.media.single.mediaType, 'vinyl');
    expect(release.tracks.single, isA<MusicTrack>());
    expect(release.tracks.single.id, const MusicTrackId('track-1'));
    expect(release.tracks.single.mediaId, release.media.single.id);
    expect(release.tracks.single.position, 'A1');
    expect(release.tracks.single.durationSeconds, 187);
  });

  test('preserves typed Music release graphs through JSON', () {
    const release = MusicRelease(
      id: MusicReleaseId('release-2'),
      title: 'Animals',
      media: [
        MusicMedia(
          id: MusicMediaId('media-2'),
          releaseId: MusicReleaseId('release-2'),
          mediaNumber: 1,
          tracks: [
            MusicTrack(
              id: MusicTrackId('track-2'),
              mediaId: MusicMediaId('media-2'),
              position: '1',
              title: 'Pigs on the Wing 1',
            ),
          ],
        ),
      ],
    );

    final decoded = MusicRelease.fromJson(release.toJson());

    expect(decoded.id, release.id);
    expect(decoded.media.single.id, const MusicMediaId('media-2'));
    expect(decoded.tracks.single.id, const MusicTrackId('track-2'));
  });

  test('rejects a non-Music Core payload at every typed boundary', () {
    final release = MusicReleaseDto.fromJson({
      'id': 'wrong-release',
      'kind': 'movie',
      'title': 'Wrong kind',
    });
    final media = MusicMediaDto.fromJson({
      'id': 'wrong-media',
      'kind': 'book',
      'release_id': 'release-1',
    });
    final track = MusicTrackDto.fromJson({
      'id': 'wrong-track',
      'kind': 'game',
      'media_id': 'media-1',
      'position': '1',
      'title': 'Wrong kind',
    });

    expect(() => MusicCoreMapper.fromReleaseDto(release), throwsStateError);
    expect(() => MusicCoreMapper.fromMediaDto(media), throwsStateError);
    expect(() => MusicCoreMapper.fromTrackDto(track), throwsStateError);
  });
}
