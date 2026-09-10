import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';

/// The serialized, kind-neutral portion of a tracking-unit row.
///
/// Coordinate data is deliberately absent. A kind codec owns the coordinate
/// table and passes its decoded value back to [fromStorageRow] as an opaque
/// object understood only by that codec.
final class TrackingUnitStorageRow {
  const TrackingUnitStorageRow({
    required this.id,
    required this.targetRef,
    required this.trackingEntryId,
    required this.ownedRef,
    required this.unitType,
    required this.completedAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final OwnedItemRef? ownedRef;
  final String unitType;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

/// Kind-owned persistence and projection behavior for tracking units.
///
/// The generic collection repository supplies transaction and query
/// mechanics. It never reads a kind's coordinate fields or chooses a domain
/// subtype based on semantic field names.
abstract interface class TrackingUnitCodec {
  const TrackingUnitCodec();

  CatalogMediaKind get kind;

  /// Reads the complete kind-owned tracking-unit rows.
  ///
  /// The Collection repository orchestrates across codecs, but each codec
  /// owns its Drift table and reconstructs its concrete unit type.
  Future<List<TrackingUnit>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  });

  Future<TrackingUnit?> findFromStorage(
    LocalDatabase db,
    TrackingUnitRef ref,
  );

  Future<void> upsertToStorage(LocalDatabase db, TrackingUnit unit);

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingUnit unit,
    DateTime deletedAt,
  );

  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  );

  TrackingUnit fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  );

  int compareCoordinates(TrackingUnit left, TrackingUnit right);
}

TrackingUnitStorageRow trackingUnitStorageRowFromColumns({
  required String id,
  required String targetRefJson,
  required String? trackingEntryId,
  required String? ownedItemId,
  required String unitType,
  required DateTime completedAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) {
  final decoded = jsonDecode(targetRefJson);
  if (decoded is! Map) {
    throw FormatException(
        'Tracking unit target_ref is invalid: $targetRefJson');
  }
  return TrackingUnitStorageRow(
    id: id,
    targetRef: CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded)),
    trackingEntryId: trackingEntryId,
    ownedRef: ownedItemRefFromSerialized(ownedItemId),
    unitType: unitType,
    completedAt: completedAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
