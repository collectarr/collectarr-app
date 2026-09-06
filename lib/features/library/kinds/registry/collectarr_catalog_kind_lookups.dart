import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/catalog/anime_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/catalog/boardgame_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/catalog/book_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/catalog/comic_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/catalog/game_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/catalog/manga_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/catalog/movie_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/catalog/music_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/catalog/tv_catalog_lookup.dart';

/// Composition-root registration for typed local catalog lookups.
List<CatalogKindLookup> collectarrCatalogKindLookups(LocalDatabase db) => [
      ComicCatalogLookup(db),
      MangaCatalogLookup(db),
      BookCatalogLookup(db),
      GameCatalogLookup(db),
      BoardGameCatalogLookup(db),
      MovieCatalogLookup(db),
      TvCatalogLookup(db),
      AnimeCatalogLookup(db),
      MusicCatalogLookup(db),
    ];
