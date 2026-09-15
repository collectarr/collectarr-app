import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late MusicListeningRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MusicListeningRepository(db);
  });

  tearDown(() => db.close());

  test('persists typed events and keeps release history scoped',
      () async {
    final groupRef = _musicRef('group-1');
    final releaseRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: const CatalogEntityTypeId('release'),
      id: 'release-1',
      rootId: 'group-1',
      parentId: 'group-1',
    );
    final older = MusicListenEvent(
      id: 'listen-older',
      targetRef: releaseRef,
      releaseGroupId: 'group-1',
      releaseId: 'release-1',
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    final newer = MusicListenEvent(
      id: 'listen-newer',
      targetRef: releaseRef,
      releaseGroupId: 'group-1',
      releaseId: 'release-1',
      ownedRef: const OwnedItemRef(
        kind: CatalogMediaKind.music,
        id: OwnedItemId('owned-1'),
      ),
      listenedAt: DateTime.utc(2026, 8, 2),
      notes: 'First pressing',
    );

    await repository.upsertAll([older, newer]);

    final events = await repository.listForTarget(groupRef);
    expect(events.map((event) => event.id), ['listen-newer', 'listen-older']);
    expect(events.first.targetRef, releaseRef);
    expect(events.first.ownedRef?.key, 'music:owned-1');
    expect(events.first.notes, 'First pressing');
    expect(
      MusicListeningStats.fromSessions(events).lastListened?.toUtc(),
      DateTime.utc(2026, 8, 2),
    );

    final releaseEvents = await repository.listForTarget(releaseRef);
    expect(releaseEvents.map((event) => event.id), [
      'listen-newer',
      'listen-older',
    ]);
  });

  test('deleted events stay out of active history', () async {
    final event = MusicListenEvent(
      id: 'listen-deleted',
      targetRef: _releaseRef('group-1', 'release-1'),
      releaseGroupId: 'group-1',
      releaseId: 'release-1',
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    await repository.upsert(event);
    await repository.markDeleted(event, DateTime.utc(2026, 8, 3));

    expect(
      await repository
          .listForReleaseGroup(const MusicReleaseGroupId('group-1')),
      isEmpty,
    );
    final stored = await repository.findById(event.id);
    expect(stored?.isDeleted, isTrue);
  });

  test('group tracking summary aggregates events without a stored group row',
      () async {
    final music = MusicRepository(db);
    await music.updateRelease(
      MusicRelease(
        id: const MusicReleaseId('release-1'),
        releaseGroupId: const MusicReleaseGroupId('group-1'),
        title: 'Album',
      ),
    );
    await music.updateRelease(
      MusicRelease(
        id: const MusicReleaseId('release-2'),
        releaseGroupId: const MusicReleaseGroupId('group-1'),
        title: 'Album Deluxe',
      ),
    );
    await repository.upsertAll([
      MusicListenEvent(
        id: 'listen-release-1',
        targetRef: CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: const CatalogEntityTypeId('release'),
          id: 'release-1',
          rootId: 'group-1',
        ),
        releaseGroupId: 'group-1',
        releaseId: 'release-1',
        listenedAt: DateTime.utc(2026, 8, 1),
      ),
      MusicListenEvent(
        id: 'listen-release-2',
        targetRef: CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: const CatalogEntityTypeId('release'),
          id: 'release-2',
          rootId: 'group-1',
        ),
        releaseGroupId: 'group-1',
        releaseId: 'release-2',
        listenedAt: DateTime.utc(2026, 8, 2),
      ),
    ]);

    final summary = await repository.getTrackingSummary(
      const MusicReleaseGroupId('group-1'),
    );
    expect(summary.totalListenCount, 2);
    expect(summary.totalReleases, 2);
    expect(summary.listenedReleaseCount, 2);
    expect(summary.listenedReleases, ['release-1', 'release-2']);
    expect(summary.firstListened?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(summary.lastListened?.toUtc(), DateTime.utc(2026, 8, 2));
  });
}

CatalogEntityRef _musicRef(String id) => CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.root,
      id: id,
    );

CatalogEntityRef _releaseRef(String groupId, String releaseId) =>
    CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: const CatalogEntityTypeId('release'),
      id: releaseId,
      rootId: groupId,
    );
