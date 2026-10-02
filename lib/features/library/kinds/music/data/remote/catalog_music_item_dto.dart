import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// Transport model for Core's flattened Music Catalog Item API.
///
/// One DTO represents one concrete album edition. Discs and tracks are
/// contained catalog data, not Work or Release records.
final class CatalogMusicItemDto implements JsonEncodable {
  CatalogMusicItemDto({
    required this.id,
    required this.title,
    this.sortTitle,
    this.subtitle,
    this.artist,
    this.artistCredits = const [],
    this.originalReleaseDate,
    this.originalReleaseDateParts,
    this.recordingDate,
    this.recordingDateParts,
    this.releaseDate,
    this.releaseDateParts,
    this.label,
    this.format,
    this.barcode,
    this.catalogNumber,
    this.genres = const [],
    this.packaging,
    List<String> studios = const [],
    this.country,
    this.isLive,
    this.soundTypes = const [],
    this.vinylColor,
    this.vinylWeight,
    this.rpm,
    this.extra,
    this.spars,
    this.boxSet,
    this.composers = const [],
    this.conductors = const [],
    this.choruses = const [],
    this.compositions = const [],
    this.orchestras = const [],
    this.songwriters = const [],
    this.producers = const [],
    this.engineers = const [],
    this.musicians = const [],
    this.externalLinks = const [],
    this.coverImageUrl,
    this.backCoverImageUrl,
    this.thumbnailImageUrl,
    this.revision = 1,
    this.discs = const [],
  }) : studios = List<String>.unmodifiable(studios);

  factory CatalogMusicItemDto.fromJson(Map<String, dynamic> json) {
    final catalogJson = Map<String, dynamic>.from(json);
    const allowedKeys = {
      'id',
      'kind',
      'title',
      'sort_title',
      'subtitle',
      'artist',
      'artist_credits',
      'original_release_date',
      'original_release_date_parts',
      'recording_date',
      'recording_date_parts',
      'release_date',
      'release_date_parts',
      'label',
      'format',
      'barcode',
      'catalog_number',
      'genres',
      'packaging',
      'studios',
      'country',
      'is_live',
      'sound_types',
      'vinyl_color',
      'vinyl_weight',
      'rpm',
      'extra',
      'spars',
      'box_set',
      'composers',
      'conductors',
      'choruses',
      'compositions',
      'orchestras',
      'songwriters',
      'producers',
      'engineers',
      'musicians',
      'external_links',
      'cover_image_url',
      'back_cover_image_url',
      'thumbnail_image_url',
      'revision',
      'discs',
    };
    for (final key in catalogJson.keys) {
      if (!allowedKeys.contains(key)) {
        throw FormatException('Unrecognized Music Catalog Item field "$key".');
      }
    }

    final id = _string(catalogJson['id']);
    final title = _string(catalogJson['title']);
    final kind = _string(catalogJson['kind']);
    if (kind != null && kind != CatalogMediaKind.music.apiValue) {
      throw FormatException('Expected a Music Catalog Item, received $kind.');
    }
    if (id == null || title == null) {
      throw const FormatException(
        'Music Catalog Item response requires id and title.',
      );
    }
    return CatalogMusicItemDto(
      id: id,
      title: title,
      sortTitle: _string(catalogJson['sort_title']),
      subtitle: _string(catalogJson['subtitle']),
      artist: _string(catalogJson['artist']),
      artistCredits: _objectList(catalogJson['artist_credits']),
      originalReleaseDate: _string(catalogJson['original_release_date']),
      originalReleaseDateParts: catalogJson['original_release_date_parts'],
      recordingDate: _string(catalogJson['recording_date']),
      recordingDateParts: catalogJson['recording_date_parts'],
      releaseDate: _string(catalogJson['release_date']),
      releaseDateParts: catalogJson['release_date_parts'],
      label: _string(catalogJson['label']),
      format: _string(catalogJson['format']),
      barcode: _string(catalogJson['barcode']),
      catalogNumber: _string(catalogJson['catalog_number']),
      genres: _stringList(catalogJson['genres']),
      packaging: _string(catalogJson['packaging']),
      studios: _stringList(catalogJson['studios']),
      country: _string(catalogJson['country']),
      isLive: catalogJson['is_live'] as bool?,
      soundTypes: _stringList(catalogJson['sound_types']),
      vinylColor: _string(catalogJson['vinyl_color']),
      vinylWeight: _string(catalogJson['vinyl_weight']),
      rpm: _integer(catalogJson['rpm']),
      extra: _string(catalogJson['extra']),
      spars: _string(catalogJson['spars']),
      boxSet: _string(catalogJson['box_set']),
      composers: _objectList(catalogJson['composers']),
      conductors: _objectList(catalogJson['conductors']),
      choruses: _stringList(catalogJson['choruses']),
      compositions: _stringList(catalogJson['compositions']),
      orchestras: _stringList(catalogJson['orchestras']),
      songwriters: _objectList(catalogJson['songwriters']),
      producers: _objectList(catalogJson['producers']),
      engineers: _objectList(catalogJson['engineers']),
      musicians: _objectList(catalogJson['musicians']),
      externalLinks: _objectList(catalogJson['external_links']),
      coverImageUrl: _string(catalogJson['cover_image_url']),
      backCoverImageUrl: _string(catalogJson['back_cover_image_url']),
      thumbnailImageUrl: _string(catalogJson['thumbnail_image_url']),
      revision: _integer(catalogJson['revision']) ?? 1,
      discs: [
        for (final disc in _objectList(catalogJson['discs']))
          CatalogMusicDiscDto.fromJson(disc),
      ],
    );
  }

  factory CatalogMusicItemDto.fromCatalogSearchPayload(
    Map<String, dynamic> payload,
  ) {
    return CatalogMusicItemDto.fromJson(payload);
  }

  final String id;

  CatalogItemRef get ref => CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: id,
      );

  final String title;
  final String? sortTitle;
  final String? subtitle;
  final String? artist;
  final List<Map<String, Object?>> artistCredits;
  final String? originalReleaseDate;
  final Object? originalReleaseDateParts;
  final String? recordingDate;
  final Object? recordingDateParts;
  final String? releaseDate;
  final Object? releaseDateParts;
  final String? label;
  final String? format;
  final String? barcode;
  final String? catalogNumber;
  final List<String> genres;
  final String? packaging;
  final List<String> studios;
  final String? country;
  final bool? isLive;
  final List<String> soundTypes;
  final String? vinylColor;
  final String? vinylWeight;
  final int? rpm;
  final String? extra;
  final String? spars;
  final String? boxSet;
  final List<Map<String, Object?>> composers;
  final List<Map<String, Object?>> conductors;
  final List<String> choruses;
  final List<String> compositions;
  final List<String> orchestras;
  final List<Map<String, Object?>> songwriters;
  final List<Map<String, Object?>> producers;
  final List<Map<String, Object?>> engineers;
  final List<Map<String, Object?>> musicians;
  final List<Map<String, Object?>> externalLinks;
  final String? coverImageUrl;
  final String? backCoverImageUrl;
  final String? thumbnailImageUrl;
  final int revision;
  final List<CatalogMusicDiscDto> discs;

  /// Returns canonical v1 fields suitable for a user Catalog Item proposal.
  /// Server identity and revision are intentionally excluded.
  Map<String, Object?> toProposalData() => {
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        if (originalReleaseDateParts != null || originalReleaseDate != null)
          'original_release_date':
              originalReleaseDateParts ?? originalReleaseDate,
        if (recordingDateParts != null || recordingDate != null)
          'recording_date': recordingDateParts ?? recordingDate,
        if (releaseDateParts != null || releaseDate != null)
          'release_date': releaseDateParts ?? releaseDate,
        if (artistCredits.isNotEmpty)
          'artist_credits': artistCredits
        else if (artist != null && artist!.trim().isNotEmpty)
          'artist_credits': [
            <String, Object?>{'name': artist}
          ],
        if (label != null) 'label': label,
        if (format != null) 'format': format,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (genres.isNotEmpty) 'genres': genres,
        if (packaging != null) 'packaging': packaging,
        if (studios.isNotEmpty) 'studios': studios,
        if (country != null) 'country': country,
        if (isLive != null) 'is_live': isLive,
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (rpm != null) 'rpm': rpm,
        if (extra != null) 'extra': extra,
        if (spars != null) 'spars': spars,
        if (boxSet != null) 'box_set': boxSet,
        if (composers.isNotEmpty) 'composers': composers,
        if (conductors.isNotEmpty) 'conductors': conductors,
        if (choruses.isNotEmpty) 'choruses': choruses,
        if (compositions.isNotEmpty) 'compositions': compositions,
        if (orchestras.isNotEmpty) 'orchestras': orchestras,
        if (songwriters.isNotEmpty) 'songwriters': songwriters,
        if (producers.isNotEmpty) 'producers': producers,
        if (engineers.isNotEmpty) 'engineers': engineers,
        if (musicians.isNotEmpty) 'musicians': musicians,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (backCoverImageUrl != null)
          'back_cover_image_url': backCoverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (externalLinks.isNotEmpty) 'external_links': externalLinks,
        if (discs.isNotEmpty)
          'discs': discs.map((disc) => disc.toJson()).toList(),
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'music',
        ...toProposalData(),
      };

  /// Projects one Music item into the shared catalog search envelope.
  ///
  /// Only routing identity sits outside `kind_data`. Title, cover, dates, and
  /// every other catalog value remain owned by the Music kind.
  Map<String, dynamic> toSearchJson() => {
        'id': id,
        'kind': 'music',
        'kind_data': toProposalData(),
      };
}

final class CatalogMusicDiscDto {
  const CatalogMusicDiscDto({
    required this.id,
    required this.discNumber,
    this.title,
    this.matrixNumberSideA,
    this.matrixNumberSideB,
    this.tracks = const [],
  });

  factory CatalogMusicDiscDto.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id']);
    final discNumber = _integer(json['disc_number']);
    if (id == null || discNumber == null) {
      throw const FormatException(
        'Music disc response requires id and disc_number.',
      );
    }
    return CatalogMusicDiscDto(
      id: id,
      discNumber: discNumber,
      title: _string(json['title']),
      matrixNumberSideA: _string(json['matrix_number_side_a']),
      matrixNumberSideB: _string(json['matrix_number_side_b']),
      tracks: [
        for (final track in _objectList(json['tracks']))
          CatalogMusicTrackDto.fromJson(track),
      ],
    );
  }

  final String id;
  final int discNumber;
  final String? title;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final List<CatalogMusicTrackDto> tracks;

  Map<String, Object?> toJson() => {
        'disc_number': discNumber,
        if (title != null) 'title': title,
        if (matrixNumberSideA != null)
          'matrix_number_side_a': matrixNumberSideA,
        if (matrixNumberSideB != null)
          'matrix_number_side_b': matrixNumberSideB,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

final class CatalogMusicTrackDto {
  const CatalogMusicTrackDto({
    required this.id,
    required this.position,
    required this.title,
    this.positionOrder = 0,
    this.artist,
    this.durationMs,
  });

  factory CatalogMusicTrackDto.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id']);
    final position = _string(json['position']);
    final title = _string(json['title']);
    if (id == null || position == null || title == null) {
      throw const FormatException(
        'Music track response requires id, position, and title.',
      );
    }
    return CatalogMusicTrackDto(
      id: id,
      position: position,
      positionOrder: _integer(json['position_order']) ?? 0,
      title: title,
      artist: _string(json['artist']),
      durationMs: _integer(json['duration_ms']),
    );
  }

  final String id;
  final String position;
  final int positionOrder;
  final String title;
  final String? artist;
  final int? durationMs;

  Map<String, Object?> toJson() => {
        'position': position,
        'title': title,
        if (artist != null) 'artist': artist,
        if (durationMs != null) 'duration_ms': durationMs,
      };
}

String? _string(Object? value) => value is String ? value : null;

int? _integer(Object? value) => value is int && value is! bool ? value : null;

List<String> _stringList(Object? value) => [
      if (value is Iterable)
        for (final item in value)
          if (item is String) item,
    ];

List<Map<String, Object?>> _objectList(Object? value) => [
      if (value is Iterable)
        for (final item in value)
          if (item is Map) Map<String, Object?>.from(item),
    ];
