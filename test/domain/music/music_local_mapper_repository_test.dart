import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicRepository round-trips release-group/release/medium/track',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final group = _group();
    final release = group.primaryRelease!;
    final medium = release.mediums.single;

    await repository.updateReleaseGroup(group);

    final restoredGroup = await repository.getReleaseGroup(group.id);
    final restoredRelease = await repository.getRelease(release.id);
    expect(restoredGroup?.title, 'The Wall');
    expect(restoredGroup?.externalLinks.single.url,
        'https://music.example.test/the-wall');
    expect(restoredGroup?.primaryRelease?.id, release.id);
    expect(restoredRelease?.releaseGroupId, group.id);
    expect(restoredRelease?.externalLinks.single.url,
        'https://music.example.test/release-1');
    expect(restoredRelease?.mediums.single.id, medium.id);
    expect(
        restoredRelease?.mediums.single.tracks.single.title, 'In the Flesh?');
    expect(restoredRelease?.tracks.single.durationMs, 187000);
    expect(restoredRelease?.metadataJson['provider'], 'core');
    expect((await repository.search('floyd')).single.id, release.id);
    expect((await repository.searchReleaseGroups('floyd')).single.id, group.id);
    expect((await repository.getMedium(release.id, medium.id))?.mediumType,
        'Vinyl');
    expect(
        (await repository.getTrack(medium.id, medium.tracks.single.id))
            ?.position,
        'A1');
  });

  test('MusicRepository preserves release box-set membership', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final group = MusicReleaseGroup(
      id: const MusicReleaseGroupId('box-group'),
      title: 'Box group',
      releases: [
        MusicRelease(
          id: const MusicReleaseId('box-release'),
          releaseGroupId: const MusicReleaseGroupId('box-group'),
          title: 'Box release',
          boxSetMembership: const MusicBoxSetMembership(
            boxSetRef: CatalogEntityRef(
              kind: CatalogMediaKind.music,
              entityType: CatalogEntityTypeId('box_set'),
              id: 'box-1',
            ),
            sequenceNumber: 3,
          ),
        ),
      ],
    );

    await repository.updateReleaseGroup(group);

    final restored =
        await repository.getRelease(const MusicReleaseId('box-release'));
    expect(restored?.boxSetMembership?.boxSetRef.id, 'box-1');
    expect(restored?.boxSetMembership?.sequenceNumber, 3);
  });

  test(
      'MusicRepository populates and then reads a remote release through cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _group().primaryRelease!;
    final repository = MusicRepository(db, remote: _FakeMusicRemote(expected));

    final first = await repository.getRelease(expected.id);
    final second = await repository.getRelease(expected.id);

    expect(first?.id, expected.id);
    expect(second?.releaseGroupId, expected.releaseGroupId);
    expect(second?.mediums.single.tracks.single.id,
        expected.mediums.single.tracks.single.id);
  });

  test('MusicLocalMapper round-trips the complete owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MusicOwnedItem(
      id: const MusicOwnedItemId('owned-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.root,
        id: 'group-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId('release'),
        id: 'release-1',
        rootId: 'group-1',
      ),
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 3999,
      currency: 'EUR',
      personalNotes: 'Signed first pressing',
      quantity: 2,
      indexNumber: 3,
      tags: 'favorite,limited',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Music collector',
      locationId: 'shelf-music',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 4500,
      soldAt: DateTime.utc(2026, 5, 1),
      sellPriceCents: 5000,
      soldTo: 'Record collector',
      details: MusicOwnedDetails(
        signedBy: 'Roger Waters',
        lastCleanedDate: DateTime.utc(2026, 4, 4),
        media: const [
          MusicOwnedMediumDetails(
            mediumIndex: 1,
            storageDevice: 'Vinyl shelf',
            storageSlot: 'M-01',
            matrixRunouts: [
              MusicMatrixRunout(side: 'A', runoutText: 'SHVL 804 A-2'),
            ],
          ),
        ],
      ),
    );

    await db.into(db.musicOwnedItemsRows).insert(
          MusicLocalMapper.toOwnedItemRow(item),
        );
    final row = await db.select(db.musicOwnedItemsRows).getSingle();
    final restored = MusicLocalMapper.fromOwnedItemRow(row);

    expect(row.targetRefJson, isNotNull);
    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.catalogRef.entityType, CatalogEntityTypeId.root);
    expect(restored.targetRef?.entityType.apiValue, 'release');
    expect(restored.targetRef?.rootId, 'group-1');
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.quantity, item.quantity);
    expect(restored.indexNumber, item.indexNumber);
    expect(restored.tags, item.tags);
    expect(restored.updatedAt.toUtc(), item.updatedAt);
    expect(restored.ownerUserId, item.ownerUserId);
    expect(restored.ownerLabel, item.ownerLabel);
    expect(restored.locationId, item.locationId);
    expect(restored.purchaseStore, item.purchaseStore);
    expect(restored.collectionStatus, item.collectionStatus);
    expect(restored.marketValueCents, item.marketValueCents);
    expect(restored.soldAt?.toUtc(), item.soldAt);
    expect(restored.sellPriceCents, item.sellPriceCents);
    expect(restored.soldTo, item.soldTo);
    expect(restored.details.media, hasLength(1));
    expect(restored.details.media.single.storageDevice, 'Vinyl shelf');
    expect(restored.details.media.single.storageSlot, 'M-01');
    expect(restored.details.signedBy, item.details.signedBy);
    expect(restored.details.media.single.matrixRunouts, hasLength(1));
    expect(restored.details.media.single.matrixRunouts.single.runoutText,
        'SHVL 804 A-2');
  });

  test('MusicRepository enforces typed graph ownership', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final release = _group().primaryRelease!;
    final medium = release.mediums.single;
    final badMedium = MusicMedium(
      id: medium.id,
      releaseId: const MusicReleaseId('other-release'),
      mediumNumber: 1,
    );
    final badTrack = MusicTrack(
      id: medium.tracks.single.id,
      mediumId: const MusicMediumId('other-medium'),
      position: '1',
      title: 'Wrong parent',
    );

    expect(
      () => repository.updateMedium(release.id, badMedium),
      throwsStateError,
    );
    expect(
      () => repository.updateTrack(medium.id, badTrack),
      throwsStateError,
    );
    expect(
      () => MusicLocalMapper.toReleaseRow(
        MusicRelease(
          id: MusicReleaseId(''),
          releaseGroupId: MusicReleaseGroupId('group-1'),
          title: 'Draft',
        ),
      ),
      throwsStateError,
    );
  });

  test('Music schema exposes dedicated graph tables at schema version 2', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
  });
}

MusicReleaseGroup _group() {
  return MusicReleaseGroup(
    id: MusicReleaseGroupId('group-1'),
    title: 'The Wall',
    artist: 'Pink Floyd',
    externalLinks: const [
      MusicExternalLink(
        url: 'https://music.example.test/the-wall',
        title: 'Artist site',
      ),
    ],
    releases: [
      MusicRelease(
        id: MusicReleaseId('release-1'),
        releaseGroupId: MusicReleaseGroupId('group-1'),
        title: 'The Wall',
        publisher: 'Harvest',
        catalogNumber: 'SHDW 804',
        externalLinks: const [
          MusicExternalLink(
            url: 'https://music.example.test/release-1',
            title: 'Pressing page',
          ),
        ],
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
        metadataJson: {'provider': 'core'},
      ),
    ],
  );
}

final class _FakeMusicRemote implements MusicRemoteSource {
  const _FakeMusicRemote(this.release);

  final MusicRelease release;

  @override
  Future<MusicRelease> fetchRelease(MusicReleaseId id) async => release;
}
