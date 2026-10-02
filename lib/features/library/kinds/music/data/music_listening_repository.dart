import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:drift/drift.dart';

/// Local persistence for App-owned Music listening activity.
final class MusicListeningRepository {
  const MusicListeningRepository(this._db);

  final LocalDatabase _db;

  Future<MusicListenEvent?> findById(String id) async {
    final row = await (_db.select(_db.musicListenEventsRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<MusicListenEvent>> listForCatalogItem(
    CatalogItemRef catalogRef,
  ) async {
    _validateCatalogItem(catalogRef);
    final rows = await (_db.select(_db.musicListenEventsRows)
          ..where(
            (table) =>
                table.catalogItemId.equals(catalogRef.id) &
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
    CatalogItemRef catalogRef,
  ) async {
    final events = await listForCatalogItem(catalogRef);
    return MusicCatalogItemListeningSummary.fromEvents(
      catalogItemId: catalogRef.id,
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
        catalogRef: event.catalogRef,
        collectionItemRef: event.collectionItemRef,
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
    catalogItemId: event.catalogRef.id,
    collectionItemId: Value(event.collectionItemRef?.id.value),
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
      catalogRef: CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: row.catalogItemId,
      ),
      collectionItemRef: row.collectionItemId == null
          ? null
          : CollectionItemRef(
              kind: CatalogMediaKind.music,
              id: CollectionItemId(row.collectionItemId!),
            ),
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
  _validateCatalogItem(event.catalogRef);
  if (event.collectionItemRef case final owned?
      when owned.kind != CatalogMediaKind.music) {
    throw StateError(
      'Music listen events can only reference Music collection items',
    );
  }
  if (event.collectionItemRef case final owned?) {
    final ownedRow = await (db.select(db.musicCollectionItemsRows)
          ..where((table) => table.id.equals(owned.id.value)))
        .getSingleOrNull();
    if (ownedRow == null || ownedRow.itemId != event.catalogRef.id) {
      throw StateError(
        'The Music collection item must belong to the event Catalog Item',
      );
    }
  }
}

void _validateCatalogItem(CatalogItemRef catalogRef) {
  if (catalogRef.kind != CatalogMediaKind.music ||
      catalogRef.id.trim().isEmpty) {
    throw ArgumentError.value(
      catalogRef,
      'catalogRef',
      'Music listening requires a concrete Music Catalog Item',
    );
  }
}
