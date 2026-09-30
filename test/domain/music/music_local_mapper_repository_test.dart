import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicRepository round-trips one album and its contained disc data',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final album = _album();
    final medium = album.mediums.single;

    await repository.updateRelease(album);

    final restored = await repository.getRelease(album.id);
    expect(restored?.title, 'The Wall');
    expect(restored?.artist, 'Pink Floyd');
    expect(restored?.externalLinks.single.url,
        'https://music.example.test/the-wall');
    expect(restored?.localCoverImagePath, '/cache/music/album-cover.jpg');
    expect(restored?.localBackImagePath, '/cache/music/album-back.jpg');
    expect(restored?.localThumbnailImagePath, '/cache/music/album-thumb.jpg');
    expect(restored?.physicalFormat, 'vinyl');
    expect(restored?.physicalFormatLabel, 'Vinyl');
    expect(restored?.boxSetName, 'The Wall collection');
    expect(restored?.contributions.single.displayName, 'Pink Floyd');
    expect(restored?.contributions.single.imageUrl,
        'https://music.example.test/pink-floyd.jpg');
    expect(restored?.mediums.single.id, medium.id);
    expect(restored?.mediums.single.tracks.single.title, 'In the Flesh?');
    expect(restored?.tracks.single.durationMs, 187000);
    expect((await repository.search('floyd')).single.id, album.id);
    expect((await repository.getMedium(album.id, medium.id))?.mediumType,
        'Vinyl');
    expect(
      (await repository.getTrack(medium.id, medium.tracks.single.id))?.position,
      'A1',
    );
  });

  test('MusicRepository preserves album box-set membership', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final album = MusicRelease(
      id: const MusicReleaseId('box-album'),
      title: 'Box album',
      boxSetMembership: const MusicBoxSetMembership(
        boxSetRef: CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId('box_set'),
          id: 'box-1',
        ),
        sequenceNumber: 3,
      ),
    );

    await repository.updateRelease(album);

    final restored = await repository.getRelease(album.id);
    expect(restored?.boxSetMembership?.boxSetRef.id, 'box-1');
    expect(restored?.boxSetMembership?.sequenceNumber, 3);
  });

  test('MusicLocalMapper round-trips the complete owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MusicOwnedItem(
      id: const MusicOwnedCopyId('owned-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.root,
        id: 'album-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
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

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.catalogRef.entityType, CatalogEntityTypeId.root);
    expect(restored.toJson().containsKey('target_ref'), isFalse);
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

  test('MusicRepository enforces ownership of contained disc data', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final album = _album();
    final medium = album.mediums.single;
    final badMedium = MusicMedium(
      id: medium.id,
      releaseId: const MusicReleaseId('other-album'),
      mediumNumber: 1,
    );
    final badTrack = MusicTrack(
      id: medium.tracks.single.id,
      mediumId: const MusicMediumId('other-disc'),
      position: '1',
      title: 'Wrong parent',
    );

    expect(
      () => repository.updateMedium(album.id, badMedium),
      throwsStateError,
    );
    expect(
      () => repository.updateTrack(medium.id, badTrack),
      throwsStateError,
    );
    expect(
      () => MusicLocalMapper.toReleaseRow(
        MusicRelease(id: MusicReleaseId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });

  test('Music starts from the clean v1 local database baseline', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 1);
  });
}

MusicRelease _album() => MusicRelease(
      id: const MusicReleaseId('album-1'),
      title: 'The Wall',
      artist: 'Pink Floyd',
      localCoverImagePath: '/cache/music/album-cover.jpg',
      localBackImagePath: '/cache/music/album-back.jpg',
      localThumbnailImagePath: '/cache/music/album-thumb.jpg',
      externalLinks: const [
        MusicExternalLink(
          url: 'https://music.example.test/the-wall',
          title: 'Album page',
        ),
      ],
      boxSetName: 'The Wall collection',
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
              position: 'A1',
              title: 'In the Flesh?',
              durationMs: 187000,
            ),
          ],
        ),
      ],
      contributions: [
        MusicReleaseContribution(
          id: const MusicReleaseContributionId('contribution-1'),
          releaseId: const MusicReleaseId('album-1'),
          personId: 'pink-floyd',
          role: 'Artist',
          displayName: 'Pink Floyd',
          imageUrl: 'https://music.example.test/pink-floyd.jpg',
        ),
      ],
    );
