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
    required this.itemId,
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
  final String itemId;
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

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => !isDeleted;
}