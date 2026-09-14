import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_release_group_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicAddSchema exposes Music-owned manual release fields', () {
    final draft = MusicAddManualDraft();
    addTearDown(draft.dispose);

    final fieldIds = [
      for (final section in musicAddSchema.sections)
        for (final field in section.fields) field.id,
    ];

    expect(
      fieldIds,
      containsAll([
        'edition_title',
        'format',
        'catalog_number',
        'barcode',
        'artist',
        'record_label',
        'genres',
      ]),
    );
    draft.releaseDateController.text = 'not-a-date';
    expect(musicAddSchema.validate!(draft), 'Release date is invalid');
  });

  test('Music release-group and release drafts round-trip canonically', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      genres: ['Progressive Rock'],
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-1'),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'The Wall',
          publisher: 'Harvest',
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
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final groupDraft = MusicReleaseGroupEditDraft.fromReleaseGroup(group)
      ..title = 'The Wall (Remastered)'
      ..genres = ['Rock'];
    final releaseDraft =
        MusicReleaseEditDraft.fromRelease(group.primaryRelease!)
          ..catalogNumber = 'SHDW 804';
    final ownedDraft = MusicOwnedEditDraft.fromDetails(
      const MusicOwnedDetails(storageDevice: 'Shelf 1'),
    )..signedBy = 'Roger Waters';

    final editedGroup = groupDraft.toReleaseGroup();
    final editedRelease = releaseDraft.toRelease();
    final editedOwned = ownedDraft.toDetails();

    expect(editedGroup.title, 'The Wall (Remastered)');
    expect(editedGroup.genres, ['Rock']);
    expect(editedRelease.catalogNumber, 'SHDW 804');
    expect(editedRelease.releaseGroupId, group.id);
    expect(editedOwned.storageDevice, 'Shelf 1');
    expect(editedOwned.signedBy, 'Roger Waters');
    expect(
      musicReleaseEditSchema.validate!(group.primaryRelease!, releaseDraft),
      isNull,
    );
    expect(musicReleaseGroupEditSchema.validate!(group, groupDraft), isNull);
    expect(musicOwnedEditSchema.tabs, isNotEmpty);
  });

  test('MusicReleaseGroupAddDraft creates a canonical group and release', () {
    const draft = MusicReleaseGroupAddDraft(
      title: 'Discovery',
      artist: 'Daft Punk',
      mediumType: 'CD',
      genres: ['Electronic'],
    );

    final group = draft.toReleaseGroup(
      groupId: const MusicReleaseGroupId('group-1'),
      releaseId: const MusicReleaseId('release-1'),
    );

    expect(group.id.value, 'group-1');
    expect(group.artist, 'Daft Punk');
    expect(group.genres, ['Electronic']);
    expect(group.releases.single.id.value, 'release-1');
    expect(group.releases.single.releaseGroupId, group.id);
    expect(group.releases.single.mediums, isEmpty);
    expect(group.releases.single.metadataJson['medium_type'], 'CD');
  });
}
