import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';

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
    required this.ownedItemId,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
    required this.unitType,
    required this.completedAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
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

  String get kind;

  Future<void> clearCoordinates(LocalDatabase db, String id);

  Future<void> writeCoordinates(LocalDatabase db, TrackingUnit unit);

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
