// ignore_for_file: use_super_parameters

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

sealed class LibraryWorkspaceEntry {
  LibraryWorkspaceEntry._({
    required this.id,
    required this.mediaType,
    required this.title,
    this.ownedItemId,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.isOwned = false,
    this.isWishlisted = false,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.condition,
    this.grade,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.keyComic = false,
    this.keyReason,
    this.notes,
    this.pricePaidCents,
    this.currency,
    this.storageBox,
    this.creators,
    this.characters,
    this.storyArcs,
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    required this.updatedAt,
    this.rawPlatforms,
  });

  factory LibraryWorkspaceEntry({
    required String id,
    required String mediaType,
    required String title,
    String? ownedItemId,
    String? itemNumber,
    String? synopsis,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? publisher,
    DateTime? releaseDate,
    int? releaseYear,
    String? barcode,
    String? variant,
    bool isOwned = false,
    bool isWishlisted = false,
    bool hasMissingCover = false,
    bool hasMissingMetadata = false,
    String? condition,
    String? grade,
    String? rawOrSlabbed,
    String? gradingCompany,
    bool keyComic = false,
    String? keyReason,
    String? notes,
    int? pricePaidCents,
    String? currency,
    String? storageBox,
    CatalogSeriesDetails? series,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
    CatalogPublishingDetails? publishing,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<String>? storyArcs,
    List<String>? genres,
    String? country,
    String? language,
    String? ageRating,
    required DateTime updatedAt,
  }) {
    final normalizedMediaType = mediaType.trim().toLowerCase();
    final common = _LibraryWorkspaceCommon(
      id: id,
      ownedItemId: ownedItemId,
      mediaType: normalizedMediaType,
      title: title,
      itemNumber: itemNumber,
      synopsis: synopsis,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl,
      publisher: publisher,
      releaseDate: releaseDate,
      releaseYear: releaseYear,
      barcode: barcode,
      variant: variant,
      isOwned: isOwned,
      isWishlisted: isWishlisted,
      hasMissingCover: hasMissingCover,
      hasMissingMetadata: hasMissingMetadata,
      condition: condition,
      grade: grade,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      keyComic: keyComic,
      keyReason: keyReason,
      notes: notes,
      pricePaidCents: pricePaidCents,
      currency: currency,
      storageBox: storageBox,
      creators: _copyMapList(creators),
      characters: _copyStringList(characters),
      storyArcs: _copyStringList(storyArcs),
      genres: _copyStringList(genres),
      country: country,
      language: language,
      ageRating: ageRating,
      updatedAt: updatedAt,
      rawPlatforms: _copyStringList(game?.platforms),
    );
    series = series == null ? null : _seriesOrNull(series);
    publishing = publishing == null ? null : _publishingOrNull(publishing);
    video = video == null ? null : _videoOrNull(video);
    music = music == null ? null : _musicOrNull(music);
    game = game == null ? null : _gameOrNull(game);

    switch (normalizedMediaType) {
      case 'comic':
        return ComicWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'manga':
        return MangaWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'book':
        return BookWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'movie':
        return MovieWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'tv':
        return TvWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'anime':
        return AnimeWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'music':
        return MusicWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          music: music,
        );
      case 'game':
        return GameWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case 'boardgame':
        return BoardGameWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      default:
        return GenericWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
          game: game,
        );
    }
  }

  final String id;
  final String? ownedItemId;
  final String mediaType;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? condition;
  final String? grade;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final bool keyComic;
  final String? keyReason;
  final String? notes;
  final int? pricePaidCents;
  final String? currency;
  final String? storageBox;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final DateTime updatedAt;
  final List<String>? rawPlatforms;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  CatalogSeriesDetails? get series;
  CatalogPublishingDetails? get publishing;
  VideoCatalogDetails? get video;
  MusicCatalogDetails? get music;
  GameCatalogDetails? get game;

}

abstract base class _TypedLibraryWorkspaceEntry extends LibraryWorkspaceEntry {
  _TypedLibraryWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    this.seriesDetails,
    this.publishingDetails,
    this.videoDetails,
    this.musicDetails,
    this.gameDetails,
  }) : super._(
          id: common.id,
          ownedItemId: common.ownedItemId,
          mediaType: common.mediaType,
          title: common.title,
          itemNumber: common.itemNumber,
          synopsis: common.synopsis,
          coverImageUrl: common.coverImageUrl,
          thumbnailImageUrl: common.thumbnailImageUrl,
          publisher: common.publisher,
          releaseDate: common.releaseDate,
          releaseYear: common.releaseYear,
          barcode: common.barcode,
          variant: common.variant,
          isOwned: common.isOwned,
          isWishlisted: common.isWishlisted,
          hasMissingCover: common.hasMissingCover,
          hasMissingMetadata: common.hasMissingMetadata,
          condition: common.condition,
          grade: common.grade,
          rawOrSlabbed: common.rawOrSlabbed,
          gradingCompany: common.gradingCompany,
          keyComic: common.keyComic,
          keyReason: common.keyReason,
          notes: common.notes,
          pricePaidCents: common.pricePaidCents,
          currency: common.currency,
          storageBox: common.storageBox,
          creators: common.creators,
          characters: common.characters,
          storyArcs: common.storyArcs,
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          updatedAt: common.updatedAt,
          rawPlatforms: common.rawPlatforms,
        );

  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final MusicCatalogDetails? musicDetails;
  final GameCatalogDetails? gameDetails;

  @override
  CatalogSeriesDetails? get series => seriesDetails;

  @override
  CatalogPublishingDetails? get publishing => publishingDetails;

  @override
  VideoCatalogDetails? get video => videoDetails;

  @override
  MusicCatalogDetails? get music => musicDetails;

  @override
  GameCatalogDetails? get game => gameDetails;
}

final class ComicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  ComicWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MangaWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MangaWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class BookWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BookWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MovieWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MovieWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class TvWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  TvWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class AnimeWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  AnimeWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class MusicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MusicWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    MusicCatalogDetails? music,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          musicDetails: music,
        );
}

final class GameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GameWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class BoardGameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BoardGameWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class GenericWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GenericWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
          musicDetails: music,
          gameDetails: game,
        );
}

class _LibraryWorkspaceCommon {
  const _LibraryWorkspaceCommon({
    required this.id,
    required this.ownedItemId,
    required this.mediaType,
    required this.title,
    required this.itemNumber,
    required this.synopsis,
    required this.coverImageUrl,
    required this.thumbnailImageUrl,
    required this.publisher,
    required this.releaseDate,
    required this.releaseYear,
    required this.barcode,
    required this.variant,
    required this.isOwned,
    required this.isWishlisted,
    required this.hasMissingCover,
    required this.hasMissingMetadata,
    required this.condition,
    required this.grade,
    required this.rawOrSlabbed,
    required this.gradingCompany,
    required this.keyComic,
    required this.keyReason,
    required this.notes,
    required this.pricePaidCents,
    required this.currency,
    required this.storageBox,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
    required this.country,
    required this.language,
    required this.ageRating,
    required this.updatedAt,
    required this.rawPlatforms,
  });

  final String id;
  final String? ownedItemId;
  final String mediaType;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? condition;
  final String? grade;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final bool keyComic;
  final String? keyReason;
  final String? notes;
  final int? pricePaidCents;
  final String? currency;
  final String? storageBox;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final DateTime updatedAt;
  final List<String>? rawPlatforms;
}

CatalogSeriesDetails? _seriesOrNull(CatalogSeriesDetails details) {
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingOrNull(CatalogPublishingDetails details) {
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoOrNull(VideoCatalogDetails details) {
  return details.hasData ? details : null;
}

MusicCatalogDetails? _musicOrNull(MusicCatalogDetails details) {
  return details.hasData ? details : null;
}

GameCatalogDetails? _gameOrNull(GameCatalogDetails details) {
  return details.hasData ? details : null;
}

List<String>? _copyStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<Map<String, dynamic>>? _copyMapList(List<Map<String, dynamic>>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

int compareLibraryWorkspaceEntries(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
  bool ascending,
) {
  final result = switch (column) {
    LibrarySortColumn.status => _compareBools(left.isOwned, right.isOwned),
    LibrarySortColumn.title => _compareNullableStrings(left.title, right.title),
    LibrarySortColumn.issue =>
      _compareIssueNumbers(left.itemNumber, right.itemNumber),
    LibrarySortColumn.variant =>
      _compareNullableStrings(left.variant, right.variant),
    LibrarySortColumn.publisher =>
      _compareNullableStrings(left.publisher, right.publisher),
    LibrarySortColumn.releaseDate =>
      _compareNullableDates(left.releaseDate, right.releaseDate),
    LibrarySortColumn.barcode =>
      _compareNullableStrings(left.barcode, right.barcode),
    LibrarySortColumn.grade => _compareNullableStrings(left.grade, right.grade),
    LibrarySortColumn.condition =>
      _compareNullableStrings(left.condition, right.condition),
    LibrarySortColumn.price =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    LibrarySortColumn.storageBox =>
      _compareNullableStrings(left.storageBox, right.storageBox),
    LibrarySortColumn.wishlist =>
      _compareBools(left.isWishlisted, right.isWishlisted),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
    LibrarySortColumn.country =>
      _compareNullableStrings(left.country, right.country),
    LibrarySortColumn.language =>
      _compareNullableStrings(left.language, right.language),
    LibrarySortColumn.pageCount =>
      _compareNullableInts(left.publishing?.pageCount, right.publishing?.pageCount),
    LibrarySortColumn.ageRating =>
      _compareNullableStrings(left.ageRating, right.ageRating),
    LibrarySortColumn.imprint =>
      _compareNullableStrings(left.publishing?.imprint, right.publishing?.imprint),
  };
  if (result != 0) {
    return ascending ? result : -result;
  }
  return _compareNullableStrings(left.title, right.title);
}

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _numericPrefixSortValue(left);
  final rightNumber = _numericPrefixSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _numericPrefixSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

int _compareNullableInts(int? left, int? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? 0).compareTo(right ?? 0);
}

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    right ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

int _compareBools(bool left, bool right) {
  if (left == right) {
    return 0;
  }
  return left ? -1 : 1;
}
