import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:drift/drift.dart';

/// Local persistence for App-entry Music listening activity.
final class MusicListeningRepository {
  const MusicListeningRepository(this._db);

  final LocalDatabase _db;

  Future<MusicListenEvent?> findById(String id) async {
    final row = await (_db.select(_db.musicListenEventsRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<MusicListenEvent>> listForLibraryEntry(
    LibraryEntryRef libraryEntryRef,
  ) async {
    _validateLibraryEntry(libraryEntryRef);
    final rows = await (_db.select(_db.musicListenEventsRows)
          ..where(
            (table) =>
                table.libraryEntryRefKey.equals(libraryEntryRef.key) &
                table.deletedAt.isNull(),
          )
          ..orderBy([
            (table) => OrderingTerm.desc(table.listenedAt),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .get();
    return [for (final row in rows) _fromRow(row)];
  }

  Future<MusicCatalogItemListeningSummary> getSummary(
    LibraryEntryRef libraryEntryRef,
  ) async {
    final events = await listForLibraryEntry(libraryEntryRef);
    return MusicCatalogItemListeningSummary.fromEvents(
      catalogItemId: libraryEntryRef.id.value,
      events: events,
    );
  }

  Future<void> upsert(MusicListenEvent event) async {
    await _validateEvent(_db, event);
    await _db.into(_db.musicListenEventsRows).insertOnConflictUpdate(
          _toRow(event),
        );
  }

  Future<void> upsertAll(Iterable<MusicListenEvent> events) async {
    final values = events.toList(growable: false);
    for (final event in values) {
      await _validateEvent(_db, event);
    }
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.musicListenEventsRows,
        values.map(_toRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MusicListenEvent event, DateTime deletedAt) {
    return upsert(
      MusicListenEvent(
        id: event.id,
        libraryEntryRef: event.libraryEntryRef,
        listenedAt: event.listenedAt,
        startedAt: event.startedAt,
        finishedAt: event.finishedAt,
        location: event.location,
        notes: event.notes,
        createdAt: event.createdAt,
        updatedAt: deletedAt,
        deletedAt: deletedAt,
      ),
    );
  }
}

MusicListenEventsRowsCompanion _toRow(MusicListenEvent event) {
  return MusicListenEventsRowsCompanion.insert(
    id: event.id,
    libraryEntryRefKey: event.libraryEntryRef.key,
    listenedAt: event.listenedAt,
    startedAt: Value(event.startedAt),
    finishedAt: Value(event.finishedAt),
    location: Value(event.location),
    notes: Value(event.notes),
    createdAt: event.createdAt ?? event.listenedAt,
    updatedAt: event.updatedAt ?? event.listenedAt,
    deletedAt: Value(event.deletedAt),
  );
}

MusicListenEvent _fromRow(MusicListenEventsRow row) => MusicListenEvent(
      id: row.id,
      libraryEntryRef: LibraryEntryRef.fromKey(row.libraryEntryRefKey),
      listenedAt: row.listenedAt,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      location: row.location,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );

Future<void> _validateEvent(LocalDatabase db, MusicListenEvent event) async {
  if (event.id.trim().isEmpty) {
    throw StateError('Cannot persist a Music listen event without an id');
  }
  _validateLibraryEntry(event.libraryEntryRef);
  final entryRow = await (db.select(db.libraryEntries)
        ..where((table) =>
            table.kind.equals('music') &
            table.id.equals(event.libraryEntryRef.id.value)))
      .getSingleOrNull();
  if (entryRow == null) {
    throw StateError(
      'Music listen events require an existing local Music library entry.',
    );
  }
}

void _validateLibraryEntry(LibraryEntryRef libraryEntryRef) {
  if (libraryEntryRef.kind != CatalogMediaKind.music ||
      libraryEntryRef.id.value.trim().isEmpty) {
    throw ArgumentError.value(
      libraryEntryRef,
      'libraryEntryRef',
      'Music listening requires a concrete local Music library entry.',
    );
  }
}
