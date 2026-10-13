import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';

/// Manga-entry volume/chapter progress unit.
final class MangaTrackingUnit extends TrackingUnitSummary {
  const MangaTrackingUnit({
    required super.id,
    required super.libraryEntryRef,
    required super.completedAt,
    required super.updatedAt,
    this.volumeNumber,
    this.chapterNumber,
    super.trackingEntryId,
    super.deletedAt,
  });

  static const type = 'chapter';

  final int? volumeNumber;
  final int? chapterNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()
      ..addAll({
        'unit_type': type,
        'volume_number': volumeNumber,
        'chapter_number': chapterNumber,
      });
  }

  @override
  MangaTrackingUnit copyWith({
    String? id,
    String? trackingEntryId,
    LibraryEntryRef? libraryEntryRef,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MangaTrackingUnit(
      id: id ?? this.id,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      volumeNumber: volumeNumber,
      chapterNumber: chapterNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
