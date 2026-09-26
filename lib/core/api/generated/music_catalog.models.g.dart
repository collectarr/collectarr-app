// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tool/core_contracts/music-catalog-v1.json
// Contract SHA-256: 31380c6ec3523be1171dd42c3f836790d1af3da355af43c8392e9e2e2e367b6b
part of 'collectarr_api.models.dart';

String _musicString(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Missing or invalid Music field: $field');
}

int _musicInt(Object? value, String field) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Missing or invalid Music field: $field');
}

DateTime _musicDateTime(Object? value, String field) {
  final result = value is String ? DateTime.tryParse(value) : null;
  if (result != null) return result;
  throw FormatException('Missing or invalid Music field: $field');
}

List<T> _musicObjects<T>(
  Object? value,
  T Function(Map<String, dynamic>) decode,
) {
  if (value is! List) return <T>[];
  return [
    for (final row in value)
      if (row is Map) decode(Map<String, dynamic>.from(row))
  ];
}

class MusicAlbumArtistDto {
  const MusicAlbumArtistDto({
    required this.name,
    required this.sortName,
  });

  final String name;
  final String? sortName;

  factory MusicAlbumArtistDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumArtistDto(
      name: _musicString(json['name'], 'name'),
      sortName:
          (json['sort_name'] == null ? null : json['sort_name'] as String?),
    );
  }
  Map<String, dynamic> toJson() => {
        'name': name,
        'sort_name': (sortName == null ? null : sortName),
      };
}

class MusicAlbumCreditDto {
  const MusicAlbumCreditDto({
    required this.creditedName,
    required this.instrument,
    required this.joinPhrase,
    required this.role,
    required this.sequence,
  });

  final String creditedName;
  final String? instrument;
  final String? joinPhrase;
  final String role;
  final int sequence;

  factory MusicAlbumCreditDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumCreditDto(
      creditedName: _musicString(json['credited_name'], 'credited_name'),
      instrument:
          (json['instrument'] == null ? null : json['instrument'] as String?),
      joinPhrase:
          (json['join_phrase'] == null ? null : json['join_phrase'] as String?),
      role: _musicString(json['role'], 'role'),
      sequence: _musicInt(json['sequence'], 'sequence'),
    );
  }
  Map<String, dynamic> toJson() => {
        'credited_name': creditedName,
        'instrument': (instrument == null ? null : instrument),
        'join_phrase': (joinPhrase == null ? null : joinPhrase),
        'role': role,
        'sequence': sequence,
      };
}

class MusicAlbumDiscTitleDto {
  const MusicAlbumDiscTitleDto({
    required this.discNumber,
    required this.title,
  });

  final int discNumber;
  final String title;

  factory MusicAlbumDiscTitleDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumDiscTitleDto(
      discNumber: _musicInt(json['disc_number'], 'disc_number'),
      title: _musicString(json['title'], 'title'),
    );
  }
  Map<String, dynamic> toJson() => {
        'disc_number': discNumber,
        'title': title,
      };
}

class MusicAlbumLabelDto {
  const MusicAlbumLabelDto({
    required this.catalogNumber,
    required this.name,
  });

  final String? catalogNumber;
  final String name;

  factory MusicAlbumLabelDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumLabelDto(
      catalogNumber: (json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?),
      name: _musicString(json['name'], 'name'),
    );
  }
  Map<String, dynamic> toJson() => {
        'catalog_number': (catalogNumber == null ? null : catalogNumber),
        'name': name,
      };
}

class MusicAlbumLinkDto {
  const MusicAlbumLinkDto({
    required this.description,
    required this.position,
    required this.title,
    required this.url,
  });

  final String? description;
  final int position;
  final String? title;
  final String url;

  factory MusicAlbumLinkDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumLinkDto(
      description:
          (json['description'] == null ? null : json['description'] as String?),
      position: _musicInt(json['position'], 'position'),
      title: (json['title'] == null ? null : json['title'] as String?),
      url: _musicString(json['url'], 'url'),
    );
  }
  Map<String, dynamic> toJson() => {
        'description': (description == null ? null : description),
        'position': position,
        'title': (title == null ? null : title),
        'url': url,
      };
}

class MusicAlbumTrackInputDto {
  const MusicAlbumTrackInputDto({
    required this.artist,
    required this.discNumber,
    required this.durationMs,
    required this.position,
    required this.title,
  });

  final String? artist;
  final int discNumber;
  final int? durationMs;
  final int position;
  final String title;

  factory MusicAlbumTrackInputDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumTrackInputDto(
      artist: (json['artist'] == null ? null : json['artist'] as String?),
      discNumber: _musicInt(json['disc_number'], 'disc_number'),
      durationMs: (json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num?)?.toInt()),
      position: _musicInt(json['position'], 'position'),
      title: _musicString(json['title'], 'title'),
    );
  }
  Map<String, dynamic> toJson() => {
        'artist': (artist == null ? null : artist),
        'disc_number': discNumber,
        'duration_ms': (durationMs == null ? null : durationMs),
        'position': position,
        'title': title,
      };
}

class MusicAlbumTrackDto {
  const MusicAlbumTrackDto({
    required this.albumId,
    required this.artist,
    required this.discNumber,
    required this.durationMs,
    required this.position,
    required this.title,
  });

  final String albumId;
  final String? artist;
  final int discNumber;
  final int? durationMs;
  final int position;
  final String title;

  factory MusicAlbumTrackDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumTrackDto(
      albumId: _musicString(json['album_id'], 'album_id'),
      artist: (json['artist'] == null ? null : json['artist'] as String?),
      discNumber: _musicInt(json['disc_number'], 'disc_number'),
      durationMs: (json['duration_ms'] == null
          ? null
          : (json['duration_ms'] as num?)?.toInt()),
      position: _musicInt(json['position'], 'position'),
      title: _musicString(json['title'], 'title'),
    );
  }
  Map<String, dynamic> toJson() => {
        'album_id': albumId,
        'artist': (artist == null ? null : artist),
        'disc_number': discNumber,
        'duration_ms': (durationMs == null ? null : durationMs),
        'position': position,
        'title': title,
      };
}

class MusicAlbumDto extends TypedMetadataResponse {
  const MusicAlbumDto._(
    super.raw, {
    required this.artists,
    required this.backCoverImageUrl,
    required this.barcodeValue,
    required this.boxSet,
    required this.catalogNumber,
    required this.country,
    required this.coverImageUrlValue,
    required this.createdAt,
    required this.credits,
    required this.discTitles,
    required this.extras,
    required this.format,
    required this.genres,
    required this.id,
    required this.isLive,
    required this.labels,
    required this.links,
    required this.matrixNumberSideA,
    required this.matrixNumberSideB,
    required this.originalReleaseDate,
    required this.packaging,
    required this.recordingDate,
    required this.releaseDateParts,
    required this.rpm,
    required this.sortTitle,
    required this.soundTypes,
    required this.sparsCode,
    required this.studio,
    required this.subtitle,
    required this.title,
    required this.tracks,
    required this.updatedAt,
    required this.vinylColor,
    required this.vinylWeight,
  });

  final List<MusicAlbumArtistDto> artists;
  final String? backCoverImageUrl;
  final String? barcodeValue;
  final String? boxSet;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrlValue;
  final DateTime createdAt;
  final List<MusicAlbumCreditDto> credits;
  final List<MusicAlbumDiscTitleDto> discTitles;
  final List<String> extras;
  final String? format;
  final List<String> genres;
  @override
  final String id;
  final bool? isLive;
  final List<MusicAlbumLabelDto> labels;
  final List<MusicAlbumLinkDto> links;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final PartialDate? originalReleaseDate;
  final String? packaging;
  final PartialDate? recordingDate;
  final PartialDate? releaseDateParts;
  final int? rpm;
  final String? sortTitle;
  final List<String> soundTypes;
  final String? sparsCode;
  final List<String> studio;
  final String? subtitle;
  @override
  final String title;
  final List<MusicAlbumTrackDto> tracks;
  final DateTime updatedAt;
  final String? vinylColor;
  final String? vinylWeight;
  @override
  String? get kind => 'music';
  @override
  DateTime? get releaseDate => releaseDateParts?.asDateTime;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrl;
  @override
  String? get barcode => barcodeValue;

  factory MusicAlbumDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumDto._(
      Map<String, dynamic>.from(json),
      artists: _musicObjects<MusicAlbumArtistDto>(
          json['artists'], MusicAlbumArtistDto.fromJson),
      backCoverImageUrl: (json['back_cover_image_url'] == null
          ? null
          : json['back_cover_image_url'] as String?),
      barcodeValue:
          (json['barcode'] == null ? null : json['barcode'] as String?),
      boxSet: (json['box_set'] == null ? null : json['box_set'] as String?),
      catalogNumber: (json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?),
      country: (json['country'] == null ? null : json['country'] as String?),
      coverImageUrlValue: (json['cover_image_url'] == null
          ? null
          : json['cover_image_url'] as String?),
      createdAt: _musicDateTime(json['created_at'], 'created_at'),
      credits: _musicObjects<MusicAlbumCreditDto>(
          json['credits'], MusicAlbumCreditDto.fromJson),
      discTitles: _musicObjects<MusicAlbumDiscTitleDto>(
          json['disc_titles'], MusicAlbumDiscTitleDto.fromJson),
      extras: (json['extras'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      format: (json['format'] == null ? null : json['format'] as String?),
      genres: (json['genres'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      id: _musicString(json['id'], 'id'),
      isLive: (json['is_live'] == null ? null : json['is_live'] as bool?),
      labels: _musicObjects<MusicAlbumLabelDto>(
          json['labels'], MusicAlbumLabelDto.fromJson),
      links: _musicObjects<MusicAlbumLinkDto>(
          json['links'], MusicAlbumLinkDto.fromJson),
      matrixNumberSideA: (json['matrix_number_side_a'] == null
          ? null
          : json['matrix_number_side_a'] as String?),
      matrixNumberSideB: (json['matrix_number_side_b'] == null
          ? null
          : json['matrix_number_side_b'] as String?),
      originalReleaseDate: (json['original_release_date'] == null
          ? null
          : PartialDate.tryParse(json['original_release_date'])),
      packaging:
          (json['packaging'] == null ? null : json['packaging'] as String?),
      recordingDate: (json['recording_date'] == null
          ? null
          : PartialDate.tryParse(json['recording_date'])),
      releaseDateParts: (json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date'])),
      rpm: (json['rpm'] == null ? null : (json['rpm'] as num?)?.toInt()),
      sortTitle:
          (json['sort_title'] == null ? null : json['sort_title'] as String?),
      soundTypes: (json['sound_types'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      sparsCode:
          (json['spars_code'] == null ? null : json['spars_code'] as String?),
      studio: (json['studio'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      subtitle: (json['subtitle'] == null ? null : json['subtitle'] as String?),
      title: _musicString(json['title'], 'title'),
      tracks: _musicObjects<MusicAlbumTrackDto>(
          json['tracks'], MusicAlbumTrackDto.fromJson),
      updatedAt: _musicDateTime(json['updated_at'], 'updated_at'),
      vinylColor:
          (json['vinyl_color'] == null ? null : json['vinyl_color'] as String?),
      vinylWeight: (json['vinyl_weight'] == null
          ? null
          : json['vinyl_weight'] as String?),
    );
  }
  Map<String, dynamic> toJson() => {
        'artists': artists.map((item) => item.toJson()).toList(),
        'back_cover_image_url':
            (backCoverImageUrl == null ? null : backCoverImageUrl),
        'barcode': (barcodeValue == null ? null : barcodeValue),
        'box_set': (boxSet == null ? null : boxSet),
        'catalog_number': (catalogNumber == null ? null : catalogNumber),
        'country': (country == null ? null : country),
        'cover_image_url':
            (coverImageUrlValue == null ? null : coverImageUrlValue),
        'created_at': createdAt.toIso8601String(),
        'credits': credits.map((item) => item.toJson()).toList(),
        'disc_titles': discTitles.map((item) => item.toJson()).toList(),
        'extras': extras,
        'format': (format == null ? null : format),
        'genres': genres,
        'id': id,
        'is_live': (isLive == null ? null : isLive),
        'labels': labels.map((item) => item.toJson()).toList(),
        'links': links.map((item) => item.toJson()).toList(),
        'matrix_number_side_a':
            (matrixNumberSideA == null ? null : matrixNumberSideA),
        'matrix_number_side_b':
            (matrixNumberSideB == null ? null : matrixNumberSideB),
        'original_release_date': (originalReleaseDate == null
            ? null
            : originalReleaseDate?.toJson()),
        'packaging': (packaging == null ? null : packaging),
        'recording_date':
            (recordingDate == null ? null : recordingDate?.toJson()),
        'release_date':
            (releaseDateParts == null ? null : releaseDateParts?.toJson()),
        'rpm': (rpm == null ? null : rpm),
        'sort_title': (sortTitle == null ? null : sortTitle),
        'sound_types': soundTypes,
        'spars_code': (sparsCode == null ? null : sparsCode),
        'studio': studio,
        'subtitle': (subtitle == null ? null : subtitle),
        'title': title,
        'tracks': tracks.map((item) => item.toJson()).toList(),
        'updated_at': updatedAt.toIso8601String(),
        'vinyl_color': (vinylColor == null ? null : vinylColor),
        'vinyl_weight': (vinylWeight == null ? null : vinylWeight),
      };
}

class MusicAlbumWriteDto {
  const MusicAlbumWriteDto({
    required this.artists,
    required this.backCoverImageUrl,
    required this.barcode,
    required this.boxSet,
    required this.catalogNumber,
    required this.country,
    required this.coverImageUrl,
    required this.credits,
    required this.discTitles,
    required this.extras,
    required this.format,
    required this.genres,
    required this.isLive,
    required this.labels,
    required this.links,
    required this.matrixNumberSideA,
    required this.matrixNumberSideB,
    required this.originalReleaseDate,
    required this.packaging,
    required this.recordingDate,
    required this.releaseDate,
    required this.rpm,
    required this.sortTitle,
    required this.soundTypes,
    required this.sparsCode,
    required this.studio,
    required this.subtitle,
    required this.title,
    required this.tracks,
    required this.vinylColor,
    required this.vinylWeight,
  });

  final List<MusicAlbumArtistDto> artists;
  final String? backCoverImageUrl;
  final String? barcode;
  final String? boxSet;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrl;
  final List<MusicAlbumCreditDto> credits;
  final List<MusicAlbumDiscTitleDto> discTitles;
  final List<String> extras;
  final String? format;
  final List<String> genres;
  final bool? isLive;
  final List<MusicAlbumLabelDto> labels;
  final List<MusicAlbumLinkDto> links;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final PartialDate? originalReleaseDate;
  final String? packaging;
  final PartialDate? recordingDate;
  final PartialDate? releaseDate;
  final int? rpm;
  final String? sortTitle;
  final List<String> soundTypes;
  final String? sparsCode;
  final List<String> studio;
  final String? subtitle;
  final String title;
  final List<MusicAlbumTrackInputDto> tracks;
  final String? vinylColor;
  final double? vinylWeight;

  factory MusicAlbumWriteDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumWriteDto(
      artists: _musicObjects<MusicAlbumArtistDto>(
          json['artists'], MusicAlbumArtistDto.fromJson),
      backCoverImageUrl: (json['back_cover_image_url'] == null
          ? null
          : json['back_cover_image_url'] as String?),
      barcode: (json['barcode'] == null ? null : json['barcode'] as String?),
      boxSet: (json['box_set'] == null ? null : json['box_set'] as String?),
      catalogNumber: (json['catalog_number'] == null
          ? null
          : json['catalog_number'] as String?),
      country: (json['country'] == null ? null : json['country'] as String?),
      coverImageUrl: (json['cover_image_url'] == null
          ? null
          : json['cover_image_url'] as String?),
      credits: _musicObjects<MusicAlbumCreditDto>(
          json['credits'], MusicAlbumCreditDto.fromJson),
      discTitles: _musicObjects<MusicAlbumDiscTitleDto>(
          json['disc_titles'], MusicAlbumDiscTitleDto.fromJson),
      extras: (json['extras'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      format: (json['format'] == null ? null : json['format'] as String?),
      genres: (json['genres'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      isLive: (json['is_live'] == null ? null : json['is_live'] as bool?),
      labels: _musicObjects<MusicAlbumLabelDto>(
          json['labels'], MusicAlbumLabelDto.fromJson),
      links: _musicObjects<MusicAlbumLinkDto>(
          json['links'], MusicAlbumLinkDto.fromJson),
      matrixNumberSideA: (json['matrix_number_side_a'] == null
          ? null
          : json['matrix_number_side_a'] as String?),
      matrixNumberSideB: (json['matrix_number_side_b'] == null
          ? null
          : json['matrix_number_side_b'] as String?),
      originalReleaseDate: (json['original_release_date'] == null
          ? null
          : PartialDate.tryParse(json['original_release_date'])),
      packaging:
          (json['packaging'] == null ? null : json['packaging'] as String?),
      recordingDate: (json['recording_date'] == null
          ? null
          : PartialDate.tryParse(json['recording_date'])),
      releaseDate: (json['release_date'] == null
          ? null
          : PartialDate.tryParse(json['release_date'])),
      rpm: (json['rpm'] == null ? null : (json['rpm'] as num?)?.toInt()),
      sortTitle:
          (json['sort_title'] == null ? null : json['sort_title'] as String?),
      soundTypes: (json['sound_types'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      sparsCode:
          (json['spars_code'] == null ? null : json['spars_code'] as String?),
      studio: (json['studio'] as List? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      subtitle: (json['subtitle'] == null ? null : json['subtitle'] as String?),
      title: _musicString(json['title'], 'title'),
      tracks: _musicObjects<MusicAlbumTrackInputDto>(
          json['tracks'], MusicAlbumTrackInputDto.fromJson),
      vinylColor:
          (json['vinyl_color'] == null ? null : json['vinyl_color'] as String?),
      vinylWeight: (json['vinyl_weight'] == null
          ? null
          : (json['vinyl_weight'] as num?)?.toDouble()),
    );
  }
  Map<String, dynamic> toJson() => {
        'artists': artists.map((item) => item.toJson()).toList(),
        'back_cover_image_url':
            (backCoverImageUrl == null ? null : backCoverImageUrl),
        'barcode': (barcode == null ? null : barcode),
        'box_set': (boxSet == null ? null : boxSet),
        'catalog_number': (catalogNumber == null ? null : catalogNumber),
        'country': (country == null ? null : country),
        'cover_image_url': (coverImageUrl == null ? null : coverImageUrl),
        'credits': credits.map((item) => item.toJson()).toList(),
        'disc_titles': discTitles.map((item) => item.toJson()).toList(),
        'extras': extras,
        'format': (format == null ? null : format),
        'genres': genres,
        'is_live': (isLive == null ? null : isLive),
        'labels': labels.map((item) => item.toJson()).toList(),
        'links': links.map((item) => item.toJson()).toList(),
        'matrix_number_side_a':
            (matrixNumberSideA == null ? null : matrixNumberSideA),
        'matrix_number_side_b':
            (matrixNumberSideB == null ? null : matrixNumberSideB),
        'original_release_date': (originalReleaseDate == null
            ? null
            : originalReleaseDate?.toJson()),
        'packaging': (packaging == null ? null : packaging),
        'recording_date':
            (recordingDate == null ? null : recordingDate?.toJson()),
        'release_date': (releaseDate == null ? null : releaseDate?.toJson()),
        'rpm': (rpm == null ? null : rpm),
        'sort_title': (sortTitle == null ? null : sortTitle),
        'sound_types': soundTypes,
        'spars_code': (sparsCode == null ? null : sparsCode),
        'studio': studio,
        'subtitle': (subtitle == null ? null : subtitle),
        'title': title,
        'tracks': tracks.map((item) => item.toJson()).toList(),
        'vinyl_color': (vinylColor == null ? null : vinylColor),
        'vinyl_weight': (vinylWeight == null ? null : vinylWeight),
      };
}
