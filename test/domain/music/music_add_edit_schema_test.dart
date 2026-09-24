import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';
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
        'title',
        'format',
        'catalog_number',
        'barcode',
        'country',
        'packaging',
        'release_date',
        'artist',
        'record_label',
        'genres',
      ]),
    );
    draft.year = 0;
    expect(
      musicAddSchema.validate!(draft),
      'Release year must be greater than zero',
    );
  });

  test('Music release-group and release drafts round-trip canonically', () {
    final group = MusicReleaseGroup(
      id: MusicReleaseGroupId('group-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      sortTitle: 'Wall, The',
      originalTitle: 'The Wall (Original)',
      originalReleaseDate: DateTime.utc(1979, 11, 30),
      recordingDate: DateTime.utc(1979, 1, 1),
      studio: 'Britannia Row',
      isLive: false,
      genres: ['Progressive Rock'],
      createdAt: DateTime.utc(2020, 1, 1),
      updatedAt: DateTime.utc(2020, 1, 2),
      releases: [
        MusicRelease(
          id: MusicReleaseId('release-1'),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'The Wall',
          sortTitle: 'Wall, The',
          subtitle: 'Remastered',
          releaseType: 'Album',
          releaseStatus: 'Official',
          releaseDate: DateTime.utc(1979, 11, 30),
          publisher: 'Harvest',
          countryCode: 'GB',
          language: 'eng',
          barcode: '5099902987613',
          upc: '5099902987613',
          packaging: 'Jewel Case',
          boxSetMembership: const MusicBoxSetMembership(
            boxSetRef: CatalogEntityRef(
              kind: CatalogMediaKind.music,
              entityType: CatalogEntityTypeId('box_set'),
              id: 'box-1',
            ),
            sequenceNumber: 2,
          ),
          coverImageUrl: 'https://example.test/wall.jpg',
          createdAt: DateTime.utc(2020, 1, 1),
          updatedAt: DateTime.utc(2020, 1, 2),
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
    final groupDraft = MusicReleaseGroupEditDraft.fromReleaseGroup(group);
    groupDraft.values
      ..title = 'The Wall (Remastered)'
      ..sortTitle = 'Wall Remastered'
      ..artist = 'Pink Floyd & Guests'
      ..originalTitle = 'The Wall'
      ..originalReleaseDate = DateTime.utc(1980, 1, 1)
      ..recordingDate = DateTime.utc(1978, 1, 1)
      ..studio = 'New Studio'
      ..isLive = true
      ..genres = ['Rock'];
    final releaseDraft =
        MusicReleaseEditDraft.fromRelease(group.primaryRelease!);
    releaseDraft.values
      ..title = 'The Wall - 2026 Edition'
      ..sortTitle = 'Wall - 2026'
      ..subtitle = 'Deluxe'
      ..releaseType = 'Album'
      ..releaseStatus = 'Official'
      ..releaseDate = DateTime.utc(2026, 3, 1)
      ..publisher = 'Columbia'
      ..countryCode = 'US'
      ..language = 'eng'
      ..barcode = '999'
      ..upc = '999'
      ..catalogNumber = 'SHDW 804'
      ..packaging = 'Digipak'
      ..coverImageUrl = 'https://example.test/new-wall.jpg';
    final ownedDraft = MusicOwnedDetailsDraft(
      media: const [
        MusicOwnedMediumDetails(
          mediumIndex: 1,
          storageDevice: 'Shelf 1',
          storageSlot: 'A-01',
          matrixRunouts: [
            MusicMatrixRunout(side: 'A', runoutText: 'A-1'),
          ],
        ),
      ],
      signedBy: 'David Gilmour',
      lastCleanedDate: DateTime.utc(2026, 2, 1),
    );

    final editedGroup = groupDraft.toReleaseGroup();
    final editedRelease = releaseDraft.toRelease();
    final editedOwned = ownedDraft.toDetails();

    expect(editedGroup.title, 'The Wall (Remastered)');
    expect(editedGroup.artist, 'Pink Floyd & Guests');
    expect(editedGroup.studio, 'New Studio');
    expect(editedGroup.genres, ['Rock']);
    expect(editedGroup.createdAt, group.createdAt);
    expect(editedGroup.updatedAt, group.updatedAt);
    expect(editedRelease.title, 'The Wall - 2026 Edition');
    expect(editedRelease.publisher, 'Columbia');
    expect(editedRelease.barcode, '999');
    expect(editedRelease.catalogNumber, 'SHDW 804');
    expect(editedRelease.packaging, 'Digipak');
    expect(editedRelease.boxSetMembership?.boxSetRef.id, 'box-1');
    expect(editedRelease.boxSetMembership?.sequenceNumber, 2);
    expect(editedRelease.createdAt, group.primaryRelease!.createdAt);
    expect(editedRelease.updatedAt, group.primaryRelease!.updatedAt);
    expect(editedRelease.releaseGroupId, group.id);
    expect(editedOwned.media.single.storageDevice, 'Shelf 1');
    expect(editedOwned.media.single.storageSlot, 'A-01');
    expect(editedOwned.signedBy, 'David Gilmour');
    expect(editedOwned.lastCleanedDate, DateTime.utc(2026, 2, 1));
    expect(editedOwned.media.single.matrixRunouts.single.runoutText, 'A-1');
    expect(
      musicReleaseEditSchema.validate!(group.primaryRelease!, releaseDraft),
      isNull,
    );
    expect(musicReleaseGroupEditSchema.validate!(group, groupDraft), isNull);
    expect(musicOwnedEditSchema.tabs, isNotEmpty);
  });

  test('Music scoped form adapters create a canonical group and release', () {
    final groupId = MusicReleaseGroupId('group-1');
    final releaseId = MusicReleaseId('release-1');
    final release = MusicReleaseFormAdapter.create(
      MusicReleaseFormValues(title: 'Discovery', physicalFormat: 'CD'),
      id: releaseId,
      releaseGroupId: groupId,
      mediums: [
        MusicMedium(
          id: MusicMediumId('release-1:medium:1'),
          releaseId: releaseId,
          mediumNumber: 1,
          mediumType: 'CD',
        ),
      ],
    );
    final group = MusicReleaseGroupFormAdapter.create(
      MusicReleaseGroupFormValues(
        title: 'Discovery',
        artist: 'Daft Punk',
        genres: ['Electronic'],
      ),
      id: groupId,
      releases: [release],
    );

    expect(group.id.value, 'group-1');
    expect(group.artist, 'Daft Punk');
    expect(group.genres, ['Electronic']);
    expect(group.releases.single.id.value, 'release-1');
    expect(group.releases.single.releaseGroupId, group.id);
    expect(group.releases.single.mediums.single.mediumType, 'CD');
  });

  test('manual Music candidate preserves group and release fields', () {
    final draft = MusicAddManualDraft();
    addTearDown(draft.dispose);
    draft.releaseGroup.artist = 'Daft Punk';
    draft.release.title = 'Discovery (Vinyl)';
    draft.release.publisher = 'Virgin';
    draft.release.catalogNumber = '7243';
    draft.release.barcode = '123456789';
    draft.release.physicalFormatLabel = 'Vinyl';
    draft.release.packaging = 'Gatefold';
    draft.release.countryCode = 'FR';
    draft.release.language = 'fra';
    draft.release.releaseDate = DateTime.utc(2001, 3, 12);
    draft.releaseGroup.genres = ['Electronic', 'House'];
    draft.releaseGroup.coverImageUrl = 'https://example.test/cover.jpg';

    final candidate = buildMusicManualCandidate(draft, title: 'Discovery');

    expect(candidate, isNotNull);
    final group = candidate!.kindCapability
        .mapTransport(MusicCatalogMapper.mapDtoToMusic);
    final release = group.primaryRelease!;
    expect(group.title, 'Discovery');
    expect(release.title, 'Discovery (Vinyl)');
    expect(group.artist, 'Daft Punk');
    expect(group.genres, ['Electronic', 'House']);
    expect(release.publisher, 'Virgin');
    expect(release.catalogNumber, '7243');
    expect(release.barcode, '123456789');
    expect(release.packaging, 'Gatefold');
    expect(release.countryCode, 'FR');
    expect(release.language, 'fra');
    expect(release.releaseDate, DateTime.utc(2001, 3, 12));
    expect(group.coverImageUrl, 'https://example.test/cover.jpg');
  });
}
