import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';

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
    );
  }
}

final class GameWork {
  const GameWork({
    required this.id,
    required this.title,
    this.platforms = const <String>[],
    this.identifiers = const <String>[],
    this.companyRoles = const <String>[],
    this.ageRatings = const <String>[],
    this.releases = const <GameRelease>[],
  });

  final String id;
  final String title;
  final List<String> platforms;
  final List<String> identifiers;
  final List<String> companyRoles;
  final List<String> ageRatings;
  final List<GameRelease> releases;

  factory GameWork.fromDto(GameWorkDto dto) {
    return GameWork(
      id: dto.id,
      title: dto.title,
      platforms: List<String>.unmodifiable(dto.platforms),
      identifiers: List<String>.unmodifiable(dto.identifiers),
      companyRoles: List<String>.unmodifiable(dto.companyRoles),
      ageRatings: List<String>.unmodifiable(dto.ageRatings),
    );
  }
}
