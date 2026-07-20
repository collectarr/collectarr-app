import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';

class CatalogDiscDto {
  const CatalogDiscDto({
    required this.discNumber,
    this.discName,
    this.discFormat,
    this.storageDevice,
    this.slot,
    this.matrixSideA,
    this.matrixSideB,
    this.trackCount,
    this.expectedTrackCount,
    this.ownedTrackCount,
    this.missingTrackCount,
    this.missingTrackPositions = const <String>[],
    this.toc,
    this.cddbId,
    this.leadoutOffset,
    this.bpDiscId,
    this.packaging,
    this.mediaCondition,
    this.soundType,
    this.rpm,
    this.vinylColor,
    this.vinylWeight,
    this.tracks = const <CatalogTrackDto>[],
  });

  final int discNumber;
  final String? discName;
  final String? discFormat;
  final String? storageDevice;
  final String? slot;
  final String? matrixSideA;
  final String? matrixSideB;
  final int? trackCount;
  final int? expectedTrackCount;
  final int? ownedTrackCount;
  final int? missingTrackCount;
  final List<String> missingTrackPositions;
  final String? toc;
  final String? cddbId;
  final int? leadoutOffset;
  final String? bpDiscId;
  final String? packaging;
  final String? mediaCondition;
  final String? soundType;
  final int? rpm;
  final String? vinylColor;
  final String? vinylWeight;
  final List<CatalogTrackDto> tracks;

  factory CatalogDiscDto.fromJson(Map<String, dynamic> json) {
    return CatalogDiscDto(
      discNumber: json['disc_number'] as int? ?? 1,
      discName: json['disc_name'] as String?,
      discFormat: json['disc_format'] as String?,
      storageDevice: json['storage_device'] as String?,
      slot: json['slot'] as String?,
      matrixSideA: json['matrix_side_a'] as String?,
      matrixSideB: json['matrix_side_b'] as String?,
      trackCount: json['track_count'] as int?,
      expectedTrackCount: json['expected_track_count'] as int?,
      ownedTrackCount: json['owned_track_count'] as int?,
      missingTrackCount: json['missing_track_count'] as int?,
      missingTrackPositions: (json['missing_track_positions'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      toc: json['toc'] as String?,
      cddbId: json['cddb_id'] as String?,
      leadoutOffset: json['leadout_offset'] as int?,
      bpDiscId: json['bp_disc_id'] as String?,
      packaging: json['packaging'] as String?,
      mediaCondition: json['media_condition'] as String?,
      soundType: json['sound_type'] as String?,
      rpm: json['rpm'] as int?,
      vinylColor: json['vinyl_color'] as String?,
      vinylWeight: json['vinyl_weight'] as String?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogTrackDto.fromJson)
              .toList(growable: false) ??
          const <CatalogTrackDto>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disc_number': discNumber,
      if (discName != null) 'disc_name': discName,
      if (discFormat != null) 'disc_format': discFormat,
      if (storageDevice != null) 'storage_device': storageDevice,
      if (slot != null) 'slot': slot,
      if (matrixSideA != null) 'matrix_side_a': matrixSideA,
      if (matrixSideB != null) 'matrix_side_b': matrixSideB,
      if (trackCount != null) 'track_count': trackCount,
      if (expectedTrackCount != null) 'expected_track_count': expectedTrackCount,
      if (ownedTrackCount != null) 'owned_track_count': ownedTrackCount,
      if (missingTrackCount != null) 'missing_track_count': missingTrackCount,
      if (missingTrackPositions.isNotEmpty)
        'missing_track_positions': missingTrackPositions,
      if (toc != null) 'toc': toc,
      if (cddbId != null) 'cddb_id': cddbId,
      if (leadoutOffset != null) 'leadout_offset': leadoutOffset,
      if (bpDiscId != null) 'bp_disc_id': bpDiscId,
      if (packaging != null) 'packaging': packaging,
      if (mediaCondition != null) 'media_condition': mediaCondition,
      if (soundType != null) 'sound_type': soundType,
      if (rpm != null) 'rpm': rpm,
      if (vinylColor != null) 'vinyl_color': vinylColor,
      if (vinylWeight != null) 'vinyl_weight': vinylWeight,
      if (tracks.isNotEmpty)
        'tracks': tracks.map((track) => track.toJson()).toList(growable: false),
    };
  }
}
