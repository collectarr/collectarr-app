import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Sentinel used by typed tracking-entry subclasses when they need to
/// distinguish an omitted nullable patch from an explicit `null`.
///
/// The sentinel lets kind-owned tracking entries preserve omitted nullable
/// patches through common lifecycle updates without adding semantic fields to
/// the shared model.
const Object trackingEntryUnset = Object();

class TrackingEntry extends PersonalTrackingBase {
  TrackingEntry({
    required this.id,
    required this.catalogRef,
    this.ownedRef,
    Object? sourceType,
    super.status,
    super.rating,
    super.startedAt,
    DateTime? finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    super.notes,
    required this.updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        super(
          completedAt: finishedAt,
        );

  final String id;
  final CatalogEntityRef catalogRef;
  final OwnedItemRef? ownedRef;
  final TrackingSourceType? sourceType;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
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
      'owned_ref': ownedRef?.toJson(),
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
    Object? ownedRef = trackingEntryUnset,
    Object? sourceType = trackingEntryUnset,
    Object? status = trackingEntryUnset,
    Object? rating = trackingEntryUnset,
    Object? startedAt = trackingEntryUnset,
    Object? finishedAt = trackingEntryUnset,
    Object? progressCurrent = trackingEntryUnset,
    Object? progressTotal = trackingEntryUnset,
    Object? timesCompleted = trackingEntryUnset,
    Object? notes = trackingEntryUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingEntryUnset,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedRef: identical(ownedRef, trackingEntryUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
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
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingEntryUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
