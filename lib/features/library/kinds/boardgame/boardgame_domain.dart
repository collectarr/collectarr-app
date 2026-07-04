import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

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
    this.coverImageUrl,
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
  final String? coverImageUrl;

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
      coverImageUrl: dto.coverImageUrl,
    );
  }

  factory BoardGameEdition.fromCatalogEdition(CatalogEdition edition) {
    return BoardGameEdition(
      id: edition.id,
      title: edition.title,
      editionTitle: edition.title,
      format: edition.format,
      publisher: edition.publisher,
      catalogNumber: edition.upc,
      barcode: edition.upc,
      releaseStatus: null,
      releaseDate: edition.releaseDate,
      language: edition.language,
      country: edition.region,
      ageRating: null,
      audienceRating: null,
      minPlayers: null,
      maxPlayers: null,
      playingTimeMinutes: null,
      minAge: null,
      coverImageUrl: edition.variants.isNotEmpty
          ? edition.variants.first.coverImageUrl
          : null,
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

  factory BoardGameWork.fromLibraryMetadataItem(LibraryMetadataItem item) {
    return BoardGameWork(
      id: item.id,
      title: item.title,
      platforms:
          List<String>.unmodifiable(item.game?.platforms ?? const <String>[]),
      identifiers: const <String>[],
      contributors: item.creators == null
          ? const <String>[]
          : List<String>.unmodifiable(
              item.creators!
                  .map((creator) => creator['name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty),
            ),
      mechanics: const <String>[],
      categories: item.genres == null
          ? const <String>[]
          : List<String>.unmodifiable(item.genres!),
      families: const <String>[],
      expansions: const <String>[],
      rankings: const <String>[],
      editions: [
        for (final edition in item.editions) BoardGameEdition.fromCatalogEdition(edition),
      ],
    );
  }

}
