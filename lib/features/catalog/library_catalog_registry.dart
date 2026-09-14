import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/catalog/anime_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/catalog/boardgame_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/catalog/book_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/catalog/comic_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/catalog/game_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/catalog/manga_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/catalog/movie_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/catalog/music_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/catalog/tv_catalog_lookup.dart';

const List<CatalogKindTransportBoundary> libraryCatalogTransportCodecs = [
  AnimeCatalogTransportCodec(),
  BoardGameCatalogTransportCodec(),
  BookCatalogTransportCodec(),
  ComicCatalogTransportCodec(),
  GameCatalogTransportCodec(),
  MangaCatalogTransportCodec(),
  MovieCatalogTransportCodec(),
  MusicCatalogTransportCodec(),
  TvCatalogTransportCodec(),
];

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
