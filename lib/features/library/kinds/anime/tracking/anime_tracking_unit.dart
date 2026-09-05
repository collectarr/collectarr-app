import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';

/// Anime-owned season/episode progress unit.
final class AnimeTrackingUnit extends TrackingUnit {
  const AnimeTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.seasonNumber,
    this.episodeNumber,
    super.trackingEntryId,
    super.ownedItemId,
    super.editionId,
    super.variantId,
    super.bundleReleaseId,
    super.deletedAt,
  }) : super(unitType: AnimeTrackingUnit.type);

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
  AnimeTrackingUnit copyWith({
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
    return AnimeTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
