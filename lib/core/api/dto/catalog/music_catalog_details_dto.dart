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

  // Extended getters used by the inspector (null by default in the generic DTO)
  int? get expectedMediaCount => null;
  int? get ownedMediaCount => null;
  int? get missingMediaCount => null;
  List<int> get missingDiscNumbers => const <int>[];
  String? get upc => catalogNumber;
  String? get localCoverImagePath => null;
  String? get localBackImagePath => null;
  String? get localThumbnailImagePath => null;

  factory MusicCatalogDetailsDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    }

    final rawTracks = (json['tracks'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) => CatalogTrackDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false) ??
        const <CatalogTrackDto>[];

    final rawDiscs = (json['discs'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) => CatalogDiscDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false) ??
        const <CatalogDiscDto>[];

    return MusicCatalogDetailsDto(
      trackCount: json['track_count'] as int? ??
          (rawTracks.isNotEmpty ? rawTracks.length : null),
      tracks: rawTracks,
      discs: rawDiscs,
      catalogNumber: json['catalog_number'] as String?,
      releaseStatus: json['release_status'] as String?,
      originalReleaseDate:
          parseDate(json['original_release_date'] as String?),
      recordingDate: parseDate(json['recording_date'] as String?),
      studio: json['studio'] as String?,
      rpm: json['rpm'] as String?,
      spars: json['spars'] as String?,
      soundType: json['sound_type'] as String?,
      vinylColor: json['vinyl_color'] as String?,
      vinylWeight: json['vinyl_weight'] as String?,
      mediaCondition: json['media_condition'] as String?,
      instrument: json['instrument'] as String?,
      isLive: json['is_live'] as bool?,
      composition: json['composition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (trackCount != null) 'track_count': trackCount,
        if (tracks.isNotEmpty)
          'tracks': tracks.map((e) => e.toJson()).toList(),
        if (discs.isNotEmpty) 'discs': discs.map((e) => e.toJson()).toList(),
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (originalReleaseDate != null)
          'original_release_date':
              originalReleaseDate!.toUtc().toIso8601String(),
        if (recordingDate != null)
          'recording_date': recordingDate!.toUtc().toIso8601String(),
        if (studio != null) 'studio': studio,
        if (rpm != null) 'rpm': rpm,
        if (spars != null) 'spars': spars,
        if (soundType != null) 'sound_type': soundType,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (mediaCondition != null) 'media_condition': mediaCondition,
        if (instrument != null) 'instrument': instrument,
        if (isLive != null) 'is_live': isLive,
        if (composition != null) 'composition': composition,
      };
}

typedef MusicCatalogDetails = MusicCatalogDetailsDto;
