import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// Sentinel used by typed tracking lifecycle subclasses when they need to
/// distinguish an omitted nullable patch from an explicit `null`.
///
/// The sentinel lets kind-owned tracking entries preserve omitted nullable
/// patches through common lifecycle updates without adding semantic fields to
/// the shared model.
const Object trackingLifecycleUnset = Object();

abstract class TrackingLifecycle extends PersonalTrackingBase {
  TrackingLifecycle({
    required this.id,
    required this.catalogRef,
    this.ownedRef,
    Object? sourceType,
    super.status,
    super.rating,
    super.startedAt,
    DateTime? finishedAt,
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
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Kind-owned progress exposed as a structural orchestration snapshot.
  TrackingProgressSnapshot get progress;

  /// Returns the owning kind's lifecycle with a progress patch applied.
  TrackingLifecycle copyWithProgress(TrackingProgressSnapshot progress);

  DateTime? get finishedAt => completedAt;

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
      'notes': notes,
    };
  }

  TrackingLifecycle copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingLifecycleUnset,
    Object? sourceType = trackingLifecycleUnset,
    Object? status = trackingLifecycleUnset,
    Object? rating = trackingLifecycleUnset,
    Object? startedAt = trackingLifecycleUnset,
    Object? finishedAt = trackingLifecycleUnset,
    Object? notes = trackingLifecycleUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingLifecycleUnset,
  });
}
