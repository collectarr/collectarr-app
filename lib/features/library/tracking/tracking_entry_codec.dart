import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';

/// The serialized, kind-neutral portion of a tracking-entry row.
///
/// Hierarchy coordinates deliberately do not cross this boundary. The owning
/// kind receives the row and its opaque coordinate projection through
/// [TrackingEntryCodec.fromStorageRow].
final class TrackingEntryStorageRow {
  const TrackingEntryStorageRow({
    required this.id,
    required this.catalogRef,
    required this.ownedItemId,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
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
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
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

/// Kind-owned tracking-entry storage and reconstruction behavior.
///
/// The generic repository owns transaction and query mechanics only. A codec
/// may continue to read a legacy shared table during migration, but the
/// semantic columns and their interpretation live in the kind adapter.
abstract interface class TrackingEntryCodec {
  const TrackingEntryCodec();

  String get kind;

  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  );

  Future<void> clearCoordinates(LocalDatabase db, String id);

  Future<void> writeCoordinates(LocalDatabase db, TrackingEntry entry);

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
