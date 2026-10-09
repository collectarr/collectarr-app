import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late MusicListeningRepository repository;

  setUp(() async {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MusicListeningRepository(db);
    await db.into(db.libraryEntries).insert(
          LibraryEntriesCompanion.insert(
            id: 'entry-1',
            kind: 'music',
            payloadJson: '{}',
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    await db.into(db.libraryEntries).insert(
          LibraryEntriesCompanion.insert(
            id: 'entry-2',
            kind: 'music',
            payloadJson: '{}',
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
  });

  tearDown(() => db.close());

  test('listening events only accept Music library entries', () {
    const bookEntry = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('book-1'),
    );

    expect(
      () => MusicListenEvent(
        id: 'listen-book',
        libraryEntryRef: bookEntry,
        listenedAt: DateTime.utc(2026, 8, 1),
      ),
      throwsArgumentError,
    );
  });

  test('persists history against a collection library entry', () async {
    const entry1 = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId('entry-1'),
    );
    const entry2 = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId('entry-2'),
    );
    final older = MusicListenEvent(
      id: 'listen-older',
      libraryEntryRef: entry1,
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    final newer = MusicListenEvent(
      id: 'listen-newer',
      libraryEntryRef: entry1,
      listenedAt: DateTime.utc(2026, 8, 2),
      notes: 'First pressing',
    );

    await repository.upsertAll([older, newer]);

    final events = await repository.listForLibraryEntry(entry1);
    expect(events.map((event) => event.id), ['listen-newer', 'listen-older']);
    expect(events.first.libraryEntryRef, entry1);
    expect(events.first.notes, 'First pressing');
    expect(
      MusicListeningStats.fromSessions(events).lastListened?.toUtc(),
      DateTime.utc(2026, 8, 2),
    );
    expect(
      await repository.listForLibraryEntry(entry2),
      isEmpty,
    );
  });

  test('deleted events stay out of active history', () async {
    const entry = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId('entry-1'),
    );
    final event = MusicListenEvent(
      id: 'listen-deleted',
      libraryEntryRef: entry,
      listenedAt: DateTime.utc(2026, 8, 1),
    );
    await repository.upsert(event);
    await repository.markDeleted(event, DateTime.utc(2026, 8, 3));

    expect(await repository.listForLibraryEntry(entry), isEmpty);
    expect((await repository.findById(event.id))?.isDeleted, isTrue);
  });

  test('Library entry summary aggregates its event history', () async {
    const entry1 = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId('entry-1'),
    );
    const entry2 = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId('entry-2'),
    );
    await repository.upsertAll([
      MusicListenEvent(
        id: 'listen-one',
        libraryEntryRef: entry1,
        listenedAt: DateTime.utc(2026, 8, 1),
      ),
      MusicListenEvent(
        id: 'listen-two',
        libraryEntryRef: entry1,
        listenedAt: DateTime.utc(2026, 8, 2),
      ),
      MusicListenEvent(
        id: 'listen-other-album',
        libraryEntryRef: entry2,
        listenedAt: DateTime.utc(2026, 8, 3),
      ),
    ]);

    final summary = await repository.getSummary(entry1);
    expect(summary.libraryEntryRef, entry1);
    expect(summary.totalListenCount, 2);
    expect(summary.firstListened?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(summary.lastListened?.toUtc(), DateTime.utc(2026, 8, 2));
    expect(summary.recentEvents.map((event) => event.id), [
      'listen-two',
      'listen-one',
    ]);
  });
}
