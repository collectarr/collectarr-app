import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:drift/drift.dart';

import 'game_tracking_entry.dart';

/// Game-owned lifecycle tracking mapping. Platform/release semantics stay in
/// the Game vertical; this codec only maps the universal lifecycle contract.
final class GameTrackingEntryCodec
    with TrackingEntryStorageSupport
    implements TrackingEntryCodec {
  const GameTrackingEntryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Future<List<TrackingEntryStorageRecord>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  }) async {
    final query = db.select(db.gameTrackingRows);
    if (activeOnly) query.where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    return [
      for (final row in rows)
        TrackingEntryStorageRecord(
          trackingEntryStorageRowFromColumns(
            id: row.id,
            catalogRefJson: row.catalogRefJson,
            ownedItemId: row.ownedItemId,
            sourceType: row.sourceType,
            status: row.status,
            rating: row.rating,
            startedAt: row.startedAt,
            finishedAt: row.finishedAt,
            progressCurrent: row.progressCurrent,
            progressTotal: row.progressTotal,
            timesCompleted: row.timesCompleted,
            notes: row.notes,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
          ),
          null,
        ),
    ];
  }

  @override
  Future<void> writeStorageRecord(LocalDatabase db, TrackingEntry entry) async {
    _validateKind(entry.catalogRef);
    await db.into(db.gameTrackingRows).insertOnConflictUpdate(
          GameTrackingRowsCompanion.insert(
            id: entry.id,
            catalogRefJson: jsonEncode(entry.catalogRef.toJson()),
            ownedItemId: Value(entry.ownedRef?.key),
            sourceType: Value(entry.sourceTypeApiValue),
            status: Value(entry.statusStorageValue),
            rating: Value(entry.rating),
            startedAt: Value(entry.startedAt),
            finishedAt: Value(entry.finishedAt),
            progressCurrent: Value(entry.progressCurrent),
            progressTotal: Value(entry.progressTotal),
            timesCompleted: Value(entry.timesCompleted),
            notes: Value(entry.notes),
            updatedAt: entry.updatedAt,
            deletedAt: Value(entry.deletedAt),
          ),
        );
  }

  @override
  Future<void> deleteStorageRecord(
      LocalDatabase db, TrackingEntry entry, DateTime deletedAt) async {
    _validateKind(entry.catalogRef);
    await (db.update(db.gameTrackingRows)
          ..where((row) => row.id.equals(entry.id)))
        .write(GameTrackingRowsCompanion(
      deletedAt: Value(deletedAt),
      updatedAt: Value(deletedAt),
    ));
  }

  @override
  GameTrackingEntry create({
    required String id,
    required CatalogEntityRef catalogRef,
    OwnedItemRef? ownedRef,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    _validateKind(catalogRef);
    return GameTrackingEntry(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async =>
      const {};

  @override
  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    _validateKind(entry.catalogRef);
    return entry.toSyncPayload();
  }

  @override
  TrackingEntry fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final catalogRef = _catalogRefFromPayload(payload);
    _validateKind(catalogRef);
    return GameTrackingEntry(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedItemRefFromSerialized(payload['owned_ref']),
      sourceType: payload['source_type'] as String?,
      status: payload['status'] as String?,
      rating: _int(payload['rating']),
      startedAt: _date(payload['started_at']),
      finishedAt: _date(payload['finished_at']),
      progressCurrent: _int(payload['progress_current']),
      progressTotal: _int(payload['progress_total']),
      timesCompleted: _int(payload['times_completed']),
      notes: payload['notes'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  ) {
    _validateKind(row.catalogRef);
    return GameTrackingEntry(
      id: row.id,
      catalogRef: row.catalogRef,
      ownedRef: row.ownedRef,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogEntityRef _catalogRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException('Game tracking entry is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }

  void _validateKind(CatalogEntityRef ref) {
    if (ref.mediaKind != kind) {
      throw ArgumentError.value(
        ref.mediaKind,
        'catalogRef.kind',
        'Expected Game tracking entry',
      );
    }
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
