import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';

class MusicCatalogDetailsDto {
  const MusicCatalogDetailsDto({
    this.trackCount,
    this.tracks = const <CatalogTrackDto>[],
    this.discs = const <CatalogDiscDto>[],
    this.expectedMediaCount,
    this.ownedMediaCount,
    this.missingMediaCount,
    this.missingDiscNumbers = const <int>[],
    this.catalogNumber,
    this.upc,
    this.releaseStatus,
    this.originalReleaseDate,
    this.recordingDate,
    this.studio,
    this.rpm,
    this.spars,
    this.soundType,
    this.vinylColor,
    this.vinylWeight,
    this.mediaCondition,
    this.instrument,
    this.isLive,
    this.composition,
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
  });

  final int? trackCount;
  final List<CatalogTrackDto> tracks;
  final List<CatalogDiscDto> discs;
  final int? expectedMediaCount;
  final int? ownedMediaCount;
  final int? missingMediaCount;
  final List<int> missingDiscNumbers;
  final String? catalogNumber;
  final String? upc;
  final String? releaseStatus;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final String? studio;
  final String? rpm;
  final String? spars;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final String? mediaCondition;
  final String? instrument;
  final bool? isLive;
  final String? composition;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;

  bool get hasData =>
      trackCount != null ||
      tracks.isNotEmpty ||
      discs.isNotEmpty ||
      expectedMediaCount != null ||
      ownedMediaCount != null ||
      missingMediaCount != null ||
      missingDiscNumbers.isNotEmpty ||
      catalogNumber != null ||
      upc != null ||
      releaseStatus != null ||
      originalReleaseDate != null ||
      recordingDate != null ||
      studio != null ||
      rpm != null ||
      spars != null ||
      soundType != null ||
      vinylColor != null ||
      vinylWeight != null ||
      mediaCondition != null ||
      instrument != null ||
      isLive != null ||
      composition != null ||
      localCoverImagePath != null ||
      localBackImagePath != null ||
      localThumbnailImagePath != null;

  int get discCount => discs.length;

  String? get length {
    var totalSeconds = 0;
    for (final track in tracks) {
      final duration = track.durationSeconds;
      if (duration != null && duration > 0) {
        totalSeconds += duration;
      }
    }
    if (totalSeconds <= 0) {
      return null;
    }
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
