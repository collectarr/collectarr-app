import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a canonical Music release group into a workspace release', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      genres: ['Rock'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-1'),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'The Wall',
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
                  position: 'A1',
                  title: 'In the Flesh?',
                  durationMs: 187000,
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final item = testCatalogItem(
      id: 'group-1',
      kind: 'music',
      title: group.title,
      payload: group.toJson(),
    ).withKindMetadata(group);

    final release = MusicWorkspaceMapper.fromCatalogItem(item);

    expect(release.id, const MusicReleaseId('release-1'));
    expect(release.releaseGroupId, group.id);
    expect(release.title, 'The Wall');
    expect(release.mediums.single.mediumType, 'Vinyl');
    expect(
        release.mediums.single.tracks.single.id, const MusicTrackId('track-1'));
    expect(release.tracks.single.durationMs, 187000);
  });

  test('selects a concrete release without imposing video hierarchy', () {
    final group = MusicReleaseGroup.fromJson({
      'id': 'group-2',
      'title': 'Discovery',
      'artist': 'Daft Punk',
      'releases': [
        {
          'id': 'release-cd',
          'release_group_id': 'group-2',
          'title': 'Discovery CD',
          'release_type': 'Album',
          'mediums': <Map<String, dynamic>>[],
        },
      ],
    });
    final item = testCatalogItem(
      id: 'group-2',
      kind: 'music',
      title: 'Discovery',
      payload: group.toJson(),
    ).withKindMetadata(group);

    final release = MusicWorkspaceMapper.fromCatalogItem(
      item,
      releaseId: 'release-cd',
    );

    expect(release.id.value, 'release-cd');
    expect(release.releaseGroupId.value, 'group-2');
    expect(release.title, 'Discovery CD');
    expect(release.mediums, isEmpty);
  });

  test('Music vocabularies project canonical release-group fields', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-vocab'),
      title: 'Kind of Blue',
      artist: 'Miles Davis',
      genres: ['Jazz'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-vocab'),
          releaseGroupId: MusicReleaseGroupId('group-vocab'),
          title: 'Kind of Blue',
          publisher: 'Columbia Records',
          countryCode: 'US',
          mediums: [
            MusicMedium(
              id: MusicMediumId('medium-vocab'),
              releaseId: MusicReleaseId('release-vocab'),
              mediumNumber: 1,
              mediumType: 'Vinyl LP',
              tracks: [
                MusicTrack(
                  id: MusicTrackId('track-vocab'),
                  mediumId: MusicMediumId('medium-vocab'),
                  position: '1',
                  title: 'So What',
                ),
              ],
            ),
          ],
          contributions: [
            MusicReleaseContribution(
              id: MusicReleaseContributionId('contribution-1'),
              releaseId: MusicReleaseId('release-vocab'),
              personId: 'person-miles-davis',
              role: 'Performer',
              metadataJson: {'name': 'Miles Davis'},
            ),
          ],
        ),
      ],
    );

    expect(MusicVocabularies.genre.valuesFrom!(group), contains('Jazz'));
    expect(
        MusicVocabularies.mediaType.valuesFrom!(group), contains('Vinyl LP'));
    expect(
        MusicVocabularies.creditRole.valuesFrom!(group), contains('Performer'));
    expect(MusicVocabularies.country.valuesFrom!(group), contains('US'));
  });
}
