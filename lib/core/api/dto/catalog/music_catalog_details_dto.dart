import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';

class MusicCatalogDetailsDto {
  const MusicCatalogDetailsDto({
    this.trackCount,
    this.tracks = const <CatalogTrackDto>[],
    this.discs = const <CatalogDiscDto>[],
    this.catalogNumber,
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
  });

  final int? trackCount;
  final List<CatalogTrackDto> tracks;
  final List<CatalogDiscDto> discs;

  int? get discCount => discs.isEmpty ? null : discs.length;
  String? get length => null;
  final String? catalogNumber;
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

  bool get hasData =>
      trackCount != null ||
      tracks.isNotEmpty ||
      discs.isNotEmpty ||
      (catalogNumber != null && catalogNumber!.isNotEmpty) ||
      (releaseStatus != null && releaseStatus!.isNotEmpty) ||
      originalReleaseDate != null ||
      recordingDate != null ||
      (studio != null && studio!.isNotEmpty) ||
      (rpm != null && rpm!.isNotEmpty) ||
      (spars != null && spars!.isNotEmpty) ||
      (soundType != null && soundType!.isNotEmpty) ||
      (vinylColor != null && vinylColor!.isNotEmpty) ||
      (vinylWeight != null && vinylWeight!.isNotEmpty) ||
      (mediaCondition != null && mediaCondition!.isNotEmpty) ||
      (instrument != null && instrument!.isNotEmpty) ||
      isLive != null ||
      (composition != null && composition!.isNotEmpty);
}

typedef MusicCatalogDetails = MusicCatalogDetailsDto;
