import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, LibraryAdminContributor>
    libraryAdminContributorsByKind = {
  CatalogMediaKind.music: const MusicAdminContributor(),
  CatalogMediaKind.game: const GameAdminContributor(),
};
