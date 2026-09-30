import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// One concrete Movie edition returned by Core.
///
/// Disc and media rows remain contained children. This projection deliberately
/// has no Work or Release collection because the Core item already represents
/// the collectible edition.
final class MovieCatalogItem {
  const MovieCatalogItem({
    required this.id,
    required this.title,
    this.sortTitle,
    this.originalTitle,
    this.synopsis,
    this.releaseDate,
    this.publisher,
    this.distributor,
    this.barcode,
    this.catalogNumber,
    this.physicalFormat,
    this.country,
    this.language,
    this.runtimeMinutes,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.ageRating,
    this.audienceRating,
    this.seriesTitle,
    this.itemNumber,
    this.variant,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.genres = const [],
    this.creators = const [],
    this.contributors = const [],
    this.externalLinks = const [],
    this.trailerUrls = const [],
    this.media = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? sortTitle;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? publisher;
  final String? distributor;
  final String? barcode;
  final String? catalogNumber;
  final String? physicalFormat;
  final String? country;
  final String? language;
  final int? runtimeMinutes;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? ageRating;
  final String? audienceRating;
  final String? seriesTitle;
  final String? itemNumber;
  final String? variant;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String> genres;
  final List<Map<String, dynamic>> creators;
  final List<Map<String, dynamic>> contributors;
  final List<Map<String, dynamic>> externalLinks;
  final List<Map<String, dynamic>> trailerUrls;
  final List<MovieCatalogItemMedia> media;
  final Map<String, dynamic> rawPayload;

  String? get director => _contributorWithRole('director');
  String? get writer => _contributorWithRole('writer');
  String? get producer => _contributorWithRole('producer');

  factory MovieCatalogItem.fromDto(CatalogItemDto dto) =>
      MovieCatalogMapper.mapDtoToMovie(dto);

  String? _contributorWithRole(String role) {
    for (final entry in [...contributors, ...creators]) {
      if ((entry['role'] ?? entry['type'])?.toString().toLowerCase() != role) {
        continue;
      }
      final name = entry['name'] ?? entry['display_name'] ?? entry['person'];
      if (name is String && name.trim().isNotEmpty) return name.trim();
    }
    return null;
  }
}

/// A disc or other medium contained by one Movie Catalog Item.
final class MovieCatalogItemMedia {
  const MovieCatalogItemMedia({
    required this.id,
    required this.mediaNumber,
    this.title,
    this.formatLabel,
    this.numDiscs,
    this.nrLayers,
    this.aspectRatio,
    this.screenRatio,
    this.color,
    this.audioTracks,
    this.subtitles,
    this.layers,
  });

  final String id;
  final int mediaNumber;
  final String? title;
  final String? formatLabel;
  final int? numDiscs;
  final int? nrLayers;
  final String? aspectRatio;
  final String? screenRatio;
  final String? color;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;

  factory MovieCatalogItemMedia.fromJson(Map<String, dynamic> json) =>
      MovieCatalogItemMedia(
        id: _text(json['id']) ?? '',
        mediaNumber: _integer(json['media_number']) ?? 1,
        title: _text(json['title']),
        formatLabel: _text(json['media_type'] ?? json['format_label']),
        numDiscs: _integer(json['num_discs']),
        nrLayers: _integer(json['nr_layers']),
        aspectRatio: _text(json['aspect_ratio']),
        screenRatio: _text(json['screen_ratio']),
        color: _text(json['color']),
        audioTracks: _text(json['audio_tracks']),
        subtitles: _text(json['subtitles']),
        layers: _text(json['layers']),
      );
}

final class MovieCatalogMapper {
  const MovieCatalogMapper._();

  static MovieCatalogItem mapDtoToMovie(CatalogItemDto dto) {
    final payload = dto.payload;
    return MovieCatalogItem(
      id: dto.id,
      title: dto.title,
      sortTitle: dto.sortKey,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      publisher: _text(payload['publisher'] ?? payload['studio']),
      distributor: _text(payload['distributor']),
      barcode: dto.barcode,
      catalogNumber: _text(payload['catalog_number']),
      physicalFormat: dto.physicalFormat,
      country: _text(payload['country'] ?? payload['region']),
      language: _text(payload['language'] ?? payload['original_language']),
      runtimeMinutes: _integer(payload['runtime_minutes']),
      screenRatio: _text(payload['screen_ratio']),
      audioTracks: _text(payload['audio_tracks']),
      subtitles: _text(payload['subtitles']),
      layers: _text(payload['layers']),
      ageRating: _text(payload['age_rating']),
      audienceRating: _text(payload['audience_rating']),
      seriesTitle: _text(payload['series_title']),
      itemNumber: dto.itemNumber,
      variant: dto.variant,
      coverImageUrl: dto.coverImageUrl,
      thumbnailImageUrl: dto.thumbnailImageUrl,
      genres: _strings(payload['genres']),
      creators: _maps(payload['creators']),
      contributors: _maps(payload['contributors'] ?? payload['contributions']),
      externalLinks: _maps(payload['external_links']),
      trailerUrls: [for (final trailer in dto.trailerUrls) trailer.toJson()],
      media: [
        for (final entry in _maps(payload['media'] ?? payload['discs']))
          MovieCatalogItemMedia.fromJson(entry),
      ],
      rawPayload: Map.unmodifiable(payload),
    );
  }

  static MovieCatalogItem mapMetadataItemToMovie(CatalogItemDto item) =>
      mapDtoToMovie(item);
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _integer(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> _strings(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is String) entry
      ]
    : const [];

List<Map<String, dynamic>> _maps(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const [];
