import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';

/// The serialized, kind-neutral portion of a lifecycle row.
///
/// Hierarchy coordinates deliberately do not cross this boundary. The owning
/// kind receives the row and its opaque coordinate projection through
/// [TrackingLifecycleCodec.fromStorageRow].
final class TrackingLifecycleStorageRow {
  const TrackingLifecycleStorageRow({
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

final class TrackingLifecycleStorageRecord {
  const TrackingLifecycleStorageRecord(this.row, this.coordinates);

  final TrackingLifecycleStorageRow row;
  final Object? coordinates;
}

/// Kind-owned lifecycle storage and reconstruction behavior.
///
/// The generic repository owns transaction and query mechanics only. A codec
/// semantic columns and their interpretation live in the kind adapter.
abstract interface class TrackingLifecycleCodec {
  const TrackingLifecycleCodec();

  CatalogMediaKind get kind;

  Future<List<TrackingLifecycleStorageRecord>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  });

  /// Reads complete lifecycle rows from the owning kind table.
  Future<List<TrackingLifecycle>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  });

  Future<TrackingLifecycle?> findFromStorage(
    LocalDatabase db,
    TrackingLifecycleRef ref,
  );

  Future<void> upsertToStorage(LocalDatabase db, TrackingLifecycle entry);

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingLifecycle entry,
    DateTime deletedAt,
  );

  TrackingLifecycle create({
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

  Map<String, dynamic> toSyncPayload(TrackingLifecycle entry);

  /// Reconstructs a tracking entry received from the provider sync boundary.
  ///
  /// Kind-specific coordinates are parsed by the owning codec rather than by
  /// the shared model's transport factory.
  TrackingLifecycle fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });

  TrackingLifecycle fromStorageRow(
    TrackingLifecycleStorageRow row,
    Object? coordinates,
  );

  TrackingSummary summaryFromStorageRow(TrackingLifecycleStorageRow row);
}

/// Shared persistence mechanics for kind-owned lifecycle codecs.
///
/// The mixin owns only filtering/reconstruction mechanics. Each kind supplies
/// its row query and its own Drift companion, so no semantic table definition
/// or field interpretation crosses the kind boundary.
mixin TrackingLifecycleStorageSupport {
  CatalogMediaKind get kind;

  TrackingLifecycle fromStorageRow(
    TrackingLifecycleStorageRow row,
    Object? coordinates,
  );

  TrackingSummary summaryFromStorageRow(TrackingLifecycleStorageRow row) {
    return TrackingSummary(
      id: row.id,
      catalogRef: row.catalogRef,
      status:
          mediaTrackingStatusFromValue(row.status) ?? MediaTrackingStatus.none,
      ownedRef: row.ownedRef,
      sourceType: trackingSourceTypeFromValue(row.sourceType),
      rating: row.rating,
      startedAt: row.startedAt,
      completedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  Future<List<TrackingLifecycleStorageRecord>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  });

  Future<void> writeStorageRecord(LocalDatabase db, TrackingLifecycle entry);

  Future<void> deleteStorageRecord(
    LocalDatabase db,
    TrackingLifecycle entry,
    DateTime deletedAt,
  );

  Future<List<TrackingLifecycle>> listFromStorage(
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

  Future<TrackingLifecycle?> findFromStorage(
    LocalDatabase db,
    TrackingLifecycleRef ref,
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

  Future<void> upsertToStorage(LocalDatabase db, TrackingLifecycle entry) {
    return writeStorageRecord(db, entry);
  }

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingLifecycle entry,
    DateTime deletedAt,
  ) {
    return deleteStorageRecord(db, entry, deletedAt);
  }
}

TrackingLifecycleStorageRow trackingLifecycleStorageRowFromColumns({
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
  return TrackingLifecycleStorageRow(
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
