import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

enum TrackingUnitType {
  season('season'),
  episode('episode'),
  volume('volume'),
  chapter('chapter'),
  issue('issue');

  const TrackingUnitType(this.storageValue);

  final String storageValue;
}

TrackingUnitType? trackingUnitTypeFromValue(String? value) {
  if (value == null) {
    return null;
  }
  for (final type in TrackingUnitType.values) {
    if (type.storageValue == value) {
      return type;
    }
  }
  return null;
}

class TrackingUnit {
  const TrackingUnit({
    required this.id,
    required this.targetRef,
    required this.unitType,
    required this.completedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.ownedItemId,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
    this.seasonNumber,
    this.episodeNumber,
    this.volumeNumber,
    this.chapterNumber,
    this.issueNumber,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final TrackingUnitType unitType;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? volumeNumber;
  final int? chapterNumber;
  final String? issueNumber;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => targetRef.id;

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => !isDeleted;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': targetRef.toJson(),
      'unit_type': unitType.storageValue,
      'tracking_entry_id': trackingEntryId,
      'owned_item_id': ownedItemId,
      'edition_id': editionId,
      'variant_id': variantId,
      'bundle_release_id': bundleReleaseId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'volume_number': volumeNumber,
      'chapter_number': chapterNumber,
      'issue_number': issueNumber,
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }

  TrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingUnitType? unitType,
    int? seasonNumber,
    int? episodeNumber,
    int? volumeNumber,
    int? chapterNumber,
    String? issueNumber,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      unitType: unitType ?? this.unitType,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      issueNumber: issueNumber ?? this.issueNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}