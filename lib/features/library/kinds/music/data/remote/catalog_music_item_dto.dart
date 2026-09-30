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
    const hierarchicalMusicKeys = {
      'release_group',
      'release_group_id',
      'release_id',
      'releases',
      'mediums',
    };
    for (final key in hierarchicalMusicKeys) {
      if (json.containsKey(key)) {
        throw FormatException(
          'Music Catalog Item payload is flat; "$key" is not supported.',
        );
      }
    }

    final id = _string(json['id']);
    final title = _string(json['title']);
    final kind = _string(json['kind']);
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
      sortTitle: _string(json['sort_title']),
      subtitle: _string(json['subtitle']),
      artist: _string(json['artist']),
      artistCredits: _objectList(json['artist_credits']),
      originalReleaseDate: _string(json['original_release_date']),
      originalReleaseDateParts: json['original_release_date_parts'],
      recordingDate: _string(json['recording_date']),
      recordingDateParts: json['recording_date_parts'],
      releaseDate: _string(json['release_date']),
      releaseDateParts: json['release_date_parts'],
      label: _string(json['label']),
      format: _string(json['format']),
      barcode: _string(json['barcode']),
      catalogNumber: _string(json['catalog_number']),
      genres: _stringList(json['genres']),
      packaging: _string(json['packaging']),
      studios: _stringList(json['studios']),
      country: _string(json['country']),
      isLive: json['is_live'] as bool?,
      soundTypes: _stringList(json['sound_types']),
      vinylColor: _string(json['vinyl_color']),
      vinylWeight: _string(json['vinyl_weight']),
      rpm: _integer(json['rpm']),
      extra: _string(json['extra']),
      spars: _string(json['spars']),
      boxSet: _string(json['box_set']),
      composers: _objectList(json['composers']),
      conductors: _objectList(json['conductors']),
      choruses: _stringList(json['choruses']),
      compositions: _stringList(json['compositions']),
      orchestras: _stringList(json['orchestras']),
      songwriters: _objectList(json['songwriters']),
      producers: _objectList(json['producers']),
      engineers: _objectList(json['engineers']),
      musicians: _objectList(json['musicians']),
      externalLinks: _objectList(json['external_links']),
      coverImageUrl: _string(json['cover_image_url']),
      backCoverImageUrl: _string(json['back_cover_image_url']),
      thumbnailImageUrl: _string(json['thumbnail_image_url']),
      revision: _integer(json['revision']) ?? 1,
      discs: [
        for (final disc in _objectList(json['discs']))
          CatalogMusicDiscDto.fromJson(disc),
      ],
    );
  }

  factory CatalogMusicItemDto.fromCatalogSearchPayload(
    Map<String, dynamic> payload,
  ) {
    final nestedMusic = payload['music'];
    if (nestedMusic is! Map) {
      throw const FormatException(
        'Music catalog search result requires a music payload.',
      );
    }
    final json = Map<String, dynamic>.from(nestedMusic);
    json['id'] = payload['id'];
    json['kind'] = payload['kind'];
    return CatalogMusicItemDto.fromJson(json);
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

  /// Projects one flat Music item into the shared catalog search envelope.
  ///
  /// Music-specific fields stay owned by this DTO; the shared candidate only
  /// receives the generic envelope plus the untouched Music payload.
  Map<String, dynamic> toSearchJson() => {
        'id': id,
        'kind': 'music',
        'title': title,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (releaseDate != null) 'release_date': releaseDate,
        if (releaseDateParts != null) 'release_date_parts': releaseDateParts,
        if (revision > 0) 'revision': revision,
        'music': toProposalData(),
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
