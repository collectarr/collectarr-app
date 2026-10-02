import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';

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
    required this.collectionItemRef,
    required this.completedAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final CollectionItemRef? collectionItemRef;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

/// Kind-owned persistence and projection behavior for tracking units.
///
/// The generic collection repository supplies transaction and query
/// mechanics. It never reads a kind's coordinate fields or chooses a domain
/// subtype based on semantic field names.
abstract interface class TrackingUnitStorageCodec {
  const TrackingUnitStorageCodec();

  CatalogMediaKind get kind;

  /// Reads the complete kind-owned tracking-unit rows.
  ///
  /// The Collection repository orchestrates across codecs, but each codec
  /// owns its Drift table and reconstructs its concrete unit type.
  Future<List<TrackingUnitSummary>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  });

  Future<TrackingUnitSummary?> findFromStorage(
    LocalDatabase db,
    TrackingUnitRef ref,
  );

  Future<void> upsertToStorage(LocalDatabase db, TrackingUnitSummary unit);

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingUnitSummary unit,
    DateTime deletedAt,
  );

  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  );

  TrackingUnitSummary fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  );

  TrackingUnitSummary fromSyncPayload({
    required String id,
    required Map<String, Object?> payload,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  });

  int compareCoordinates(TrackingUnitSummary left, TrackingUnitSummary right);
}

TrackingUnitStorageRow trackingUnitStorageRowFromSyncPayload({
  required String id,
  required Map<String, Object?> payload,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) {
  final rawTargetRef = payload['catalog_ref'];
  if (rawTargetRef is! Map) {
    throw const FormatException(
      'Tracking unit sync payload is missing catalog_ref',
    );
  }
  final targetRef = CatalogEntityRef.fromJson(
    Map<String, Object?>.from(rawTargetRef),
  );
  requireKnownCatalogRef(targetRef, 'trackingUnit.targetRef');
  final collectionItemRef = collectionItemRefFromSerialized(payload['collection_item_ref']);
  if (collectionItemRef != null) {
    requireMatchingCatalogAndCollectionItemKinds(targetRef, collectionItemRef);
  }
  final completedAtValue = payload['completed_at'];
  if (completedAtValue is! String) {
    throw const FormatException(
      'Tracking unit sync payload is missing completed_at',
    );
  }
  final trackingEntryId = payload['tracking_entry_id'];
  if (trackingEntryId != null && trackingEntryId is! String) {
    throw const FormatException('Invalid tracking_entry_id');
  }
  return TrackingUnitStorageRow(
    id: id,
    targetRef: targetRef,
    trackingEntryId: trackingEntryId as String?,
    collectionItemRef: collectionItemRef,
    completedAt: DateTime.parse(completedAtValue),
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

int? trackingUnitSyncInt(Object? value) {
  if (value == null) return null;
  if (value is int && value >= 0) return value;
  throw FormatException('Expected an integer tracking coordinate, got $value');
}

void requireTrackingUnitType(Map<String, Object?> payload, String expected) {
  if (payload['unit_type'] != expected) {
    throw FormatException('Expected tracking unit type "$expected"');
  }
}

String? trackingUnitSyncString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Expected a string tracking coordinate, got $value');
}

TrackingUnitStorageRow trackingUnitStorageRowFromColumns({
  required String id,
  required String targetRefJson,
  required String? trackingEntryId,
  required String? collectionItemRefKey,
  required DateTime completedAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) {
  final decoded = jsonDecode(targetRefJson);
  if (decoded is! Map) {
    throw FormatException(
        'Tracking unit target_ref is invalid: $targetRefJson');
  }
  final targetRef = CatalogEntityRef.fromJson(
    Map<String, Object?>.from(decoded),
  );
  requireKnownCatalogRef(targetRef, 'trackingUnit.targetRef');
  final collectionItemRef = collectionItemRefFromSerialized(collectionItemRefKey);
  if (collectionItemRef != null) {
    requireMatchingCatalogAndCollectionItemKinds(targetRef, collectionItemRef);
  }
  return TrackingUnitStorageRow(
    id: id,
    targetRef: targetRef,
    trackingEntryId: trackingEntryId,
    collectionItemRef: collectionItemRef,
    completedAt: completedAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
