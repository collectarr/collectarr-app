import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';

/// TV-owned season/episode progress unit.
final class TvTrackingUnit extends TrackingUnitSummary {
  const TvTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.seasonNumber,
    this.episodeNumber,
    super.trackingEntryId,
    super.ownedRef,
    super.deletedAt,
  }) : super(unitType: TvTrackingUnit.type);

  static const type = 'episode';

  final int? seasonNumber;
  final int? episodeNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()
      ..addAll({
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
      });
  }

  @override
  TvTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    OwnedItemRef? ownedRef,
    String? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TvTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedRef: ownedRef ?? this.ownedRef,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
