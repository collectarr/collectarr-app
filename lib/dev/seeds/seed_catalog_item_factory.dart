import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds a catalog item for the development database seed.
///
/// This deliberately lives with the seed data instead of importing the test
/// factory from production code. The factory keeps the seed declarations
/// readable while still creating the same typed catalog boundary used by the
/// application.
CatalogItemDto seedCatalogItem({
  String id = 'seed-item-1',
  CatalogMediaKind kind = CatalogMediaKind.comic,
  String title = 'Seed Item',
  String? displayTitle,
  String? localizedTitle,
  String? originalTitle,
  String? titleExtension,
  List<String>? searchAliases,
  String? synopsis,
  String? coverImageUrl,
  String? thumbnailImageUrl,
  String? coverImageData,
  String? publisher,
  String? barcode,
  String? variant,
  String? country,
  String? language,
  String? ageRating,
  String? itemNumber,
  String? editionTitle,
  String? physicalFormat,
  String? physicalFormatLabel,
  String? sortKey,
  int? releaseYear,
  DateTime? releaseDate,
  List<String>? genres,
  List<String>? platforms,
  List<String>? rawPlatforms,
  List<String>? characters,
  List<String>? storyArcs,
  List<Map<String, dynamic>>? creators,
  List<CatalogEditionDto>? editions,
  List<TrailerLinkDto>? trailerUrls,
  CatalogSeriesDetailsDto? series,
  Object? video,
  Object? music,
  Object? game,
  CatalogPublishingDetailsDto? publishing,
  Map<String, dynamic>? payload,
}) {
  final resolvedCoverImageUrl = coverImageUrl ??
      (kind == CatalogMediaKind.music
          ? 'https://images.example.invalid/collectarr/$id.jpg'
          : null);
  final resolvedBarcode =
      barcode ?? (kind == CatalogMediaKind.music ? '9900000000000' : null);
  final resolvedPublisher =
      publisher ?? (kind == CatalogMediaKind.comic ? 'IDW' : null);
  final resolvedCreators = creators ??
      (kind == CatalogMediaKind.book
          ? const [
              {'name': 'J.R.R. Tolkien', 'role': 'Author'}
            ]
          : null);
  final resolvedPublishing = publishing ??
      (kind == CatalogMediaKind.comic
          ? const CatalogPublishingDetailsDto(
              imprint: 'IDW', subtitle: 'Director Cut')
          : null);
  final mergedPayload = <String, dynamic>{
    if (itemNumber != null) 'item_number': itemNumber,
    if (editionTitle != null) 'edition_title': editionTitle,
    if (physicalFormat != null) 'physical_format': physicalFormat,
    if (physicalFormatLabel != null)
      'physical_format_label': physicalFormatLabel,
    if (resolvedPublisher != null) 'publisher': resolvedPublisher,
    if (resolvedBarcode != null) 'barcode': resolvedBarcode,
    if (variant != null) 'variant': variant,
    if (country != null) 'country': country,
    if (language != null) 'language': language,
    if (ageRating != null) 'age_rating': ageRating,
    if (genres != null) 'genres': genres,
    if (platforms != null || rawPlatforms != null)
      'platforms': platforms ?? rawPlatforms,
    if (rawPlatforms != null) 'raw_platforms': rawPlatforms,
    if (characters != null) 'characters': characters,
    if (storyArcs != null) 'story_arcs': storyArcs,
    if (resolvedCreators != null) 'creators': resolvedCreators,
    if (series != null) 'series': series.toJson(),
    if (video != null) 'video': _encodeSeedDetails(video),
    if (music != null) 'music': _encodeSeedDetails(music),
    if (game != null) 'game': _encodeSeedDetails(game),
    if (resolvedPublishing != null) 'publishing': resolvedPublishing.toJson(),
    if (payload != null) ...payload,
  };
  final common = CatalogCommonDto(
    title: title,
    displayTitle: displayTitle,
    localizedTitle: localizedTitle,
    originalTitle: originalTitle,
    titleExtension: titleExtension,
    searchAliases: searchAliases,
    synopsis: synopsis,
    coverImageUrl: resolvedCoverImageUrl,
    thumbnailImageUrl: thumbnailImageUrl ?? resolvedCoverImageUrl,
    coverImageData: coverImageData,
    sortKey: sortKey,
    releaseDate: releaseDate,
    releaseYear: releaseYear,
    editions: editions ?? const [],
    trailerUrls: trailerUrls ?? const [],
  );
  return CatalogItemDto.raw(
    id: id,
    mediaKind: kind,
    common: common,
    payload: mergedPayload,
  );
}

Object _encodeSeedDetails(Object value) {
  return switch (value) {
    VideoCatalogDetailsDto details => details.toJson(),
    MusicCatalogDetailsDto details => details.toJson(),
    GameCatalogDetailsDto details => details.toJson(),
    Map<Object?, Object?> value => Map<String, dynamic>.from(value),
    _ => throw ArgumentError.value(
        value,
        'value',
        'Seed catalog details must be a typed catalog DTO or JSON object',
      ),
  };
}
