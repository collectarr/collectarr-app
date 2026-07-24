import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';

class CatalogDiscDto {
  const CatalogDiscDto({
    this.discNumber,
    this.name,
    this.tracks = const <CatalogTrackDto>[],
  });

  final int? discNumber;
  final String? name;
  final List<CatalogTrackDto> tracks;

  String? get discName => name;
  String? get discFormat => null;
  String? get storageDevice => null;
  String? get slot => null;
  String? get matrixSideA => null;
  String? get matrixSideB => null;

  factory CatalogDiscDto.fromJson(Map<String, dynamic> json) {
    final rawTracks = (json['tracks'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(CatalogTrackDto.fromJson)
        .toList(growable: false);
    return CatalogDiscDto(
      discNumber: json['disc_number'] as int?,
      name: json['name'] as String?,
      tracks: rawTracks ?? const <CatalogTrackDto>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (discNumber != null) 'disc_number': discNumber,
      if (name != null) 'name': name,
      if (tracks.isNotEmpty)
        'tracks': tracks.map((track) => track.toJson()).toList(growable: false),
    };
  }
}

typedef CatalogDisc = CatalogDiscDto;
