import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';

/// Book-owned volume/chapter progress unit.
final class BookTrackingUnit extends TrackingUnitSummary {
  const BookTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.volumeNumber,
    this.chapterNumber,
    super.trackingEntryId,
    super.ownedRef,
    super.deletedAt,
  }) : super(unitType: BookTrackingUnit.type);

  static const type = 'chapter';

  final int? volumeNumber;
  final int? chapterNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()
      ..addAll({
        'volume_number': volumeNumber,
        'chapter_number': chapterNumber,
      });
  }

  @override
  BookTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    OwnedItemRef? ownedRef,
    String? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return BookTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedRef: ownedRef ?? this.ownedRef,
      volumeNumber: volumeNumber,
      chapterNumber: chapterNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
