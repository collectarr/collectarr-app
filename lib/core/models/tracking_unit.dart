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

/// Fields shared by every personal tracking unit.
///
/// Coordinates deliberately live on the kind-specific subclasses below so a
/// unit cannot carry unrelated TV, print, and comic fields simultaneously.
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
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// A TV or anime season/episode tracking unit.
class VideoTrackingUnit extends TrackingUnit {
  const VideoTrackingUnit({
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
    super.unitType = TrackingUnitType.episode,
  });

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
  VideoTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingUnitType? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return VideoTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      unitType: unitType ?? this.unitType,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// A book or manga volume/chapter tracking unit.
class ReadingTrackingUnit extends TrackingUnit {
  const ReadingTrackingUnit({
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
    super.unitType = TrackingUnitType.chapter,
  });

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
  ReadingTrackingUnit copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingUnitType? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ReadingTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      unitType: unitType ?? this.unitType,
      volumeNumber: volumeNumber,
      chapterNumber: chapterNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// A comic issue tracking unit.
class ComicTrackingUnit extends TrackingUnit {
  const ComicTrackingUnit({
    required super.id,
    required super.targetRef,
    required super.completedAt,
    required super.updatedAt,
    this.issueNumber,
    super.trackingEntryId,
    super.ownedItemId,
    super.editionId,
    super.variantId,
    super.bundleReleaseId,
    super.deletedAt,
    super.unitType = TrackingUnitType.issue,
  });

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
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TrackingUnitType? unitType,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ComicTrackingUnit(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      unitType: unitType ?? this.unitType,
      issueNumber: issueNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
