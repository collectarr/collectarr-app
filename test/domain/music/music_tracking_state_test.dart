import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = CatalogEntityRef(
    kind: CatalogMediaKind.music,
    entityType: CatalogEntityTypeId.root,
    id: 'music-item-1',
  );

  test('Music tracking targets a catalog item and remains unowned', () {
    final state = MusicTrackingState(
      id: 'tracking-1',
      catalogRef: item,
      status: MediaTrackingStatus.completed,
      updatedAt: DateTime.utc(2026, 9, 15),
    );

    expect(state.catalogRef, item);
    expect(state.ownedRef, isNull);
    expect(const MusicTrackingStateCodec().toSyncPayload(state)['catalog_ref'],
        item.toJson());
  });

  test('Music codec rejects child and owned-copy tracking targets', () {
    const codec = MusicTrackingStateCodec();

    expect(
      () => codec.create(
        id: 'group-tracking',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId('track'),
          id: 'track-1',
          rootId: 'music-item-1',
        ),
        status: MediaTrackingStatus.planned,
        updatedAt: DateTime.utc(2026, 9, 15),
      ),
      throwsStateError,
    );
    expect(
      () => codec.create(
        id: 'copy-tracking',
        catalogRef: item,
        ownedRef: const OwnedCopyRef(
          kind: CatalogMediaKind.music,
          itemId: 'music-item-1',
          id: OwnedCopyId('copy-1'),
        ),
        updatedAt: DateTime.utc(2026, 9, 15),
      ),
      throwsStateError,
    );
  });

  test('repository keeps one canonical row per catalog item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: const [MusicTrackingStateCodec()],
    );
    const item2 = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: 'music-item-2',
    );

    await repository.upsertMutation(
      id: 'tracking-1',
      catalogRef: item,
      status: MediaTrackingStatus.completed,
      updatedAt: DateTime.utc(2026, 9, 15),
    );
    await repository.upsertMutation(
      id: 'tracking-2',
      catalogRef: item2,
      status: MediaTrackingStatus.inProgress,
      updatedAt: DateTime.utc(2026, 9, 15, 1),
    );

    final entries = await repository.listActiveStorageRecords();
    final musicEntries = entries.where(
      (entry) => entry.catalogRef.mediaKind == CatalogMediaKind.music,
    );
    expect(musicEntries.map((entry) => entry.catalogRef.id),
        containsAll(<String>['music-item-1', 'music-item-2']));
    expect(musicEntries.every((entry) => entry.ownedRef == null), isTrue);
  });
}
