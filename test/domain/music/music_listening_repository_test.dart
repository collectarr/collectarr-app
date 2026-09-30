import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
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

  test('persists history against one Catalog Item and optional owned copy',
      () async {
    final album = _musicRef('album-1');
    final older = MusicListenEvent(
      id: 'listen-older',
      catalogRef: album,
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    final newer = MusicListenEvent(
      id: 'listen-newer',
      catalogRef: album,
      ownedRef: const OwnedCopyRef(
        kind: CatalogMediaKind.music,
        itemId: 'album-1',
        id: OwnedCopyId('owned-1'),
      ),
      listenedAt: DateTime.utc(2026, 8, 2),
      notes: 'First pressing',
    );

    await repository.upsertAll([older, newer]);

    final events = await repository.listForCatalogItem(album);
    expect(events.map((event) => event.id), ['listen-newer', 'listen-older']);
    expect(events.first.catalogRef, album);
    expect(events.first.ownedRef?.key, 'music:owned-1');
    expect(events.first.notes, 'First pressing');
    expect(
      MusicListeningStats.fromSessions(events).lastListened?.toUtc(),
      DateTime.utc(2026, 8, 2),
    );
    expect(
      await repository.listForCatalogItem(_musicRef('album-2')),
      isEmpty,
    );
  });

  test('deleted events stay out of active Catalog Item history', () async {
    final album = _musicRef('album-1');
    final event = MusicListenEvent(
      id: 'listen-deleted',
      catalogRef: album,
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    await repository.upsert(event);
    await repository.markDeleted(event, DateTime.utc(2026, 8, 3));

    expect(await repository.listForCatalogItem(album), isEmpty);
    expect((await repository.findById(event.id))?.isDeleted, isTrue);
  });

  test('Catalog Item summary aggregates its event history', () async {
    final album = _musicRef('album-1');
    await repository.upsertAll([
      MusicListenEvent(
        id: 'listen-one',
        catalogRef: album,
        listenedAt: DateTime.utc(2026, 8, 1),
      ),
      MusicListenEvent(
        id: 'listen-two',
        catalogRef: album,
        listenedAt: DateTime.utc(2026, 8, 2),
      ),
      MusicListenEvent(
        id: 'listen-other-album',
        catalogRef: _musicRef('album-2'),
        listenedAt: DateTime.utc(2026, 8, 3),
      ),
    ]);

    final summary = await repository.getSummary(album);
    expect(summary.catalogItemId, 'album-1');
    expect(summary.totalListenCount, 2);
    expect(summary.firstListened?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(summary.lastListened?.toUtc(), DateTime.utc(2026, 8, 2));
    expect(summary.recentEvents.map((event) => event.id), [
      'listen-two',
      'listen-one',
    ]);
  });
}

CatalogItemRef _musicRef(String id) => CatalogItemRef(
      kind: CatalogMediaKind.music,
      id: id,
    );
