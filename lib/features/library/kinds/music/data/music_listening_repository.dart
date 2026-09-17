import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:drift/drift.dart';

/// Local persistence for Music listening events.
///
/// The repository is deliberately typed and Music-owned. The generic
/// tracking repository stores lifecycle state; it must not flatten repeated
/// listening events into one universal table.
final class MusicListeningRepository {
  const MusicListeningRepository(this._db);

  final LocalDatabase _db;

  Future<MusicListenEvent?> findById(String id) async {
    final row = await (_db.select(_db.musicListenEventsRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<MusicListenEvent>> listForReleaseGroup(
    MusicReleaseGroupId groupId,
  ) async {
    final rows = await (_db.select(_db.musicListenEventsRows)
          ..where(
            (table) =>
                table.releaseGroupId.equals(groupId.value) &
                table.deletedAt.isNull(),
          )
          ..orderBy([
            (table) => OrderingTerm.desc(table.listenedAt),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .get();
    return [for (final row in rows) _fromRow(row)];
  }

  Future<List<MusicListenEvent>> listForRelease(
    CatalogEntityRef releaseRef,
  ) async {
    _validateTarget(releaseRef);
    if (releaseRef.entityType.apiValue != 'release') {
      throw ArgumentError.value(
        releaseRef,
        'releaseRef',
        'Music listening release query requires a release reference',
      );
    }
    final rows = await (_db.select(_db.musicListenEventsRows)
          ..where(
            (table) =>
                table.releaseId.equals(releaseRef.id) &
                table.deletedAt.isNull(),
          )
          ..orderBy([
            (table) => OrderingTerm.desc(table.listenedAt),
            (table) => OrderingTerm.desc(table.id),
          ]))
        .get();
    return [for (final row in rows) _fromRow(row)];
  }

  /// Computes the group-level listening projection from event history and
  /// the typed release table. The result is intentionally not persisted.
  Future<MusicReleaseGroupTrackingSummary> getTrackingSummary(
    MusicReleaseGroupId groupId,
  ) async {
    final events = await listForReleaseGroup(groupId);
    final releaseRows = await (_db.select(_db.musicReleaseRows)
          ..where((table) => table.releaseGroupId.equals(groupId.value)))
        .get();
    return MusicReleaseGroupTrackingSummary.fromEvents(
      releaseGroupId: groupId.value,
      events: events,
      releaseIds: releaseRows.map((row) => row.id),
    );
  }

  Future<List<MusicListenEvent>> listForTarget(
    CatalogEntityRef target,
  ) async {
    _validateTarget(target);
    if (target.entityType.apiValue == 'release') {
      return listForRelease(target);
    }
    final events = await listForReleaseGroup(
      MusicReleaseGroupId(target.rootId ?? target.id),
    );
    final root = target.rootScope;
    return [
      for (final event in events)
        if (event.targetRef == target ||
            event.targetRef?.rootScope == root ||
            event.releaseRef.rootScope == root)
          event,
    ];
  }

  Future<void> upsert(MusicListenEvent event) {
    _validateEvent(event);
    return _db.into(_db.musicListenEventsRows).insertOnConflictUpdate(
          _toRow(event),
        );
  }

  Future<void> upsertAll(Iterable<MusicListenEvent> events) async {
    final values = events.toList(growable: false);
    for (final event in values) {
      _validateEvent(event);
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
        releaseRef: event.releaseRef,
        targetRef: event.targetRef,
        ownedRef: event.ownedRef,
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
    targetRefJson: jsonEncode((event.targetRef ?? event.releaseRef).toJson()),
    releaseGroupId: event.releaseGroupId,
    releaseId: Value(event.releaseId),
    ownedRefJson: Value(
      event.ownedRef == null ? null : jsonEncode(event.ownedRef!.toJson()),
    ),
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

MusicListenEvent _fromRow(MusicListenEventsRow row) {
  final target = _decodeTarget(row.targetRefJson);
  final owned = _decodeOwnedRef(row.ownedRefJson);
  final releaseId = row.releaseId ??
      (target.entityType.apiValue == 'release'
          ? target.id
          : (throw StateError(
              'Stored Music listen event is missing releaseId')));
  final releaseRef = target.entityType.apiValue == 'release'
      ? target
      : musicReleaseRefForRoot(target.rootScope, releaseId);
  return MusicListenEvent(
    id: row.id,
    releaseRef: releaseRef,
    targetRef: target == releaseRef ? null : target,
    ownedRef: owned,
    listenedAt: row.listenedAt,
    startedAt: row.startedAt,
    finishedAt: row.finishedAt,
    location: row.location,
    notes: row.notes,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
}

CatalogEntityRef _decodeTarget(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw const FormatException('Music listen target is not an object');
  }
  final target = CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded));
  _validateTarget(target);
  return target;
}

OwnedItemRef? _decodeOwnedRef(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw const FormatException('Music listen owned ref is not an object');
  }
  return OwnedItemRef.fromJson(Map<String, Object?>.from(decoded));
}

void _validateEvent(MusicListenEvent event) {
  if (event.id.trim().isEmpty) {
    throw StateError('Cannot persist a Music listen event without an id');
  }
  if (event.targetRef case final target?) {
    _validateTarget(target);
  }
  if (event.ownedRef case final owned?
      when owned.kind != CatalogMediaKind.music) {
    throw StateError(
        'Music listen events can only reference Music owned items');
  }
  requireMusicReleaseRef(
    event.releaseRef,
    label: 'Music listen event releaseRef',
  );
  final target = event.targetRef;
  if (target != null) {
    if (target.rootScope.id != event.releaseRef.rootScope.id) {
      throw StateError(
        'Music listen event target must belong to its releaseRef',
      );
    }
  }
}

void _validateTarget(CatalogEntityRef target) {
  if (!target.isKnown || target.mediaKind != CatalogMediaKind.music) {
    throw ArgumentError.value(
      target,
      'targetRef',
      'Music listening requires a known Music catalog reference',
    );
  }
}
