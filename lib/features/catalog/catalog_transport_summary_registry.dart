import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_transport_codec.dart';

/// Kind codecs own the semantic title and image projection used by mixed
/// catalog surfaces. This registry only dispatches to the matching codec.
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

CatalogDisplaySummary summarizeCatalogTransportPayload(CatalogItemDto item) {
  final codec = libraryCatalogTransportCodecs.firstWhere(
    (candidate) => candidate.kind == item.mediaKind,
    orElse: () => throw StateError(
      'No Catalog Item codec is registered for ${item.mediaKind.apiValue}.',
    ),
  );
  return codec.summarizeTransport(item);
}
