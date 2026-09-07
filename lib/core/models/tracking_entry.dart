import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Sentinel used by typed tracking-entry subclasses when they need to
/// distinguish an omitted nullable patch from an explicit `null`.
///
/// The common tracking model still exposes its legacy coordinate parameters
/// while callers are migrated to kind-owned tracking entries. Keeping the
/// sentinel public lets those subclasses preserve their typed coordinates
/// through common lifecycle updates without adding semantic fields to the
/// shared model.
const Object trackingEntryUnset = Object();

class TrackingEntry extends PersonalTrackingBase {
  TrackingEntry({
    required this.id,
    required this.catalogRef,
    this.ownedItemId,
    Object? sourceType,
    super.status,
    super.rating,
    super.startedAt,
    DateTime? finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    super.notes,
    this.seasonNumber,
    this.episodeNumber,
    Map<String, int>? episodeRatings,
    required this.updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        episodeRatings = episodeRatings ?? const {},
        super(
          completedAt: finishedAt,
        );

  final String id;
  final CatalogEntityRef catalogRef;
  final String? ownedItemId;
  final TrackingSourceType? sourceType;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int> episodeRatings;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DateTime? get finishedAt => completedAt;

  /// Stable work identifier used for mixed/global queries. Child targets keep
  /// their concrete identity in [catalogRef] while sharing the work key.
  String get itemId => catalogRef.rootId ?? catalogRef.id;

  TrackingSourceType? get trackingSource => sourceType;

  String? get sourceTypeApiValue => sourceType?.apiValue;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'owned_item_id': ownedItemId,
      'source_type': sourceTypeApiValue,
      'status': statusStorageValue,
      'rating': rating,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'progress_current': progressCurrent,
      'progress_total': progressTotal,
      'times_completed': timesCompleted,
      'notes': notes,
    };
  }

  TrackingEntry copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedItemId = trackingEntryUnset,
    Object? sourceType = trackingEntryUnset,
    Object? status = trackingEntryUnset,
    Object? rating = trackingEntryUnset,
    Object? startedAt = trackingEntryUnset,
    Object? finishedAt = trackingEntryUnset,
    Object? progressCurrent = trackingEntryUnset,
    Object? progressTotal = trackingEntryUnset,
    Object? timesCompleted = trackingEntryUnset,
    Object? notes = trackingEntryUnset,
    Object? seasonNumber = trackingEntryUnset,
    Object? episodeNumber = trackingEntryUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = trackingEntryUnset,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedItemId: identical(ownedItemId, trackingEntryUnset)
          ? this.ownedItemId
          : ownedItemId as String?,
      sourceType: identical(sourceType, trackingEntryUnset)
          ? this.sourceType
          : trackingSourceTypeFromValue(sourceType),
      status: identical(status, trackingEntryUnset)
          ? this.status
          : mediaTrackingStatusFromValue(status),
      rating:
          identical(rating, trackingEntryUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingEntryUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingEntryUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingEntryUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingEntryUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingEntryUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingEntryUnset) ? this.notes : notes as String?,
      seasonNumber: identical(seasonNumber, trackingEntryUnset)
          ? this.seasonNumber
          : seasonNumber as int?,
      episodeNumber: identical(episodeNumber, trackingEntryUnset)
          ? this.episodeNumber
          : episodeNumber as int?,
      episodeRatings: episodeRatings ?? this.episodeRatings,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingEntryUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
