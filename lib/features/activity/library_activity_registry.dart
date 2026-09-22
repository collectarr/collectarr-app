import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, LibraryActivityContributor>
    libraryActivityContributorsByKind = {
  CatalogMediaKind.anime: const AnimeActivityContributor(),
  CatalogMediaKind.tv: const TvActivityContributor(),
};
