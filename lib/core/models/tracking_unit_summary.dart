import 'package:collectarr_app/core/models/library_entry_projection.dart';

/// Structural mixed-feature projection of a kind-entry tracking unit.
///
/// A unit's domain coordinates are entry by the concrete kind model. This
/// summary carries only references and lifecycle fields required by shared
/// sync, persistence orchestration, and event infrastructure. It is not a
/// canonical tracking-domain aggregate.
class TrackingUnitSummary {
  const TrackingUnitSummary({
    required this.id,
    required this.libraryEntryRef,
    required this.completedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.deletedAt,
  });

  final String id;
  final String? trackingEntryId;
  final LibraryEntryRef libraryEntryRef;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  bool get isCompleted => !isDeleted;

  Map<String, dynamic> toSyncPayload() {
    return {
      'library_entry_ref': libraryEntryRef.toJson(),
      'tracking_entry_id': trackingEntryId,
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }

  TrackingUnitSummary copyWith({
    String? id,
    String? trackingEntryId,
    LibraryEntryRef? libraryEntryRef,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrackingUnitSummary(
      id: id ?? this.id,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
