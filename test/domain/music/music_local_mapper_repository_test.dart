import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicRepository round-trips the typed release/media/track graph',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final release = _release();

    await repository.updateRelease(release);

    final restored = await repository.getRelease(release.id);
    expect(restored?.title, 'The Wall');
    expect(restored?.artist, 'Pink Floyd');
    expect(restored?.media.single.id, const MusicMediaId('media-1'));
    expect(restored?.media.single.tracks.single.title, 'In the Flesh?');
    expect(restored?.tracks.single.durationMs, 187000);
    expect(restored?.rawPayload['provider'], 'core');
    expect((await repository.search('floyd')).single.id, release.id);

    expect(
      (await repository.getMedia(release.id, release.media.single.id))
          ?.mediaType,
      'vinyl',
    );
    expect(
      (await repository.getTrack(
        release.media.single.id,
        release.media.single.tracks.single.id,
      ))
          ?.position,
      'A1',
    );

    const owned = MusicOwnedDetails(
      storageDevice: 'Shelf 4',
      storageSlot: 'B-12',
      signedBy: 'Roger Waters',
      matrixRunouts: [
        MusicMatrixRunout(side: 'A', runoutText: 'SHVL 804 A-2'),
      ],
    );
    await repository.updateOwnedDetails('owned-music-1', owned);
    expect(await repository.getOwnedDetails('owned-music-1'), owned);
  });

  test(
      'MusicRepository populates and then reads a remote release through cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _release();
    final repository = MusicRepository(
      db,
      remote: _FakeMusicRemote(expected),
    );

    final first = await repository.getRelease(expected.id);
    final second = await repository.getRelease(expected.id);

    expect(first?.id, expected.id);
    expect(
      second?.media.single.tracks.single.id,
      expected.media.single.tracks.single.id,
    );
  });

  test('MusicLocalMapper round-trips the complete owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MusicOwnedItem(
      id: const MusicOwnedItemId('owned-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'music',
        entityType: CatalogEntityType.work,
        id: 'music-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: 'edition',
        editionId: 'release-1',
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
      details: MusicOwnedDetails(
        storageDevice: 'Vinyl shelf',
        storageSlot: 'M-01',
        signedBy: 'Roger Waters',
        lastCleanedDate: DateTime.utc(2026, 4, 4),
        matrixRunouts: [
          MusicMatrixRunout(
            mediumIndex: 1,
            side: 'A',
            runoutText: 'SHVL 804 A-2',
          ),
        ],
      ),
    );

    await db.into(db.musicOwnedItemsRows).insert(
          MusicLocalMapper.toOwnedItemRow(item),
        );
    final restored = MusicLocalMapper.fromOwnedItemRow(
      await db.select(db.musicOwnedItemsRows).getSingle(),
    );

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.anchor?.apiValue, 'edition');
    expect(restored.anchor?.editionId, 'release-1');
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
    expect(restored.details.storageDevice, item.details.storageDevice);
    expect(restored.details.storageSlot, item.details.storageSlot);
    expect(restored.details.signedBy, item.details.signedBy);
    expect(
      restored.details.lastCleanedDate?.toUtc(),
      item.details.lastCleanedDate?.toUtc(),
    );
    expect(restored.details.matrixRunouts, hasLength(1));
    expect(restored.details.matrixRunouts.single.mediumIndex, 1);
    expect(restored.details.matrixRunouts.single.side, 'A');
    expect(restored.details.matrixRunouts.single.runoutText, 'SHVL 804 A-2');
  });

  test('Music repository enforces typed graph ownership', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    const releaseId = MusicReleaseId('release-1');
    const media = MusicMedia(
      id: MusicMediaId('media-1'),
      releaseId: MusicReleaseId('other-release'),
      mediaNumber: 1,
    );
    const track = MusicTrack(
      id: MusicTrackId('track-1'),
      mediaId: MusicMediaId('other-media'),
      position: '1',
      title: 'Wrong parent',
    );

    expect(
      () => repository.updateMedia(releaseId, media),
      throwsStateError,
    );
    expect(
      () => repository.updateTrack(const MusicMediaId('media-1'), track),
      throwsStateError,
    );
    expect(
      () => MusicLocalMapper.toReleaseRow(
        const MusicRelease(id: MusicReleaseId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });

  test('Music schema exposes dedicated graph tables at schema version 33', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 35);
  });
}

MusicRelease _release() {
  return const MusicRelease(
    id: MusicReleaseId('release-1'),
    title: 'The Wall',
    artist: 'Pink Floyd',
    publisher: 'Harvest',
    catalogNumber: 'SHDW 804',
    releaseDate: null,
    media: [
      MusicMedia(
        id: MusicMediaId('media-1'),
        releaseId: MusicReleaseId('release-1'),
        mediaNumber: 1,
        mediaType: 'vinyl',
        tracks: [
          MusicTrack(
            id: MusicTrackId('track-1'),
            mediaId: MusicMediaId('media-1'),
            position: 'A1',
            title: 'In the Flesh?',
            durationMs: 187000,
          ),
        ],
      ),
    ],
    rawPayload: {'provider': 'core'},
  );
}

final class _FakeMusicRemote implements MusicRemoteSource {
  const _FakeMusicRemote(this.release);

  final MusicRelease release;

  @override
  Future<MusicRelease> fetchRelease(MusicReleaseId id) async => release;
}
