import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';

/// Structural mixed-feature projection of a kind-owned tracking unit.
///
/// A unit's domain coordinates are owned by the concrete kind model. This
/// summary carries only references and lifecycle fields required by shared
/// sync, persistence orchestration, and event infrastructure. It is not a
/// canonical tracking-domain aggregate.
class TrackingUnitSummary {
  const TrackingUnitSummary({
    required this.id,
    required this.targetRef,
    required this.completedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.collectionItemRef,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final CollectionItemRef? collectionItemRef;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => !isDeleted;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': targetRef.toJson(),
      'tracking_entry_id': trackingEntryId,
      'collection_item_ref': collectionItemRef?.toJson(),
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }

  TrackingUnitSummary copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    CollectionItemRef? collectionItemRef,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrackingUnitSummary(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      collectionItemRef: collectionItemRef ?? this.collectionItemRef,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
