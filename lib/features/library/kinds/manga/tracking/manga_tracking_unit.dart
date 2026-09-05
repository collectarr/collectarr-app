import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';

/// Manga-owned volume/chapter progress unit.
final class MangaTrackingUnit extends TrackingUnit {
  const MangaTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.volumeNumber,
    this.chapterNumber,
    super.trackingEntryId,
    super.ownedItemId,
    super.editionId,
    super.variantId,
    super.bundleReleaseId,
    super.deletedAt,
  }) : super(unitType: MangaTrackingUnit.type);

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
  MangaTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MangaTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      volumeNumber: volumeNumber,
      chapterNumber: chapterNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
