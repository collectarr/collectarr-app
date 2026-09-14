import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Core release-group summaries into the canonical group model', () {
    final dto = MusicReleaseGroupDto.fromJson({
      'id': 'group-1',
      'kind': 'music',
      'title': 'The Wall',
      'artist': 'Pink Floyd',
      'original_release_date': '1979-11-30',
      'genres': ['rock', 'progressive rock'],
      'releases': [
        {
          'id': 'release-1',
          'release_group_id': 'group-1',
          'title': 'The Wall',
          'release_date': '1979-11-30',
          'release_type': 'Album',
          'publisher': 'Harvest',
          'barcode': '123',
        },
      ],
    });

    final group = MusicCoreMapper.fromReleaseGroupDto(dto);

    expect(group, isA<MusicReleaseGroup>());
    expect(group.id, const MusicReleaseGroupId('group-1'));
    expect(group.artist, 'Pink Floyd');
    expect(group.genres, ['rock', 'progressive rock']);
    expect(group.releases.single.id, const MusicReleaseId('release-1'));
    expect(group.releases.single.releaseGroupId, group.id);
    expect(group.releases.single.publisher, 'Harvest');
  });

  test('maps the complete Core release -> medium -> track graph', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'release-1',
      'kind': 'music',
      'release_group_id': 'group-1',
      'title': 'The Wall',
      'publisher': 'Harvest',
      'release_date': '1979-11-30',
      'recording_date': '1979-01-01',
      'release_type': 'Album',
      'barcode': '123',
      'cover_image_url': 'https://cdn/cover.jpg',
      'contributions': [
        {'name': 'Pink Floyd', 'role': 'Artist'},
      ],
      'mediums': [
        {
          'id': 'medium-1',
          'kind': 'music',
          'release_id': 'release-1',
          'medium_number': 1,
          'medium_type': 'Vinyl',
          'media_condition': 'Excellent',
          'tracks': [
            {
              'id': 'track-1',
              'kind': 'music',
              'medium_id': 'medium-1',
              'position': 'A1',
              'title': 'In the Flesh?',
              'duration_ms': 187000,
              'composition': 'Waters',
              'instrument': 'Bass',
            },
          ],
        },
      ],
    });

    final release = MusicCoreMapper.fromReleaseDto(dto);
    final medium = release.mediums.single;
    final track = medium.tracks.single;

    expect(release.id, const MusicReleaseId('release-1'));
    expect(release.releaseGroupId, const MusicReleaseGroupId('group-1'));
    expect(release.contributions.single.role, 'Artist');
    expect(medium.id, const MusicMediumId('medium-1'));
    expect(medium.releaseId, release.id);
    expect(medium.mediumType, 'Vinyl');
    expect(track, isA<MusicTrack>());
    expect(track.id, const MusicTrackId('track-1'));
    expect(track.mediumId, medium.id);
    expect(track.durationMs, 187000);
    expect(track.composition, 'Waters');
  });

  test('preserves the canonical release graph through JSON', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-2'),
      title: 'Animals',
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-2'),
          releaseGroupId: MusicReleaseGroupId('group-2'),
          title: 'Animals',
          mediums: [
            MusicMedium(
              id: MusicMediumId('medium-2'),
              releaseId: MusicReleaseId('release-2'),
              mediumNumber: 1,
              tracks: [
                MusicTrack(
                  id: MusicTrackId('track-2'),
                  mediumId: MusicMediumId('medium-2'),
                  position: '1',
                  title: 'Pigs on the Wing 1',
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final decoded = MusicReleaseGroup.fromJson(group.toJson());
    expect(decoded.id, group.id);
    expect(decoded.primaryRelease!.id, const MusicReleaseId('release-2'));
    expect(decoded.primaryRelease!.mediums.single.id,
        const MusicMediumId('medium-2'));
    expect(decoded.tracks.single.track.id, const MusicTrackId('track-2'));
  });

  test('rejects a non-Music Core payload at every typed boundary', () {
    final group = MusicReleaseGroupDto.fromJson({
      'id': 'wrong-group',
      'kind': 'movie',
      'title': 'Wrong kind',
    });
    final release = MusicReleaseDto.fromJson({
      'id': 'wrong-release',
      'kind': 'book',
      'release_group_id': 'group-1',
      'title': 'Wrong kind',
    });
    final medium = MusicMediumDto.fromJson({
      'id': 'wrong-medium',
      'kind': 'game',
      'release_id': 'release-1',
      'medium_number': 1,
    });
    final track = MusicTrackDto.fromJson({
      'id': 'wrong-track',
      'kind': 'comic',
      'medium_id': 'medium-1',
      'position': '1',
      'title': 'Wrong kind',
    });

    expect(() => MusicCoreMapper.fromReleaseGroupDto(group), throwsStateError);
    expect(() => MusicCoreMapper.fromReleaseDto(release), throwsStateError);
    expect(() => MusicCoreMapper.fromMediumDto(medium), throwsStateError);
    expect(() => MusicCoreMapper.fromTrackDto(track), throwsStateError);
  });
}
