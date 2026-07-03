import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

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
      releases: [
        for (final release in dto.releases)
          ..._gameReleasesFromDtoValue(release),
      ],
    );
  }

  factory GameWork.fromMetadataItem(LibraryMetadataItem item) {
    final releases = [
      for (final edition in item.editions)
        GameRelease(
          id: edition.id,
          title: edition.title,
          platform: item.game?.platforms.isNotEmpty == true
              ? item.game!.platforms.first
              : null,
          releaseDate: edition.releaseDate,
          format: edition.format,
          publisher: edition.publisher,
          catalogNumber: edition.upc,
          releaseStatus: null,
          language: edition.language,
          barcode: edition.upc,
          coverImageUrl: edition.variants.isNotEmpty
              ? edition.variants.first.coverImageUrl
              : null,
        ),
    ];
    return GameWork(
      id: item.id,
      title: item.title,
      platforms:
          List<String>.unmodifiable(item.game?.platforms ?? const <String>[]),
      identifiers: const <String>[],
      companyRoles: const <String>[],
      ageRatings: item.ageRating == null
          ? const <String>[]
          : List<String>.unmodifiable([item.ageRating!]),
      releases: releases,
    );
  }
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
