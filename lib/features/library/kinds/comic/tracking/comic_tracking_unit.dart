import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';

/// Comic-entry issue progress unit.
final class ComicTrackingUnit extends TrackingUnitSummary {
  const ComicTrackingUnit({
    required super.id,
    required super.libraryEntryRef,
    required super.completedAt,
    required super.updatedAt,
    this.issueNumber,
    super.trackingEntryId,
    super.deletedAt,
  });

  static const type = 'issue';

  final String? issueNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()
      ..['unit_type'] = type
      ..['issue_number'] = issueNumber;
  }

  @override
  ComicTrackingUnit copyWith({
    String? id,
    String? trackingEntryId,
    LibraryEntryRef? libraryEntryRef,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ComicTrackingUnit(
      id: id ?? this.id,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      issueNumber: issueNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
