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
}
