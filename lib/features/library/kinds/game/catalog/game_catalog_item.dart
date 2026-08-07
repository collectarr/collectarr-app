import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';

class GameWorkMetadata {
  const GameWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.releaseDate,
    this.platforms = const [],
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? releaseDate;
  final List<String> platforms;
  final List<String> genres;
}

class GameCatalogItem {
  const GameCatalogItem({
    required this.id,
    required this.work,
    required this.releases,
  });

  final String id;
  final GameWorkMetadata work;
  final List<GameRelease> releases;

  GameRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String get title => work.title;
  String? get displayTitle => work.title;
  String? get localizedTitle => null;
  String? get originalTitle => work.originalTitle;
  String? get synopsis => work.synopsis;
  String? get itemNumber => null;
  String? get coverImageUrl => primaryRelease?.coverImageUrl;
  String? get thumbnailImageUrl => primaryRelease?.coverImageUrl;
  String? get publisher => primaryRelease?.publisher;
  DateTime? get coverDate => work.releaseDate;
  DateTime? get releaseDate => primaryRelease?.releaseDate ?? work.releaseDate;
  int? get releaseYear => releaseDate?.year;
  String? get barcode => primaryRelease?.barcode;
  String? get variant => primaryRelease?.title;
  String? get crossover => null;
  String? get displayCoverUrl => coverImageUrl;
  bool get hasMissingCoreMetadata => work.title.isEmpty;
  List<TrailerLink> get trailerUrls => const [];
  String? get plotSummary => work.synopsis;
  String? get plotDescription => null;
  List<Map<String, dynamic>>? get creators => null;
  List<String>? get characters => null;
  List<String>? get storyArcs => null;
  List<String> get genres => work.genres;
  List<String> get platforms => work.platforms;
  String? get country => null;
  String? get language => null;
  String? get ageRating => null;
  String? get audienceRating => null;
  CatalogSeriesDetails? get series => null;
  CatalogPublishingDetails? get publishingDetails => null;
  GameCatalogDetails? get videoDetails => null;
  GameCatalogDetails? get game => null;
}
