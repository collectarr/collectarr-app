import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_entry_ref.dart';

/// The serialized, kind-neutral portion of a tracking-entry row.
///
/// Hierarchy coordinates deliberately do not cross this boundary. The owning
/// kind receives the row and its opaque coordinate projection through
/// [TrackingEntryCodec.fromStorageRow].
final class TrackingEntryStorageRow {
  const TrackingEntryStorageRow({
    required this.id,
    required this.catalogRef,
    required this.ownedRef,
    required this.sourceType,
    required this.status,
    required this.rating,
    required this.startedAt,
    required this.finishedAt,
    required this.progressCurrent,
    required this.progressTotal,
    required this.timesCompleted,
    required this.notes,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final OwnedItemRef? ownedRef;
  final String? sourceType;
  final String? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

final class TrackingEntryStorageRecord {
  const TrackingEntryStorageRecord(this.row, this.coordinates);

  final TrackingEntryStorageRow row;
  final Object? coordinates;
}

/// Kind-owned tracking-entry storage and reconstruction behavior.
///
/// The generic repository owns transaction and query mechanics only. A codec
/// semantic columns and their interpretation live in the kind adapter.
abstract interface class TrackingEntryCodec {
  const TrackingEntryCodec();

  CatalogMediaKind get kind;

  /// Reads complete lifecycle rows from the owning kind table.
  Future<List<TrackingEntry>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  });

  Future<TrackingEntry?> findFromStorage(
    LocalDatabase db,
    TrackingEntryRef ref,
  );

  Future<void> upsertToStorage(LocalDatabase db, TrackingEntry entry);

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingEntry entry,
    DateTime deletedAt,
  );

  TrackingEntry create({
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
  });

  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  );

  Map<String, dynamic> toSyncPayload(TrackingEntry entry);

  /// Reconstructs a tracking entry received from the provider sync boundary.
  ///
  /// Kind-specific coordinates are parsed by the owning codec rather than by
  /// the shared model's transport factory.
  TrackingEntry fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });

  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  );
}

/// Shared persistence mechanics for kind-owned tracking-entry codecs.
///
/// The mixin owns only filtering/reconstruction mechanics. Each kind supplies
/// its row query and its own Drift companion, so no semantic table definition
/// or field interpretation crosses the kind boundary.
mixin TrackingEntryStorageSupport {
  CatalogMediaKind get kind;

  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  );

  Future<List<TrackingEntryStorageRecord>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  });

  Future<void> writeStorageRecord(LocalDatabase db, TrackingEntry entry);

  Future<void> deleteStorageRecord(
    LocalDatabase db,
    TrackingEntry entry,
    DateTime deletedAt,
  );

  Future<List<TrackingEntry>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  }) async {
    return [
      for (final record in await readStorageRecords(
        db,
        activeOnly: activeOnly,
      ))
        fromStorageRow(record.row, record.coordinates),
    ];
  }

  Future<TrackingEntry?> findFromStorage(
    LocalDatabase db,
    TrackingEntryRef ref,
  ) async {
    if (ref.kind != kind) return null;
    for (final record in await readStorageRecords(
      db,
      activeOnly: false,
    )) {
      if (record.row.id == ref.id) {
        return fromStorageRow(record.row, record.coordinates);
      }
    }
    return null;
  }

  Future<void> upsertToStorage(LocalDatabase db, TrackingEntry entry) {
    return writeStorageRecord(db, entry);
  }

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingEntry entry,
    DateTime deletedAt,
  ) {
    return deleteStorageRecord(db, entry, deletedAt);
  }
}

TrackingEntryStorageRow trackingEntryStorageRowFromColumns({
  required String id,
  required String catalogRefJson,
  required String? ownedItemId,
  required String? sourceType,
  required String? status,
  required int? rating,
  required DateTime? startedAt,
  required DateTime? finishedAt,
  required int? progressCurrent,
  required int? progressTotal,
  required int? timesCompleted,
  required String? notes,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) {
  final decoded = jsonDecode(catalogRefJson);
  if (decoded is! Map) {
    throw FormatException(
        'Tracking entry catalog_ref is invalid: $catalogRefJson');
  }
  return TrackingEntryStorageRow(
    id: id,
    catalogRef: CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded)),
    ownedRef: ownedItemRefFromSerialized(ownedItemId),
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
