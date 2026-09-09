import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';

/// Comic-owned issue progress unit.
final class ComicTrackingUnit extends TrackingUnit {
  const ComicTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.issueNumber,
    super.trackingEntryId,
    super.ownedRef,
    super.deletedAt,
  }) : super(unitType: ComicTrackingUnit.type);

  static const type = 'issue';

  final String? issueNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()..['issue_number'] = issueNumber;
  }

  @override
  ComicTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    OwnedItemRef? ownedRef,
    String? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ComicTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedRef: ownedRef ?? this.ownedRef,
      issueNumber: issueNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
