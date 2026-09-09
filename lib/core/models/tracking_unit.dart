import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

/// Kind-neutral tracking-unit persistence projection.
///
/// A unit's domain coordinates are owned by the concrete kind model. This
/// base carries only references and lifecycle fields required by shared sync,
/// cache, and event infrastructure.
class TrackingUnit {
  const TrackingUnit({
    required this.id,
    required this.targetRef,
    required this.unitType,
    required this.completedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.ownedRef,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final OwnedItemRef? ownedRef;
  final String unitType;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => !isDeleted;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': targetRef.toJson(),
      'unit_type': unitType,
      'tracking_entry_id': trackingEntryId,
      'owned_ref': ownedRef?.toJson(),
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }

  TrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    OwnedItemRef? ownedRef,
    String? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedRef: ownedRef ?? this.ownedRef,
      unitType: unitType ?? this.unitType,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
