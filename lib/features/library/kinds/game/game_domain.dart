import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

final class GameRelease {
  const GameRelease({
    required this.id,
    required this.title,
    this.platform,
    this.releaseDate,
    this.regionCode,
    this.format,
    this.publisher,
    this.catalogNumber,
    this.releaseStatus,
    this.language,
    this.barcode,
    this.coverImageUrl,
    this.isPrimary = false,
  });

  final String id;
  final String title;
  final String? platform;
  final DateTime? releaseDate;
  final String? regionCode;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? language;
  final String? barcode;
  final String? coverImageUrl;
  final bool isPrimary;

  factory GameRelease.fromDto(GameReleaseDto dto) {
    return GameRelease(
      id: dto.id,
      title: dto.title,
      platform: dto.platform,
      releaseDate: dto.releaseDate,
      regionCode: dto.regionCode,
      format: dto.format,
      publisher: dto.publisher,
      catalogNumber: dto.catalogNumber,
      releaseStatus: dto.releaseStatus,
      language: dto.language,
      barcode: dto.barcode,
      coverImageUrl: dto.coverImageUrl,
      isPrimary: _boolOrFalse(dto.raw['is_primary']),
    );
  }
}

final class GameWork {
  const GameWork({
    required this.id,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.searchAliases = const <String>[],
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.coverDate,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.crossover,
    this.platforms = const <String>[],
    this.identifiers = const <String>[],
    this.companyRoles = const <String>[],
    this.ageRatings = const <String>[],
    this.releases = const <GameRelease>[],
    this.trailerUrls = const <TrailerLink>[],
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters = const <String>[],
    this.storyArcs = const <String>[],
    this.genres = const <String>[],
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.physicalFormatLabel,
  });

  final String id;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String> searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? coverDate;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> companyRoles;
  final List<String> ageRatings;
  final List<GameRelease> releases;
  final List<TrailerLink> trailerUrls;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final String? physicalFormatLabel;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayReleaseLabel =>
      variant ?? (releases.isNotEmpty ? releases.first.title : null);

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayReleaseLabel == null;

  factory GameWork.fromDto(GameWorkDto dto) {
    final releases = [
      for (final release in dto.releases) ..._gameReleasesFromDtoValue(release),
    ];
    return GameWork(
      id: dto.id,
      title: dto.title,
      displayTitle: _stringOrNull(dto.raw['display_title']),
      localizedTitle: _stringOrNull(dto.raw['localized_title']),
      originalTitle: _stringOrNull(dto.raw['original_title']),
      searchAliases: List<String>.unmodifiable(dto.searchAliases),
      itemNumber: _stringOrNull(dto.raw['item_number']),
      synopsis: dto.description,
      coverImageUrl: _stringOrNull(dto.raw['cover_image_url']),
      thumbnailImageUrl: _stringOrNull(dto.raw['thumbnail_image_url']) ??
          _stringOrNull(dto.raw['cover_image_url']),
      publisher: dto.publisher,
      coverDate: _dateOrNull(dto.raw['cover_date']),
      releaseDate: dto.releaseDate,
      releaseYear: _intOrNull(dto.raw['release_year']),
      barcode: _stringOrNull(dto.raw['barcode']),
      variant: _stringOrNull(dto.raw['variant']),
      crossover: _stringOrNull(dto.raw['crossover']),
      platforms: List<String>.unmodifiable(dto.platforms),
      identifiers: List<String>.unmodifiable(dto.identifiers),
      companyRoles: List<String>.unmodifiable(dto.companyRoles),
      ageRatings: List<String>.unmodifiable(dto.ageRatings),
      releases: releases,
      trailerUrls: const <TrailerLink>[],
      plotSummary: _stringOrNull(dto.raw['plot_summary']),
      plotDescription: _stringOrNull(dto.raw['plot_description']),
      creators: _mapListOrNull(dto.raw['creators']),
      characters: _stringListOrNull(dto.raw['characters']),
      storyArcs: _stringListOrNull(dto.raw['story_arcs']),
      genres: List<String>.unmodifiable(dto.genres),
      country: _stringOrNull(dto.raw['country']),
      language: _stringOrNull(dto.raw['language']),
      ageRating: _stringOrNull(dto.raw['age_rating']),
      audienceRating: _stringOrNull(dto.raw['audience_rating']),
      physicalFormatLabel: _stringOrNull(dto.raw['physical_format_label']),
    );
  }

  factory GameWork.fromCatalogItem(CatalogItem item) {
    return GameWork(
      id: item.id,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases:
          List<String>.unmodifiable(item.searchAliases ?? const <String>[]),
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      publisher: item.publisher,
      coverDate: item.coverDate,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      crossover: item.crossover,
      platforms:
          List<String>.unmodifiable(item.game?.platforms ?? const <String>[]),
      identifiers: const <String>[],
      companyRoles: const <String>[],
      ageRatings: item.ageRating == null
          ? const <String>[]
          : List<String>.unmodifiable([item.ageRating!]),
      releases: [
        for (var index = 0; index < item.editions.length; index++)
          _releaseFromCatalogEdition(item.editions[index],
              isPrimary: index == 0),
      ],
      trailerUrls: List<TrailerLink>.unmodifiable(item.trailerUrls),
      plotSummary: item.plotSummary,
      plotDescription: item.plotDescription,
      creators: item.creators == null
          ? null
          : List<Map<String, dynamic>>.unmodifiable(
              item.creators!
                  .map((value) => Map<String, dynamic>.unmodifiable(value)),
            ),
      characters:
          List<String>.unmodifiable(item.characters ?? const <String>[]),
      storyArcs: List<String>.unmodifiable(item.storyArcs ?? const <String>[]),
      genres: List<String>.unmodifiable(item.genres ?? const <String>[]),
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
      physicalFormatLabel: item.physicalFormatLabel,
    );
  }
}

GameRelease _releaseFromCatalogEdition(
  CatalogEdition edition, {
  bool isPrimary = false,
}) {
  return GameRelease(
    id: edition.id,
    title: edition.title,
    platform: edition.physicalFormatLabel ?? edition.physicalFormat,
    releaseDate: edition.releaseDate,
    format: edition.format ?? edition.physicalFormatLabel,
    publisher: edition.publisher,
    catalogNumber: edition.upc,
    releaseStatus: null,
    language: edition.language,
    barcode: edition.upc,
    coverImageUrl: edition.variants.isNotEmpty
        ? edition.variants.first.coverImageUrl
        : null,
    isPrimary: isPrimary,
  );
}

List<GameRelease> _gameReleasesFromDtoValue(Object? value) {
  if (value is GameReleaseDto) {
    return [GameRelease.fromDto(value)];
  }
  if (value is Map<String, dynamic>) {
    return [GameRelease.fromDto(GameReleaseDto.fromJson(value))];
  }
  return const <GameRelease>[];
}

String? _stringOrNull(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

bool _boolOrFalse(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

int? _intOrNull(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(dynamic value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<String> _stringListOrNull(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }
  final result = <String>[];
  for (final entry in value) {
    final text = _stringOrNull(entry);
    if (text != null) {
      result.add(text);
    }
  }
  return List<String>.unmodifiable(result);
}

List<Map<String, dynamic>>? _mapListOrNull(dynamic value) {
  if (value is! List) {
    return null;
  }
  final result = <Map<String, dynamic>>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      result.add(Map<String, dynamic>.unmodifiable(entry));
    }
  }
  return result.isEmpty
      ? null
      : List<Map<String, dynamic>>.unmodifiable(result);
}
