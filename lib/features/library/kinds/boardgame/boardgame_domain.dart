import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';

final class BoardGameEdition {
  const BoardGameEdition({
    required this.id,
    required this.title,
    this.editionTitle,
    this.format,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.releaseStatus,
    this.releaseDate,
    this.language,
    this.country,
    this.ageRating,
    this.audienceRating,
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.minAge,
  });

  final String id;
  final String title;
  final String? editionTitle;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final String? releaseStatus;
  final DateTime? releaseDate;
  final String? language;
  final String? country;
  final String? ageRating;
  final String? audienceRating;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final int? minAge;

  factory BoardGameEdition.fromDto(BoardGameEditionDto dto) {
    return BoardGameEdition(
      id: dto.id,
      title: dto.title,
      editionTitle: dto.editionTitle,
      format: dto.format,
      publisher: dto.publisher,
      catalogNumber: dto.catalogNumber,
      barcode: dto.barcode,
      releaseStatus: dto.releaseStatus,
      releaseDate: dto.releaseDate,
      language: dto.language,
      country: dto.country,
      ageRating: dto.ageRating,
      audienceRating: dto.audienceRating,
      minPlayers: dto.minPlayers,
      maxPlayers: dto.maxPlayers,
      playingTimeMinutes: dto.playingTimeMinutes,
      minAge: dto.minAge,
    );
  }
}

final class BoardGameWork {
  const BoardGameWork({
    required this.id,
    required this.title,
    this.platforms = const <String>[],
    this.identifiers = const <String>[],
    this.contributors = const <String>[],
    this.mechanics = const <String>[],
    this.categories = const <String>[],
    this.families = const <String>[],
    this.expansions = const <String>[],
    this.rankings = const <String>[],
    this.editions = const <BoardGameEdition>[],
  });

  final String id;
  final String title;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> expansions;
  final List<String> rankings;
  final List<BoardGameEdition> editions;

  factory BoardGameWork.fromDto(BoardGameWorkDto dto) {
    return BoardGameWork(
      id: dto.id,
      title: dto.title,
      platforms: List<String>.unmodifiable(dto.platforms),
      identifiers: List<String>.unmodifiable(dto.identifiers),
      contributors: List<String>.unmodifiable(dto.contributors),
      mechanics: List<String>.unmodifiable(dto.mechanics),
      categories: List<String>.unmodifiable(dto.categories),
      families: List<String>.unmodifiable(dto.families),
      expansions: List<String>.unmodifiable(dto.expansions),
      rankings: List<String>.unmodifiable(dto.rankings),
    );
  }
}
