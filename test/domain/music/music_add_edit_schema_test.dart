import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_release_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_media_edit_schema.dart';
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
        ]));
    draft.releaseDateController.text = 'not-a-date';
    expect(musicAddSchema.validate!(draft), 'Release date is invalid');
  });

  test('Music release/media/owned drafts round-trip through explicit schemas',
      () {
    const release = MusicRelease(
      id: MusicReleaseId('release-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      media: [
        MusicMedia(
          id: MusicMediaId('media-1'),
          releaseId: MusicReleaseId('release-1'),
          mediaNumber: 1,
          mediaType: 'Vinyl',
          tracks: [
            MusicTrack(
              id: MusicTrackId('track-1'),
              mediaId: MusicMediaId('media-1'),
              position: 'A1',
              title: 'In the Flesh?',
            ),
          ],
        ),
      ],
    );
    final releaseDraft = MusicReleaseEditDraft.fromRelease(release)
      ..title = 'The Wall (Remastered)'
      ..genres = ['Rock'];
    final mediaDraft = MusicMediaEditDraft.fromMedia(release.media.single)
      ..packaging = 'Gatefold Sleeve'
      ..rpm = 33;
    final ownedDraft = MusicOwnedEditDraft.fromDetails(
      const MusicOwnedDetails(storageDevice: 'Shelf 1'),
    )..signedBy = 'Roger Waters';

    final editedRelease = releaseDraft.toRelease();
    final editedMedia = mediaDraft.toMedia();
    final editedOwned = ownedDraft.toDetails();

    expect(editedRelease.title, 'The Wall (Remastered)');
    expect(editedRelease.genres, ['Rock']);
    expect(editedMedia.packaging, 'Gatefold Sleeve');
    expect(editedMedia.rpm, 33);
    expect(editedOwned.storageDevice, 'Shelf 1');
    expect(editedOwned.signedBy, 'Roger Waters');
    expect(musicReleaseEditSchema.validate!(release, releaseDraft), isNull);
    expect(musicMediaEditSchema.validate!(release.media.single, mediaDraft),
        isNull);
    expect(musicOwnedEditSchema.tabs, isNotEmpty);
  });

  test('MusicReleaseAddDraft creates a typed release without fake media', () {
    const draft = MusicReleaseAddDraft(
      title: 'Discovery',
      artist: 'Daft Punk',
      format: 'CD',
      genres: ['Electronic'],
    );

    final release = draft.toRelease(const MusicReleaseId('release-1'));

    expect(release.id.value, 'release-1');
    expect(release.artist, 'Daft Punk');
    expect(release.media, isEmpty);
    expect(release.tracks, isEmpty);
    expect(release.rawPayload['format'], 'CD');
  });
}
