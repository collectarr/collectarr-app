import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const release = CatalogEntityRef(
    kind: CatalogMediaKind.music,
    entityType: CatalogEntityTypeId('release'),
    id: 'release-1',
    rootId: 'group-1',
  );

  test('Music tracking is explicitly release-scoped and unowned', () {
    final state = MusicTrackingState(
      id: 'tracking-1',
      releaseRef: release,
      status: MediaTrackingStatus.completed,
      updatedAt: DateTime.utc(2026, 9, 15),
    );

    expect(state.releaseId, 'release-1');
    expect(state.catalogRef, release);
    expect(state.ownedRef, isNull);
    expect(const MusicTrackingStateCodec().toSyncPayload(state)['catalog_ref'],
        release.toJson());
  });

  test('Music codec rejects group and owned-copy tracking targets', () {
    const codec = MusicTrackingStateCodec();

    expect(
      () => codec.create(
        id: 'group-tracking',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId.root,
          id: 'group-1',
        ),
        status: MediaTrackingStatus.planned,
        updatedAt: DateTime.utc(2026, 9, 15),
      ),
      throwsStateError,
    );
    expect(
      () => codec.create(
        id: 'copy-tracking',
        catalogRef: release,
        ownedRef: const OwnedItemRef(
          kind: CatalogMediaKind.music,
          id: OwnedItemId('copy-1'),
        ),
        updatedAt: DateTime.utc(2026, 9, 15),
      ),
      throwsStateError,
    );
  });

  test('repository keeps separate canonical rows for separate releases',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: const [MusicTrackingStateCodec()],
    );
    const release2 = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId('release'),
      id: 'release-2',
      rootId: 'group-1',
    );

    await repository.upsertMutation(
      id: 'tracking-1',
      catalogRef: release,
      status: MediaTrackingStatus.completed,
      updatedAt: DateTime.utc(2026, 9, 15),
    );
    await repository.upsertMutation(
      id: 'tracking-2',
      catalogRef: release2,
      status: MediaTrackingStatus.inProgress,
      updatedAt: DateTime.utc(2026, 9, 15, 1),
    );

    final entries = await repository.listActiveStorageRecords();
    final musicEntries = entries.where(
      (entry) => entry.catalogRef.mediaKind == CatalogMediaKind.music,
    );
    expect(musicEntries.map((entry) => entry.catalogRef.id),
        containsAll(<String>['release-1', 'release-2']));
    expect(musicEntries.every((entry) => entry.ownedRef == null), isTrue);
  });
}
