import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_transport_summary_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

export 'package:collectarr_app/features/catalog/catalog_transport_summary_registry.dart'
    show libraryCatalogTransportCodecs;

CatalogDisplaySummary summarizeCatalogTransport(CatalogItemDto item) {
  return summarizeCatalogTransportPayload(item);
}

List<CatalogKindLookup> libraryCatalogLookups(LocalDatabase database) => [
      AnimeCatalogLookup(database),
      BoardGameCatalogLookup(database),
      BookCatalogLookup(database),
      ComicCatalogLookup(database),
      GameCatalogLookup(database),
      MangaCatalogLookup(database),
      MovieCatalogLookup(database),
      MusicCatalogLookup(database),
      TvCatalogLookup(database),
    ];
