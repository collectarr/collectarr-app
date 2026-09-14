import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Sentinel used by kind-owned tracking records for omitted nullable patches.
const Object trackingStorageUnset = Object();

/// Opaque kind-owned tracking operation passed across generic boundaries.
///
/// The concrete kind defines the payload and the owning tracking codec is the
/// only code allowed to interpret it.
abstract interface class TrackingKindPatch {
  CatalogMediaKind get kind;
}

/// Structural behavior contract implemented by every kind's tracking record.
///
/// This is intentionally an interface, not a common tracking aggregate. The
/// concrete kind owns the complete record and may add coordinates, progress,
/// ratings, or other domain state without routing through a universal model.
abstract interface class TrackingStorageRecord {
  String get id;
  CatalogEntityRef get catalogRef;
  OwnedItemRef? get ownedRef;
  TrackingSourceType? get sourceType;
  MediaTrackingStatus? get status;
  int? get rating;
  DateTime? get startedAt;
  DateTime? get finishedAt;
  String? get notes;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  TrackingProgressSnapshot get progress;
  String? get statusStorageValue;
  String? get sourceTypeApiValue;
  String? get trackingSourceApiValue;
  bool get isDeleted;

  TrackingStorageRecord copyWithProgress(TrackingProgressSnapshot progress);

  TrackingStorageRecord copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef,
    Object? sourceType,
    Object? status,
    Object? rating,
    Object? startedAt,
    Object? finishedAt,
    Object? notes,
    DateTime? updatedAt,
    Object? deletedAt,
  });

  Map<String, dynamic> toSyncPayload();
}

/// Shared implementation of genuinely structural tracking behavior.
///
/// The mixin contributes no storage or domain aggregate. Concrete kind
/// records provide all identity/state fields themselves and only reuse the
/// stable schema-v1 serialization shape and universal lifecycle predicates.
mixin TrackingStorageRecordBehavior on PersonalTrackingBase
    implements TrackingStorageRecord {
  @override
  DateTime? get finishedAt => completedAt;

  @override
  String? get sourceTypeApiValue => sourceType?.apiValue;

  @override
  String? get trackingSourceApiValue => sourceTypeApiValue;

  @override
  bool get isDeleted => deletedAt != null;

  @override
  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'owned_ref': ownedRef?.toJson(),
      'source_type': trackingSourceApiValue,
      'status': statusStorageValue,
      'rating': rating,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'notes': notes,
    };
  }
}
